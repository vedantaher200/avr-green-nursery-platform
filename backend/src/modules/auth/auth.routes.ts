import { Router } from 'express';
import { authController } from './auth.controller';
import { authenticate } from '../../middlewares/auth.middleware';
import { validate } from '../../middlewares/validate.middleware';
import {
  RegisterDto,
  LoginDto,
  RefreshTokenDto,
  VerifyOtpDto,
} from './auth.dto';
import rateLimit from 'express-rate-limit';
import { config } from '../../config';

// ─────────────────────────────────────────────────────────────────────────────
// Strict rate limiter for auth endpoints (5 req / min per IP)
// ─────────────────────────────────────────────────────────────────────────────
const authLimiter = rateLimit({
  windowMs: config.rateLimit.windowMs,
  max: config.rateLimit.authMax,
  message: { success: false, error: 'Too many requests, please try again later' },
  standardHeaders: true,
  legacyHeaders: false,
});

const router = Router();

// Public routes
router.post('/register', authLimiter, validate({ body: RegisterDto }), authController.register);
router.post('/login',    authLimiter, validate({ body: LoginDto }),    authController.login);
router.post('/refresh',              validate({ body: RefreshTokenDto }), authController.refresh);
router.post('/otp/send',   authLimiter, authController.sendOtp);
router.post('/otp/verify', authLimiter, validate({ body: VerifyOtpDto }), authController.verifyOtp);

// Protected routes
router.post('/logout', authenticate, authController.logout);
router.get('/me',      authenticate, authController.me);

export default router;
