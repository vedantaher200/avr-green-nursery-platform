// ─────────────────────────────────────────────────────────────────────────────
// Unified API Response Envelope
// ─────────────────────────────────────────────────────────────────────────────

export interface ApiResponse<T = unknown> {
  success: boolean;
  data?: T;
  error?: string;
  message?: string;
  meta?: PaginationMeta;
}

export interface PaginationMeta {
  page: number;
  limit: number;
  total: number;
  totalPages: number;
  hasNext: boolean;
  hasPrev: boolean;
}

export function successResponse<T>(
  data: T,
  message?: string,
  meta?: PaginationMeta
): ApiResponse<T> {
  return { success: true, data, message, meta };
}

export function errorResponse(error: string, message?: string): ApiResponse {
  return { success: false, error, message };
}

export function paginationMeta(
  total: number,
  page: number,
  limit: number
): PaginationMeta {
  const totalPages = Math.ceil(total / limit);
  return {
    page,
    limit,
    total,
    totalPages,
    hasNext: page < totalPages,
    hasPrev: page > 1,
  };
}
