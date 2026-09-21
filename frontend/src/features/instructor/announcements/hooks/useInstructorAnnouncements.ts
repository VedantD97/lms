import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  createCourseAnnouncement,
  deleteInstructorAnnouncement,
  fetchCourseAnnouncements,
  publishInstructorAnnouncement,
} from "@/features/instructor/announcements/api/instructorAnnouncementsApi";

export function useCourseAnnouncements(courseUuid: string) {
  return useQuery({
    queryKey: ["instructor", "courses", courseUuid, "announcements"],
    queryFn: async () => (await fetchCourseAnnouncements(courseUuid)).data,
    enabled: Boolean(courseUuid),
  });
}

export function useCreateCourseAnnouncement(courseUuid: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (payload: { title: string; body: string }) => createCourseAnnouncement(courseUuid, payload),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["instructor", "courses", courseUuid, "announcements"] }),
  });
}

export function usePublishInstructorAnnouncement(courseUuid: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: publishInstructorAnnouncement,
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["instructor", "courses", courseUuid, "announcements"] }),
  });
}

export function useDeleteInstructorAnnouncement(courseUuid: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: deleteInstructorAnnouncement,
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["instructor", "courses", courseUuid, "announcements"] }),
  });
}
