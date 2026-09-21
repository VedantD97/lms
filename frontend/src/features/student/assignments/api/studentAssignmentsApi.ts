import { apiGet, apiPost } from "@/lib/api/client";
import type { StudentAssignment, StudentAssignmentSubmission } from "@/lib/api/types/assignment";

const base = "/student";

export async function fetchEnrollmentAssignments(enrollmentUuid: string) {
  return apiGet<StudentAssignment[]>(`${base}/enrollments/${enrollmentUuid}/assignments`);
}

export async function fetchEnrollmentAssignment(enrollmentUuid: string, assignmentUuid: string) {
  return apiGet<StudentAssignment>(`${base}/enrollments/${enrollmentUuid}/assignments/${assignmentUuid}`);
}

export async function submitAssignment(enrollmentUuid: string, assignmentUuid: string, body: string) {
  return apiPost<StudentAssignmentSubmission>(
    `${base}/enrollments/${enrollmentUuid}/assignments/${assignmentUuid}/submit`,
    { submission: { body } },
  );
}
