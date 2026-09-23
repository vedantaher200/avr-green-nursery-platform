-- =============================================================================
-- AVRGREEN - Enterprise Nursery Management System (SaaS Platform)
-- PostgreSQL Normalized Database Schema with Multi-Tenancy & Row Level Security
-- =============================================================================

CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- -----------------------------------------------------------------------------
-- ENUMS
-- -----------------------------------------------------------------------------
CREATE TYPE tenant_status AS ENUM ('active', 'suspended', 'trial');
CREATE TYPE user_status AS ENUM ('active', 'invited', 'disabled');
CREATE TYPE role_name AS ENUM ('super_admin', 'owner', 'manager', 'staff', 'customer', 'delivery_agent', 'supplier');
CREATE TYPE location_type AS ENUM ('branch', 'warehouse', 'greenhouse');
CREATE TYPE product_status AS ENUM ('active', 'discontinued', 'out_of_stock');
CREATE TYPE movement_type AS ENUM ('purchase_in', 'sale_out', 'transfer_in', 'transfer_out', 'damaged', 'adjustment');
CREATE TYPE transfer_status AS ENUM ('requested', 'approved', 'dispatched', 'received', 'cancelled');
CREATE TYPE po_status AS ENUM ('draft', 'sent', 'confirmed', 'goods_received', 'paid', 'cancelled');
CREATE TYPE order_status AS ENUM ('cart', 'pending_payment', 'confirmed', 'packed', 'dispatched', 'delivered', 'cancelled', 'failed');
CREATE TYPE payment_method AS ENUM ('upi', 'card', 'net_banking', 'cash');
CREATE TYPE payment_status AS ENUM ('initiated', 'success', 'failed', 'refunded');
CREATE TYPE delivery_status AS ENUM ('assigned', 'picked_up', 'in_transit', 'delivered', 'failed');
CREATE TYPE notification_channel AS ENUM ('email', 'sms', 'push');
CREATE TYPE notification_status AS ENUM ('queued', 'sent', 'failed');

-- -----------------------------------------------------------------------------
-- 1. SUBSCRIPTIONS & TENANTS
-- -----------------------------------------------------------------------------
CREATE TABLE subscription_plans (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(100) NOT NULL,
    price_monthly NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    max_branches INT NOT NULL DEFAULT 1,
    max_users INT NOT NULL DEFAULT 5,
    features JSONB NOT NULL DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE tenants (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(100) UNIQUE NOT NULL,
    subscription_plan_id UUID REFERENCES subscription_plans(id),
    status tenant_status NOT NULL DEFAULT 'trial',
    settings JSONB DEFAULT '{}',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------------------------------
-- 2. USERS, ROLES & PERMISSIONS
-- -----------------------------------------------------------------------------
CREATE TABLE roles (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    name role_name UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE permissions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    code VARCHAR(100) UNIQUE NOT NULL,
    description TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE role_permissions (
    role_id UUID REFERENCES roles(id) ON DELETE CASCADE,
    permission_id UUID REFERENCES permissions(id) ON DELETE CASCADE,
    PRIMARY KEY (role_id, permission_id)
);

CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID REFERENCES tenants(id) ON DELETE CASCADE, -- NULL for Super Admin
    role_id UUID NOT NULL REFERENCES roles(id),
    email VARCHAR(255) UNIQUE NOT NULL,
    phone VARCHAR(20),
    password_hash VARCHAR(255) NOT NULL,
    first_name VARCHAR(100),
    last_name VARCHAR(100),
    avatar_url TEXT,
    mfa_enabled BOOLEAN DEFAULT FALSE,
    mfa_secret VARCHAR(255),
    status user_status NOT NULL DEFAULT 'active',
    deleted_at TIMESTAMP WITH TIME ZONE NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE sessions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    refresh_token_hash TEXT NOT NULL,
    device_info JSONB DEFAULT '{}',
    expires_at TIMESTAMP WITH TIME ZONE NOT NULL,
    revoked BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------------------------------
-- 3. NURSERIES & LOCATIONS
-- -----------------------------------------------------------------------------
CREATE TABLE nurseries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    code VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE locations (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    nursery_id UUID NOT NULL REFERENCES nurseries(id) ON DELETE CASCADE,
    type location_type NOT NULL DEFAULT 'branch',
    name VARCHAR(255) NOT NULL,
    address JSONB NOT NULL DEFAULT '{}',
    geo_lat NUMERIC(10, 8),
    geo_lng NUMERIC(11, 8),
    contact_phone VARCHAR(20),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE user_locations (
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    location_id UUID REFERENCES locations(id) ON DELETE CASCADE,
    PRIMARY KEY (user_id, location_id)
);

-- -----------------------------------------------------------------------------
-- 4. CATEGORIES & PRODUCTS
-- -----------------------------------------------------------------------------
CREATE TABLE categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    parent_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    name VARCHAR(255) NOT NULL,
    slug VARCHAR(255) NOT NULL,
    icon_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(tenant_id, slug)
);

CREATE TABLE suppliers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    contact_name VARCHAR(100),
    email VARCHAR(255),
    phone VARCHAR(20),
    address JSONB DEFAULT '{}',
    rating NUMERIC(3, 2) DEFAULT 5.00,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE products (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    sku VARCHAR(100) NOT NULL,
    category_id UUID REFERENCES categories(id) ON DELETE SET NULL,
    supplier_id UUID REFERENCES suppliers(id) ON DELETE SET NULL,
    common_name VARCHAR(255) NOT NULL,
    scientific_name VARCHAR(255),
    description TEXT,
    care_instructions JSONB DEFAULT '{"sunlight": "Indirect Light", "watering": "Moderate", "fertilizer": "Monthly Organic", "temperature": "18-28 C"}',
    price NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    cost_price NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    images JSONB DEFAULT '[]',
    barcode VARCHAR(100),
    qr_code VARCHAR(100),
    status product_status NOT NULL DEFAULT 'active',
    crop VARCHAR(100),
    variety VARCHAR(100),
    selling_unit VARCHAR(50) DEFAULT 'seedling',
    tray_size INT DEFAULT 104,
    min_order_qty INT DEFAULT 1,
    deleted_at TIMESTAMP WITH TIME ZONE NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(tenant_id, sku)
);

-- -----------------------------------------------------------------------------
-- 5. INVENTORY MANAGEMENT
-- -----------------------------------------------------------------------------
CREATE TABLE inventory (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    location_id UUID NOT NULL REFERENCES locations(id) ON DELETE CASCADE,
    quantity_available INT NOT NULL DEFAULT 0,
    quantity_reserved INT NOT NULL DEFAULT 0,
    quantity_damaged INT NOT NULL DEFAULT 0,
    batch_number VARCHAR(100) DEFAULT 'DEFAULT_BATCH',
    expiry_date DATE,
    low_stock_threshold INT DEFAULT 10,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    UNIQUE(product_id, location_id, batch_number)
);

CREATE TABLE inventory_movements (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    inventory_id UUID NOT NULL REFERENCES inventory(id) ON DELETE CASCADE,
    type movement_type NOT NULL,
    quantity INT NOT NULL,
    reference_id UUID,
    notes TEXT,
    performed_by UUID REFERENCES users(id) ON DELETE SET NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE stock_transfers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id) ON DELETE CASCADE,
    source_location_id UUID NOT NULL REFERENCES locations(id),
    destination_location_id UUID NOT NULL REFERENCES locations(id),
    quantity INT NOT NULL,
    status transfer_status NOT NULL DEFAULT 'requested',
    notes TEXT,
    requested_by UUID REFERENCES users(id),
    approved_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------------------------------
-- 6. CUSTOMERS & LOYALTY
-- -----------------------------------------------------------------------------
CREATE TABLE customers (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    user_id UUID UNIQUE REFERENCES users(id) ON DELETE CASCADE,
    loyalty_points INT DEFAULT 0,
    total_spent NUMERIC(12, 2) DEFAULT 0.00,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE customer_addresses (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    customer_id UUID NOT NULL REFERENCES customers(id) ON DELETE CASCADE,
    label VARCHAR(50) DEFAULT 'Home',
    address JSONB NOT NULL,
    geo_lat NUMERIC(10, 8),
    geo_lng NUMERIC(11, 8),
    is_default BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------------------------------
-- 7. PURCHASE ORDERS
-- -----------------------------------------------------------------------------
CREATE TABLE purchase_orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    supplier_id UUID NOT NULL REFERENCES suppliers(id),
    location_id UUID NOT NULL REFERENCES locations(id),
    po_number VARCHAR(100) UNIQUE NOT NULL,
    status po_status NOT NULL DEFAULT 'draft',
    total_amount NUMERIC(12, 2) DEFAULT 0.00,
    created_by UUID REFERENCES users(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE purchase_order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    purchase_order_id UUID NOT NULL REFERENCES purchase_orders(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id),
    quantity INT NOT NULL,
    unit_price NUMERIC(10, 2) NOT NULL,
    total_price NUMERIC(10, 2) NOT NULL
);

-- -----------------------------------------------------------------------------
-- 8. ORDERS & PAYMENTS
-- -----------------------------------------------------------------------------
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    order_number VARCHAR(100) UNIQUE NOT NULL,
    customer_id UUID NOT NULL REFERENCES customers(id),
    location_id UUID NOT NULL REFERENCES locations(id),
    status order_status NOT NULL DEFAULT 'pending_payment',
    subtotal NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    tax_amount NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    discount_amount NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    total_amount NUMERIC(10, 2) NOT NULL DEFAULT 0.00,
    shipping_address JSONB NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id),
    quantity INT NOT NULL,
    unit_price NUMERIC(10, 2) NOT NULL,
    total_price NUMERIC(10, 2) NOT NULL
);

CREATE TABLE payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    method payment_method NOT NULL DEFAULT 'upi',
    status payment_status NOT NULL DEFAULT 'initiated',
    amount NUMERIC(10, 2) NOT NULL,
    gateway_reference VARCHAR(255),
    idempotency_key VARCHAR(255) UNIQUE NOT NULL,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE invoices (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    order_id UUID UNIQUE NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    invoice_number VARCHAR(100) UNIQUE NOT NULL,
    gstin VARCHAR(50),
    gst_breakdown JSONB NOT NULL,
    pdf_object_key TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- -----------------------------------------------------------------------------
-- 9. DELIVERIES & NOTIFICATIONS
-- -----------------------------------------------------------------------------
CREATE TABLE deliveries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    order_id UUID UNIQUE NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    delivery_agent_id UUID REFERENCES users(id),
    status delivery_status NOT NULL DEFAULT 'assigned',
    current_lat NUMERIC(10, 8),
    current_lng NUMERIC(11, 8),
    proof_of_delivery JSONB DEFAULT '{}',
    failure_reason TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE notifications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID NOT NULL REFERENCES tenants(id) ON DELETE CASCADE,
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    channel notification_channel NOT NULL DEFAULT 'push',
    event_type VARCHAR(100) NOT NULL,
    title VARCHAR(255) NOT NULL,
    body TEXT NOT NULL,
    payload JSONB DEFAULT '{}',
    status notification_status NOT NULL DEFAULT 'queued',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE audit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    tenant_id UUID REFERENCES tenants(id) ON DELETE SET NULL,
    user_id UUID REFERENCES users(id) ON DELETE SET NULL,
    action VARCHAR(100) NOT NULL,
    resource VARCHAR(100) NOT NULL,
    resource_id UUID,
    details JSONB DEFAULT '{}',
    ip_address VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT CURRENT_TIMESTAMP
);

-- Keep stock and transactional quantities valid even if an API is bypassed.
ALTER TABLE inventory ADD CONSTRAINT inventory_available_non_negative CHECK (quantity_available >= 0);
ALTER TABLE inventory ADD CONSTRAINT inventory_reserved_non_negative CHECK (quantity_reserved >= 0);
ALTER TABLE inventory ADD CONSTRAINT inventory_damaged_non_negative CHECK (quantity_damaged >= 0);
ALTER TABLE inventory_movements ADD CONSTRAINT inventory_movement_non_zero CHECK (quantity <> 0);
ALTER TABLE purchase_order_items ADD CONSTRAINT purchase_item_quantity_positive CHECK (quantity > 0);
ALTER TABLE order_items ADD CONSTRAINT order_item_quantity_positive CHECK (quantity > 0);

-- -----------------------------------------------------------------------------
-- INDEXES FOR MAXIMUM QUERY PERFORMANCE
-- -----------------------------------------------------------------------------
CREATE INDEX idx_users_tenant_email ON users(tenant_id, email);
CREATE INDEX idx_products_tenant_sku ON products(tenant_id, sku);
CREATE INDEX idx_products_category ON products(category_id);
CREATE INDEX idx_inventory_product_loc ON inventory(product_id, location_id);
CREATE INDEX idx_orders_tenant_cust ON orders(tenant_id, customer_id);
CREATE INDEX idx_orders_status ON orders(status);
CREATE INDEX idx_payments_order ON payments(order_id);
CREATE INDEX idx_deliveries_agent_status ON deliveries(delivery_agent_id, status);
CREATE INDEX idx_notifications_user_status ON notifications(user_id, status);
CREATE INDEX idx_audit_logs_tenant ON audit_logs(tenant_id, created_at DESC);

-- -----------------------------------------------------------------------------
-- ROW LEVEL SECURITY (RLS) POLICIES FOR TENANT ISOLATION
-- -----------------------------------------------------------------------------
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE nurseries ENABLE ROW LEVEL SECURITY;
ALTER TABLE locations ENABLE ROW LEVEL SECURITY;
ALTER TABLE products ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory ENABLE ROW LEVEL SECURITY;
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;
ALTER TABLE payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE invoices ENABLE ROW LEVEL SECURITY;
ALTER TABLE deliveries ENABLE ROW LEVEL SECURITY;
ALTER TABLE audit_logs ENABLE ROW LEVEL SECURITY;

-- Dynamic RLS policy using current_setting('app.current_tenant_id', true)
CREATE POLICY tenant_isolation_users ON users USING (tenant_id = NULLIF(current_setting('app.current_tenant_id', true), '')::UUID OR tenant_id IS NULL);
CREATE POLICY tenant_isolation_products ON products USING (tenant_id = NULLIF(current_setting('app.current_tenant_id', true), '')::UUID);
CREATE POLICY tenant_isolation_inventory ON inventory USING (tenant_id = NULLIF(current_setting('app.current_tenant_id', true), '')::UUID);
CREATE POLICY tenant_isolation_orders ON orders USING (tenant_id = NULLIF(current_setting('app.current_tenant_id', true), '')::UUID);
