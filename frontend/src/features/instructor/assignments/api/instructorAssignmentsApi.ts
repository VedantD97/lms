import { apiGet, apiPatch, apiPost } from "@/lib/api/client";
import type { Assignment, AssignmentSubmission } from "@/lib/api/types/assignment";

const base = "/instructor";

export async function fetchLessonAssignments(lessonUuid: string) {
  return apiGet<Assignment[]>(`${base}/lessons/${lessonUuid}/assignments`);
}

export async function fetchInstructorAssignment(uuid: string) {
  return apiGet<Assignment>(`${base}/assignments/${uuid}`);
}

export async function createLessonAssignment(lessonUuid: string, payload: Partial<Assignment>) {
  return apiPost<Assignment>(`${base}/lessons/${lessonUuid}/assignments`, { assignment: payload });
}

export async function updateInstructorAssignment(uuid: string, payload: Partial<Assignment>) {
  return apiPatch<Assignment>(`${base}/assignments/${uuid}`, { assignment: payload });
}

export async function publishInstructorAssignment(uuid: string) {
  return apiPost<Assignment>(`${base}/assignments/${uuid}/publish`);
}

export async function unpublishInstructorAssignment(uuid: string) {
  return apiPost<Assignment>(`${base}/assignments/${uuid}/unpublish`);
}

export async function fetchAssignmentSubmissions(uuid: string, params?: Record<string, string | number | undefined>) {
  return apiGet<AssignmentSubmission[]>(`${base}/assignments/${uuid}/submissions`, params);
}

export async function gradeSubmission(uuid: string, payload: { points: number; feedback?: string }) {
  return apiPatch<AssignmentSubmission>(`${base}/submissions/${uuid}/grade`, { grade: payload });
}
