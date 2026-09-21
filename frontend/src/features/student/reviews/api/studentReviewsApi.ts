import { apiDelete, apiGet, apiPatch, apiPost } from "@/lib/api/client";
import type { Review } from "@/lib/api/types/review";

const base = "/student";

export async function fetchCourseReviews(courseUuid: string, params?: Record<string, string | number | undefined>) {
  return apiGet<Review[]>(`${base}/courses/${courseUuid}/reviews`, params);
}

export async function createCourseReview(courseUuid: string, payload: { rating: number; body?: string }) {
  return apiPost<Review>(`${base}/courses/${courseUuid}/reviews`, { review: payload });
}

export async function updateReview(uuid: string, payload: { rating: number; body?: string }) {
  return apiPatch<Review>(`${base}/reviews/${uuid}`, { review: payload });
}

export async function deleteReview(uuid: string) {
  await apiDelete(`${base}/reviews/${uuid}`);
}
