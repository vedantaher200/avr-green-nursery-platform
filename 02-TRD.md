# Technical Requirements Document (TRD)
## Nursery Management System (NMS)

**Version:** 1.0
**Status:** Draft
**Related Docs:** PRD, App Flow, UI/UX Design Brief, Backend Schema, Implementation Plan

---

## 1. Technology Stack

### 1.1 Frontend — Flutter
- Single codebase targeting Android, iOS, and optional Web
- State management: Riverpod (preferred) or Bloc
- Responsive layout system for phone/tablet/web breakpoints
- Local caching via Hive/SharedPreferences for offline-tolerant screens (catalog browsing, cart)

### 1.2 Backend — Express.js
- REST API architecture, versioned (`/api/v1/...`)
- JWT authentication (access + refresh token pair)
- RBAC middleware enforced per-route
- Socket.IO for real-time delivery tracking and live notifications
- Background job processing (BullMQ on Redis) for async tasks: invoice generation, notification dispatch, report generation
- Centralized error-handling middleware with structured logging

### 1.3 Database — PostgreSQL
- ACID-compliant relational store for all transactional data
- JSONB columns for flexible/semi-structured fields (e.g., care instructions, custom metadata)
- Multi-tenant design: `tenant_id` scoping on all tenant-owned tables, enforced via row-level security policies
- Indexing strategy on high-cardinality lookup columns (SKU, order_id, customer_id, tenant_id)

### 1.4 File Storage — Cloudflare R2
- Object storage for product images, plant images, delivery proof photos, invoices, and documents
- Signed URL generation for time-bound secure access
- CDN-backed delivery for catalog images

### 1.5 Cache & Queue — Redis
- OTP storage with TTL expiry
- JWT/session token blacklist and refresh token store
- API response caching for high-read endpoints (catalog, categories)
- BullMQ job queue backing store
- Rate limiting counters (sliding window)

### 1.6 Monitoring — Prometheus + Grafana
- Prometheus scrapes metrics from Express instances (request latency, error rate, queue depth)
- Grafana dashboards for API health, DB connection pool, job queue backlog, and business KPIs
- Alerting rules for SLA breaches (uptime, latency, error rate)

### 1.7 Deployment — Docker + Kubernetes
- Each service (API, worker, scheduler) containerized independently
- Kubernetes manages orchestration, auto-scaling (HPA on CPU/queue depth), and rolling deployments
- Environment-based config via Kubernetes ConfigMaps/Secrets
- Horizontal scaling of API pods behind a load balancer / ingress controller

---

## 2. High-Level Architecture

```
                Flutter Application
          Android | iOS | Web

                     │
                     │ HTTPS
                     ▼

              Express API Server
         (REST + Socket.IO + RBAC)

      ┌────────────┼────────────┐
      │            │            │
 PostgreSQL      Redis      Cloudflare R2
 (Primary DB)  (Cache/Queue)  (Object Store)
      │            │            │
      └────────────┼────────────┘
                    │
          Prometheus + Grafana
                    │
                 Docker
                    │
               Kubernetes
```

### 2.1 Service Decomposition (Logical, single-repo modular monolith for MVP)
- **Auth Service** — registration, login, token issuance, MFA
- **Catalog Service** — products, categories, images
- **Inventory Service** — stock, batches, transfers, movements
- **Order Service** — cart, checkout, order lifecycle
- **Payment Service** — gateway integration, webhooks, reconciliation
- **Invoice Service** — PDF generation, GST computation
- **Delivery Service** — assignment, live tracking (Socket.IO), POD
- **Notification Service** — email/SMS/push dispatch via job queue
- **Reporting Service** — aggregated queries, scheduled report generation

A modular monolith is recommended for MVP to reduce operational overhead; service boundaries are designed so each module can later be extracted into an independent microservice without a data-model rewrite.

---

## 3. API Design Principles

- RESTful resource-oriented endpoints, versioned under `/api/v1`
- Consistent envelope: `{ success, data, error, meta }`
- Pagination via cursor or offset+limit for list endpoints
- Idempotency keys required on payment and order-creation endpoints
- All mutating endpoints require CSRF-safe JWT bearer auth
- Rate limiting per user/IP via Redis sliding-window counters

### Sample Endpoint Groups
```
/api/v1/auth/*
/api/v1/tenants/*
/api/v1/locations/*
/api/v1/products/*
/api/v1/categories/*
/api/v1/inventory/*
/api/v1/customers/*
/api/v1/suppliers/*
/api/v1/purchase-orders/*
/api/v1/orders/*
/api/v1/payments/*
/api/v1/invoices/*
/api/v1/deliveries/*
/api/v1/notifications/*
/api/v1/reports/*
```

---

## 4. Authentication & Authorization

- **Access token:** short-lived JWT (15 min), signed with RS256
- **Refresh token:** long-lived (7–30 days), stored hashed in Redis, rotated on each use
- **RBAC model:** Role → Permission mapping stored in DB; middleware checks `role.permissions` against route metadata
- **MFA:** TOTP-based (RFC 6238), optional for Owner/Manager, mandatory for Super Admin
- **Session revocation:** refresh tokens can be invalidated per-device from user settings

---

## 5. Real-Time Requirements

- Socket.IO namespace `/tracking` for live delivery GPS updates (Agent → Server → Customer)
- Socket.IO namespace `/notifications` for in-app push-style alerts
- Redis adapter for Socket.IO to support horizontal scaling across multiple API pod replicas

---

## 6. Background Jobs (BullMQ on Redis)

| Job | Trigger | Notes |
|---|---|---|
| Invoice generation | Payment success | Generates PDF, uploads to R2, emails receipt |
| Notification dispatch | Various events | Retries with exponential backoff |
| Low-stock check | Scheduled (cron, every 15 min) | Compares stock vs. threshold |
| Report generation | Scheduled (daily/monthly) or on-demand | Long-running aggregation offloaded from request thread |
| Reserved-stock release | Order checkout timeout | Releases inventory hold if payment not completed |

---

## 7. Security Requirements

- HTTPS enforced everywhere (HSTS enabled)
- Passwords hashed with bcrypt (cost factor ≥ 12) or argon2id
- Input validation via schema validation (e.g., Zod/Joi) on every endpoint
- Rate limiting: auth endpoints stricter (e.g., 5 req/min/IP) than general API
- File upload validation: MIME-type whitelist, max size, virus scan hook (future)
- SQL injection prevention via parameterized queries / ORM (Prisma or Knex)
- Secrets managed via Kubernetes Secrets, never committed to source

---

## 8. Multi-Tenancy Model

- Shared database, shared schema, `tenant_id` column on all tenant-scoped tables
- PostgreSQL Row-Level Security (RLS) policies enforce tenant isolation at the DB layer as a defense-in-depth measure alongside application-layer scoping
- Super Admin queries bypass RLS via a dedicated service role with audit logging

---

## 9. Scalability Plan

| Layer | Scaling Strategy |
|---|---|
| API | Horizontal pod autoscaling (Kubernetes HPA) based on CPU + request latency |
| Database | Read replicas for reporting queries; connection pooling (PgBouncer) |
| Cache/Queue | Redis Cluster mode at scale |
| Storage | Cloudflare R2 scales natively; CDN caching for static/catalog assets |
| Real-time | Socket.IO Redis adapter enables multi-pod fan-out |

---

## 10. Environments

- **Local** — Docker Compose (API, Postgres, Redis, mock R2 via MinIO)
- **Staging** — Kubernetes namespace, seeded test tenant data
- **Production** — Kubernetes cluster with autoscaling, Prometheus/Grafana monitoring, automated backups

## 11. CI/CD

- Git-based workflow with PR checks: lint, unit tests, integration tests
- Docker image build on merge to main, pushed to container registry
- Kubernetes rolling deployment via manifests/Helm chart
- Database migrations run as a pre-deploy job (versioned, e.g., via Prisma Migrate or Knex migrations)

## 12. Testing Strategy

| Level | Tooling | Coverage Target |
|---|---|---|
| Unit | Jest (backend), Flutter test (frontend) | Core business logic ≥ 80% |
| Integration | Supertest against test DB | All API modules |
| E2E | Flutter integration_test / Playwright (web) | Critical user flows (order, payment, delivery) |
| Load | k6 / Artillery | Target concurrent user baseline from PRD |

## 13. Non-Functional Compliance Mapping

| PRD NFR | Technical Implementation |
|---|---|
| API p95 < 300ms | Redis caching, DB indexing, connection pooling |
| 99.5% uptime | Kubernetes self-healing, multi-replica deployments, health checks |
| ACID financial ops | PostgreSQL transactions wrapping order/payment/inventory updates |
| GST compliance | Invoice Service computes tax breakdown per Indian GST rules |
