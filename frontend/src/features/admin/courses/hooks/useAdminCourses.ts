import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  archiveAdminCourse,
  assignInstructor,
  createAdminCategory,
  createAdminCourse,
  deleteAdminCategory,
  fetchAdminCategories,
  fetchAdminCourse,
  fetchAdminCourses,
  fetchAdminUsers,
  publishAdminCourse,
  unpublishAdminCourse,
  updateAdminCategory,
  updateAdminCourse,
} from "@/features/admin/courses/api/adminCoursesApi";

export function useAdminCourses(params: Record<string, string | number | undefined>) {
  return useQuery({
    queryKey: ["admin", "courses", params],
    queryFn: async () => {
      const response = await fetchAdminCourses(params);
      return response;
    },
  });
}

export function useAdminCourse(uuid: string) {
  return useQuery({
    queryKey: ["admin", "courses", uuid],
    queryFn: async () => (await fetchAdminCourse(uuid)).data,
    enabled: Boolean(uuid),
  });
}

export function useAdminCategories() {
  return useQuery({
    queryKey: ["admin", "categories"],
    queryFn: async () => (await fetchAdminCategories()).data,
  });
}

export function useAdminInstructors() {
  return useQuery({
    queryKey: ["admin", "users", "instructor"],
    queryFn: async () => (await fetchAdminUsers("instructor")).data,
  });
}

export function useCreateAdminCourse() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: createAdminCourse,
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["admin", "courses"] }),
  });
}

export function useUpdateAdminCourse(uuid: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (payload: Parameters<typeof updateAdminCourse>[1]) => updateAdminCourse(uuid, payload),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["admin", "courses"] });
      queryClient.invalidateQueries({ queryKey: ["admin", "courses", uuid] });
    },
  });
}

export function usePublishAdminCourse() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: publishAdminCourse,
    onSuccess: (_, uuid) => {
      queryClient.invalidateQueries({ queryKey: ["admin", "courses"] });
      queryClient.invalidateQueries({ queryKey: ["admin", "courses", uuid] });
    },
  });
}

export function useUnpublishAdminCourse() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: unpublishAdminCourse,
    onSuccess: (_, uuid) => {
      queryClient.invalidateQueries({ queryKey: ["admin", "courses"] });
      queryClient.invalidateQueries({ queryKey: ["admin", "courses", uuid] });
    },
  });
}

export function useArchiveAdminCourse() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: archiveAdminCourse,
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["admin", "courses"] }),
  });
}

export function useAssignInstructor() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ courseUuid, userUuid }: { courseUuid: string; userUuid: string }) =>
      assignInstructor(courseUuid, userUuid),
    onSuccess: (_, variables) => {
      queryClient.invalidateQueries({ queryKey: ["admin", "courses", variables.courseUuid] });
    },
  });
}

export function useCreateAdminCategory() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: createAdminCategory,
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["admin", "categories"] }),
  });
}

export function useUpdateAdminCategory() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ uuid, payload }: { uuid: string; payload: Parameters<typeof updateAdminCategory>[1] }) =>
      updateAdminCategory(uuid, payload),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["admin", "categories"] }),
  });
}

export function useDeleteAdminCategory() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: deleteAdminCategory,
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["admin", "categories"] }),
  });
}
