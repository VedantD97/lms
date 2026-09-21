import { Link } from "react-router-dom";
import { Button } from "@/components/ui/Button";
import { LoadingSpinner } from "@/components/feedback/LoadingSpinner";
import { PageHeader } from "@/components/shared/PageHeader";
import { formatPercent } from "@/features/admin/reports/reportHelpers";
import { useCourseCompletionReport, useEnrollmentsReport } from "@/features/admin/reports/hooks/useAdminReports";

export function AdminReportsPage() {
  const { data: enrollments, isLoading: enrollmentsLoading } = useEnrollmentsReport();
  const { data: completion, isLoading: completionLoading } = useCourseCompletionReport();

  return (
    <div>
      <PageHeader
        title="Reports"
        description="Enrollment trends and course completion analytics."
        action={
          <Link to="/admin/dashboard">
            <Button variant="secondary">Back to dashboard</Button>
          </Link>
        }
      />

      <section className="mb-10">
        <h2 className="mb-4 text-lg font-semibold text-slate-900">Enrollment summary</h2>
        {enrollmentsLoading || !enrollments ? (
          <LoadingSpinner label="Loading enrollment report..." />
        ) : (
          <>
            <div className="mb-6 grid gap-4 md:grid-cols-4">
              <div className="rounded-xl border border-slate-200 bg-white p-4">
                <p className="text-sm text-slate-600">Total</p>
                <p className="text-2xl font-semibold">{enrollments.summary.total}</p>
              </div>
              <div className="rounded-xl border border-slate-200 bg-white p-4">
                <p className="text-sm text-slate-600">Active</p>
                <p className="text-2xl font-semibold text-emerald-700">{enrollments.summary.active}</p>
              </div>
              <div className="rounded-xl border border-slate-200 bg-white p-4">
                <p className="text-sm text-slate-600">Completed</p>
                <p className="text-2xl font-semibold text-blue-700">{enrollments.summary.completed}</p>
              </div>
              <div className="rounded-xl border border-slate-200 bg-white p-4">
                <p className="text-sm text-slate-600">Dropped</p>
                <p className="text-2xl font-semibold text-amber-700">{enrollments.summary.dropped}</p>
              </div>
            </div>

            <div className="overflow-hidden rounded-xl border border-slate-200 bg-white">
              <table className="min-w-full divide-y divide-slate-200 text-sm">
                <thead className="bg-slate-50">
                  <tr>
                    <th className="px-4 py-3 text-left font-medium text-slate-700">Course</th>
                    <th className="px-4 py-3 text-left font-medium text-slate-700">Total</th>
                    <th className="px-4 py-3 text-left font-medium text-slate-700">Active</th>
                    <th className="px-4 py-3 text-left font-medium text-slate-700">Completed</th>
                    <th className="px-4 py-3 text-left font-medium text-slate-700">Dropped</th>
                  </tr>
                </thead>
                <tbody className="divide-y divide-slate-100">
                  {enrollments.by_course.map((row) => (
                    <tr key={row.course_uuid}>
                      <td className="px-4 py-3">{row.course_title}</td>
                      <td className="px-4 py-3">{row.total}</td>
                      <td className="px-4 py-3">{row.active}</td>
                      <td className="px-4 py-3">{row.completed}</td>
                      <td className="px-4 py-3">{row.dropped}</td>
                    </tr>
                  ))}
                </tbody>
              </table>
            </div>
          </>
        )}
      </section>

      <section>
        <h2 className="mb-4 text-lg font-semibold text-slate-900">Course completion</h2>
        {completionLoading || !completion ? (
          <LoadingSpinner label="Loading completion report..." />
        ) : (
          <div className="overflow-hidden rounded-xl border border-slate-200 bg-white">
            <table className="min-w-full divide-y divide-slate-200 text-sm">
              <thead className="bg-slate-50">
                <tr>
                  <th className="px-4 py-3 text-left font-medium text-slate-700">Course</th>
                  <th className="px-4 py-3 text-left font-medium text-slate-700">Enrollments</th>
                  <th className="px-4 py-3 text-left font-medium text-slate-700">Completed</th>
                  <th className="px-4 py-3 text-left font-medium text-slate-700">Completion rate</th>
                  <th className="px-4 py-3 text-left font-medium text-slate-700">Avg progress</th>
                </tr>
              </thead>
              <tbody className="divide-y divide-slate-100">
                {completion.map((row) => (
                  <tr key={row.course_uuid}>
                    <td className="px-4 py-3">{row.course_title}</td>
                    <td className="px-4 py-3">{row.total_enrollments}</td>
                    <td className="px-4 py-3">{row.completed_enrollments}</td>
                    <td className="px-4 py-3">{formatPercent(row.completion_rate)}</td>
                    <td className="px-4 py-3">{formatPercent(row.average_progress)}</td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
      </section>
    </div>
  );
}
