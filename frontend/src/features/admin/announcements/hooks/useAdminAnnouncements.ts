import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  createAdminAnnouncement,
  deleteAdminAnnouncement,
  fetchAdminAnnouncements,
  publishAdminAnnouncement,
  updateAdminAnnouncement,
} from "@/features/admin/announcements/api/adminAnnouncementsApi";

export function useAdminAnnouncements(params?: Record<string, string | number | undefined>) {
  return useQuery({
    queryKey: ["admin", "announcements", params],
    queryFn: () => fetchAdminAnnouncements(params),
  });
}

export function useCreateAdminAnnouncement() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: createAdminAnnouncement,
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["admin", "announcements"] }),
  });
}

export function useUpdateAdminAnnouncement(uuid: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (payload: { title: string; body: string }) => updateAdminAnnouncement(uuid, payload),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["admin", "announcements"] }),
  });
}

export function usePublishAdminAnnouncement() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: publishAdminAnnouncement,
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["admin", "announcements"] }),
  });
}

export function useDeleteAdminAnnouncement() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: deleteAdminAnnouncement,
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["admin", "announcements"] }),
  });
}
