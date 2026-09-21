import { Link } from "react-router-dom";
import { Button } from "@/components/ui/Button";
import { LoadingSpinner } from "@/components/feedback/LoadingSpinner";
import { PageHeader } from "@/components/shared/PageHeader";
import { useInstructorDashboard, usePendingSubmissions } from "@/features/instructor/dashboard/hooks/useInstructorDashboard";
import { studentName } from "@/features/instructor/dashboard/instructorDashboardHelpers";

function StatCard({ label, value, hint }: { label: string; value: string | number; hint?: string }) {
  return (
    <div className="rounded-xl border border-slate-200 bg-white p-5 shadow-sm">
      <p className="text-sm font-medium text-slate-600">{label}</p>
      <p className="mt-2 text-3xl font-semibold text-slate-900">{value}</p>
      {hint ? <p className="mt-2 text-xs text-slate-500">{hint}</p> : null}
    </div>
  );
}

export function InstructorDashboardPage() {
  const { data, isLoading } = useInstructorDashboard();
  const { data: pendingData } = usePendingSubmissions({ page: 1 });

  return (
    <div>
      <PageHeader
        title="Dashboard"
        description="Overview of your courses, students, and grading queue."
        action={
          <Link to="/instructor/courses">
            <Button variant="secondary">Manage courses</Button>
          </Link>
        }
      />

      {isLoading || !data ? (
        <LoadingSpinner label="Loading dashboard..." />
      ) : (
        <>
          <div className="grid gap-4 md:grid-cols-2 xl:grid-cols-4">
            <StatCard
              label="My courses"
              value={data.courses.total}
              hint={`${data.courses.published} published · ${data.courses.draft} draft`}
            />
            <StatCard
              label="Active students"
              value={data.enrollments.active}
              hint={`${data.enrollments.completed} completed`}
            />
            <StatCard label="Pending grading" value={data.pending_submissions} />
            <StatCard label="New enrollments (30d)" value={data.recent_enrollments_30d} />
          </div>

          <section className="mt-8">
            <div className="mb-4 flex items-center justify-between">
              <h2 className="text-lg font-semibold text-slate-900">Grading queue</h2>
              <Link to="/instructor/grading" className="text-sm text-emerald-700 hover:underline">
                View all
              </Link>
            </div>
            {pendingData?.data.length ? (
              <div className="overflow-hidden rounded-xl border border-slate-200 bg-white">
                <table className="min-w-full divide-y divide-slate-200 text-sm">
                  <thead className="bg-slate-50">
                    <tr>
                      <th className="px-4 py-3 text-left font-medium text-slate-700">Student</th>
                      <th className="px-4 py-3 text-left font-medium text-slate-700">Assignment</th>
                      <th className="px-4 py-3 text-left font-medium text-slate-700">Course</th>
                      <th className="px-4 py-3 text-right font-medium text-slate-700">Action</th>
                    </tr>
                  </thead>
                  <tbody className="divide-y divide-slate-100">
                    {pendingData.data.slice(0, 5).map((submission) => (
                      <tr key={submission.uuid}>
                        <td className="px-4 py-3">{studentName(submission.student)}</td>
                        <td className="px-4 py-3">{submission.assignment_title}</td>
                        <td className="px-4 py-3">{submission.course_title}</td>
                        <td className="px-4 py-3 text-right">
                          <Link to={`/instructor/assignments/${submission.assignment_uuid}`}>
                            <Button variant="secondary">Grade</Button>
                          </Link>
                        </td>
                      </tr>
                    ))}
                  </tbody>
                </table>
              </div>
            ) : (
              <p className="rounded-xl border border-slate-200 bg-white p-5 text-sm text-slate-600">
                No submissions waiting for grading.
              </p>
            )}
          </section>

          <section className="mt-8">
            <h2 className="mb-4 text-lg font-semibold text-slate-900">Your courses</h2>
            <div className="grid gap-4 md:grid-cols-2">
              {data.course_breakdown.map((course) => (
                <div key={course.course_uuid} className="rounded-xl border border-slate-200 bg-white p-5">
                  <div className="flex items-start justify-between gap-3">
                    <div>
                      <Link
                        to={`/instructor/courses/${course.course_uuid}`}
                        className="font-semibold text-slate-900 hover:text-emerald-700"
                      >
                        {course.course_title}
                      </Link>
                      <p className="mt-1 text-sm capitalize text-slate-600">{course.status}</p>
                    </div>
                    <div className="text-right text-sm">
                      <p>{course.enrollments} students</p>
                      {course.pending_submissions > 0 ? (
                        <p className="text-amber-700">{course.pending_submissions} to grade</p>
                      ) : null}
                    </div>
                  </div>
                  <div className="mt-4 flex gap-2">
                    <Link to={`/instructor/courses/${course.course_uuid}/students`}>
                      <Button variant="secondary">View students</Button>
                    </Link>
                  </div>
                </div>
              ))}
            </div>
          </section>
        </>
      )}
    </div>
  );
}
