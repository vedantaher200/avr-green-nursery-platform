# Backend Schema Document
## Nursery Management System (NMS)

**Version:** 1.0
**Database:** PostgreSQL
**Related Docs:** PRD, TRD, App Flow, UI/UX Design Brief, Implementation Plan

---

## 1. Schema Design Principles

- Every tenant-owned table carries a `tenant_id` column; PostgreSQL Row-Level Security policies enforce isolation (see TRD §8).
- All tables use UUID primary keys for safe multi-tenant merging and public-facing references.
- Soft deletes (`deleted_at TIMESTAMP NULL`) on customer-facing and financial records; hard deletes reserved for non-critical config data.
- `created_at` / `updated_at` timestamps on every table.
- JSONB used for flexible/extensible attributes (care instructions, custom metadata) rather than proliferating sparse columns.

---

## 2. Core Tables

### 2.1 `tenants`
| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| name | TEXT | Nursery business name |
| subscription_plan_id | UUID FK → subscription_plans | |
| status | ENUM(active, suspended, trial) | |
| created_at / updated_at | TIMESTAMP | |

### 2.2 `subscription_plans`
| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| name | TEXT | e.g., Starter, Growth, Enterprise |
| price_monthly | NUMERIC | |
| max_branches | INT | |
| max_users | INT | |
| features | JSONB | Feature flags per plan |

### 2.3 `users`
| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | NULL for Super Admin |
| role_id | UUID FK → roles | |
| email | TEXT UNIQUE | |
| phone | TEXT | |
| password_hash | TEXT | bcrypt/argon2 |
| mfa_enabled | BOOLEAN | |
| mfa_secret | TEXT | encrypted at rest |
| status | ENUM(active, invited, disabled) | |
| created_at / updated_at | TIMESTAMP | |

### 2.4 `roles`
| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| name | ENUM(super_admin, owner, manager, staff, customer, delivery_agent, supplier) | |
| description | TEXT | |

### 2.5 `permissions`
| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| code | TEXT UNIQUE | e.g., `inventory.write`, `orders.read` |
| description | TEXT | |

### 2.6 `role_permissions`
| Column | Type | Notes |
|---|---|---|
| role_id | UUID FK → roles | |
| permission_id | UUID FK → permissions | |
| (composite PK) | | |

### 2.7 `sessions`
| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| user_id | UUID FK → users | |
| refresh_token_hash | TEXT | |
| device_info | JSONB | |
| expires_at | TIMESTAMP | |
| revoked | BOOLEAN | |

---

## 3. Nursery & Location Tables

### 3.1 `nurseries`
| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| name | TEXT | |
| created_at / updated_at | TIMESTAMP | |

### 3.2 `locations`
| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| nursery_id | UUID FK → nurseries | |
| type | ENUM(branch, warehouse, greenhouse) | |
| name | TEXT | |
| address | JSONB | |
| geo_lat / geo_lng | NUMERIC | |

### 3.3 `user_locations`
| Column | Type | Notes |
|---|---|---|
| user_id | UUID FK → users | |
| location_id | UUID FK → locations | |
| (composite PK) | | For location-scoped staff/manager access |

---

## 4. Catalog Tables

### 4.1 `categories`
| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| parent_id | UUID FK → categories NULL | Self-referencing for hierarchy |
| name | TEXT | |

### 4.2 `products`
| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| sku | TEXT UNIQUE (per tenant) | |
| category_id | UUID FK → categories | |
| supplier_id | UUID FK → suppliers NULL | |
| scientific_name | TEXT | |
| common_name | TEXT | |
| description | TEXT | |
| care_instructions | JSONB | |
| price | NUMERIC | |
| images | JSONB | Array of R2 object keys |
| status | ENUM(active, discontinued) | |
| created_at / updated_at | TIMESTAMP | |

---

## 5. Inventory Tables

### 5.1 `inventory`
| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| product_id | UUID FK → products | |
| location_id | UUID FK → locations | |
| quantity_available | INT | |
| quantity_reserved | INT | |
| quantity_damaged | INT | |
| batch_number | TEXT | |
| expiry_date | DATE NULL | |
| low_stock_threshold | INT | |
| UNIQUE(product_id, location_id, batch_number) | | |

### 5.2 `inventory_movements`
| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| inventory_id | UUID FK → inventory | |
| type | ENUM(purchase_in, sale_out, transfer_in, transfer_out, damaged, adjustment) | |
| quantity | INT | Signed |
| reference_id | UUID NULL | Points to order_id / purchase_order_id / transfer_id |
| performed_by | UUID FK → users | |
| created_at | TIMESTAMP | |

### 5.3 `stock_transfers`
| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| product_id | UUID FK → products | |
| source_location_id | UUID FK → locations | |
| destination_location_id | UUID FK → locations | |
| quantity | INT | |
| status | ENUM(requested, approved, dispatched, received) | |
| created_at / updated_at | TIMESTAMP | |

---

## 6. Customer & Loyalty Tables

### 6.1 `customers`
| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| user_id | UUID FK → users | |
| loyalty_points | INT DEFAULT 0 | |
| created_at / updated_at | TIMESTAMP | |

### 6.2 `customer_addresses`
| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| customer_id | UUID FK → customers | |
| label | TEXT | Home/Work/Other |
| address | JSONB | |
| geo_lat / geo_lng | NUMERIC | |
| is_default | BOOLEAN | |

---

## 7. Supplier & Purchase Tables

### 7.1 `suppliers`
| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| name | TEXT | |
| contact_info | JSONB | |
| rating | NUMERIC | |

### 7.2 `purchase_orders`
| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| supplier_id | UUID FK → suppliers | |
| location_id | UUID FK → locations | Delivery destination |
| status | ENUM(draft, sent, confirmed, goods_received, paid) | |
| total_amount | NUMERIC | |
| created_by | UUID FK → users | |
| created_at / updated_at | TIMESTAMP | |

### 7.3 `purchase_order_items`
| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| purchase_order_id | UUID FK → purchase_orders | |
| product_id | UUID FK → products | |
| quantity | INT | |
| unit_price | NUMERIC | |

---

## 8. Order Tables

### 8.1 `orders`
| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| customer_id | UUID FK → customers | |
| location_id | UUID FK → locations | Fulfilling branch/warehouse |
| status | ENUM(cart, pending_payment, confirmed, packed, dispatched, delivered, cancelled, failed) | |
| subtotal / tax_amount / discount_amount / total_amount | NUMERIC | |
| shipping_address | JSONB | |
| created_at / updated_at | TIMESTAMP | |

### 8.2 `order_items`
| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| order_id | UUID FK → orders | |
| product_id | UUID FK → products | |
| quantity | INT | |
| unit_price | NUMERIC | |

---

## 9. Payment & Invoice Tables

### 9.1 `payments`
| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| order_id | UUID FK → orders | |
| method | ENUM(upi, card, net_banking, cash) | |
| status | ENUM(initiated, success, failed, refunded) | |
| gateway_reference | TEXT | |
| amount | NUMERIC | |
| idempotency_key | TEXT UNIQUE | |
| created_at / updated_at | TIMESTAMP | |

### 9.2 `invoices`
| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| order_id | UUID FK → orders | |
| invoice_number | TEXT UNIQUE | Sequential per tenant |
| gst_breakdown | JSONB | |
| pdf_object_key | TEXT | R2 reference |
| created_at | TIMESTAMP | |

---

## 10. Delivery Tables

### 10.1 `deliveries`
| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| order_id | UUID FK → orders | |
| delivery_agent_id | UUID FK → users | |
| status | ENUM(assigned, picked_up, in_transit, delivered, failed) | |
| current_lat / current_lng | NUMERIC | Updated via Socket.IO |
| proof_of_delivery | JSONB | photo/signature R2 keys |
| failure_reason | TEXT NULL | |
| created_at / updated_at | TIMESTAMP | |

---

## 11. Notification Tables

### 11.1 `notifications`
| Column | Type | Notes |
|---|---|---|
| id | UUID PK | |
| tenant_id | UUID FK → tenants | |
| user_id | UUID FK → users | |
| channel | ENUM(email, sms, push) | |
| event_type | TEXT | e.g., order_confirmed, low_stock |
| payload | JSONB | |
| status | ENUM(queued, sent, failed) | |
| created_at | TIMESTAMP | |

---

## 12. Entity Relationship Summary

```
tenants 1─* nurseries 1─* locations
tenants 1─* users *─1 roles *─* permissions
locations *─* users (via user_locations)
tenants 1─* products *─1 categories
products 1─* inventory *─1 locations
inventory 1─* inventory_movements
tenants 1─* customers 1─1 users
customers 1─* customer_addresses
tenants 1─* suppliers 1─* purchase_orders 1─* purchase_order_items
tenants 1─* orders *─1 customers
orders 1─* order_items *─1 products
orders 1─* payments
orders 1─1 invoices
orders 1─1 deliveries *─1 users(delivery_agent)
users 1─* notifications
```

## 13. Indexing Strategy

- `tenant_id` indexed on every tenant-scoped table (composite with primary lookup column where applicable).
- `orders(customer_id, status, created_at)` composite index for order history/filtering.
- `inventory(product_id, location_id)` composite unique index.
- `products(sku)` unique index scoped to tenant.
- `payments(idempotency_key)` unique index to guarantee exactly-once processing.
- `deliveries(delivery_agent_id, status)` for agent route queries.

## 14. Migration & Versioning

- Schema migrations managed via a versioned migration tool (Prisma Migrate or Knex), one migration file per schema change, applied automatically in the CI/CD pre-deploy step (see TRD §11).
- Backward-compatible migrations preferred (additive columns before removals) to support zero-downtime rolling deploys.
