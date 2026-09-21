import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  completeLesson,
  downloadLessonResource,
  fetchStudentEnrollment,
  fetchStudentEnrollments,
  fetchStudentLesson,
  updateLessonProgress,
} from "@/features/student/learning/api/studentLearningApi";

export function useStudentEnrollments(params?: Record<string, string | number | undefined>) {
  return useQuery({
    queryKey: ["student", "enrollments", params],
    queryFn: () => fetchStudentEnrollments(params),
  });
}

export function useStudentEnrollment(uuid: string) {
  return useQuery({
    queryKey: ["student", "enrollments", uuid],
    queryFn: async () => (await fetchStudentEnrollment(uuid)).data,
    enabled: Boolean(uuid),
  });
}

export function useStudentLesson(enrollmentUuid: string, lessonUuid: string) {
  return useQuery({
    queryKey: ["student", "enrollments", enrollmentUuid, "lessons", lessonUuid],
    queryFn: async () => (await fetchStudentLesson(enrollmentUuid, lessonUuid)).data,
    enabled: Boolean(enrollmentUuid && lessonUuid),
  });
}

export function useUpdateLessonProgress(enrollmentUuid: string, lessonUuid: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (payload: { progress_percent: number; last_position_seconds?: number }) =>
      updateLessonProgress(enrollmentUuid, lessonUuid, payload),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["student", "enrollments", enrollmentUuid, "lessons", lessonUuid] });
      queryClient.invalidateQueries({ queryKey: ["student", "enrollments"] });
    },
  });
}

export function useCompleteLesson(enrollmentUuid: string, lessonUuid: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: () => completeLesson(enrollmentUuid, lessonUuid),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["student"] });
    },
  });
}

export function useDownloadLessonResource() {
  return useMutation({
    mutationFn: ({
      enrollmentUuid,
      resource,
    }: {
      enrollmentUuid: string;
      resource: { uuid: string; title: string; resource_type: string };
    }) => downloadLessonResource(enrollmentUuid, resource),
  });
}
