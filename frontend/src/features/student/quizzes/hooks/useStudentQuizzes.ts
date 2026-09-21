import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  fetchEnrollmentQuiz,
  fetchEnrollmentQuizzes,
  fetchQuizAttempt,
  fetchQuizAttemptResults,
  saveQuizResponses,
  startQuizAttempt,
  submitQuizAttempt,
} from "@/features/student/quizzes/api/studentQuizzesApi";

export function useEnrollmentQuizzes(enrollmentUuid: string) {
  return useQuery({
    queryKey: ["student", "enrollments", enrollmentUuid, "quizzes"],
    queryFn: async () => (await fetchEnrollmentQuizzes(enrollmentUuid)).data,
    enabled: Boolean(enrollmentUuid),
  });
}

export function useEnrollmentQuiz(enrollmentUuid: string, quizUuid: string) {
  return useQuery({
    queryKey: ["student", "enrollments", enrollmentUuid, "quizzes", quizUuid],
    queryFn: async () => (await fetchEnrollmentQuiz(enrollmentUuid, quizUuid)).data,
    enabled: Boolean(enrollmentUuid && quizUuid),
  });
}

export function useQuizAttempt(uuid: string) {
  return useQuery({
    queryKey: ["student", "quiz_attempts", uuid],
    queryFn: async () => (await fetchQuizAttempt(uuid)).data,
    enabled: Boolean(uuid),
  });
}

export function useQuizAttemptResults(uuid: string) {
  return useQuery({
    queryKey: ["student", "quiz_attempts", uuid, "results"],
    queryFn: async () => (await fetchQuizAttemptResults(uuid)).data,
    enabled: Boolean(uuid),
  });
}

export function useStartQuizAttempt() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ enrollmentUuid, quizUuid }: { enrollmentUuid: string; quizUuid: string }) =>
      startQuizAttempt(enrollmentUuid, quizUuid),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["student"] }),
  });
}

export function useSaveQuizResponses(attemptUuid: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (responses: Array<{ question_uuid: string; selected_option_uuids: string[] }>) =>
      saveQuizResponses(attemptUuid, responses),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["student", "quiz_attempts", attemptUuid] }),
  });
}

export function useSubmitQuizAttempt() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({
      attemptUuid,
      responses,
    }: {
      attemptUuid: string;
      responses?: Array<{ question_uuid: string; selected_option_uuids: string[] }>;
    }) => submitQuizAttempt(attemptUuid, responses),
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: ["student", "quiz_attempts", variables.attemptUuid] });
      queryClient.invalidateQueries({ queryKey: ["student"] });
    },
  });
}
