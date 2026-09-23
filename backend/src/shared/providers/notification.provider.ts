import { pool } from '../../config/database';
import { logger } from '../logger';

export interface NotificationPayload {
  tenantId: string;
  userId: string;
  eventType: string;
  title: string;
  body: string;
  channel?: 'in_app' | 'email' | 'sms' | 'push';
  metadata?: Record<string, unknown>;
}

export interface NotificationProvider {
  send(payload: NotificationPayload): Promise<boolean>;
  sendBatch(payloads: NotificationPayload[]): Promise<number>;
}

export class MultiChannelNotificationProvider implements NotificationProvider {
  async send(payload: NotificationPayload): Promise<boolean> {
    const channel = payload.channel || 'in_app';
    logger.info(`[Notification] Dispatching [${channel.toUpperCase()}] to user ${payload.userId}: ${payload.title} - ${payload.body}`);

    try {
      // 1. In-app notifications stored in database
      const dbChannel = channel === 'in_app' ? 'push' : channel;
      await pool.query(
        `INSERT INTO notifications (tenant_id, user_id, channel, event_type, title, body, payload, status)
         VALUES ($1, $2, $3, $4, $5, $6, $7, 'sent')`,
        [
          payload.tenantId,
          payload.userId,
          dbChannel,
          payload.eventType,
          payload.title,
          payload.body,
          JSON.stringify(payload.metadata || {}),
        ]
      );

      // 2. Mock / Dev channel handling for SMS/Email
      if (channel === 'sms') {
        logger.debug(`[SMS Simulation] Sent SMS: "${payload.body}" to user ${payload.userId}`);
      } else if (channel === 'email') {
        logger.debug(`[Email Simulation] Sent Email Subject: "${payload.title}" to user ${payload.userId}`);
      }

      return true;
    } catch (err) {
      logger.error('[NotificationProvider] Failed to dispatch notification', { err });
      return false;
    }
  }

  async sendBatch(payloads: NotificationPayload[]): Promise<number> {
    let successCount = 0;
    for (const p of payloads) {
      const ok = await this.send(p);
      if (ok) successCount++;
    }
    return successCount;
  }
}

export const notificationService = new MultiChannelNotificationProvider();
