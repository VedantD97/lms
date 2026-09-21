import { Link } from "react-router-dom";
import { Button } from "@/components/ui/Button";
import { LoadingSpinner } from "@/components/feedback/LoadingSpinner";
import { PageHeader } from "@/components/shared/PageHeader";
import { useDashboardSummary } from "@/features/admin/reports/hooks/useAdminReports";

function StatCard({ label, value, hint }: { label: string; value: string | number; hint?: string }) {
  return (
    <div className="rounded-xl border border-slate-200 bg-white p-5 shadow-sm">
      <p className="text-sm font-medium text-slate-600">{label}</p>
      <p className="mt-2 text-3xl font-semibold text-slate-900">{value}</p>
      {hint ? <p className="mt-2 text-xs text-slate-500">{hint}</p> : null}
    </div>
  );
}

export function AdminDashboardPage() {
  const { data, isLoading } = useDashboardSummary();

  return (
    <div>
      <PageHeader
        title="Dashboard"
        description="Overview of platform activity and health."
        action={
          <Link to="/admin/reports">
            <Button variant="secondary">View reports</Button>
          </Link>
        }
      />

      {isLoading || !data ? (
        <LoadingSpinner label="Loading dashboard..." />
      ) : (
        <>
          <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
            <StatCard label="Students" value={data.users.students} hint={`${data.users.instructors} instructors`} />
            <StatCard
              label="Published courses"
              value={data.courses.published}
              hint={`${data.courses.draft} draft · ${data.courses.archived} archived`}
            />
            <StatCard
              label="Active enrollments"
              value={data.enrollments.active}
              hint={`${data.enrollments.completed} completed · ${data.enrollments.dropped} dropped`}
            />
            <StatCard
              label="Certificates issued"
              value={data.certificates.active}
              hint={`${data.certificates.revoked} revoked`}
            />
          </div>

          <div className="mt-6 grid gap-4 md:grid-cols-3">
            <StatCard label="Total enrollments" value={data.enrollments.total} />
            <StatCard label="New enrollments (30d)" value={data.recent_enrollments_30d} />
            <StatCard
              label="Reviews"
              value={data.reviews.total}
              hint={
                data.reviews.average_rating != null
                  ? `Average rating ${data.reviews.average_rating.toFixed(1)}`
                  : "No ratings yet"
              }
            />
          </div>
        </>
      )}
    </div>
  );
}
