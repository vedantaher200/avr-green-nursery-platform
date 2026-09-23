import { Server as HttpServer } from 'http';
import { Server as SocketServer, Socket } from 'socket.io';
import { createAdapter } from '@socket.io/redis-adapter';
import { createClient } from 'redis';
import { config } from '../config';
import { logger } from '../shared/logger';
import jwt from 'jsonwebtoken';
import type { JwtPayload } from '../middlewares/auth.middleware';

// ─────────────────────────────────────────────────────────────────────────────
// Socket.IO Server — Real-time GPS Tracking & Notifications
// ─────────────────────────────────────────────────────────────────────────────

export function createSocketServer(httpServer: HttpServer): SocketServer {
  const io = new SocketServer(httpServer, {
    cors: {
      origin: config.cors.origins,
      methods: ['GET', 'POST'],
    },
    path: '/socket.io',
    transports: ['websocket', 'polling'],
  });

  // ── Redis Adapter for multi-pod horizontal scaling ────────────────────────
  const pubClient = createClient({
    url: config.redis.url,
    socket: {
      connectTimeout: 1000,
      reconnectStrategy: false,
    },
  });
  const subClient = pubClient.duplicate();

  Promise.all([pubClient.connect(), subClient.connect()])
    .then(() => {
      io.adapter(createAdapter(pubClient, subClient) as any);
      logger.info('Socket.IO: Redis adapter connected for horizontal scaling');
    })
    .catch(() => {
      logger.info('Socket.IO: running with default in-memory adapter (local dev)');
    });

  // ── JWT Authentication Middleware ─────────────────────────────────────────
  io.use((socket, next) => {
    const token = socket.handshake.auth.token as string;
    if (!token) return next(new Error('Authentication required'));

    try {
      const payload = jwt.verify(token, config.jwt.accessSecret) as JwtPayload;
      (socket as any).user = payload;
      next();
    } catch {
      next(new Error('Invalid token'));
    }
  });

  // ── Namespace: /tracking — Live Delivery GPS ──────────────────────────────
  const tracking = io.of('/tracking');

  tracking.use((socket, next) => {
    // Re-check roles on namespace level
    const user = (socket as any).user as JwtPayload;
    if (!['delivery_agent', 'customer', 'manager', 'owner'].includes(user.roleName)) {
      return next(new Error('Unauthorized for tracking namespace'));
    }
    next();
  });

  tracking.on('connection', (socket: Socket) => {
    const user = (socket as any).user as JwtPayload;
    logger.debug('Tracking socket connected', { userId: user.userId, role: user.roleName });

    // Delivery agent: joins their personal room & broadcasts location
    if (user.roleName === 'delivery_agent') {
      socket.join(`agent:${user.userId}`);

      socket.on('location:update', (data: { deliveryId: string; lat: number; lng: number }) => {
        // Broadcast to all clients tracking this delivery
        tracking.to(`delivery:${data.deliveryId}`).emit('location:changed', {
          deliveryId: data.deliveryId,
          lat: data.lat,
          lng: data.lng,
          timestamp: new Date().toISOString(),
        });
        logger.debug('Location updated', { deliveryId: data.deliveryId, lat: data.lat, lng: data.lng });
      });

      socket.on('delivery:status', (data: { deliveryId: string; status: string }) => {
        tracking.to(`delivery:${data.deliveryId}`).emit('delivery:status_changed', data);
      });
    }

    // Customer/Manager: subscribes to a specific delivery room
    socket.on('track:delivery', (deliveryId: string) => {
      socket.join(`delivery:${deliveryId}`);
      logger.debug('Client tracking delivery', { deliveryId, userId: user.userId });
    });

    socket.on('untrack:delivery', (deliveryId: string) => {
      socket.leave(`delivery:${deliveryId}`);
    });

    socket.on('disconnect', () => {
      logger.debug('Tracking socket disconnected', { userId: user.userId });
    });
  });

  // ── Namespace: /notifications — In-App Push Alerts ────────────────────────
  const notifications = io.of('/notifications');

  notifications.on('connection', (socket: Socket) => {
    const user = (socket as any).user as JwtPayload;
    socket.join(`user:${user.userId}`);
    if (user.tenantId) socket.join(`tenant:${user.tenantId}`);

    socket.on('disconnect', () => {
      logger.debug('Notification socket disconnected', { userId: user.userId });
    });
  });

  // Expose helper to emit notifications from other services
  (io as any).notifyUser = (userId: string, event: string, data: unknown) => {
    notifications.to(`user:${userId}`).emit(event, data);
  };

  (io as any).notifyTenant = (tenantId: string, event: string, data: unknown) => {
    notifications.to(`tenant:${tenantId}`).emit(event, data);
  };

  logger.info('Socket.IO server initialized with /tracking and /notifications namespaces');
  return io;
}
