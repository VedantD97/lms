import { Link } from "react-router-dom";
import { EmptyState } from "@/components/feedback/EmptyState";
import { LoadingSpinner } from "@/components/feedback/LoadingSpinner";
import { PageHeader } from "@/components/shared/PageHeader";
import { useStudentCertificates } from "@/features/student/certificates/hooks/useStudentCertificates";

export function StudentCertificatesPage() {
  const { data, isLoading } = useStudentCertificates();

  return (
    <div>
      <PageHeader
        title="My certificates"
        description="Certificates earned by completing courses."
        action={
          <Link to="/student/my-courses" className="text-sm text-violet-700 hover:underline">
            Back to my courses
          </Link>
        }
      />

      {isLoading ? (
        <LoadingSpinner label="Loading certificates..." />
      ) : !data?.length ? (
        <EmptyState
          title="No certificates yet"
          description="Complete a course to earn your first certificate."
        />
      ) : (
        <div className="grid gap-4 md:grid-cols-2">
          {data.map((certificate) => (
            <div key={certificate.uuid} className="rounded-xl border border-violet-200 bg-gradient-to-br from-violet-50 to-white p-6 shadow-sm">
              <p className="text-xs font-semibold uppercase tracking-wide text-violet-700">Certificate of completion</p>
              <h2 className="mt-2 text-lg font-semibold text-slate-900">{certificate.course.title}</h2>
              <p className="mt-3 text-sm text-slate-600">Certificate no. {certificate.certificate_number}</p>
              <p className="text-sm text-slate-600">Issued {new Date(certificate.issued_at).toLocaleDateString()}</p>
            </div>
          ))}
        </div>
      )}
    </div>
  );
}
