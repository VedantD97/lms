import { apiGet } from "@/lib/api/client";
import type { StudentDashboardSummary } from "@/lib/api/types/studentDashboard";

const base = "/student";

export async function fetchStudentDashboard() {
  return apiGet<StudentDashboardSummary>(`${base}/dashboard`);
}
