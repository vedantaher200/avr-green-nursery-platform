# 🌿 AVR Green Nursery Platform

<div align="center">
  <h2>Commercial Multi-Tenant SaaS Platform for Nursery Businesses</h2>
  <p><b>Company:</b> AVR Mitra &nbsp;|&nbsp; <b>Product:</b> AVR Green Nursery &nbsp;|&nbsp; <b>Architecture:</b> Mobile-First Modular Monolith</p>

  ![Flutter](https://img.shields.io/badge/Flutter-3.47.1-02569B?logo=flutter)
  ![Dart](https://img.shields.io/badge/Dart-3.13.1-0175C2?logo=dart)
  ![TypeScript](https://img.shields.io/badge/TypeScript-5.3-3178C6?logo=typescript)
  ![Express](https://img.shields.io/badge/Express.js-4.18-000000?logo=express)
  ![PostgreSQL](https://img.shields.io/badge/PostgreSQL-16%2F18-336791?logo=postgresql)
  ![Redis](https://img.shields.io/badge/Redis-7.x-DC382D?logo=redis)
  ![Tests](https://img.shields.io/badge/Tests-25%2F25%20Passing-brightgreen)
</div>

---

## 📖 Executive Summary

The **AVR Green Nursery Platform** is an enterprise-grade, mobile-first SaaS solution engineered by **AVR Mitra** to digitize end-to-end nursery operations. It supports the entire agricultural commercial lifecycle:
```
AVR Mitra (SaaS Platform Owner)
      │
      ▼  SaaS Platform
Nursery Owner (Primary SaaS Customer)
      │
      ▼  Nursery Commerce & Advisory
Farmer / End Customer (Touch-First Mobile Buyer)
```

The system addresses the fragmented spreadsheets, stock discrepancies, manual invoicing, and delivery opacity common in commercial nurseries by providing a unified, multi-tenant solution with centralized inventory, automatic GST-compliant PDF invoicing, atomic stock reservation, and real-time order tracking.

---

## 🏗️ Architecture & Technology Stack

```
                   Mobile-First Flutter App (Android / iOS)
                                      │
                                      ▼ HTTPS / REST API
                       Node.js + Express + TypeScript
                                      │
            ┌─────────────────────────┼─────────────────────────┐
            ▼                         ▼                         ▼
   PostgreSQL 16/18                 Redis               Object Storage
 (Multi-Tenant Schema)       (Tokens / Cache)          (Local / R2 / S3)
```

- **Frontend**: Flutter 3.47+, Dart 3.13+, Material 3 Botanical Design System, Riverpod 2.6 state management, GoRouter 13.2 with role guards, Dio 5.11 HTTP client.
- **Backend**: Node.js v25+, Express.js 4.18, TypeScript 5.3, Modular Monolith architecture.
- **Database**: PostgreSQL with UUID primary keys, normalized tables, constraints (`quantity_available >= 0`), indexes, and Row Level Security (RLS) policies.
- **Security**: JWT Access + Refresh token rotation, bcrypt hashing, Helmet security headers, rate limiting, and server-enforced tenant authorization.
- **External Provider Abstractions**:
  - `PaymentProvider`: Provider-agnostic interface with **SandboxPaymentProvider** for verifiable local testing (UPI, Card, Net Banking, COD) and **RazorpayPaymentProvider** for production HMAC verification.
  - `StorageProvider`: **LocalStorageProvider** for local file streaming and **CloudflareR2StorageProvider** for cloud assets.
  - `NotificationProvider`: Multi-channel persistence for In-App notifications with development logging for SMS, Email, and Push notifications.

---

## 🎨 Design System & Botanical Palette

Optimized for mobile one-hand touch interaction, outdoor visibility, and botanical elegance:
| Token | Color Code | Role |
|---|---|---|
| **Deep Forest Green** | `#1F5D3A` | Primary brand color, headers, primary buttons |
| **Warm Terracotta** | `#C9713D` | Secondary accent, CTAs, buy now, badges |
| **Soft Sage** | `#A8C5A0` | Light accent, backgrounds, subtle borders |
| **Success** | `#3C9A5F` | Confirmed orders, in-stock indicators |
| **Warning** | `#D98E27` | Low-stock warnings, in-transit status |
| **Error** | `#B84C3C` | Destructive actions, out of stock |

---

## 🌐 Multilingual Architecture

Supports English, Hindi, and Marathi ready for regional farmers:
```dart
AppStrings.get('app_name', AppLanguage.hi) // एवीआर ग्रीन नर्सरी
AppStrings.get('add_to_cart', AppLanguage.mr) // कार्टमध्ये जोडा
```

---

## 📁 Repository Structure

```
AVR-Green-Nursery-Platform/
├── backend/
│   ├── src/
│   │   ├── config/              # PostgreSQL pool, Redis, Socket, App config
│   │   ├── db/                  # schema.sql, seeds.sql, seedRunner.ts
│   │   ├── middlewares/         # Auth, RBAC, Validate, Error, Subscription Limits
│   │   ├── modules/
│   │   │   ├── auth/            # Registration, Login, Refresh tokens, OTP
│   │   │   ├── catalog/         # Products, Categories, Botanical Metadata
│   │   │   ├── inventory/       # Stock levels, Batches, Movements, Transfers
│   │   │   ├── order/           # Cart, Checkout, Atomic stock reservation
│   │   │   ├── invoice/         # Pure TS PDF 1.4 Tax Invoice Generator & routes
│   │   │   ├── delivery/        # Route dispatch, Agent console, Live tracking
│   │   │   ├── report/          # Revenue analytics, Top plants, CSV exports
│   │   │   └── management/      # Suppliers, Purchase Orders, Staff, Tenants
│   │   ├── shared/
│   │   │   ├── providers/       # Payment, Storage, Notification abstractions
│   │   │   ├── logger.ts        # Winston logger
│   │   │   └── response.ts      # Standardized JSON response formatting
│   │   ├── app.ts               # Express bootstrap & route mounting
│   │   └── server.ts            # Server entrypoint & graceful shutdown
│   ├── tests/
│   │   └── tenant_isolation.test.ts # Mandatory 25-assertion test suite
│   ├── package.json
│   └── tsconfig.json
│
├── frontend/
│   ├── lib/
│   │   ├── core/
│   │   │   ├── theme/           # AVRColors, AVRTheme, Typography
│   │   │   ├── router/          # GoRouter with role guards
│   │   │   ├── localization/    # English, Hindi, Marathi strings
│   │   │   ├── network/         # ApiClient (Dio with auth interceptor)
│   │   │   └── widgets/         # Buttons, Cards, Inputs, Metric Tiles
│   │   ├── features/
│   │   │   ├── auth/            # Login, Register, OTP verification
│   │   │   ├── dashboard/       # Role-adaptive KPI dashboard
│   │   │   ├── customer/        # Storefront, Plant details, Cart, Checkout
│   │   │   ├── catalog/         # Plant variety management & care guide
│   │   │   ├── inventory/       # Multi-location stock, adjust & transfer
│   │   │   ├── order/           # Order tracking timeline & invoice PDF
│   │   │   ├── delivery/        # Agent console & live GPS tracking
│   │   │   ├── report/          # Analytics & sales breakdown
│   │   │   └── superadmin/      # Tenant onboarding, plans, audit logs
│   │   └── main.dart            # Flutter app root
│   ├── test/
│   │   └── widget_test.dart     # Flutter widget & unit tests
│   └── pubspec.yaml
│
├── 01-PRD.md                    # Product Requirements Document
├── 02-TRD.md                    # Technical Architecture Document
├── 03-App-Flow.md               # User & Role Flow Specifications
├── 04-UI-UX-Design-Brief.md     # Botanical UI/UX Guidelines
├── 05-Backend-Schema.md         # Database Schema Documentation
└── README.md                    # Complete Documentation
```

---

## 🧪 Verification & Automated Testing

### 1. Mandatory Multi-Tenant Isolation Test (Section 79)
Verifies complete data segregation between independent tenants:
- **Tenant A** creates *Product A*; **Tenant B** creates *Product B*.
- Tenant A queries catalog $\rightarrow$ receives **ONLY Product A**.
- Tenant B queries catalog $\rightarrow$ receives **ONLY Product B**.
- Tenant A direct access to Product B $\rightarrow$ **Blocked (NULL / 404 / 403)**.
- Full isolation verified for **Orders**, **Inventory**, **Invoices**, and **Customers**.
- Concurrency & atomic stock reservation verified (overselling prevented).

Run backend tests:
```bash
cd backend
npm test
```
Result: **25/25 Passing**

### 2. Flutter Unit & Widget Tests
Validates corporate botanical color palette, multilingual translations, botanical metadata models, and cart business logic:
```bash
cd frontend
flutter test
```
Result: **All 4 test groups passing**

### 3. Static Analysis & Build
- Backend TypeScript compilation:
  ```bash
  cd backend
  npm run build
  ```
  Result: Clean exit (code 0)
- Flutter static analysis:
  ```bash
  cd frontend
  flutter analyze
  ```
  Result: 0 errors

---

## 🚀 Running Locally

### Backend Setup
```bash
cd backend
# 1. Configure environment
cp .env.example .env

# 2. Run automated test suite
npm test

# 3. Start development server
npm run dev
```
The API engine will be accessible at `http://localhost:5000/api/v1`.

### Flutter Setup
```bash
cd frontend
# 1. Fetch dependencies
flutter pub get

# 2. Run unit tests
flutter test

# 3. Launch mobile application
flutter run
```

---

## 👥 Default Demo Credentials (Development Seed Data)

All demo accounts use password: `Password123!`

| Role | Email | Capabilities |
|---|---|---|
| **Super Admin** | `admin@avrgreen.com` | Multi-tenant onboarding, SaaS plans, platform health |
| **Nursery Owner** | `owner@avrnursery.com` | Full operational control, sales KPIs, billing, staff |
| **Manager** | `manager@avrnursery.com` | Inventory adjustments, branch transfers, order dispatch |
| **Staff Member** | `staff@avrnursery.com` | Floor inventory scanning, packing orders |
| **Farmer / Customer** | `customer@gmail.com` | Storefront browsing, plant care guide, cart, orders |
| **Delivery Agent** | `driver@avrlogistics.com`| Route queue, live GPS update, proof of delivery |
| **Wholesale Supplier**| `vendor@greenagro.com` | Fulfills nursery purchase orders |

---

## 📄 License

This software is developed for **AVR Mitra** under proprietary commercial SaaS distribution.
