import { apiGet } from "@/lib/api/client";
import type {
  InstructorDashboardSummary,
  InstructorEnrollment,
  InstructorPendingSubmission,
} from "@/lib/api/types/instructorDashboard";

const base = "/instructor";

export async function fetchInstructorDashboard() {
  return apiGet<InstructorDashboardSummary>(`${base}/dashboard`);
}

export async function fetchCourseEnrollments(courseUuid: string, params?: Record<string, string | number | undefined>) {
  return apiGet<InstructorEnrollment[]>(`${base}/courses/${courseUuid}/enrollments`, params);
}

export async function fetchEnrollmentProgress(enrollmentUuid: string) {
  return apiGet<InstructorEnrollment>(`${base}/enrollments/${enrollmentUuid}/progress`);
}

export async function fetchPendingSubmissions(params?: Record<string, string | number | undefined>) {
  return apiGet<InstructorPendingSubmission[]>(`${base}/submissions/pending`, params);
}
