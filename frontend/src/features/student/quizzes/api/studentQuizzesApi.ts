import { apiGet, apiPatch, apiPost } from "@/lib/api/client";
import type { QuizAttempt, QuizAttemptResult, StudentQuiz } from "@/lib/api/types/quiz";

const base = "/student";

export async function fetchEnrollmentQuizzes(enrollmentUuid: string) {
  return apiGet<StudentQuiz[]>(`${base}/enrollments/${enrollmentUuid}/quizzes`);
}

export async function fetchEnrollmentQuiz(enrollmentUuid: string, quizUuid: string) {
  return apiGet<StudentQuiz>(`${base}/enrollments/${enrollmentUuid}/quizzes/${quizUuid}`);
}

export async function startQuizAttempt(enrollmentUuid: string, quizUuid: string) {
  return apiPost<QuizAttempt>(`${base}/enrollments/${enrollmentUuid}/quizzes/${quizUuid}/start`);
}

export async function fetchQuizAttempt(uuid: string) {
  return apiGet<QuizAttempt>(`${base}/quiz_attempts/${uuid}`);
}

export async function saveQuizResponses(uuid: string, responses: Array<{ question_uuid: string; selected_option_uuids: string[] }>) {
  return apiPatch<QuizAttempt>(`${base}/quiz_attempts/${uuid}/responses`, { responses });
}

export async function submitQuizAttempt(uuid: string, responses?: Array<{ question_uuid: string; selected_option_uuids: string[] }>) {
  return apiPost<QuizAttemptResult>(`${base}/quiz_attempts/${uuid}/submit`, responses ? { responses } : undefined);
}

export async function fetchQuizAttemptResults(uuid: string) {
  return apiGet<QuizAttemptResult>(`${base}/quiz_attempts/${uuid}/results`);
}
