import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  fetchEnrollmentAssignment,
  fetchEnrollmentAssignments,
  submitAssignment,
} from "@/features/student/assignments/api/studentAssignmentsApi";

export function useEnrollmentAssignments(enrollmentUuid: string) {
  return useQuery({
    queryKey: ["student", "enrollments", enrollmentUuid, "assignments"],
    queryFn: async () => (await fetchEnrollmentAssignments(enrollmentUuid)).data,
    enabled: Boolean(enrollmentUuid),
  });
}

export function useEnrollmentAssignment(enrollmentUuid: string, assignmentUuid: string) {
  return useQuery({
    queryKey: ["student", "enrollments", enrollmentUuid, "assignments", assignmentUuid],
    queryFn: async () => (await fetchEnrollmentAssignment(enrollmentUuid, assignmentUuid)).data,
    enabled: Boolean(enrollmentUuid && assignmentUuid),
  });
}

export function useSubmitAssignment(enrollmentUuid: string, assignmentUuid: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (body: string) => submitAssignment(enrollmentUuid, assignmentUuid, body),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["student", "enrollments", enrollmentUuid, "assignments"] });
      queryClient.invalidateQueries({ queryKey: ["student", "enrollments"] });
    },
  });
}
