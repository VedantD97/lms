import { useQuery } from "@tanstack/react-query";
import { fetchAuditLogs } from "@/features/admin/audit-logs/api/adminAuditLogsApi";

export function useAuditLogs(params?: Record<string, string | number | undefined>) {
  return useQuery({
    queryKey: ["admin", "audit_logs", params],
    queryFn: () => fetchAuditLogs(params),
  });
}
