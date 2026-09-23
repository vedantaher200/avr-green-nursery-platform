# UI/UX Design Brief
## Nursery Management System (NMS)

**Version:** 1.0
**Related Docs:** PRD, TRD, App Flow, Backend Schema, Implementation Plan

---

## 1. Design Principles

1. **Clarity over decoration** — inventory numbers, order statuses, and money figures must be scannable at a glance; no ambiguity in critical data.
2. **Role-appropriate density** — customer-facing screens are spacious and visual (plant photography leads); operational screens (Owner/Manager/Staff) are data-dense, table-driven, optimized for speed.
3. **Consistency across platforms** — one Flutter codebase, one design system, adapted responsively rather than redesigned per platform.
4. **Trust signals** — GST invoice visibility, live delivery tracking, and clear payment status reduce customer anxiety at every step of a purchase.

---

## 2. Brand & Visual Direction

Nurseries are a green, organic, natural-light business — the UI should feel calm and botanical without becoming twee or overly decorative on operational screens.

### 2.1 Color Palette
| Role | Color | Usage |
|---|---|---|
| Primary | Deep Forest Green (#1F5D3A) | Primary buttons, active nav, brand marks |
| Secondary | Warm Terracotta (#C9713D) | Secondary actions, highlights, badges |
| Accent | Soft Sage (#A8C5A0) | Backgrounds, cards, subtle emphasis |
| Success | Leaf Green (#3C9A5F) | Order success, delivered status, in-stock |
| Warning | Amber (#D98E27) | Low stock, pending payment |
| Error | Clay Red (#B84C3C) | Failed payment, out of stock, delivery failure |
| Neutral / Text | Charcoal (#2A2E2B) on Off-White (#F7F6F2) | Body text, backgrounds |

### 2.2 Typography
- **Headings:** A clean geometric sans-serif (e.g., Inter or Poppins) — confident, modern.
- **Body/Data tables:** A highly legible sans-serif with strong numeral clarity (e.g., Inter, IBM Plex Sans) for financial and inventory figures.
- Avoid decorative or script fonts entirely — this is an operational SaaS tool wearing a botanical color story, not a lifestyle brand.

### 2.3 Imagery
- Real plant photography with natural lighting for the customer catalog.
- Iconography: simple line icons (outline style), consistent stroke width, botanical where it aids recognition (leaf for category, drop for watering instructions) but functional icons (truck, invoice, chart) stay standard and unambiguous.

---

## 3. Platform-Specific Considerations (Flutter)

- **Mobile (Android/iOS):** Primary surface for Customer and Delivery Agent roles. Bottom navigation for core sections, large touch targets, single-column layouts.
- **Tablet:** Primary surface for Staff (order pick/pack) and Manager (branch dashboard) — two-pane layouts where useful (list + detail).
- **Web (optional):** Primary surface for Owner and Super Admin — dashboard-first, multi-column, data table heavy, sidebar navigation.
- All layouts built responsively from one Flutter widget tree using breakpoint-aware layout builders rather than separate codebases.

---

## 4. Screen Inventory by Role

### 4.1 Customer (Mobile-first)
- Splash / Onboarding
- Home (featured plants, categories, search bar)
- Category browse / filter / sort
- Product detail (image gallery, care instructions, price, stock badge, add-to-cart)
- Cart
- Checkout (address, payment method)
- Order confirmation
- Order tracking (map + live status)
- Order history
- Invoice view/download
- Profile & addresses
- Loyalty points
- Notifications center

### 4.2 Owner / Manager (Tablet/Web-first)
- Dashboard (KPI cards: revenue, active orders, low stock alerts, branch selector)
- Inventory table (filter by location, category, stock status)
- Stock transfer modal
- Orders table (status filter, search, bulk actions)
- Order detail (timeline view of status changes)
- Customer directory + profile detail
- Staff management (role assignment, location scoping)
- Supplier directory
- Purchase order builder (line items, quantities, expected delivery)
- Reports (chart + table hybrid, date range picker, export button)
- Settings (branches, warehouses, subscription, notifications)

### 4.3 Staff (Tablet-first)
- Today's task list
- Order pick/pack checklist view
- Inventory quick-update form (barcode/SKU scan input)

### 4.4 Delivery Agent (Mobile-first)
- Today's route (list + map)
- Order detail with navigate button
- Pickup confirmation
- Live tracking toggle (auto-starts on "En Route")
- Proof of delivery capture (camera + signature pad)
- Delivered/Failed status screen

### 4.5 Supplier (Web/Mobile)
- PO inbox
- PO detail (accept/reject/counter)
- Dispatch confirmation
- Payment status view

### 4.6 Super Admin (Web-only)
- Platform dashboard (tenant count, MRR, active users)
- Tenant management table
- Subscription plan editor
- Global reports
- Audit log viewer

---

## 5. Key Interaction Patterns

- **Status badges:** every order/delivery/payment status uses a consistent color-coded pill component across all roles (see palette above) — a Manager and a Customer should recognize "Delivered" instantly by color even before reading the label.
- **Live tracking map:** persistent bottom sheet showing agent ETA, updates via Socket.IO without full screen refresh.
- **Low-stock alert:** surfaces as a dismissible banner on Owner/Manager dashboard, plus a badge count on the Inventory nav item.
- **Empty states:** every list screen (orders, inventory, customers) has an illustrated empty state with a clear next action, not a blank table.
- **Data tables (Owner/Web):** sticky header, inline sort, row-level quick actions (view, edit, transfer), pagination footer.

---

## 6. Accessibility

- Minimum contrast ratio 4.5:1 for all text (verified against the palette above, especially Amber and Sage backgrounds which need darker text overlays).
- Touch targets ≥ 44x44px on mobile.
- All status-communicating color must be paired with a text label or icon — never color alone (critical for Order Status and Stock Status).
- Screen-reader labels on all icon-only buttons (camera capture, navigate, notification bell).

---

## 7. Component Library Scope (for design system build)

- Buttons (primary/secondary/destructive/ghost)
- Status pill/badge
- Data table (sortable, filterable, paginated)
- KPI card
- Form inputs (text, dropdown, date picker, address autocomplete)
- Modal / bottom sheet
- Toast/snackbar notification
- Navigation: bottom nav (mobile), sidebar (web), tab bar (tablet)
- Map component wrapper (tracking + navigation)
- Camera/signature capture widget
- Chart components (line, bar, donut) for Reports

---

## 8. Design-to-Dev Handoff

- Figma (or equivalent) file organized by role, matching the Screen Inventory in §4.
- Design tokens (colors, spacing, typography scale) exported as a shared config consumable by Flutter theming (`ThemeData`).
- Redlines/spacing specs required only for components outside the standard 8px spacing grid.
