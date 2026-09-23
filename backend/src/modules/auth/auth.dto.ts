import { z } from 'zod';

// ─────────────────────────────────────────────────────────────────────────────
// Auth Module DTOs (Data Transfer Objects with Zod validation)
// ─────────────────────────────────────────────────────────────────────────────

export const RegisterDto = z
  .object({
    firstName: z.string().min(1).max(50).optional().default('Farmer'),
    lastName: z.string().max(50).optional().default('Grower'),
    email: z.string().email().optional(),
    phone: z.string().regex(/^\+?[0-9\s-]{10,15}$/, 'Invalid phone number'),
    password: z.string().min(4).optional(),
    pin: z.string().regex(/^\d{6}$/, 'PIN must be 6 digits').optional(),
    role: z.enum(['owner', 'customer', 'manager', 'staff']).default('customer'),
    tenantSlug: z.string().optional(),
    nurseryName: z.string().optional(),
  })
  .refine((data) => data.password || data.pin, {
    message: 'Password or 6-digit PIN is required',
    path: ['pin'],
  });

export const LoginDto = z
  .object({
    email: z.string().email().optional(),
    phone: z.string().optional(),
    password: z.string().min(1).optional(),
    pin: z.string().min(4).max(6).optional(),
    mfaCode: z.string().length(6).optional(),
  })
  .refine((data) => data.email || data.phone, {
    message: 'Either email or mobile number is required',
    path: ['phone'],
  })
  .refine((data) => data.password || data.pin, {
    message: 'Password or 6-digit PIN is required',
    path: ['pin'],
  });

export const RefreshTokenDto = z.object({
  refreshToken: z.string().min(1),
});

export const ForgotPasswordDto = z.object({
  email: z.string().email().optional(),
  phone: z.string().optional(),
});

export const ResetPasswordDto = z.object({
  token: z.string().min(1),
  newPassword: z.string().min(6),
});

export const VerifyOtpDto = z.object({
  phone: z.string(),
  otp: z.string().length(6),
});

export const ChangePasswordDto = z.object({
  currentPassword: z.string().min(1),
  newPassword: z.string().min(6),
});

export type RegisterDtoType = z.infer<typeof RegisterDto>;
export type LoginDtoType = z.infer<typeof LoginDto>;
export type RefreshTokenDtoType = z.infer<typeof RefreshTokenDto>;
export type ForgotPasswordDtoType = z.infer<typeof ForgotPasswordDto>;
export type ResetPasswordDtoType = z.infer<typeof ResetPasswordDto>;
export type VerifyOtpDtoType = z.infer<typeof VerifyOtpDto>;
