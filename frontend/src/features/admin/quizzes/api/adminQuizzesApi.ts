import { apiGet } from "@/lib/api/client";
import type { Quiz, QuizStatistics } from "@/lib/api/types/quiz";

const base = "/admin";

export async function fetchAdminQuizzes(params?: Record<string, string | number | undefined>) {
  return apiGet<Quiz[]>(`${base}/quizzes`, params);
}

export async function fetchAdminQuiz(uuid: string) {
  return apiGet<Quiz>(`${base}/quizzes/${uuid}`);
}

export async function fetchQuizStatistics(uuid: string) {
  return apiGet<QuizStatistics>(`${base}/quizzes/${uuid}/statistics`);
}
