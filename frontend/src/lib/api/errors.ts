export interface ApiErrorDetail {
  field: string;
  message: string;
}

export interface ApiError {
  code: string;
  message: string;
  details?: ApiErrorDetail[];
}

export class ApiRequestError extends Error {
  status: number;
  error: ApiError;

  constructor(status: number, error: ApiError) {
    super(error.message);
    this.status = status;
    this.error = error;
  }
}

export function getErrorMessage(error: unknown): string {
  if (error instanceof ApiRequestError) {
    if (error.error.code === "rate_limit_exceeded") {
      return "Too many attempts. Please wait a few minutes and try again.";
    }
    return error.error.details?.[0]?.message ?? error.message;
  }
  if (error instanceof Error) {
    return error.message;
  }
  return "Something went wrong";
}
