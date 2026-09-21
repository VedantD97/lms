import { apiDelete, apiGet, apiPatch, apiPost, apiPostForm } from "@/lib/api/client";
import type { Course, CourseModule, Lesson, LessonResource } from "@/lib/api/types/course";

const base = "/instructor";

export async function fetchInstructorCourses(params?: Record<string, string | number | undefined>) {
  return apiGet<Course[]>(`${base}/courses`, params);
}

export async function fetchInstructorCourse(uuid: string) {
  return apiGet<Course>(`${base}/courses/${uuid}`);
}

export async function createInstructorCourse(payload: Partial<Course>) {
  return apiPost<Course>(`${base}/courses`, { course: payload });
}

export async function updateInstructorCourse(uuid: string, payload: Partial<Course>) {
  return apiPatch<Course>(`${base}/courses/${uuid}`, { course: payload });
}

export async function publishInstructorCourse(uuid: string) {
  return apiPost<Course>(`${base}/courses/${uuid}/publish`);
}

export async function unpublishInstructorCourse(uuid: string) {
  return apiPost<Course>(`${base}/courses/${uuid}/unpublish`);
}

export async function createModule(courseUuid: string, payload: Partial<CourseModule>) {
  return apiPost<CourseModule>(`${base}/courses/${courseUuid}/modules`, { module: payload });
}

export async function updateModule(uuid: string, payload: Partial<CourseModule>) {
  return apiPatch<CourseModule>(`${base}/modules/${uuid}`, { module: payload });
}

export async function deleteModule(uuid: string) {
  return apiDelete(`${base}/modules/${uuid}`);
}

export async function reorderModules(courseUuid: string, orderedUuids: string[]) {
  return apiPatch<CourseModule[]>(`${base}/courses/${courseUuid}/modules/reorder`, { ordered_uuids: orderedUuids });
}

export async function createLesson(moduleUuid: string, payload: Partial<Lesson>) {
  return apiPost<Lesson>(`${base}/modules/${moduleUuid}/lessons`, { lesson: payload });
}

export async function updateLesson(uuid: string, payload: Partial<Lesson>) {
  return apiPatch<Lesson>(`${base}/lessons/${uuid}`, { lesson: payload });
}

export async function deleteLesson(uuid: string) {
  return apiDelete(`${base}/lessons/${uuid}`);
}

export async function reorderLessons(moduleUuid: string, orderedUuids: string[]) {
  return apiPatch<Lesson[]>(`${base}/modules/${moduleUuid}/lessons/reorder`, { ordered_uuids: orderedUuids });
}

export async function createLessonResource(lessonUuid: string, payload: FormData) {
  return apiPostForm<LessonResource>(`${base}/lessons/${lessonUuid}/resources`, payload);
}

export async function deleteLessonResource(uuid: string) {
  return apiDelete(`${base}/resources/${uuid}`);
}

export type { LessonResource };
