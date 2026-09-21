import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  fetchNotifications,
  fetchStudentAnnouncements,
  fetchUnreadCount,
  markAllNotificationsRead,
  markNotificationRead,
} from "@/features/student/notifications/api/studentNotificationsApi";

export function useNotifications(params?: Record<string, string | number | undefined>) {
  return useQuery({
    queryKey: ["student", "notifications", params],
    queryFn: () => fetchNotifications(params),
  });
}

export function useUnreadNotificationCount() {
  return useQuery({
    queryKey: ["student", "notifications", "unread_count"],
    queryFn: async () => (await fetchUnreadCount()).data.unread_count,
    refetchInterval: 60_000,
  });
}

export function useMarkNotificationRead() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: markNotificationRead,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["student", "notifications"] });
    },
  });
}

export function useMarkAllNotificationsRead() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: markAllNotificationsRead,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["student", "notifications"] });
    },
  });
}

export function useStudentAnnouncements(params?: Record<string, string | number | undefined>) {
  return useQuery({
    queryKey: ["student", "announcements", params],
    queryFn: () => fetchStudentAnnouncements(params),
  });
}
