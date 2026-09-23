# Application Flow Document
## Nursery Management System (NMS)

**Version:** 1.0
**Related Docs:** PRD, TRD, UI/UX Design Brief, Backend Schema, Implementation Plan

---

## 1. Purpose

This document maps every user journey through the application, screen by screen, for each role. It is the reference for UI/UX design, QA test-case writing, and frontend implementation sequencing.

---

## 2. Customer Flow

```
Splash Screen
   │
   ▼
Onboarding (first-time only)
   │
   ▼
Register / Login ──► OTP Verification
   │
   ▼
Home (Featured Plants, Categories, Search)
   │
   ▼
Category / Search Results
   │
   ▼
Product Detail (images, care instructions, price, stock status)
   │
   ▼
Add to Cart
   │
   ▼
Cart Review ──► Apply Loyalty Points / Coupons
   │
   ▼
Checkout ──► Select/Add Address
   │
   ▼
Payment Method Selection (UPI / Card / Net Banking / COD)
   │
   ▼
Payment Processing
   │
   ├── Success ──► Order Confirmation Screen
   │                    │
   │                    ▼
   │              Inventory Reserved → Invoice Generated
   │                    │
   │                    ▼
   │              Order Tracking (Live GPS once dispatched)
   │                    │
   │                    ▼
   │              Delivered → Rate & Review
   │
   └── Failure ──► Retry Payment / Change Method

Additional Customer Screens:
- Order History
- Invoice Download
- Loyalty Points Balance
- Profile & Saved Addresses
- Notifications Center
- Support / Help
```

### Key States
- **Cart abandonment:** reserved inventory auto-releases after checkout timeout (see TRD §6).
- **COD orders:** skip payment gateway step, go directly to Order Confirmation with `payment_status = pending`.

---

## 3. Nursery Owner Flow

```
Login (MFA optional)
   │
   ▼
Owner Dashboard
   (Revenue snapshot, active orders, low-stock alerts, branch selector)
   │
   ├──► Inventory
   │       ├── View stock by location
   │       ├── Transfer stock between branches
   │       └── Adjust damaged/reserved stock
   │
   ├──► Orders
   │       ├── All orders (filterable by status/branch)
   │       └── Order detail → manual status override if needed
   │
   ├──► Customers
   │       ├── Customer list & profiles
   │       └── Loyalty program configuration
   │
   ├──► Staff Management
   │       ├── Add/edit employees, assign roles & locations
   │       └── Performance view (orders processed, deliveries completed)
   │
   ├──► Suppliers & Purchase Orders
   │       ├── Supplier directory
   │       └── Create/track purchase orders
   │
   ├──► Reports
   │       ├── Sales (daily/monthly)
   │       ├── Inventory valuation
   │       ├── Best-selling plants
   │       └── Profit & revenue
   │
   └──► Business Settings
           ├── Branches & warehouses
           ├── Subscription plan (view/upgrade)
           └── Notification preferences
```

---

## 4. Manager Flow

```
Login
   │
   ▼
Manager Dashboard (branch-scoped)
   │
   ├──► Inventory (view + update, no cross-branch transfer approval)
   ├──► Orders (assign to staff/delivery agents)
   ├──► Employees (schedule, task assignment within branch)
   └──► Deliveries (assign agents, monitor live status)
```

---

## 5. Staff Flow

```
Login
   │
   ▼
Staff Dashboard (Today's Tasks)
   │
   ├──► Order Queue ──► Pick & Pack ──► Mark Ready for Dispatch
   └──► Inventory Update (stock count, mark damaged items)
```

---

## 6. Delivery Agent Flow

```
Login
   │
   ▼
Today's Assigned Orders (route list)
   │
   ▼
Order Detail ──► Navigate (map integration)
   │
   ▼
Pickup Confirmation (at branch/warehouse)
   │
   ▼
En Route ──► Live GPS broadcast starts (Socket.IO)
   │
   ▼
Arrived at Customer Location
   │
   ▼
Proof of Delivery
   ├── Photo capture
   └── Customer signature (optional)
   │
   ▼
Mark Delivered / Mark Failed (with reason)
   │
   ▼
Next Order in Route
```

---

## 7. Supplier Flow

```
Login (Supplier Portal)
   │
   ▼
Purchase Order Inbox
   │
   ▼
Review PO ──► Confirm / Reject / Propose Changes
   │
   ▼
Confirmed ──► Prepare Goods ──► Mark Dispatched
   │
   ▼
Nursery Confirms Goods Received
   │
   ▼
Payment Status Visible to Supplier
```

---

## 8. Super Admin Flow

```
Login (MFA mandatory)
   │
   ▼
Platform Dashboard
   │
   ├──► Tenant Management (onboard/suspend nurseries)
   ├──► Subscription Plans (create/edit pricing tiers)
   ├──► Global Reports (platform-wide usage, revenue)
   └──► Security & Audit Logs
```

---

## 9. Cross-Cutting Flows

### 9.1 Notification Delivery Flow
```
Event Triggered (order placed, payment success, low stock, delivery update)
   │
   ▼
Notification Service enqueues job (BullMQ)
   │
   ▼
Worker dispatches via Email / SMS / Push based on user preference
   │
   ▼
Delivery status logged (sent/failed) for retry
```

### 9.2 Purchase-to-Inventory Flow
```
Manager/Owner creates Purchase Order
   │
   ▼
Supplier confirms
   │
   ▼
Goods received at warehouse (staff scans/enters batch + expiry)
   │
   ▼
Inventory Service updates stock levels
   │
   ▼
Payment processed to supplier
```

### 9.3 Stock Transfer Flow
```
Manager initiates transfer request (source → destination location)
   │
   ▼
Owner/Manager approval (if cross-branch)
   │
   ▼
Staff at source confirms dispatch
   │
   ▼
Staff at destination confirms receipt
   │
   ▼
Inventory Movements log updated at both locations
```

---

## 10. Error & Edge-Case Flows

- **Payment failure:** customer returned to payment method selection; order remains in `pending_payment` for a bounded window before auto-cancellation and stock release.
- **Delivery failure:** agent logs failure reason (customer unavailable, address issue, refused); order routes back to Manager for re-scheduling.
- **Stock unavailable at checkout:** system re-validates stock at payment confirmation (not just cart-add time) to prevent overselling; customer notified if unavailable.
- **Session expiry mid-flow:** refresh token silently renews access token; if refresh token also expired, user is redirected to login with cart/session state preserved locally where possible.
