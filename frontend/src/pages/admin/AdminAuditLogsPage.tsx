import { useState } from "react";
import { Button } from "@/components/ui/Button";
import { LoadingSpinner } from "@/components/feedback/LoadingSpinner";
import { PageHeader } from "@/components/shared/PageHeader";
import { useAuditLogs } from "@/features/admin/audit-logs/hooks/useAdminAuditLogs";

export function AdminAuditLogsPage() {
  const [page, setPage] = useState(1);
  const { data, isLoading, error } = useAuditLogs({ page });

  if (error) {
    return (
      <div>
        <PageHeader title="Audit logs" description="Restricted to super administrators." />
        <p className="text-sm text-red-700">You do not have permission to view audit logs.</p>
      </div>
    );
  }

  return (
    <div>
      <PageHeader title="Audit logs" description="Track sensitive admin actions across the platform." />

      {isLoading ? (
        <LoadingSpinner label="Loading audit logs..." />
      ) : (
        <div className="overflow-hidden rounded-xl border border-slate-200 bg-white">
          <table className="min-w-full divide-y divide-slate-200 text-sm">
            <thead className="bg-slate-50">
              <tr>
                <th className="px-4 py-3 text-left font-medium text-slate-700">When</th>
                <th className="px-4 py-3 text-left font-medium text-slate-700">Actor</th>
                <th className="px-4 py-3 text-left font-medium text-slate-700">Action</th>
                <th className="px-4 py-3 text-left font-medium text-slate-700">Details</th>
                <th className="px-4 py-3 text-left font-medium text-slate-700">IP</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {data?.data.map((log) => (
                <tr key={log.uuid}>
                  <td className="px-4 py-3">{new Date(log.created_at).toLocaleString()}</td>
                  <td className="px-4 py-3">
                    {log.actor.first_name} {log.actor.last_name}
                    <div className="text-xs text-slate-500">{log.actor.email}</div>
                  </td>
                  <td className="px-4 py-3 font-mono text-xs">{log.action}</td>
                  <td className="max-w-md truncate px-4 py-3 text-xs text-slate-600">
                    {JSON.stringify(log.changes)}
                  </td>
                  <td className="px-4 py-3 text-xs text-slate-500">{log.ip_address ?? "—"}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {data?.meta && data.meta.total > data.meta.per_page ? (
        <div className="mt-4 flex gap-2">
          <Button variant="secondary" disabled={page <= 1} onClick={() => setPage((p) => p - 1)}>
            Previous
          </Button>
          <Button
            variant="secondary"
            disabled={page * data.meta.per_page >= data.meta.total}
            onClick={() => setPage((p) => p + 1)}
          >
            Next
          </Button>
        </div>
      ) : null}
    </div>
  );
}
