import { apiDownload, apiGet, apiPatch, apiPost } from "@/lib/api/client";
import type { LessonProgress, ResourceDownloadResponse, StudentEnrollment, StudentLessonDetail } from "@/lib/api/types/learning";

const base = "/student";

export async function fetchStudentEnrollments(params?: Record<string, string | number | undefined>) {
  return apiGet<StudentEnrollment[]>(`${base}/enrollments`, params);
}

export async function fetchStudentEnrollment(uuid: string) {
  return apiGet<StudentEnrollment & { lesson_progress?: LessonProgress[] }>(`${base}/enrollments/${uuid}`);
}

export async function fetchStudentLesson(enrollmentUuid: string, lessonUuid: string) {
  return apiGet<StudentLessonDetail>(`${base}/enrollments/${enrollmentUuid}/lessons/${lessonUuid}`);
}

export async function updateLessonProgress(
  enrollmentUuid: string,
  lessonUuid: string,
  payload: { progress_percent: number; last_position_seconds?: number },
) {
  return apiPatch<LessonProgress>(`${base}/enrollments/${enrollmentUuid}/lessons/${lessonUuid}/progress`, {
    progress: payload,
  });
}

export async function completeLesson(enrollmentUuid: string, lessonUuid: string) {
  return apiPost<LessonProgress>(`${base}/enrollments/${enrollmentUuid}/lessons/${lessonUuid}/complete`);
}

export async function downloadLessonResource(
  enrollmentUuid: string,
  resource: { uuid: string; title: string; resource_type: string },
) {
  if (resource.resource_type === "link") {
    const response = await apiGet<ResourceDownloadResponse>(
      `${base}/enrollments/${enrollmentUuid}/resources/${resource.uuid}/download`,
    );
    if (response.data.external_url) {
      window.open(response.data.external_url, "_blank", "noopener,noreferrer");
    }
    return;
  }

  await apiDownload(`${base}/enrollments/${enrollmentUuid}/resources/${resource.uuid}/download`, resource.title);
}
