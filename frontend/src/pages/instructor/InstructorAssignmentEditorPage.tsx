import { useEffect, useState } from "react";
import { Link, useParams } from "react-router-dom";
import { Button } from "@/components/ui/Button";
import { Input, Label, Textarea } from "@/components/ui/Field";
import { LoadingSpinner } from "@/components/feedback/LoadingSpinner";
import { PageHeader, StatusBadge } from "@/components/shared/PageHeader";
import {
  useAssignmentSubmissions,
  useGradeSubmission,
  useInstructorAssignment,
  usePublishInstructorAssignment,
  useUnpublishInstructorAssignment,
  useUpdateInstructorAssignment,
} from "@/features/instructor/assignments/hooks/useInstructorAssignments";
import type { AssignmentSubmission } from "@/lib/api/types/assignment";
import { getErrorMessage } from "@/lib/api/errors";

export function InstructorAssignmentEditorPage() {
  const { uuid } = useParams();
  const { data: assignment, isLoading } = useInstructorAssignment(uuid ?? "");
  const { data: submissionsData } = useAssignmentSubmissions(uuid ?? "");
  const updateAssignment = useUpdateInstructorAssignment(uuid ?? "");
  const publish = usePublishInstructorAssignment();
  const unpublish = useUnpublishInstructorAssignment();
  const gradeSubmission = useGradeSubmission(uuid ?? "");

  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [maxPoints, setMaxPoints] = useState(100);
  const [passingScore, setPassingScore] = useState(70);
  const [dueAt, setDueAt] = useState("");
  const [allowLate, setAllowLate] = useState(false);
  const [allowResubmit, setAllowResubmit] = useState(true);
  const [requiredForCompletion, setRequiredForCompletion] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    if (!assignment) return;
    setTitle(assignment.title);
    setDescription(assignment.description ?? "");
    setMaxPoints(Number(assignment.max_points));
    setPassingScore(Number(assignment.passing_score));
    setDueAt(assignment.due_at ? assignment.due_at.slice(0, 16) : "");
    setAllowLate(assignment.allow_late);
    setAllowResubmit(assignment.allow_resubmit);
    setRequiredForCompletion(assignment.required_for_completion);
  }, [assignment]);

  if (isLoading || !assignment) return <LoadingSpinner label="Loading assignment..." />;

  async function handleSave(event: React.FormEvent) {
    event.preventDefault();
    setError(null);
    try {
      await updateAssignment.mutateAsync({
        title,
        description,
        max_points: maxPoints,
        passing_score: passingScore,
        due_at: dueAt ? new Date(dueAt).toISOString() : null,
        allow_late: allowLate,
        allow_resubmit: allowResubmit,
        required_for_completion: requiredForCompletion,
      });
    } catch (err) {
      setError(getErrorMessage(err));
    }
  }

  return (
    <div>
      <PageHeader
        title={assignment.title}
        action={
          <Link to={`/instructor/courses/${assignment.course_uuid}`}>
            <Button variant="secondary">Back to course</Button>
          </Link>
        }
      />

      <div className="mb-6 flex flex-wrap items-center gap-3">
        <StatusBadge status={assignment.status} />
        {assignment.status === "draft" ? (
          <Button onClick={() => publish.mutate(assignment.uuid)}>Publish</Button>
        ) : (
          <Button variant="secondary" onClick={() => unpublish.mutate(assignment.uuid)}>
            Unpublish
          </Button>
        )}
      </div>

      <form onSubmit={handleSave} className="mb-10 max-w-3xl space-y-4 rounded-xl border border-slate-200 bg-white p-6">
        <div>
          <Label htmlFor="title">Title</Label>
          <Input id="title" value={title} onChange={(e) => setTitle(e.target.value)} required />
        </div>
        <div>
          <Label htmlFor="description">Instructions</Label>
          <Textarea id="description" rows={4} value={description} onChange={(e) => setDescription(e.target.value)} />
        </div>
        <div className="grid gap-4 md:grid-cols-2">
          <div>
            <Label htmlFor="max_points">Max points</Label>
            <Input
              id="max_points"
              type="number"
              min={1}
              value={maxPoints}
              onChange={(e) => setMaxPoints(Number(e.target.value))}
            />
          </div>
          <div>
            <Label htmlFor="passing_score">Passing score (%)</Label>
            <Input
              id="passing_score"
              type="number"
              min={0}
              max={100}
              value={passingScore}
              onChange={(e) => setPassingScore(Number(e.target.value))}
            />
          </div>
        </div>
        <div>
          <Label htmlFor="due_at">Due date</Label>
          <Input id="due_at" type="datetime-local" value={dueAt} onChange={(e) => setDueAt(e.target.value)} />
        </div>
        <label className="flex items-center gap-2 text-sm text-slate-700">
          <input type="checkbox" checked={allowLate} onChange={(e) => setAllowLate(e.target.checked)} />
          Allow late submissions
        </label>
        <label className="flex items-center gap-2 text-sm text-slate-700">
          <input type="checkbox" checked={allowResubmit} onChange={(e) => setAllowResubmit(e.target.checked)} />
          Allow resubmit after failed grade
        </label>
        <label className="flex items-center gap-2 text-sm text-slate-700">
          <input
            type="checkbox"
            checked={requiredForCompletion}
            onChange={(e) => setRequiredForCompletion(e.target.checked)}
          />
          Required for course completion
        </label>
        {error ? <p className="text-sm text-red-600">{error}</p> : null}
        <Button type="submit" disabled={updateAssignment.isPending}>
          Save assignment
        </Button>
      </form>

      <section>
        <h2 className="mb-4 text-lg font-semibold text-slate-900">Submissions</h2>
        {!submissionsData?.data.length ? (
          <p className="text-sm text-slate-600">No submissions yet.</p>
        ) : (
          <div className="space-y-4">
            {submissionsData.data.map((submission) => (
              <SubmissionGrader
                key={submission.uuid}
                submission={submission}
                maxPoints={Number(assignment.max_points)}
                onGrade={(payload) => gradeSubmission.mutateAsync({ submissionUuid: submission.uuid, ...payload })}
              />
            ))}
          </div>
        )}
      </section>
    </div>
  );
}

function SubmissionGrader({
  submission,
  maxPoints,
  onGrade,
}: {
  submission: AssignmentSubmission;
  maxPoints: number;
  onGrade: (payload: { points: number; feedback?: string }) => Promise<unknown>;
}) {
  const [points, setPoints] = useState(submission.grade?.points ?? maxPoints);
  const [feedback, setFeedback] = useState(submission.grade?.feedback ?? "");
  const [saving, setSaving] = useState(false);

  return (
    <div className="rounded-xl border border-slate-200 bg-white p-5">
      <div className="mb-3 flex flex-wrap items-center justify-between gap-2">
        <div>
          <p className="font-medium text-slate-900">
            {submission.student?.first_name} {submission.student?.last_name}
          </p>
          <p className="text-sm text-slate-600">{submission.student?.email}</p>
        </div>
        <span className="text-sm capitalize text-slate-600">{submission.status.replace("_", " ")}</span>
      </div>
      <p className="whitespace-pre-wrap rounded-lg bg-slate-50 p-3 text-sm text-slate-800">{submission.body}</p>
      <div className="mt-4 grid gap-3 md:grid-cols-[120px_1fr_auto]">
        <Input type="number" min={0} max={maxPoints} value={points} onChange={(e) => setPoints(Number(e.target.value))} />
        <Input value={feedback} onChange={(e) => setFeedback(e.target.value)} placeholder="Feedback" />
        <Button
          disabled={saving}
          onClick={async () => {
            setSaving(true);
            try {
              await onGrade({ points, feedback });
            } finally {
              setSaving(false);
            }
          }}
        >
          Grade
        </Button>
      </div>
      {submission.grade ? (
        <p className="mt-2 text-sm text-emerald-700">
          Graded: {submission.grade.points}/{maxPoints} ({submission.grade.percentage}%) ·{" "}
          {submission.grade.passed ? "Passed" : "Failed"}
        </p>
      ) : null}
    </div>
  );
}
