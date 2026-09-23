import { Request, Response } from 'express';
import { authService } from './auth.service';
import { asyncHandler } from '../../middlewares/error.middleware';
import { successResponse } from '../../shared/response';
import type {
  LoginDtoType,
  RegisterDtoType,
  RefreshTokenDtoType,
  VerifyOtpDtoType,
} from './auth.dto';

// ─────────────────────────────────────────────────────────────────────────────
// Auth Controller — HTTP layer only; all business logic lives in auth.service
// ─────────────────────────────────────────────────────────────────────────────

export const authController = {
  /**
   * POST /api/v1/auth/register
   * Body: RegisterDto
   */
  register: asyncHandler(async (req: Request, res: Response) => {
    const dto = req.body as RegisterDtoType;
    const result = await authService.register(dto);
    res.status(201).json(
      successResponse(result, 'Account created successfully. Check your phone for OTP.')
    );
  }),

  /**
   * POST /api/v1/auth/login
   * Body: LoginDto
   */
  login: asyncHandler(async (req: Request, res: Response) => {
    const dto = req.body as LoginDtoType;
    const deviceInfo = {
      userAgent: req.headers['user-agent'] ?? 'unknown',
      ip: req.ip,
    };
    const result = await authService.login(dto, deviceInfo);

    if ((result as any).requiresMfa) {
      res.status(200).json(
        successResponse({ requiresMfa: true }, 'Enter your MFA code to continue')
      );
      return;
    }

    res.status(200).json(
      successResponse(result, 'Login successful')
    );
  }),

  /**
   * POST /api/v1/auth/refresh
   * Body: RefreshTokenDto
   */
  refresh: asyncHandler(async (req: Request, res: Response) => {
    const dto = req.body as RefreshTokenDtoType;
    const deviceInfo = {
      userAgent: req.headers['user-agent'] ?? 'unknown',
      ip: req.ip,
    };
    const tokens = await authService.refreshToken(dto, deviceInfo);
    res.status(200).json(successResponse(tokens, 'Token refreshed'));
  }),

  /**
   * POST /api/v1/auth/logout
   * Header: Authorization Bearer <accessToken>
   * Body: { refreshToken: string }
   */
  logout: asyncHandler(async (req: Request, res: Response) => {
    const { refreshToken } = req.body;
    const { userId, jti } = req.user!;
    await authService.logout(userId, refreshToken, jti);
    res.status(200).json(successResponse(null, 'Logged out successfully'));
  }),

  /**
   * POST /api/v1/auth/otp/send
   * Body: { phone: string }
   */
  sendOtp: asyncHandler(async (req: Request, res: Response) => {
    const { phone } = req.body;
    const otp = await authService.sendOtp(phone);
    const response: Record<string, unknown> = { message: 'OTP sent to your phone' };
    // Only expose OTP in dev mode
    if (process.env.NODE_ENV === 'development') response.otp = otp;
    res.status(200).json(successResponse(response));
  }),

  /**
   * POST /api/v1/auth/otp/verify
   * Body: VerifyOtpDto
   */
  verifyOtp: asyncHandler(async (req: Request, res: Response) => {
    const dto = req.body as VerifyOtpDtoType;
    const isValid = await authService.verifyOtp(dto.phone, dto.otp);
    if (!isValid) {
      res.status(400).json({ success: false, error: 'Invalid or expired OTP' });
      return;
    }
    res.status(200).json(successResponse({ verified: true }, 'Phone verified'));
  }),

  /**
   * GET /api/v1/auth/me
   * Header: Authorization Bearer <accessToken>
   */
  me: asyncHandler(async (req: Request, res: Response) => {
    const { userId, roleName, tenantId } = req.user!;
    res.status(200).json(
      successResponse({ userId, roleName, tenantId }, 'Authenticated user context')
    );
  }),
};
