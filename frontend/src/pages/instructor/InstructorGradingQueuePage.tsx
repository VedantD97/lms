import { Link } from "react-router-dom";
import { Button } from "@/components/ui/Button";
import { LoadingSpinner } from "@/components/feedback/LoadingSpinner";
import { PageHeader } from "@/components/shared/PageHeader";
import { usePendingSubmissions } from "@/features/instructor/dashboard/hooks/useInstructorDashboard";
import { studentName } from "@/features/instructor/dashboard/instructorDashboardHelpers";

export function InstructorGradingQueuePage() {
  const { data, isLoading } = usePendingSubmissions();

  return (
    <div>
      <PageHeader
        title="Grading queue"
        description="Assignment submissions waiting for your review."
        action={
          <Link to="/instructor/dashboard">
            <Button variant="secondary">Back to dashboard</Button>
          </Link>
        }
      />

      {isLoading ? (
        <LoadingSpinner label="Loading submissions..." />
      ) : !data?.data.length ? (
        <p className="rounded-xl border border-slate-200 bg-white p-5 text-sm text-slate-600">
          No submissions waiting for grading.
        </p>
      ) : (
        <div className="overflow-hidden rounded-xl border border-slate-200 bg-white">
          <table className="min-w-full divide-y divide-slate-200 text-sm">
            <thead className="bg-slate-50">
              <tr>
                <th className="px-4 py-3 text-left font-medium text-slate-700">Student</th>
                <th className="px-4 py-3 text-left font-medium text-slate-700">Assignment</th>
                <th className="px-4 py-3 text-left font-medium text-slate-700">Course</th>
                <th className="px-4 py-3 text-left font-medium text-slate-700">Submitted</th>
                <th className="px-4 py-3 text-right font-medium text-slate-700">Action</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {data.data.map((submission) => (
                <tr key={submission.uuid}>
                  <td className="px-4 py-3">{studentName(submission.student)}</td>
                  <td className="px-4 py-3">{submission.assignment_title}</td>
                  <td className="px-4 py-3">{submission.course_title}</td>
                  <td className="px-4 py-3">{new Date(submission.submitted_at).toLocaleDateString()}</td>
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
      )}
    </div>
  );
}
