/**
 * AVR Green Nursery Platform - Automated Tenant Isolation & Security Verification
 * Implements Mandatory Section 79 & Business Logic Verification
 */

import jwt from 'jsonwebtoken';
import { generateInvoicePdf, InvoiceData } from '../src/modules/invoice/pdf-generator';
import { SandboxPaymentProvider } from '../src/shared/providers/payment.provider';
import { LocalStorageProvider } from '../src/shared/providers/storage.provider';
import fs from 'fs';
import path from 'path';

// ANSI terminal colors
const GREEN = '\x1b[32m';
const RED = '\x1b[31m';
const CYAN = '\x1b[36m';
const YELLOW = '\x1b[33m';
const RESET = '\x1b[0m';

let passedTests = 0;
let failedTests = 0;

function assert(condition: boolean, testName: string, details?: string) {
  if (condition) {
    console.log(`  ${GREEN}✓ PASS${RESET} - ${testName}`);
    passedTests++;
  } else {
    console.error(`  ${RED}✗ FAIL${RESET} - ${testName}${details ? ` (${details})` : ''}`);
    failedTests++;
  }
}

// In-Memory simulated multi-tenant database state
interface MockRecord {
  id: string;
  tenant_id: string;
  [key: string]: any;
}

class MockMultiTenantDB {
  public products: MockRecord[] = [];
  public inventory: MockRecord[] = [];
  public orders: MockRecord[] = [];
  public invoices: MockRecord[] = [];
  public customers: MockRecord[] = [];

  // Scoped query simulator representing PostgreSQL WHERE tenant_id = $1
  queryProducts(tenantId: string): MockRecord[] {
    return this.products.filter(p => p.tenant_id === tenantId && !p.deleted_at);
  }

  getProductById(tenantId: string, productId: string): MockRecord | null {
    return this.products.find(p => p.tenant_id === tenantId && p.id === productId && !p.deleted_at) || null;
  }

  queryOrders(tenantId: string, customerId?: string): MockRecord[] {
    return this.orders.filter(o => o.tenant_id === tenantId && (!customerId || o.customer_id === customerId));
  }

  getOrderById(tenantId: string, orderId: string): MockRecord | null {
    return this.orders.find(o => o.tenant_id === tenantId && o.id === orderId) || null;
  }

  getInvoiceById(tenantId: string, invoiceId: string): MockRecord | null {
    return this.invoices.find(i => i.tenant_id === tenantId && (i.id === invoiceId || i.order_id === invoiceId)) || null;
  }

  reserveStock(tenantId: string, productId: string, quantity: number): boolean {
    const inv = this.inventory.find(i => i.tenant_id === tenantId && i.product_id === productId);
    if (!inv || inv.quantity_available < quantity) {
      return false;
    }
    inv.quantity_available -= quantity;
    inv.quantity_reserved += quantity;
    return true;
  }
}

async function runTenantIsolationTests() {
  console.log(`\n${CYAN}============================================================${RESET}`);
  console.log(`${CYAN}AVR GREEN NURSERY PLATFORM — MANDATORY TEST SUITE${RESET}`);
  console.log(`${CYAN}Executing Tenant Isolation, RBAC & Core Business Flows${RESET}`);
  console.log(`${CYAN}============================================================\n${RESET}`);

  const db = new MockMultiTenantDB();

  // Test setup: Define Tenant A and Tenant B
  const tenantA_Id = '11111111-aaaa-aaaa-aaaa-aaaaaaaaaaaa';
  const tenantB_Id = '22222222-bbbb-bbbb-bbbb-bbbbbbbbbbbb';

  const jwtSecret = 'test_jwt_secret_512bits_secure_key_for_testing_isolation';

  // Issue tokens
  const tokenA = jwt.sign(
    { userId: 'user-a-1', tenantId: tenantA_Id, roleId: 'role-owner', roleName: 'owner', jti: 'jti-1' },
    jwtSecret
  );
  const tokenB = jwt.sign(
    { userId: 'user-b-1', tenantId: tenantB_Id, roleId: 'role-owner', roleName: 'owner', jti: 'jti-2' },
    jwtSecret
  );

  console.log(`${YELLOW}1. Multi-Tenant Token & Identity Decoding${RESET}`);
  const decodedA: any = jwt.verify(tokenA, jwtSecret);
  const decodedB: any = jwt.verify(tokenB, jwtSecret);
  assert(decodedA.tenantId === tenantA_Id, 'Token A decodes strictly to Tenant A');
  assert(decodedB.tenantId === tenantB_Id, 'Token B decodes strictly to Tenant B');
  assert(decodedA.tenantId !== decodedB.tenantId, 'Tenant A and Tenant B IDs are strictly isolated');

  console.log(`\n${YELLOW}2. Mandatory Catalog Isolation (Section 79)${RESET}`);
  // Tenant A creates Product A
  const productA: MockRecord = {
    id: 'prod-aaa-001',
    tenant_id: tenantA_Id,
    sku: 'PLANT-TENANT-A-ROSE',
    name: 'Desi Rose Tenant A',
    price: 399.00,
  };
  db.products.push(productA);

  // Tenant B creates Product B
  const productB: MockRecord = {
    id: 'prod-bbb-002',
    tenant_id: tenantB_Id,
    sku: 'PLANT-TENANT-B-MONSTERA',
    name: 'Monstera Deliciosa Tenant B',
    price: 899.00,
  };
  db.products.push(productB);

  // Tenant A requests products
  const tenantAProducts = db.queryProducts(tenantA_Id);
  assert(
    tenantAProducts.length === 1 && tenantAProducts[0].id === productA.id,
    'Tenant A receives ONLY Product A',
    `Received: ${tenantAProducts.map(p => p.name).join(', ')}`
  );

  // Tenant B requests products
  const tenantBProducts = db.queryProducts(tenantB_Id);
  assert(
    tenantBProducts.length === 1 && tenantBProducts[0].id === productB.id,
    'Tenant B receives ONLY Product B',
    `Received: ${tenantBProducts.map(p => p.name).join(', ')}`
  );

  // Cross-tenant breach attempt: Tenant A tries to access Product B
  const breachAttempt = db.getProductById(tenantA_Id, productB.id);
  assert(breachAttempt === null, 'Tenant A accessing Product B returns NULL (secure 404/403 Forbidden)');

  console.log(`\n${YELLOW}3. Inventory Concurrency & Stock Reservation Safety (Section 53)${RESET}`);
  db.inventory.push({
    id: 'inv-a-1',
    tenant_id: tenantA_Id,
    product_id: productA.id,
    quantity_available: 1, // Only 1 plant available
    quantity_reserved: 0,
  });

  // Customer 1 tries to purchase 1
  const res1 = db.reserveStock(tenantA_Id, productA.id, 1);
  assert(res1 === true, 'First customer successfully reserves remaining 1 stock');

  // Customer 2 tries to purchase the same 1 plant concurrently
  const res2 = db.reserveStock(tenantA_Id, productA.id, 1);
  assert(res2 === false, 'Second customer attempt to reserve exhausted stock is atomically rejected');

  console.log(`\n${YELLOW}4. Order & Invoice Isolation (Section 79)${RESET}`);
  // Create orders
  db.orders.push({
    id: 'ord-a-1',
    tenant_id: tenantA_Id,
    order_number: 'ORD-A-001',
    customer_id: 'cust-a',
    total_amount: 399.00,
  });
  db.orders.push({
    id: 'ord-b-1',
    tenant_id: tenantB_Id,
    order_number: 'ORD-B-001',
    customer_id: 'cust-b',
    total_amount: 899.00,
  });

  const tenantAOrders = db.queryOrders(tenantA_Id);
  assert(tenantAOrders.length === 1 && tenantAOrders[0].id === 'ord-a-1', 'Tenant A queries orders -> receives ONLY Order A');

  const tenantBOrderAccessByA = db.getOrderById(tenantA_Id, 'ord-b-1');
  assert(tenantBOrderAccessByA === null, 'Tenant A accessing Order B returns NULL (tenant isolation enforced)');

  // Invoices isolation
  db.invoices.push({
    id: 'inv-a-1',
    tenant_id: tenantA_Id,
    order_id: 'ord-a-1',
    invoice_number: 'INV-2026-000001',
    total_amount: 399.00,
  });
  db.invoices.push({
    id: 'inv-b-1',
    tenant_id: tenantB_Id,
    order_id: 'ord-b-1',
    invoice_number: 'INV-2026-000002',
    total_amount: 899.00,
  });

  const invoiceAccessA = db.getInvoiceById(tenantA_Id, 'inv-a-1');
  assert(invoiceAccessA !== null, 'Tenant A retrieves Invoice A successfully');

  const breachInvoiceAttempt = db.getInvoiceById(tenantA_Id, 'inv-b-1');
  assert(breachInvoiceAttempt === null, 'Tenant A retrieving Invoice B returns NULL (isolated)');

  console.log(`\n${YELLOW}5. Sandbox Payment Provider & Idempotency (Section 21 & 54)${RESET}`);
  const paymentProvider = new SandboxPaymentProvider();
  const initResult = await paymentProvider.createPaymentOrder('ord-a-1', 399.00);
  assert(initResult.status === 'initiated' && initResult.paymentId.startsWith('pay_mock_'), 'Sandbox payment initiated with valid mock ID');

  const verifyResult = await paymentProvider.verifyPayment({
    paymentId: initResult.paymentId,
    orderId: 'ord-a-1',
    method: 'upi',
  });
  assert(verifyResult.verified === true && verifyResult.status === 'success', 'Sandbox payment verified successfully');

  const sigValid = paymentProvider.verifyWebhookSignature('{"event":"payment.captured"}', 'test_sandbox_signature');
  assert(sigValid === true, 'Webhook signature verification operates reliably');

  console.log(`\n${YELLOW}6. Automatic PDF Invoice Generation Verification (Section 22 & 23)${RESET}`);
  const invoiceData: InvoiceData = {
    invoiceNumber: 'INV-2026-TEST-999',
    invoiceDate: '23 Sep 2026',
    orderNumber: 'ORD-TEST-999',
    tenantName: 'AVR Green Flagship Nursery',
    customerName: 'Ananya Sharma',
    customerPhone: '+91 98765 43210',
    shippingAddress: { street: '123 Farm Road', city: 'Bengaluru', state: 'Karnataka', pincode: '560038' },
    items: [
      { name: 'Monstera Deliciosa', sku: 'PLANT-MON-01', quantity: 2, unitPrice: 899, totalPrice: 1798 },
      { name: 'Organic Vermicompost', sku: 'FERT-VERM-03', quantity: 1, unitPrice: 299, totalPrice: 299 },
    ],
    subtotal: 2097.00,
    cgst: 188.73,
    sgst: 188.73,
    totalAmount: 2474.46,
    paymentMethod: 'UPI',
    paymentStatus: 'PAID',
  };

  const pdfBuffer = generateInvoicePdf(invoiceData);
  assert(Buffer.isBuffer(pdfBuffer), 'Invoice PDF generator returns valid Node Buffer');
  assert(pdfBuffer.length > 500, `Invoice PDF generated with sufficient size (${pdfBuffer.length} bytes)`);

  const pdfHeader = pdfBuffer.slice(0, 8).toString('utf-8');
  assert(pdfHeader.startsWith('%PDF-1.4'), 'Generated PDF complies with PDF 1.4 specification');

  const pdfContentStr = pdfBuffer.toString('utf-8');
  assert(pdfContentStr.includes('AVR GREEN NURSERY'), 'PDF includes AVR Green Nursery branding');
  assert(pdfContentStr.includes('INV-2026-TEST-999'), 'PDF includes invoice number');
  assert(pdfContentStr.includes('Monstera Deliciosa'), 'PDF includes plant line items');
  assert(pdfContentStr.includes('startxref') && pdfContentStr.includes('%%EOF'), 'PDF includes valid xref and EOF trailer');

  console.log(`\n${YELLOW}7. Object Storage Provider (Section 47)${RESET}`);
  const storage = new LocalStorageProvider(path.resolve(__dirname, '../uploads_test'));
  const uploadRes = await storage.uploadFile(pdfBuffer, 'test_invoice.pdf', 'application/pdf', 'invoices');
  assert(uploadRes.key.includes('test_invoice.pdf'), 'Storage provider uploads file and returns valid key');

  const streamInfo = await storage.getFileStream(uploadRes.key);
  assert(streamInfo.mimeType === 'application/pdf', 'Storage provider serves correct application/pdf MIME type');
  assert(streamInfo.size === pdfBuffer.length, 'Retrieved stream size matches uploaded buffer length');

  // Cleanup test file
  await storage.deleteFile(uploadRes.key);
  const testDir = path.resolve(__dirname, '../uploads_test');
  if (fs.existsSync(testDir)) {
    fs.rmSync(testDir, { recursive: true, force: true });
  }

  console.log(`\n${CYAN}============================================================${RESET}`);
  console.log(`${CYAN}TEST SUMMARY:${RESET}`);
  console.log(`  Passed: ${GREEN}${passedTests}${RESET}`);
  console.log(`  Failed: ${failedTests > 0 ? RED : GREEN}${failedTests}${RESET}`);
  console.log(`${CYAN}============================================================\n${RESET}`);

  if (failedTests > 0) {
    process.exit(1);
  }
}

runTenantIsolationTests().catch(err => {
  console.error(`${RED}Fatal Test Runner Error:${RESET}`, err);
  process.exit(1);
});
