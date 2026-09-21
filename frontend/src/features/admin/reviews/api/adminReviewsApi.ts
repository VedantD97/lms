import { apiDelete, apiGet } from "@/lib/api/client";
import type { Review } from "@/lib/api/types/review";

const base = "/admin";

export async function fetchAdminReviews(params?: Record<string, string | number | undefined>) {
  return apiGet<Review[]>(`${base}/reviews`, params);
}

export async function deleteAdminReview(uuid: string) {
  await apiDelete(`${base}/reviews/${uuid}`);
}
