import { useState } from "react";
import { Button } from "@/components/ui/Button";
import { LoadingSpinner } from "@/components/feedback/LoadingSpinner";
import { PageHeader } from "@/components/shared/PageHeader";
import { useAdminCertificates, useRevokeCertificate } from "@/features/admin/certificates/hooks/useAdminCertificates";

export function AdminCertificatesPage() {
  const [page, setPage] = useState(1);
  const { data, isLoading } = useAdminCertificates({ page });
  const revoke = useRevokeCertificate();

  return (
    <div>
      <PageHeader title="Certificates" description="Review and revoke issued certificates." />

      {isLoading ? (
        <LoadingSpinner label="Loading certificates..." />
      ) : (
        <div className="overflow-hidden rounded-xl border border-slate-200 bg-white">
          <table className="min-w-full divide-y divide-slate-200 text-sm">
            <thead className="bg-slate-50">
              <tr>
                <th className="px-4 py-3 text-left font-medium text-slate-700">Certificate</th>
                <th className="px-4 py-3 text-left font-medium text-slate-700">Course</th>
                <th className="px-4 py-3 text-left font-medium text-slate-700">Student</th>
                <th className="px-4 py-3 text-left font-medium text-slate-700">Issued</th>
                <th className="px-4 py-3 text-left font-medium text-slate-700">Status</th>
                <th className="px-4 py-3 text-right font-medium text-slate-700">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {data?.data.map((certificate) => (
                <tr key={certificate.uuid}>
                  <td className="px-4 py-3 font-mono text-xs">{certificate.certificate_number}</td>
                  <td className="px-4 py-3">{certificate.course.title}</td>
                  <td className="px-4 py-3">
                    {certificate.student?.first_name} {certificate.student?.last_name}
                    <div className="text-xs text-slate-500">{certificate.student?.email}</div>
                  </td>
                  <td className="px-4 py-3">{new Date(certificate.issued_at).toLocaleDateString()}</td>
                  <td className="px-4 py-3">{certificate.revoked ? "Revoked" : "Active"}</td>
                  <td className="px-4 py-3 text-right">
                    {!certificate.revoked ? (
                      <Button
                        variant="danger"
                        disabled={revoke.isPending}
                        onClick={() => revoke.mutate(certificate.uuid)}
                      >
                        Revoke
                      </Button>
                    ) : null}
                  </td>
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
