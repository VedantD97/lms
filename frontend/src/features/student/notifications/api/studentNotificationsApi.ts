import { apiGet, apiPatch, apiPost } from "@/lib/api/client";
import type { Notification } from "@/lib/api/types/notification";

const base = "/student";

export async function fetchNotifications(params?: Record<string, string | number | undefined>) {
  return apiGet<Notification[]>(`${base}/notifications`, params);
}

export async function fetchUnreadCount() {
  return apiGet<{ unread_count: number }>(`${base}/notifications/unread_count`);
}

export async function markNotificationRead(uuid: string) {
  return apiPatch<Notification>(`${base}/notifications/${uuid}/read`);
}

export async function markAllNotificationsRead() {
  return apiPost<void>(`${base}/notifications/read_all`);
}

export async function fetchStudentAnnouncements(params?: Record<string, string | number | undefined>) {
  return apiGet<import("@/lib/api/types/notification").Announcement[]>(`${base}/announcements`, params);
}
