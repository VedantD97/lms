import { useQuery } from "@tanstack/react-query";
import { fetchAdminQuizzes, fetchQuizStatistics } from "@/features/admin/quizzes/api/adminQuizzesApi";

export function useAdminQuizzes(params: Record<string, string | number | undefined>) {
  return useQuery({
    queryKey: ["admin", "quizzes", params],
    queryFn: () => fetchAdminQuizzes(params),
  });
}

export function useQuizStatistics(uuid: string) {
  return useQuery({
    queryKey: ["admin", "quizzes", uuid, "statistics"],
    queryFn: async () => (await fetchQuizStatistics(uuid)).data,
    enabled: Boolean(uuid),
  });
}
