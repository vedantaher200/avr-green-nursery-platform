# ─────────────────────────────────────────────────────────────────────────────
# AVRGREEN Backend — Multi-stage Dockerfile
# Stage 1: Builder | Stage 2: Production runner
# ─────────────────────────────────────────────────────────────────────────────

# ── STAGE 1: Build TypeScript ─────────────────────────────────────────────────
FROM node:20-alpine AS builder
WORKDIR /app

COPY package*.json ./
RUN npm ci --include=dev

COPY tsconfig.json ./
COPY src ./src

RUN npm run build

# Prune devDependencies
RUN npm prune --production

# ── STAGE 2: Production Image ─────────────────────────────────────────────────
FROM node:20-alpine AS runner
WORKDIR /app

ENV NODE_ENV=production
ENV PORT=5000

# Non-root user for security
RUN addgroup --system --gid 1001 nodejs \
 && adduser --system --uid 1001 expressjs

COPY --from=builder --chown=expressjs:nodejs /app/dist ./dist
COPY --from=builder --chown=expressjs:nodejs /app/node_modules ./node_modules
COPY --from=builder --chown=expressjs:nodejs /app/package.json ./

# Create log directory
RUN mkdir -p logs && chown expressjs:nodejs logs

USER expressjs

EXPOSE 5000

HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
  CMD wget -qO- http://localhost:5000/health || exit 1

CMD ["node", "dist/server.js"]
