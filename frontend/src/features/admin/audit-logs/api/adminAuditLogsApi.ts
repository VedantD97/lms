import { apiGet } from "@/lib/api/client";
import type { AuditLog } from "@/lib/api/types/auditLog";

const base = "/admin/audit_logs";

export async function fetchAuditLogs(params?: Record<string, string | number | undefined>) {
  return apiGet<AuditLog[]>(base, params);
}

export async function fetchAuditLog(uuid: string) {
  return apiGet<AuditLog>(`${base}/${uuid}`);
}
