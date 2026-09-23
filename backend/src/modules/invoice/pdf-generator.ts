export interface InvoiceData {
  invoiceNumber: string;
  invoiceDate: string;
  orderNumber: string;
  tenantName: string;
  tenantGstin?: string;
  tenantPhone?: string;
  customerName: string;
  customerPhone?: string;
  shippingAddress: {
    street?: string;
    city?: string;
    state?: string;
    pincode?: string;
  };
  items: Array<{
    name: string;
    sku: string;
    quantity: number;
    unitPrice: number;
    totalPrice: number;
  }>;
  subtotal: number;
  cgst: number;
  sgst: number;
  totalAmount: number;
  paymentMethod: string;
  paymentStatus: string;
}

/**
 * Pure TypeScript standard PDF 1.4 document generator.
 * Produces valid, downloadable, printable invoices with zero external native dependencies.
 */
export function generateInvoicePdf(data: InvoiceData): Buffer {
  const streamLines: string[] = [];

  // Helper functions for PDF stream operations
  const drawRect = (x: number, y: number, w: number, h: number, r: number, g: number, b: number, fill = true) => {
    streamLines.push(`${r.toFixed(3)} ${g.toFixed(3)} ${b.toFixed(3)} ${fill ? 'rg' : 'RG'}`);
    streamLines.push(`${x.toFixed(2)} ${y.toFixed(2)} ${w.toFixed(2)} ${h.toFixed(2)} re ${fill ? 'f' : 'S'}`);
  };

  const drawLine = (x1: number, y1: number, x2: number, y2: number, r = 0.8, g = 0.8, b = 0.8, lineWidth = 1) => {
    streamLines.push(`${lineWidth} w`);
    streamLines.push(`${r.toFixed(3)} ${g.toFixed(3)} ${b.toFixed(3)} RG`);
    streamLines.push(`${x1.toFixed(2)} ${y1.toFixed(2)} m ${x2.toFixed(2)} ${y2.toFixed(2)} l S`);
  };

  const drawText = (text: string, x: number, y: number, font = '/F1', size = 10, r = 0.1, g = 0.1, b = 0.1) => {
    // Escape parentheses and backslashes in PDF text
    const escaped = text.replace(/\\/g, '\\\\').replace(/\(/g, '\\(').replace(/\)/g, '\\)');
    streamLines.push('BT');
    streamLines.push(`${font} ${size} Tf`);
    streamLines.push(`${r.toFixed(3)} ${g.toFixed(3)} ${b.toFixed(3)} rg`);
    streamLines.push(`1 0 0 1 ${x.toFixed(2)} ${y.toFixed(2)} Tm`);
    streamLines.push(`(${escaped}) Tj`);
    streamLines.push('ET');
  };

  // Dimensions for A4: 595.28 x 841.89 points
  const top = 800;
  const left = 45;
  const right = 550;

  // Header banner: Deep Forest Green (#1F5D3A -> RGB 0.122, 0.365, 0.227)
  drawRect(0, 750, 595.28, 92, 0.122, 0.365, 0.227, true);

  // Brand Name & Tagline
  drawText('AVR GREEN NURSERY', left, top - 18, '/F2', 20, 1.0, 1.0, 1.0);
  drawText('Cultivating Green Futures - Enterprise Nursery Platform', left, top - 34, '/F1', 9, 0.85, 0.95, 0.88);

  // Invoice Title on top right
  drawText('TAX INVOICE', right - 130, top - 18, '/F2', 18, 1.0, 1.0, 1.0);
  drawText(`ORIGINAL FOR RECIPIENT`, right - 130, top - 34, '/F1', 8, 0.85, 0.95, 0.88);

  // Nursery Info & Invoice Metadata box
  const metaY = 720;
  drawText(`Nursery / Tenant:`, left, metaY, '/F2', 10, 0.1, 0.35, 0.2);
  drawText(data.tenantName, left, metaY - 14, '/F2', 11, 0.1, 0.1, 0.1);
  drawText(`GSTIN: ${data.tenantGstin || '29AAAAA0000A1Z5'}`, left, metaY - 27, '/F1', 9, 0.3, 0.3, 0.3);
  drawText(`Phone: ${data.tenantPhone || '+91 98765 43210'}`, left, metaY - 39, '/F1', 9, 0.3, 0.3, 0.3);

  // Invoice Details on Right
  drawText(`Invoice No:`, right - 160, metaY, '/F2', 9, 0.3, 0.3, 0.3);
  drawText(data.invoiceNumber, right - 95, metaY, '/F2', 10, 0.1, 0.1, 0.1);
  drawText(`Date:`, right - 160, metaY - 14, '/F1', 9, 0.3, 0.3, 0.3);
  drawText(data.invoiceDate, right - 95, metaY - 14, '/F1', 9, 0.1, 0.1, 0.1);
  drawText(`Order Ref:`, right - 160, metaY - 27, '/F1', 9, 0.3, 0.3, 0.3);
  drawText(data.orderNumber, right - 95, metaY - 27, '/F1', 9, 0.1, 0.1, 0.1);
  drawText(`Payment:`, right - 160, metaY - 40, '/F1', 9, 0.3, 0.3, 0.3);
  drawText(`${data.paymentMethod.toUpperCase()} (${data.paymentStatus.toUpperCase()})`, right - 95, metaY - 40, '/F2', 9, 0.12, 0.55, 0.25);

  drawLine(left, metaY - 50, right, metaY - 50, 0.85, 0.85, 0.85);

  // Bill To / Shipping Details
  const billY = metaY - 68;
  drawText(`Billed & Delivered To:`, left, billY, '/F2', 10, 0.1, 0.35, 0.2);
  drawText(data.customerName, left, billY - 14, '/F2', 11, 0.1, 0.1, 0.1);
  drawText(`Phone: ${data.customerPhone || 'N/A'}`, left, billY - 27, '/F1', 9, 0.3, 0.3, 0.3);
  const addr = `${data.shippingAddress.street || ''}, ${data.shippingAddress.city || ''}, ${data.shippingAddress.state || ''} - ${data.shippingAddress.pincode || ''}`;
  drawText(`Address: ${addr}`, left, billY - 40, '/F1', 9, 0.3, 0.3, 0.3);

  // Line Items Table Header
  const tableY = billY - 60;
  // Header background (Warm Terracotta accent #C9713D -> RGB 0.788, 0.443, 0.239)
  drawRect(left, tableY - 6, right - left, 20, 0.788, 0.443, 0.239, true);
  drawText('#', left + 8, tableY, '/F2', 9, 1, 1, 1);
  drawText('Plant / Item Description', left + 35, tableY, '/F2', 9, 1, 1, 1);
  drawText('SKU', left + 260, tableY, '/F2', 9, 1, 1, 1);
  drawText('Qty', left + 345, tableY, '/F2', 9, 1, 1, 1);
  drawText('Unit Price (INR)', left + 390, tableY, '/F2', 9, 1, 1, 1);
  drawText('Total (INR)', right - 65, tableY, '/F2', 9, 1, 1, 1);

  // Items Rows
  let curY = tableY - 24;
  data.items.forEach((item, index) => {
    // Alternating row background
    if (index % 2 === 1) {
      drawRect(left, curY - 5, right - left, 18, 0.96, 0.98, 0.96, true);
    }
    drawText(`${index + 1}`, left + 8, curY, '/F1', 9, 0.4, 0.4, 0.4);
    drawText(item.name.slice(0, 38), left + 35, curY, '/F2', 9, 0.1, 0.1, 0.1);
    drawText(item.sku, left + 260, curY, '/F1', 8, 0.4, 0.4, 0.4);
    drawText(`${item.quantity}`, left + 350, curY, '/F1', 9, 0.1, 0.1, 0.1);
    drawText(`${item.unitPrice.toFixed(2)}`, left + 405, curY, '/F1', 9, 0.1, 0.1, 0.1);
    drawText(`${item.totalPrice.toFixed(2)}`, right - 55, curY, '/F2', 9, 0.1, 0.1, 0.1);
    drawLine(left, curY - 6, right, curY - 6, 0.92, 0.92, 0.92, 0.5);
    curY -= 20;
  });

  // Summary / Financials section
  curY -= 15;
  drawLine(left, curY + 10, right, curY + 10, 0.7, 0.7, 0.7, 1);

  const summaryLeft = right - 190;
  drawText('Subtotal:', summaryLeft, curY, '/F1', 9, 0.3, 0.3, 0.3);
  drawText(`INR ${data.subtotal.toFixed(2)}`, right - 65, curY, '/F1', 9, 0.1, 0.1, 0.1);

  curY -= 15;
  drawText('CGST (9%):', summaryLeft, curY, '/F1', 9, 0.3, 0.3, 0.3);
  drawText(`INR ${data.cgst.toFixed(2)}`, right - 65, curY, '/F1', 9, 0.1, 0.1, 0.1);

  curY -= 15;
  drawText('SGST (9%):', summaryLeft, curY, '/F1', 9, 0.3, 0.3, 0.3);
  drawText(`INR ${data.sgst.toFixed(2)}`, right - 65, curY, '/F1', 9, 0.1, 0.1, 0.1);

  curY -= 18;
  drawRect(summaryLeft - 10, curY - 6, right - summaryLeft + 15, 22, 0.122, 0.365, 0.227, true);
  drawText('TOTAL AMOUNT:', summaryLeft, curY, '/F2', 10, 1, 1, 1);
  drawText(`INR ${data.totalAmount.toFixed(2)}`, right - 65, curY, '/F2', 11, 1, 1, 1);

  // Terms and Note
  drawText('Notes & Terms:', left, curY, '/F2', 9, 0.2, 0.2, 0.2);
  drawText('1. Plants once delivered must be inspected within 24 hours.', left, curY - 14, '/F1', 8, 0.4, 0.4, 0.4);
  drawText('2. Keep plants in partial shade for 2 days after repotting.', left, curY - 26, '/F1', 8, 0.4, 0.4, 0.4);
  drawText('3. Computer generated invoice; no physical signature required.', left, curY - 38, '/F1', 8, 0.4, 0.4, 0.4);

  // Footer
  drawLine(left, 45, right, 45, 0.8, 0.8, 0.8, 1);
  drawText('Thank you for choosing AVR Green Nursery! Happy Gardening.', left + 100, 32, '/F2', 9, 0.122, 0.365, 0.227);
  drawText('Powered by AVR Mitra SaaS Platform', right - 160, 32, '/F1', 8, 0.5, 0.5, 0.5);

  const streamContent = streamLines.join('\n');
  const streamLength = Buffer.byteLength(streamContent, 'utf-8');

  // Build standard PDF 1.4 objects
  const objects: string[] = [
    // Obj 1: Catalog
    `1 0 obj\n<< /Type /Catalog /Pages 2 0 R >>\nendobj\n`,
    // Obj 2: Pages
    `2 0 obj\n<< /Type /Pages /Kids [3 0 R] /Count 1 >>\nendobj\n`,
    // Obj 3: Page
    `3 0 obj\n<< /Type /Page /Parent 2 0 R /MediaBox [0 0 595.28 841.89] /Contents 4 0 R /Resources << /Font << /F1 5 0 R /F2 6 0 R >> >> >>\nendobj\n`,
    // Obj 4: Stream Contents
    `4 0 obj\n<< /Length ${streamLength} >>\nstream\n${streamContent}\nendstream\nendobj\n`,
    // Obj 5: Helvetica Regular
    `5 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica >>\nendobj\n`,
    // Obj 6: Helvetica Bold
    `6 0 obj\n<< /Type /Font /Subtype /Type1 /BaseFont /Helvetica-Bold >>\nendobj\n`,
  ];

  let header = '%PDF-1.4\n';
  let offset = header.length;
  const xrefEntries: string[] = ['0000000000 65535 f \n'];

  for (const obj of objects) {
    const padded = offset.toString().padStart(10, '0');
    xrefEntries.push(`${padded} 00000 n \n`);
    offset += obj.length;
  }

  const xrefOffset = offset;
  const xref = `xref\n0 ${objects.length + 1}\n` + xrefEntries.join('');
  const trailer = `trailer\n<< /Size ${objects.length + 1} /Root 1 0 R >>\nstartxref\n${xrefOffset}\n%%EOF\n`;

  const fullPdf = header + objects.join('') + xref + trailer;
  return Buffer.from(fullPdf, 'utf-8');
}
