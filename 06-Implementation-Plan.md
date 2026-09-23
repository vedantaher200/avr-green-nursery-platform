# Implementation Plan
## Nursery Management System (NMS)

**Version:** 1.0
**Related Docs:** PRD, TRD, App Flow, UI/UX Design Brief, Backend Schema

---

## 1. Delivery Approach

Phased delivery, MVP-first, with each phase shippable and independently valuable. Modular monolith backend (per TRD §2.1) so phases add modules without re-architecting.

---

## 2. Phase 0 — Foundations (Weeks 1–3)

**Goal:** Infrastructure and scaffolding ready for feature development.

- Repository setup (backend Express monorepo, Flutter app repo)
- PostgreSQL schema migration tooling configured (Prisma/Knex)
- Docker Compose local dev environment (API, Postgres, Redis, MinIO as R2 stand-in)
- CI pipeline: lint, test, build on PR
- Base Kubernetes manifests for staging cluster
- Design system tokens finalized (colors, typography, spacing) from UI/UX Design Brief
- Auth Service skeleton: JWT issuance, RBAC middleware, role/permission seed data

**Exit criteria:** A developer can register a test tenant, log in, and hit a protected "hello" endpoint end-to-end through the deployed staging environment.

---

## 3. Phase 1 — MVP Core (Weeks 4–10)

**Goal:** A nursery owner can run basic sales operations end-to-end.

### Modules
- Full Authentication (registration, login, OTP, password reset, refresh token rotation)
- Nursery & Location management (create nursery, branches, warehouses)
- Product & Category management (CRUD, image upload to R2, CSV bulk import)
- Inventory management (stock per location, batch/expiry, movements log)
- Customer-facing catalog browse + cart (Flutter mobile)
- Order flow: cart → checkout → payment (UPI/Card via gateway) → invoice → confirmation
- GST invoice PDF generation
- Basic delivery assignment (no live GPS yet — status-only: assigned/dispatched/delivered)
- Email notifications for order confirmation and payment status
- Owner dashboard: KPI cards, order list, inventory table

**Exit criteria:** A customer can browse, buy, and pay for a plant; the owner can see the order, fulfill it, and the customer receives an invoice — fully through the deployed system, matching PRD §10 MVP release criteria.

---

## 4. Phase 2 — Operational Depth (Weeks 11–16)

**Goal:** Multi-branch operations, supplier workflows, and real-time delivery.

### Modules
- Supplier management + purchase order lifecycle (draft → confirmed → goods received → payment)
- Stock transfer between locations with approval workflow
- Delivery Agent app: route list, navigation, live GPS tracking (Socket.IO), proof of delivery capture
- Real-time order tracking for customers (map + live status)
- SMS + Push notifications (in addition to email)
- Staff & Manager role dashboards (task queues, location-scoped views)
- Loyalty points system (accrual + redemption)
- Reports module: sales, inventory valuation, best-selling plants, revenue/profit, exportable

**Exit criteria:** A multi-branch nursery can run full purchase-to-delivery operations with live tracking, and owners can pull financial/inventory reports without manual spreadsheet work.

---

## 5. Phase 3 — Platform & Scale (Weeks 17–22)

**Goal:** Super Admin platform layer and production-hardening for scale.

### Modules
- Super Admin portal: tenant management, subscription plan management, platform-wide analytics
- Subscription billing integration (plan upgrades/downgrades, usage limits enforcement)
- MFA enforcement for Owner/Manager/Super Admin
- Rate limiting and abuse protection hardening
- Prometheus + Grafana dashboards for production monitoring, alerting rules
- Kubernetes autoscaling (HPA) tuning based on load-test results
- Load testing against target concurrency (per PRD NFR table)
- Security review / penetration test pass

**Exit criteria:** Platform can onboard new tenants self-service, monitor itself, and demonstrably meets the 99.5% uptime and p95 <300ms NFR targets under load test.

---

## 6. Phase 4 — Advanced/Future Enhancements (Post-Launch, Backlog)

Not part of committed timeline — sequenced by business priority after MVP+Phase2+Phase3 are live:

- AI plant disease detection (image classification model + Flutter camera integration)
- IoT greenhouse monitoring (sensor ingestion pipeline, environment dashboards)
- Demand forecasting / smart inventory optimization (ML pipeline on historical order data)
- Customer recommendation system
- Advanced analytics dashboard (cohort analysis, predictive churn)
- Marketplace integration (listing sync to third-party plant marketplaces)
- WhatsApp Business API integration for order updates

---

## 7. Team & Workstreams

| Workstream | Responsible For |
|---|---|
| Backend (Express/Postgres/Redis) | API modules, DB schema, background jobs |
| Frontend (Flutter) | Mobile/tablet/web screens per role |
| DevOps | Docker/Kubernetes, CI/CD, monitoring |
| QA | Test plans per phase, regression suite |
| Design | Design system, per-phase screen specs |

---

## 8. Risk Register

| Risk | Impact | Mitigation |
|---|---|---|
| Payment gateway integration delay | Blocks Phase 1 order flow | Finalize provider selection in Phase 0; build against sandbox early |
| Multi-tenant RLS misconfiguration | Data leakage between tenants | Dedicated security review + automated tenant-isolation test suite before Phase 1 exit |
| Live GPS tracking battery/network drain on agent devices | Poor delivery agent adoption | Configurable location-update interval, tested on low-end Android devices |
| Scope creep into Phase 4 features early | Delays MVP | Strict phase gating; Phase 4 items explicitly out of scope until Phase 3 exit criteria met |
| Report queries degrading production DB performance | Slower checkout/order APIs during peak | Read replica for Reporting Service from Phase 2 onward |

---

## 9. Milestone Summary

| Phase | Duration | Key Deliverable |
|---|---|---|
| Phase 0 | Weeks 1–3 | Infra + Auth scaffolding live in staging |
| Phase 1 | Weeks 4–10 | MVP: browse → buy → pay → invoice → basic delivery |
| Phase 2 | Weeks 11–16 | Suppliers, live delivery tracking, reports, loyalty |
| Phase 3 | Weeks 17–22 | Super Admin, billing, hardening, load-tested at scale |
| Phase 4 | Post-launch | AI/IoT/ML advanced capabilities (backlog) |

**Total committed timeline to production-ready platform (Phase 0–3): ~22 weeks.**
