import { useEffect, useState } from "react";
import { Link, useParams } from "react-router-dom";
import { Button } from "@/components/ui/Button";
import { Label, Textarea } from "@/components/ui/Field";
import { LoadingSpinner } from "@/components/feedback/LoadingSpinner";
import { PageHeader } from "@/components/shared/PageHeader";
import {
  useEnrollmentAssignment,
  useSubmitAssignment,
} from "@/features/student/assignments/hooks/useStudentAssignments";
import { getErrorMessage } from "@/lib/api/errors";

export function StudentAssignmentPage() {
  const { enrollmentUuid, assignmentUuid } = useParams();
  const { data: assignment, isLoading } = useEnrollmentAssignment(enrollmentUuid ?? "", assignmentUuid ?? "");
  const submit = useSubmitAssignment(enrollmentUuid ?? "", assignmentUuid ?? "");
  const [body, setBody] = useState("");
  const [error, setError] = useState<string | null>(null);
  const [success, setSuccess] = useState<string | null>(null);

  useEffect(() => {
    if (!assignment?.submission_status) return;
    setSuccess(null);
  }, [assignment?.submission_status]);

  if (isLoading || !assignment) return <LoadingSpinner label="Loading assignment..." />;

  const canSubmit =
    assignment.accepting_submissions &&
    (!assignment.submission_status ||
      assignment.submission_status === "graded" && !assignment.passed && assignment.allow_resubmit);

  async function handleSubmit(event: React.FormEvent) {
    event.preventDefault();
    setError(null);
    setSuccess(null);
    try {
      await submit.mutateAsync(body);
      setSuccess("Submission sent successfully.");
    } catch (err) {
      setError(getErrorMessage(err));
    }
  }

  return (
    <div>
      <PageHeader
        title={assignment.title}
        description={assignment.description ?? undefined}
        action={
          <Link to={assignment.course_uuid ? `/student/courses/${assignment.course_uuid}` : "/student/my-courses"}>
            <Button variant="secondary">Back to course</Button>
          </Link>
        }
      />

      <div className="mb-6 flex flex-wrap gap-3 text-sm text-slate-600">
        <span>Max points: {assignment.max_points}</span>
        <span>Passing score: {assignment.passing_score}%</span>
        {assignment.due_at ? <span>Due: {new Date(assignment.due_at).toLocaleString()}</span> : null}
        {assignment.past_due ? <span className="text-amber-700">Past due</span> : null}
      </div>

      {assignment.submission_status === "graded" && assignment.grade_percentage != null ? (
        <div className="mb-6 rounded-xl border border-slate-200 bg-white p-5">
          <p className="font-medium text-slate-900">Your grade</p>
          <p className="mt-2 text-sm text-slate-700">
            Score: {assignment.grade_percentage}% · {assignment.passed ? "Passed" : "Failed"}
          </p>
        </div>
      ) : assignment.submission_status === "submitted" ? (
        <div className="mb-6 rounded-xl border border-amber-200 bg-amber-50 p-5 text-sm text-amber-900">
          Submitted and awaiting grading.
        </div>
      ) : null}

      {canSubmit ? (
        <form onSubmit={handleSubmit} className="max-w-3xl space-y-4 rounded-xl border border-slate-200 bg-white p-6">
          <div>
            <Label htmlFor="body">Your submission</Label>
            <Textarea id="body" rows={8} value={body} onChange={(e) => setBody(e.target.value)} required />
          </div>
          {error ? <p className="text-sm text-red-600">{error}</p> : null}
          {success ? <p className="text-sm text-emerald-700">{success}</p> : null}
          <Button type="submit" disabled={submit.isPending}>
            Submit assignment
          </Button>
        </form>
      ) : (
        <p className="text-sm text-slate-600">This assignment is not accepting submissions right now.</p>
      )}
    </div>
  );
}
