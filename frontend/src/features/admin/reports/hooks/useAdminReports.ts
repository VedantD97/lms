import { useAdminQuery } from "@/lib/auth/useAdminQuery";
import {
  fetchCourseCompletionReport,
  fetchDashboardSummary,
  fetchEnrollmentsReport,
} from "@/features/admin/reports/api/adminReportsApi";

export function useDashboardSummary() {
  return useAdminQuery(["admin", "reports", "dashboard"], async () => (await fetchDashboardSummary()).data);
}

export function useEnrollmentsReport(params?: Record<string, string | number | undefined>) {
  return useAdminQuery(
    ["admin", "reports", "enrollments", params],
    async () => (await fetchEnrollmentsReport(params)).data,
  );
}

export function useCourseCompletionReport() {
  return useAdminQuery(
    ["admin", "reports", "course_completion"],
    async () => (await fetchCourseCompletionReport()).data,
  );
}
