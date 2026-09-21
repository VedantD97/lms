import { apiDelete, apiGet, apiPatch, apiPost } from "@/lib/api/client";
import type { Question, QuestionOption, Quiz, QuizAttempt } from "@/lib/api/types/quiz";

const base = "/instructor";

export async function fetchLessonQuizzes(lessonUuid: string) {
  return apiGet<Quiz[]>(`${base}/lessons/${lessonUuid}/quizzes`);
}

export async function fetchCourseQuizzes(courseUuid: string) {
  return apiGet<Quiz[]>(`${base}/courses/${courseUuid}/quizzes`);
}

export async function fetchInstructorQuiz(uuid: string) {
  return apiGet<Quiz>(`${base}/quizzes/${uuid}`);
}

export async function createLessonQuiz(lessonUuid: string, payload: Partial<Quiz>) {
  return apiPost<Quiz>(`${base}/lessons/${lessonUuid}/quizzes`, { quiz: payload });
}

export async function updateInstructorQuiz(uuid: string, payload: Partial<Quiz>) {
  return apiPatch<Quiz>(`${base}/quizzes/${uuid}`, { quiz: payload });
}

export async function deleteInstructorQuiz(uuid: string) {
  return apiDelete(`${base}/quizzes/${uuid}`);
}

export async function publishInstructorQuiz(uuid: string) {
  return apiPost<Quiz>(`${base}/quizzes/${uuid}/publish`);
}

export async function unpublishInstructorQuiz(uuid: string) {
  return apiPost<Quiz>(`${base}/quizzes/${uuid}/unpublish`);
}

export async function fetchQuizAttempts(uuid: string, params?: Record<string, string | number | undefined>) {
  return apiGet<QuizAttempt[]>(`${base}/quizzes/${uuid}/attempts`, params);
}

export async function createQuestion(quizUuid: string, payload: Partial<Question>) {
  return apiPost<Question>(`${base}/quizzes/${quizUuid}/questions`, { question: payload });
}

export async function updateQuestion(uuid: string, payload: Partial<Question>) {
  return apiPatch<Question>(`${base}/questions/${uuid}`, { question: payload });
}

export async function deleteQuestion(uuid: string) {
  return apiDelete(`${base}/questions/${uuid}`);
}

export async function reorderQuestions(quizUuid: string, orderedUuids: string[]) {
  return apiPatch<Question[]>(`${base}/quizzes/${quizUuid}/questions/reorder`, { ordered_uuids: orderedUuids });
}

export async function createQuestionOption(questionUuid: string, payload: Partial<QuestionOption>) {
  return apiPost<QuestionOption>(`${base}/questions/${questionUuid}/options`, { option: payload });
}

export async function updateQuestionOption(uuid: string, payload: Partial<QuestionOption>) {
  return apiPatch<QuestionOption>(`${base}/options/${uuid}`, { option: payload });
}

export async function deleteQuestionOption(uuid: string) {
  return apiDelete(`${base}/options/${uuid}`);
}
