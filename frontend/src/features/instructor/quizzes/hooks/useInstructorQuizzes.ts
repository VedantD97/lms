import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  createLessonQuiz,
  createQuestion,
  createQuestionOption,
  deleteInstructorQuiz,
  deleteQuestion,
  deleteQuestionOption,
  fetchInstructorQuiz,
  fetchLessonQuizzes,
  fetchQuizAttempts,
  publishInstructorQuiz,
  reorderQuestions,
  unpublishInstructorQuiz,
  updateInstructorQuiz,
  updateQuestion,
  updateQuestionOption,
} from "@/features/instructor/quizzes/api/instructorQuizzesApi";

export function useLessonQuizzes(lessonUuid: string) {
  return useQuery({
    queryKey: ["instructor", "lessons", lessonUuid, "quizzes"],
    queryFn: async () => (await fetchLessonQuizzes(lessonUuid)).data,
    enabled: Boolean(lessonUuid),
  });
}

export function useInstructorQuiz(uuid: string) {
  return useQuery({
    queryKey: ["instructor", "quizzes", uuid],
    queryFn: async () => (await fetchInstructorQuiz(uuid)).data,
    enabled: Boolean(uuid),
  });
}

export function useQuizAttempts(quizUuid: string) {
  return useQuery({
    queryKey: ["instructor", "quizzes", quizUuid, "attempts"],
    queryFn: () => fetchQuizAttempts(quizUuid),
    enabled: Boolean(quizUuid),
  });
}

export function useCreateLessonQuiz(lessonUuid: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (payload: Parameters<typeof createLessonQuiz>[1]) => createLessonQuiz(lessonUuid, payload),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["instructor", "lessons", lessonUuid, "quizzes"] }),
  });
}

export function useUpdateInstructorQuiz(uuid: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (payload: Parameters<typeof updateInstructorQuiz>[1]) => updateInstructorQuiz(uuid, payload),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["instructor", "quizzes", uuid] }),
  });
}

export function useDeleteInstructorQuiz() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: deleteInstructorQuiz,
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["instructor"] }),
  });
}

export function usePublishInstructorQuiz() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: publishInstructorQuiz,
    onSuccess: (_, uuid) => queryClient.invalidateQueries({ queryKey: ["instructor", "quizzes", uuid] }),
  });
}

export function useUnpublishInstructorQuiz() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: unpublishInstructorQuiz,
    onSuccess: (_, uuid) => queryClient.invalidateQueries({ queryKey: ["instructor", "quizzes", uuid] }),
  });
}

export function useCreateQuestion(quizUuid: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (payload: Parameters<typeof createQuestion>[1]) => createQuestion(quizUuid, payload),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["instructor", "quizzes", quizUuid] }),
  });
}

export function useUpdateQuestion(quizUuid: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ uuid, payload }: { uuid: string; payload: Parameters<typeof updateQuestion>[1] }) =>
      updateQuestion(uuid, payload),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["instructor", "quizzes", quizUuid] }),
  });
}

export function useDeleteQuestion(quizUuid: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: deleteQuestion,
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["instructor", "quizzes", quizUuid] }),
  });
}

export function useReorderQuestions(quizUuid: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (orderedUuids: string[]) => reorderQuestions(quizUuid, orderedUuids),
    onSettled: () => queryClient.invalidateQueries({ queryKey: ["instructor", "quizzes", quizUuid] }),
  });
}

export function useCreateQuestionOption(quizUuid: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ questionUuid, payload }: { questionUuid: string; payload: Parameters<typeof createQuestionOption>[1] }) =>
      createQuestionOption(questionUuid, payload),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["instructor", "quizzes", quizUuid] }),
  });
}

export function useUpdateQuestionOption(quizUuid: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ uuid, payload }: { uuid: string; payload: Parameters<typeof updateQuestionOption>[1] }) =>
      updateQuestionOption(uuid, payload),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["instructor", "quizzes", quizUuid] }),
  });
}

export function useDeleteQuestionOption(quizUuid: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: deleteQuestionOption,
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["instructor", "quizzes", quizUuid] }),
  });
}
