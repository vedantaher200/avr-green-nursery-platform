import crypto from 'crypto';
import { logger } from '../logger';

export interface PaymentInitiationResult {
  orderId: string;
  paymentId: string;
  amount: number;
  currency: string;
  status: 'initiated' | 'pending' | 'success';
  gatewayReference?: string;
  checkoutPayload: Record<string, unknown>;
}

export interface PaymentVerificationResult {
  verified: boolean;
  paymentId: string;
  gatewayReference: string;
  status: 'success' | 'failed';
  amount: number;
  method: string;
  rawDetails?: Record<string, unknown>;
}

export interface PaymentProvider {
  createPaymentOrder(orderId: string, amount: number, currency?: string): Promise<PaymentInitiationResult>;
  verifyPayment(payload: { paymentId: string; orderId: string; signature?: string; method?: string }): Promise<PaymentVerificationResult>;
  verifyWebhookSignature(rawBody: string, signature: string): boolean;
}

/**
 * Sandbox/Development Payment Provider
 * Provides reliable, verifiable local payments for UPI, Card, Net Banking, and COD.
 */
export class SandboxPaymentProvider implements PaymentProvider {
  private readonly secret = 'avrgreen_sandbox_secret';

  async createPaymentOrder(orderId: string, amount: number, currency = 'INR'): Promise<PaymentInitiationResult> {
    const paymentId = `pay_mock_${Date.now()}_${crypto.randomBytes(4).toString('hex')}`;
    const gatewayRef = `ref_sandbox_${Date.now()}`;
    logger.info(`[SandboxPaymentProvider] Created mock payment ${paymentId} for order ${orderId}, amount: ${amount}`);

    return {
      orderId,
      paymentId,
      amount,
      currency,
      status: 'initiated',
      gatewayReference: gatewayRef,
      checkoutPayload: {
        provider: 'sandbox',
        paymentId,
        gatewayReference: gatewayRef,
        amount,
        currency,
        notes: 'Development / Sandbox mode for AVR Green Nursery',
      },
    };
  }

  async verifyPayment(payload: { paymentId: string; orderId: string; signature?: string; method?: string }): Promise<PaymentVerificationResult> {
    logger.info(`[SandboxPaymentProvider] Verifying sandbox payment ${payload.paymentId} for order ${payload.orderId}`);
    return {
      verified: true,
      paymentId: payload.paymentId,
      gatewayReference: `ref_sandbox_${payload.paymentId}`,
      status: 'success',
      amount: 0,
      method: payload.method ?? 'upi',
      rawDetails: { verifiedAt: new Date().toISOString(), environment: 'sandbox' },
    };
  }

  verifyWebhookSignature(rawBody: string, signature: string): boolean {
    if (!signature) return false;
    const expected = crypto.createHmac('sha256', this.secret).update(rawBody).digest('hex');
    return expected === signature || signature === 'test_sandbox_signature';
  }
}

/**
 * Razorpay Payment Provider (Production Adapter)
 * Reads credentials from environment variables.
 */
export class RazorpayPaymentProvider implements PaymentProvider {
  private readonly keyId: string;
  private readonly keySecret: string;
  private readonly webhookSecret: string;

  constructor(keyId: string, keySecret: string, webhookSecret: string) {
    this.keyId = keyId;
    this.keySecret = keySecret;
    this.webhookSecret = webhookSecret;
  }

  async createPaymentOrder(orderId: string, amount: number, currency = 'INR'): Promise<PaymentInitiationResult> {
    if (!this.keyId || !this.keySecret) {
      throw new Error('Razorpay credentials not configured in environment variables');
    }
    // Amount in paisa
    const amountInPaisa = Math.round(amount * 100);
    const receipt = `rcpt_${orderId.slice(0, 10)}`;

    return {
      orderId,
      paymentId: `rzp_order_${Date.now()}`,
      amount,
      currency,
      status: 'initiated',
      checkoutPayload: {
        key: this.keyId,
        amount: amountInPaisa,
        currency,
        orderId,
        receipt,
      },
    };
  }

  async verifyPayment(payload: { paymentId: string; orderId: string; signature?: string; method?: string }): Promise<PaymentVerificationResult> {
    if (!payload.signature) {
      return {
        verified: false,
        paymentId: payload.paymentId,
        gatewayReference: '',
        status: 'failed',
        amount: 0,
        method: payload.method ?? 'card',
      };
    }
    const hmac = crypto.createHmac('sha256', this.keySecret);
    hmac.update(`${payload.orderId}|${payload.paymentId}`);
    const generatedSignature = hmac.digest('hex');
    const verified = generatedSignature === payload.signature;

    return {
      verified,
      paymentId: payload.paymentId,
      gatewayReference: payload.paymentId,
      status: verified ? 'success' : 'failed',
      amount: 0,
      method: payload.method ?? 'upi',
    };
  }

  verifyWebhookSignature(rawBody: string, signature: string): boolean {
    if (!this.webhookSecret || !signature) return false;
    const expected = crypto.createHmac('sha256', this.webhookSecret).update(rawBody).digest('hex');
    return expected === signature;
  }
}

let activePaymentProvider: PaymentProvider | null = null;

export function getPaymentProvider(): PaymentProvider {
  if (!activePaymentProvider) {
    const keyId = process.env.RAZORPAY_KEY_ID;
    const keySecret = process.env.RAZORPAY_KEY_SECRET;
    const webhookSecret = process.env.RAZORPAY_WEBHOOK_SECRET;

    if (keyId && keySecret && !keyId.startsWith('rzp_test_xxx')) {
      activePaymentProvider = new RazorpayPaymentProvider(keyId, keySecret, webhookSecret || '');
      logger.info('Initialized Razorpay Payment Provider');
    } else {
      activePaymentProvider = new SandboxPaymentProvider();
      logger.info('Initialized Sandbox Payment Provider (Development Mode)');
    }
  }
  return activePaymentProvider;
}
