import { apiDelete, apiGet, apiPatch, apiPost } from "@/lib/api/client";
import type { Category, Course, PaginationMeta, User } from "@/lib/api/types/course";

const base = "/admin";

export async function fetchAdminCourses(params?: Record<string, string | number | undefined>) {
  return apiGet<Course[]>(`${base}/courses`, params);
}

export async function fetchAdminCourse(uuid: string) {
  return apiGet<Course>(`${base}/courses/${uuid}`);
}

export async function createAdminCourse(payload: Partial<Course> & { category_uuids?: string[] }) {
  return apiPost<Course>(`${base}/courses`, { course: payload });
}

export async function updateAdminCourse(uuid: string, payload: Partial<Course> & { category_uuids?: string[] }) {
  return apiPatch<Course>(`${base}/courses/${uuid}`, { course: payload });
}

export async function archiveAdminCourse(uuid: string) {
  return apiPost<Course>(`${base}/courses/${uuid}/archive`);
}

export async function publishAdminCourse(uuid: string) {
  return apiPost<Course>(`${base}/courses/${uuid}/publish`);
}

export async function unpublishAdminCourse(uuid: string) {
  return apiPost<Course>(`${base}/courses/${uuid}/unpublish`);
}

export async function assignInstructor(uuid: string, userUuid: string, role = "lead") {
  return apiPost<Course>(`${base}/courses/${uuid}/instructors`, { user_uuid: userUuid, role });
}

export async function fetchAdminCategories() {
  return apiGet<Category[]>(`${base}/categories`);
}

export async function createAdminCategory(payload: Partial<Category>) {
  return apiPost<Category>(`${base}/categories`, { category: payload });
}

export async function updateAdminCategory(uuid: string, payload: Partial<Category>) {
  return apiPatch<Category>(`${base}/categories/${uuid}`, { category: payload });
}

export async function deleteAdminCategory(uuid: string) {
  return apiDelete(`${base}/categories/${uuid}`);
}

export async function fetchAdminUsers(role?: string) {
  return apiGet<User[]>(`${base}/users`, role ? { role } : undefined);
}

export type ListResponse<T> = { data: T; meta?: PaginationMeta };
