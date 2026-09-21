import { apiDelete, apiGet, apiPatch, apiPost } from "@/lib/api/client";
import type { Announcement } from "@/lib/api/types/notification";

const base = "/admin";

export async function fetchAdminAnnouncements(params?: Record<string, string | number | undefined>) {
  return apiGet<Announcement[]>(`${base}/announcements`, params);
}

export async function createAdminAnnouncement(payload: { title: string; body: string }) {
  return apiPost<Announcement>(`${base}/announcements`, { announcement: payload });
}

export async function updateAdminAnnouncement(uuid: string, payload: { title: string; body: string }) {
  return apiPatch<Announcement>(`${base}/announcements/${uuid}`, { announcement: payload });
}

export async function publishAdminAnnouncement(uuid: string) {
  return apiPost<Announcement>(`${base}/announcements/${uuid}/publish`);
}

export async function deleteAdminAnnouncement(uuid: string) {
  return apiDelete(`${base}/announcements/${uuid}`);
}
