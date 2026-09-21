import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  createLessonAssignment,
  fetchAssignmentSubmissions,
  fetchInstructorAssignment,
  gradeSubmission,
  publishInstructorAssignment,
  unpublishInstructorAssignment,
  updateInstructorAssignment,
} from "@/features/instructor/assignments/api/instructorAssignmentsApi";

export function useInstructorAssignment(uuid: string) {
  return useQuery({
    queryKey: ["instructor", "assignments", uuid],
    queryFn: async () => (await fetchInstructorAssignment(uuid)).data,
    enabled: Boolean(uuid),
  });
}

export function useAssignmentSubmissions(assignmentUuid: string) {
  return useQuery({
    queryKey: ["instructor", "assignments", assignmentUuid, "submissions"],
    queryFn: () => fetchAssignmentSubmissions(assignmentUuid),
    enabled: Boolean(assignmentUuid),
  });
}

export function useUpdateInstructorAssignment(uuid: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (payload: Parameters<typeof updateInstructorAssignment>[1]) => updateInstructorAssignment(uuid, payload),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["instructor", "assignments", uuid] }),
  });
}

export function usePublishInstructorAssignment() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: publishInstructorAssignment,
    onSuccess: (_, uuid) => queryClient.invalidateQueries({ queryKey: ["instructor", "assignments", uuid] }),
  });
}

export function useUnpublishInstructorAssignment() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: unpublishInstructorAssignment,
    onSuccess: (_, uuid) => queryClient.invalidateQueries({ queryKey: ["instructor", "assignments", uuid] }),
  });
}

export function useGradeSubmission(assignmentUuid: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ submissionUuid, points, feedback }: { submissionUuid: string; points: number; feedback?: string }) =>
      gradeSubmission(submissionUuid, { points, feedback }),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["instructor", "assignments", assignmentUuid, "submissions"] });
      queryClient.invalidateQueries({ queryKey: ["student"] });
    },
  });
}

export { createLessonAssignment };
