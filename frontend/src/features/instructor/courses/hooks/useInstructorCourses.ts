import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  createInstructorCourse,
  createLesson,
  createLessonResource,
  createModule,
  deleteLesson,
  deleteLessonResource,
  deleteModule,
  fetchInstructorCourse,
  fetchInstructorCourses,
  publishInstructorCourse,
  reorderLessons,
  reorderModules,
  unpublishInstructorCourse,
  updateInstructorCourse,
  updateLesson,
  updateModule,
} from "@/features/instructor/courses/api/instructorCoursesApi";
import type { Course } from "@/lib/api/types/course";

export function useInstructorCourses(params: Record<string, string | number | undefined>) {
  return useQuery({
    queryKey: ["instructor", "courses", params],
    queryFn: () => fetchInstructorCourses(params),
  });
}

export function useInstructorCourse(uuid: string) {
  return useQuery({
    queryKey: ["instructor", "courses", uuid],
    queryFn: async () => (await fetchInstructorCourse(uuid)).data,
    enabled: Boolean(uuid),
  });
}

export function useCreateInstructorCourse() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: createInstructorCourse,
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["instructor", "courses"] }),
  });
}

export function useUpdateInstructorCourse(uuid: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (payload: Parameters<typeof updateInstructorCourse>[1]) => updateInstructorCourse(uuid, payload),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["instructor", "courses", uuid] }),
  });
}

export function usePublishInstructorCourse() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: publishInstructorCourse,
    onSuccess: (_, uuid) => queryClient.invalidateQueries({ queryKey: ["instructor", "courses", uuid] }),
  });
}

export function useUnpublishInstructorCourse() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: unpublishInstructorCourse,
    onSuccess: (_, uuid) => queryClient.invalidateQueries({ queryKey: ["instructor", "courses", uuid] }),
  });
}

export function useCreateModule(courseUuid: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (payload: Parameters<typeof createModule>[1]) => createModule(courseUuid, payload),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["instructor", "courses", courseUuid] }),
  });
}

export function useUpdateModule(courseUuid: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ uuid, payload }: { uuid: string; payload: Parameters<typeof updateModule>[1] }) =>
      updateModule(uuid, payload),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["instructor", "courses", courseUuid] }),
  });
}

export function useDeleteModule(courseUuid: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: deleteModule,
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["instructor", "courses", courseUuid] }),
  });
}

export function useReorderModules(courseUuid: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (orderedUuids: string[]) => reorderModules(courseUuid, orderedUuids),
    onMutate: async (orderedUuids) => {
      await queryClient.cancelQueries({ queryKey: ["instructor", "courses", courseUuid] });
      const previous = queryClient.getQueryData(["instructor", "courses", courseUuid]);
      queryClient.setQueryData(["instructor", "courses", courseUuid], (old: any) => {
        if (!old?.modules) return old;
        const map = new Map(old.modules.map((item: any) => [item.uuid, item]));
        return {
          ...old,
          modules: orderedUuids.map((uuid) => map.get(uuid)).filter(Boolean),
        };
      });
      return { previous };
    },
    onError: (_error, _variables, context) => {
      if (context?.previous) {
        queryClient.setQueryData(["instructor", "courses", courseUuid], context.previous);
      }
    },
    onSettled: () => queryClient.invalidateQueries({ queryKey: ["instructor", "courses", courseUuid] }),
  });
}

export function useCreateLesson(courseUuid: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ moduleUuid, payload }: { moduleUuid: string; payload: Parameters<typeof createLesson>[1] }) =>
      createLesson(moduleUuid, payload),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["instructor", "courses", courseUuid] }),
  });
}

export function useUpdateLesson(courseUuid: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ uuid, payload }: { uuid: string; payload: Parameters<typeof updateLesson>[1] }) =>
      updateLesson(uuid, payload),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["instructor", "courses", courseUuid] }),
  });
}

export function useDeleteLesson(courseUuid: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: deleteLesson,
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["instructor", "courses", courseUuid] }),
  });
}

export function useReorderLessons(courseUuid: string, moduleUuid: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (orderedUuids: string[]) => reorderLessons(moduleUuid, orderedUuids),
    onMutate: async (orderedUuids) => {
      await queryClient.cancelQueries({ queryKey: ["instructor", "courses", courseUuid] });
      const previous = queryClient.getQueryData<Course>(["instructor", "courses", courseUuid]);
      queryClient.setQueryData<Course>(["instructor", "courses", courseUuid], (old) => {
        if (!old?.modules) return old;
        return {
          ...old,
          modules: old.modules.map((module) => {
            if (module.uuid !== moduleUuid || !module.lessons) return module;
            const map = new Map(module.lessons.map((lesson) => [lesson.uuid, lesson]));
            return {
              ...module,
              lessons: orderedUuids.map((uuid) => map.get(uuid)).filter(Boolean) as typeof module.lessons,
            };
          }),
        };
      });
      return { previous };
    },
    onError: (_error, _variables, context) => {
      if (context?.previous) {
        queryClient.setQueryData(["instructor", "courses", courseUuid], context.previous);
      }
    },
    onSettled: () => queryClient.invalidateQueries({ queryKey: ["instructor", "courses", courseUuid] }),
  });
}

export function useUploadLessonResource(courseUuid: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ lessonUuid, formData }: { lessonUuid: string; formData: FormData }) =>
      createLessonResource(lessonUuid, formData),
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["instructor", "courses", courseUuid] }),
  });
}

export function useDeleteLessonResource(courseUuid: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: deleteLessonResource,
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["instructor", "courses", courseUuid] }),
  });
}
