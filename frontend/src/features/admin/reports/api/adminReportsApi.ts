import { apiGet } from "@/lib/api/client";
import type { CourseCompletionRow, DashboardSummary, EnrollmentsReport } from "@/lib/api/types/report";

const base = "/admin/reports";

export async function fetchDashboardSummary() {
  return apiGet<DashboardSummary>(`${base}/dashboard`);
}

export async function fetchEnrollmentsReport(params?: Record<string, string | number | undefined>) {
  return apiGet<EnrollmentsReport>(`${base}/enrollments`, params);
}

export async function fetchCourseCompletionReport() {
  return apiGet<CourseCompletionRow[]>(`${base}/course_completion`);
}
