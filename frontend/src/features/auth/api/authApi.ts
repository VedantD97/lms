import { apiDelete, apiGet, apiPost, setAccessToken } from "@/lib/api/client";
import type { AuthSession, User } from "@/lib/api/types/course";
import axios from "axios";
import type { ApiResponse } from "@/lib/api/client";

const apiBase = import.meta.env.VITE_API_URL ?? "/api/v1";

export async function loginRequest(email: string, password: string) {
  const response = await apiPost<AuthSession>("/auth/login", {
    auth: { email, password },
  });
  setAccessToken(response.data.access_token);
  return response.data;
}

export async function logoutRequest() {
  try {
    await apiDelete("/auth/logout");
  } finally {
    setAccessToken(null);
  }
}

export async function fetchCurrentUser() {
  const response = await apiGet<User>("/auth/me");
  return response.data;
}

/** Restore access token from the httpOnly refresh cookie (page load / session resume). */
export async function refreshSessionRequest(): Promise<AuthSession | null> {
  try {
    const response = await axios.post<ApiResponse<AuthSession>>(
      `${apiBase}/auth/refresh`,
      {},
      { withCredentials: true },
    );
    const session = response.data.data;
    setAccessToken(session.access_token);
    return session;
  } catch {
    setAccessToken(null);
    return null;
  }
}

export async function registerRequest(payload: {
  email: string;
  password: string;
  password_confirmation: string;
  first_name: string;
  last_name: string;
}) {
  return apiPost<User>("/auth/register", { user: payload });
}
