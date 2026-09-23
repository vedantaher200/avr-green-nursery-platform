# Product Requirements Document (PRD)
## Nursery Management System (NMS)

**Version:** 1.0
**Status:** Draft
**Document Owner:** Product Team
**Related Docs:** TRD, App Flow, UI/UX Design Brief, Backend Schema, Implementation Plan

---

## 1. Purpose

This PRD defines the product scope, user requirements, and success criteria for the Nursery Management System — a cloud-based, multi-tenant SaaS platform that digitizes inventory, sales, customer management, billing, delivery, greenhouse monitoring, and analytics for nursery businesses of any size.

---

## 2. Problem Statement

Nurseries today rely heavily on spreadsheets, paper registers, and disconnected point tools. This produces:

- Manual and error-prone inventory tracking, leading to stock mismatches
- No unified customer order history
- Manual invoice generation with GST compliance risk
- No real-time delivery visibility for customers or dispatchers
- Fragmented supplier and purchase order records
- No centralized, cross-branch reporting
- Difficulty scaling from one location to multiple branches/warehouses

## 3. Product Vision

A single platform where a nursery owner can run their entire business — from seed procurement to doorstep delivery — replacing 5–6 disconnected tools with one system that scales from a single shop to a multi-branch enterprise.

## 4. Goals & Success Metrics

| Goal | Metric | Target (Post-Launch, 6 months) |
|---|---|---|
| Reduce inventory discrepancy | Stock variance rate | < 2% |
| Speed up order processing | Avg. order-to-invoice time | < 3 minutes |
| Improve delivery transparency | % orders with live tracking | 100% |
| Increase repeat purchases | Customer repeat rate | +20% |
| Reduce manual reporting effort | Time to generate monthly report | < 1 minute (automated) |
| Platform reliability | API uptime | 99.5% |

## 5. Target Users & Personas

### 5.1 Super Admin (Platform Owner)
Manages the SaaS platform itself — tenant onboarding, subscription plans, billing, global analytics, and platform security. Not involved in day-to-day nursery operations.

### 5.2 Nursery Owner (Primary Buyer)
Owns one or more nursery branches. Needs full visibility into sales, inventory, staff performance, and profitability across all locations from a single dashboard.

### 5.3 Manager
Runs day-to-day operations for a branch: inventory levels, order fulfillment, employee schedules, delivery assignment.

### 5.4 Staff
Executes daily operational tasks: processing orders, updating stock counts, preparing goods for dispatch.

### 5.5 Customer
End buyer — browses catalog, places orders, pays online or COD, tracks delivery, views invoice/order history, earns loyalty points.

### 5.6 Delivery Agent
Picks up assigned orders, navigates to delivery address, updates live GPS status, captures proof of delivery (photo/signature).

### 5.7 Supplier
Receives and fulfills purchase orders raised by the nursery, confirms dispatch, and tracks payment status.

## 6. Scope

### 6.1 In Scope (MVP + Phase 2, see Implementation Plan for phasing)
- Multi-tenant nursery/branch/warehouse management
- Role-based authentication (JWT + MFA)
- Product & plant catalog with rich horticultural metadata
- Inventory management with batch/expiry tracking and multi-location transfers
- Customer-facing storefront (browse, cart, checkout)
- Order lifecycle management (cart → payment → invoice → delivery → completion)
- Supplier & purchase order management
- Payment processing (UPI, Card, Net Banking, Cash)
- GST-compliant invoice generation (PDF)
- Delivery management with live GPS tracking and proof of delivery
- Notification system (Email, SMS, Push)
- Reporting & analytics dashboard

### 6.2 Out of Scope (MVP)
- AI plant disease detection (Phase 3+)
- IoT greenhouse sensor integration (Phase 3+)
- Demand forecasting / ML-based inventory optimization (Phase 3+)
- Third-party marketplace integration (Phase 3+)
- WhatsApp Business API integration (Phase 3+)

## 7. Functional Requirements

### 7.1 Authentication & User Management
- FR-1.1: Users can register via email/phone with OTP verification.
- FR-1.2: System supports JWT access tokens + refresh token rotation.
- FR-1.3: Password reset via secure time-bound email link.
- FR-1.4: MFA (TOTP or OTP) optional for Owner/Manager/Admin roles, enforced for Super Admin.
- FR-1.5: RBAC enforced at API middleware level for every endpoint.
- FR-1.6: Session management with device-level revocation.

### 7.2 Nursery & Location Management
- FR-2.1: Owner can create and manage multiple nurseries under one tenant account.
- FR-2.2: Each nursery can have multiple branches and warehouses.
- FR-2.3: Greenhouses can be registered under a branch for environment tracking (Phase 2+).
- FR-2.4: Staff can be assigned to one or more locations with location-scoped permissions.

### 7.3 Product & Catalog Management
- FR-3.1: Each product/plant record includes SKU, images, scientific name, common name, category, supplier, price, description, and care instructions.
- FR-3.2: Products are organized into hierarchical categories (e.g., Indoor Plants → Succulents).
- FR-3.3: Bulk import/export of catalog via CSV.
- FR-3.4: Image upload to Cloudflare R2 with automatic thumbnail generation.

### 7.4 Inventory Management
- FR-4.1: Stock tracked per location (branch/warehouse) with real-time quantity.
- FR-4.2: Batch numbers and expiry dates tracked for perishable inventory (seeds, fertilizers).
- FR-4.3: Stock transfer workflow between locations with approval trail.
- FR-4.4: Damaged/reserved stock tracked separately from sellable stock.
- FR-4.5: Low-stock threshold alerts trigger notifications automatically.
- FR-4.6: Full inventory movement audit log (who, what, when, why).

### 7.5 Customer Management
- FR-5.1: Customer profile stores contact info, addresses, order history, and communication log.
- FR-5.2: Loyalty points accrue per order and can be redeemed at checkout.
- FR-5.3: Customer segmentation for targeted notifications (Phase 2).

### 7.6 Supplier & Purchase Management
- FR-6.1: Owner/Manager can create purchase orders against a supplier.
- FR-6.2: Purchase order flow: Draft → Sent → Confirmed → Goods Received → Inventory Updated → Payment.
- FR-6.3: Supplier rating captured post-fulfillment.
- FR-6.4: Full supply history per supplier is queryable.

### 7.7 Order Management
- FR-7.1: Customer order flow: Cart → Checkout → Payment → Inventory Reservation → Invoice → Delivery → Completed.
- FR-7.2: Inventory is soft-reserved at checkout and released if payment fails within a timeout window.
- FR-7.3: Order status changes trigger notifications to customer and relevant staff.
- FR-7.4: Order cancellation and refund workflow supported pre-dispatch.

### 7.8 Payment Module
- FR-8.1: Supports UPI, Card, Net Banking (via payment gateway integration) and Cash-on-Delivery.
- FR-8.2: Payment status webhook handling with idempotent reconciliation.
- FR-8.3: Refunds processed against original payment method where possible.

### 7.9 Invoice Management
- FR-9.1: GST-compliant invoice auto-generated on successful payment.
- FR-9.2: Invoice available as downloadable PDF, stored in Cloudflare R2.
- FR-9.3: Order receipt emailed automatically.

### 7.10 Delivery Management
- FR-10.1: Manager/Staff assigns confirmed orders to a Delivery Agent.
- FR-10.2: Delivery Agent app shows today's route with pickup/delivery details.
- FR-10.3: Live GPS location shared with customer during active delivery via Socket.IO.
- FR-10.4: Proof of delivery captured as photo and/or signature, stored in Cloudflare R2.
- FR-10.5: Delivery status states: Assigned → Picked Up → In Transit → Delivered / Failed.

### 7.11 Notifications
- FR-11.1: Multi-channel notification dispatch (Email, SMS, Push) via background job queue.
- FR-11.2: Triggered events: order confirmation, payment success/failure, delivery updates, low-stock alerts.
- FR-11.3: Notification preferences configurable per user.

### 7.12 Reporting & Analytics
- FR-12.1: Pre-built reports: daily/monthly sales, inventory valuation, top customers, best-selling plants, revenue, profit margin.
- FR-12.2: Reports filterable by date range, branch, and category.
- FR-12.3: Export reports as PDF/CSV.
- FR-12.4: Super Admin has cross-tenant platform analytics (usage, subscription revenue).

## 8. Non-Functional Requirements

| Category | Requirement |
|---|---|
| Performance | API p95 response time < 300ms under normal load |
| Scalability | Support thousands of users, hundreds of tenants, millions of orders |
| Availability | 99.5% uptime SLA |
| Security | JWT + refresh tokens, bcrypt/argon2 password hashing, RBAC, rate limiting, HTTPS-only |
| Data Integrity | ACID transactions on PostgreSQL for all financial operations |
| Compliance | GST invoicing compliance (India), data retention policy |
| Localization | Multi-currency and multi-language ready (English default) |
| Observability | Prometheus metrics + Grafana dashboards for all services |

## 9. Assumptions & Constraints

- Initial launch targets the Indian market (GST invoicing, UPI payments).
- Flutter is the single frontend codebase across Android, iOS, and optional Web.
- Multi-tenancy is implemented at the application/database-schema level (shared DB, tenant-scoped rows), not separate databases per tenant, for MVP.
- Payment gateway provider to be finalized during technical design (e.g., Razorpay/Stripe equivalent for India).

## 10. Release Criteria (MVP Exit)

- All Phase 1 modules (Auth, Catalog, Inventory, Orders, Payments, Invoicing, Basic Delivery, Basic Reports) functionally complete and tested.
- Security review passed (RBAC, rate limiting, HTTPS enforced).
- Load-tested to target concurrent user baseline.
- Docker/Kubernetes deployment pipeline operational.

## 11. Open Questions

- Final choice of payment gateway provider and integration SLA.
- SMS provider selection for OTP/notifications (cost vs. deliverability in India).
- Whether Web frontend ships in MVP or Phase 2.
