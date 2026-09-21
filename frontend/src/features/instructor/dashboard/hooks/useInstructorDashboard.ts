import { useQuery } from "@tanstack/react-query";
import {
  fetchCourseEnrollments,
  fetchEnrollmentProgress,
  fetchInstructorDashboard,
  fetchPendingSubmissions,
} from "@/features/instructor/dashboard/api/instructorDashboardApi";

export function useInstructorDashboard() {
  return useQuery({
    queryKey: ["instructor", "dashboard"],
    queryFn: async () => (await fetchInstructorDashboard()).data,
  });
}

export function useCourseEnrollments(courseUuid: string, params?: Record<string, string | number | undefined>) {
  return useQuery({
    queryKey: ["instructor", "courses", courseUuid, "enrollments", params],
    queryFn: () => fetchCourseEnrollments(courseUuid, params),
    enabled: Boolean(courseUuid),
  });
}

export function useEnrollmentProgress(enrollmentUuid: string) {
  return useQuery({
    queryKey: ["instructor", "enrollments", enrollmentUuid, "progress"],
    queryFn: async () => (await fetchEnrollmentProgress(enrollmentUuid)).data,
    enabled: Boolean(enrollmentUuid),
  });
}

export function usePendingSubmissions(params?: Record<string, string | number | undefined>) {
  return useQuery({
    queryKey: ["instructor", "submissions", "pending", params],
    queryFn: () => fetchPendingSubmissions(params),
  });
}
