import { apiGet, apiPost } from "@/lib/api/client";
import type { Course } from "@/lib/api/types/course";

const base = "/student";

export async function fetchStudentCourses(params?: Record<string, string | number | undefined>) {
  return apiGet<Course[]>(`${base}/courses`, params);
}

export async function fetchStudentCourse(uuid: string) {
  return apiGet<Course>(`${base}/courses/${uuid}`);
}

export async function enrollInCourse(uuid: string) {
  return apiPost<{ uuid: string; course_uuid: string }>(`${base}/courses/${uuid}/enroll`);
}

export async function fetchEnrollments() {
  return apiGet<Array<{ uuid: string; course_uuid: string; status: string }>>(`${base}/enrollments`);
}

export async function fetchCategories() {
  return apiGet<import("@/lib/api/types/course").Category[]>("/categories");
}
