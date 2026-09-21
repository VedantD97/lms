import axios, { type AxiosRequestConfig } from "axios";
import { ApiRequestError, type ApiError } from "./errors";
import type { AuthSession } from "@/lib/api/types/course";

export interface PaginationMeta {
  page: number;
  per_page: number;
  total: number;
}

export interface ApiResponse<T> {
  data: T;
  meta?: PaginationMeta & Record<string, unknown>;
}

const api = axios.create({
  baseURL: import.meta.env.VITE_API_URL ?? "/api/v1",
  withCredentials: true,
  headers: {
    "Content-Type": "application/json",
  },
});

let accessToken: string | null = null;
let refreshPromise: Promise<string | null> | null = null;

export function setAccessToken(token: string | null) {
  accessToken = token;
}

export function getAccessToken() {
  return accessToken;
}

async function refreshAccessToken(): Promise<string | null> {
  if (!refreshPromise) {
    refreshPromise = axios
      .post<ApiResponse<AuthSession>>(
        `${import.meta.env.VITE_API_URL ?? "/api/v1"}/auth/refresh`,
        {},
        { withCredentials: true },
      )
      .then((refreshResponse) => {
        const token = refreshResponse.data.data.access_token;
        setAccessToken(token);
        return token;
      })
      .catch(() => {
        setAccessToken(null);
        return null;
      })
      .finally(() => {
        refreshPromise = null;
      });
  }

  return refreshPromise;
}

api.interceptors.request.use((config) => {
  if (accessToken) {
    config.headers.Authorization = `Bearer ${accessToken}`;
  }
  return config;
});

api.interceptors.response.use(
  (response) => response,
  async (error) => {
    const originalRequest = error.config as AxiosRequestConfig & { _retry?: boolean };

    if (error.response?.status === 401 && !originalRequest._retry) {
      originalRequest._retry = true;
      const token = await refreshAccessToken();
      if (token) {
        return api(originalRequest);
      }
    }

    if (error.response?.data?.error) {
      throw new ApiRequestError(error.response.status, error.response.data.error as ApiError);
    }

    throw error;
  },
);

export async function apiGet<T>(url: string, params?: Record<string, unknown>) {
  const response = await api.get<ApiResponse<T>>(url, { params });
  return response.data;
}

export async function apiPost<T>(url: string, body?: unknown) {
  const response = await api.post<ApiResponse<T>>(url, body);
  return response.data;
}

export async function apiPatch<T>(url: string, body?: unknown) {
  const response = await api.patch<ApiResponse<T>>(url, body);
  return response.data;
}

export async function apiDelete(url: string) {
  await api.delete(url);
}

export async function apiPostForm<T>(url: string, body: FormData) {
  const response = await api.post<ApiResponse<T>>(url, body, {
    headers: { "Content-Type": "multipart/form-data" },
  });
  return response.data;
}

export async function apiDownload(url: string, filename: string) {
  const response = await api.get(url, { responseType: "blob" });
  const blobUrl = window.URL.createObjectURL(response.data);
  const link = document.createElement("a");
  link.href = blobUrl;
  link.download = filename;
  link.click();
  window.URL.revokeObjectURL(blobUrl);
}
