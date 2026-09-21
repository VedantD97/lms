import { Link, useParams } from "react-router-dom";
import { Button } from "@/components/ui/Button";
import { LoadingSpinner } from "@/components/feedback/LoadingSpinner";
import { PageHeader } from "@/components/shared/PageHeader";
import { useInstructorCourse } from "@/features/instructor/courses/hooks/useInstructorCourses";
import { useCourseEnrollments } from "@/features/instructor/dashboard/hooks/useInstructorDashboard";
import { formatProgressSummary, studentName } from "@/features/instructor/dashboard/instructorDashboardHelpers";

export function InstructorCourseStudentsPage() {
  const { uuid } = useParams();
  const { data: course, isLoading: courseLoading } = useInstructorCourse(uuid ?? "");
  const { data, isLoading } = useCourseEnrollments(uuid ?? "");

  if (courseLoading || isLoading) return <LoadingSpinner label="Loading students..." />;
  if (!course) return <p className="text-sm text-slate-600">Course not found.</p>;

  return (
    <div>
      <PageHeader
        title={`Students · ${course.title}`}
        description="Track enrollment status and progress for this course."
        action={
          <Link to={`/instructor/courses/${course.uuid}`}>
            <Button variant="secondary">Back to editor</Button>
          </Link>
        }
      />

      {!data?.data.length ? (
        <p className="rounded-xl border border-slate-200 bg-white p-5 text-sm text-slate-600">
          No students enrolled yet.
        </p>
      ) : (
        <div className="overflow-hidden rounded-xl border border-slate-200 bg-white">
          <table className="min-w-full divide-y divide-slate-200 text-sm">
            <thead className="bg-slate-50">
              <tr>
                <th className="px-4 py-3 text-left font-medium text-slate-700">Student</th>
                <th className="px-4 py-3 text-left font-medium text-slate-700">Status</th>
                <th className="px-4 py-3 text-left font-medium text-slate-700">Progress</th>
                <th className="px-4 py-3 text-left font-medium text-slate-700">Enrolled</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {data.data.map((enrollment) => (
                <tr key={enrollment.uuid}>
                  <td className="px-4 py-3">
                    <div className="font-medium text-slate-900">{studentName(enrollment.student)}</div>
                    <div className="text-xs text-slate-500">{enrollment.student.email}</div>
                  </td>
                  <td className="px-4 py-3 capitalize">{enrollment.status}</td>
                  <td className="px-4 py-3">
                    {enrollment.progress_percent}% · {formatProgressSummary(enrollment.progress_summary)}
                  </td>
                  <td className="px-4 py-3">{new Date(enrollment.enrolled_at).toLocaleDateString()}</td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}
    </div>
  );
}
