import { useQuery } from "@tanstack/react-query";
import { fetchStudentDashboard } from "@/features/student/dashboard/api/studentDashboardApi";

export function useStudentDashboard() {
  return useQuery({
    queryKey: ["student", "dashboard"],
    queryFn: async () => (await fetchStudentDashboard()).data,
  });
}
