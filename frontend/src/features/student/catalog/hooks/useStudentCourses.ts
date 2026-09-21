import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { enrollInCourse, fetchCategories, fetchEnrollments, fetchStudentCourse, fetchStudentCourses } from "@/features/student/catalog/api/studentCoursesApi";

export function useStudentCourses(params: Record<string, string | number | undefined>) {
  return useQuery({
    queryKey: ["student", "courses", params],
    queryFn: () => fetchStudentCourses(params),
  });
}

export function useStudentCourse(uuid: string) {
  return useQuery({
    queryKey: ["student", "courses", uuid],
    queryFn: async () => (await fetchStudentCourse(uuid)).data,
    enabled: Boolean(uuid),
  });
}

export function useCategories() {
  return useQuery({
    queryKey: ["categories"],
    queryFn: async () => (await fetchCategories()).data,
  });
}

export function useEnrollInCourse() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: enrollInCourse,
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["student"] }),
  });
}

export function useStudentEnrollments() {
  return useQuery({
    queryKey: ["student", "enrollments"],
    queryFn: async () => (await fetchEnrollments()).data,
  });
}
