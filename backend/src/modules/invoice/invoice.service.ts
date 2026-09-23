import { PoolClient } from 'pg';
import { pool } from '../../config/database';
import { getStorageProvider } from '../../shared/providers/storage.provider';
import { generateInvoicePdf, InvoiceData } from './pdf-generator';
import { logger } from '../../shared/logger';

export class InvoiceService {
  /**
   * Generates and persists a GST tax invoice and PDF document for a confirmed order.
   */
  static async createInvoiceForOrder(db: PoolClient | typeof pool, tenantId: string, orderId: string): Promise<string> {
    logger.info(`[InvoiceService] Generating invoice for order ${orderId}, tenant: ${tenantId}`);

    // Check if invoice already exists
    const existing = await db.query(
      `SELECT id, invoice_number FROM invoices WHERE tenant_id = $1 AND order_id = $2`,
      [tenantId, orderId]
    );
    if (existing.rows.length > 0) {
      return existing.rows[0].id;
    }

    // Fetch order, tenant, customer, and order items
    const orderRes = await db.query(
      `SELECT o.*, t.name as tenant_name, t.settings as tenant_settings,
              c.user_id as customer_user_id, u.first_name, u.last_name, u.phone as customer_phone
       FROM orders o
       JOIN tenants t ON t.id = o.tenant_id
       JOIN customers c ON c.id = o.customer_id
       JOIN users u ON u.id = c.user_id
       WHERE o.id = $1 AND o.tenant_id = $2`,
      [orderId, tenantId]
    );

    if (orderRes.rows.length === 0) {
      throw new Error(`Order ${orderId} not found for tenant ${tenantId}`);
    }

    const order = orderRes.rows[0];
    const itemsRes = await db.query(
      `SELECT oi.*, p.common_name, p.sku
       FROM order_items oi
       JOIN products p ON p.id = oi.product_id
       WHERE oi.order_id = $1`,
      [orderId]
    );

    const paymentRes = await db.query(
      `SELECT method, status FROM payments WHERE order_id = $1 ORDER BY created_at DESC LIMIT 1`,
      [orderId]
    );
    const payment = paymentRes.rows[0] || { method: 'cod', status: 'pending' };

    const subtotal = parseFloat(order.subtotal);
    const totalAmount = parseFloat(order.total_amount);
    const taxAmount = parseFloat(order.tax_amount);
    const cgst = parseFloat((taxAmount / 2).toFixed(2));
    const sgst = parseFloat((taxAmount - cgst).toFixed(2));

    const invoiceNumber = `INV-${new Date().getFullYear()}-${Math.floor(100000 + Math.random() * 900000)}`;
    const invoiceDate = new Date().toLocaleDateString('en-IN', {
      year: 'numeric',
      month: 'short',
      day: 'numeric',
    });

    const shippingAddr = typeof order.shipping_address === 'string'
      ? JSON.parse(order.shipping_address)
      : order.shipping_address || {};

    const invoiceData: InvoiceData = {
      invoiceNumber,
      invoiceDate,
      orderNumber: order.order_number,
      tenantName: order.tenant_name,
      tenantGstin: order.tenant_settings?.gstin || '29AVRPM1234F1Z9',
      tenantPhone: order.tenant_settings?.phone || '+91 98765 43210',
      customerName: `${order.first_name || ''} ${order.last_name || ''}`.trim() || 'Valued Customer',
      customerPhone: order.customer_phone || '',
      shippingAddress: shippingAddr,
      items: itemsRes.rows.map((i: any) => ({
        name: i.common_name,
        sku: i.sku,
        quantity: i.quantity,
        unitPrice: parseFloat(i.unit_price),
        totalPrice: parseFloat(i.total_price),
      })),
      subtotal,
      cgst,
      sgst,
      totalAmount,
      paymentMethod: payment.method,
      paymentStatus: payment.status,
    };

    // Generate PDF bytes
    const pdfBuffer = generateInvoicePdf(invoiceData);

    // Save PDF via Storage Provider
    const storage = getStorageProvider();
    const uploadResult = await storage.uploadFile(
      pdfBuffer,
      `${invoiceNumber}.pdf`,
      'application/pdf',
      'invoices'
    );

    const gstBreakdown = {
      rate: '18%',
      cgst_rate: '9%',
      cgst_amount: cgst,
      sgst_rate: '9%',
      sgst_amount: sgst,
      taxable_value: subtotal,
      total_tax: taxAmount,
    };

    const insertRes = await db.query(
      `INSERT INTO invoices (tenant_id, order_id, invoice_number, gstin, gst_breakdown, pdf_object_key)
       VALUES ($1, $2, $3, $4, $5, $6)
       RETURNING id, invoice_number`,
      [
        tenantId,
        orderId,
        invoiceNumber,
        invoiceData.tenantGstin,
        JSON.stringify(gstBreakdown),
        uploadResult.key,
      ]
    );

    logger.info(`[InvoiceService] Created invoice ${insertRes.rows[0].invoice_number} (id: ${insertRes.rows[0].id})`);
    return insertRes.rows[0].id;
  }

  /**
   * Retrieves an invoice and regenerates or streams its PDF content.
   */
  static async getInvoicePdf(tenantId: string, orderId: string): Promise<{ buffer: Buffer; fileName: string }> {
    const invRes = await pool.query(
      `SELECT i.*, o.order_number, t.name as tenant_name, t.settings as tenant_settings,
              u.first_name, u.last_name, u.phone as customer_phone, o.shipping_address,
              o.subtotal, o.tax_amount, o.total_amount
       FROM invoices i
       JOIN orders o ON o.id = i.order_id
       JOIN tenants t ON t.id = i.tenant_id
       JOIN customers c ON c.id = o.customer_id
       JOIN users u ON u.id = c.user_id
       WHERE i.tenant_id = $1 AND (i.order_id = $2 OR i.id = $2)`,
      [tenantId, orderId]
    );

    if (invRes.rows.length === 0) {
      throw new Error('Invoice not found for this tenant and order');
    }

    const inv = invRes.rows[0];
    const itemsRes = await pool.query(
      `SELECT oi.*, p.common_name, p.sku
       FROM order_items oi
       JOIN products p ON p.id = oi.product_id
       WHERE oi.order_id = $1`,
      [inv.order_id]
    );

    const paymentRes = await pool.query(
      `SELECT method, status FROM payments WHERE order_id = $1 ORDER BY created_at DESC LIMIT 1`,
      [inv.order_id]
    );
    const payment = paymentRes.rows[0] || { method: 'cod', status: 'paid' };

    const subtotal = parseFloat(inv.subtotal);
    const taxAmount = parseFloat(inv.tax_amount);
    const cgst = parseFloat((taxAmount / 2).toFixed(2));
    const sgst = parseFloat((taxAmount - cgst).toFixed(2));

    const invoiceData: InvoiceData = {
      invoiceNumber: inv.invoice_number,
      invoiceDate: new Date(inv.created_at).toLocaleDateString('en-IN', {
        year: 'numeric',
        month: 'short',
        day: 'numeric',
      }),
      orderNumber: inv.order_number,
      tenantName: inv.tenant_name,
      tenantGstin: inv.gstin || '29AVRPM1234F1Z9',
      tenantPhone: inv.tenant_settings?.phone || '+91 98765 43210',
      customerName: `${inv.first_name || ''} ${inv.last_name || ''}`.trim() || 'Customer',
      customerPhone: inv.customer_phone || '',
      shippingAddress: typeof inv.shipping_address === 'string' ? JSON.parse(inv.shipping_address) : inv.shipping_address || {},
      items: itemsRes.rows.map((i: any) => ({
        name: i.common_name,
        sku: i.sku,
        quantity: i.quantity,
        unitPrice: parseFloat(i.unit_price),
        totalPrice: parseFloat(i.total_price),
      })),
      subtotal,
      cgst,
      sgst,
      totalAmount: parseFloat(inv.total_amount),
      paymentMethod: payment.method,
      paymentStatus: payment.status,
    };

    const pdfBuffer = generateInvoicePdf(invoiceData);
    return {
      buffer: pdfBuffer,
      fileName: `${inv.invoice_number}.pdf`,
    };
  }
}
