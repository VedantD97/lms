import { apiDelete, apiGet, apiPatch, apiPost } from "@/lib/api/client";
import type { Announcement } from "@/lib/api/types/notification";

const base = "/instructor";

export async function fetchCourseAnnouncements(courseUuid: string) {
  return apiGet<Announcement[]>(`${base}/courses/${courseUuid}/announcements`);
}

export async function createCourseAnnouncement(courseUuid: string, payload: { title: string; body: string }) {
  return apiPost<Announcement>(`${base}/courses/${courseUuid}/announcements`, { announcement: payload });
}

export async function publishInstructorAnnouncement(uuid: string) {
  return apiPost<Announcement>(`${base}/announcements/${uuid}/publish`);
}

export async function updateInstructorAnnouncement(uuid: string, payload: { title: string; body: string }) {
  return apiPatch<Announcement>(`${base}/announcements/${uuid}`, { announcement: payload });
}

export async function deleteInstructorAnnouncement(uuid: string) {
  return apiDelete(`${base}/announcements/${uuid}`);
}
