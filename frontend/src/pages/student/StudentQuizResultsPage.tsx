import { Link, useParams } from "react-router-dom";
import { Button } from "@/components/ui/Button";
import { LoadingSpinner } from "@/components/feedback/LoadingSpinner";
import { PageHeader } from "@/components/shared/PageHeader";
import { useQuizAttemptResults } from "@/features/student/quizzes/hooks/useStudentQuizzes";

export function StudentQuizResultsPage() {
  const { enrollmentUuid, quizUuid, attemptUuid } = useParams();
  const { data: result, isLoading } = useQuizAttemptResults(attemptUuid ?? "");

  if (isLoading) return <LoadingSpinner label="Loading results..." />;
  if (!result) return <p className="text-sm text-slate-600">Results not found.</p>;

  return (
    <div>
      <PageHeader
        title="Quiz results"
        action={
          <Link to={`/student/enrollments/${enrollmentUuid}/quizzes/${quizUuid}`}>
            <Button variant="secondary">Back to quiz</Button>
          </Link>
        }
      />

      <div className="mb-8 max-w-2xl rounded-xl border border-slate-200 bg-white p-6">
        <div className="flex flex-wrap gap-4 text-sm">
          <span>Score: {result.score}/{result.max_score}</span>
          <span>Percentage: {result.percentage}%</span>
          <span className={result.passed ? "text-emerald-700" : "text-red-600"}>
            {result.passed ? "Passed" : "Failed"}
          </span>
        </div>
      </div>

      <div className="space-y-3">
        {result.responses?.map((response) => (
          <div key={response.question_uuid} className="rounded-xl border border-slate-200 bg-white p-4 text-sm">
            <div className="flex items-center justify-between">
              <span>Question</span>
              <span className={response.is_correct ? "text-emerald-700" : "text-red-600"}>
                {response.is_correct ? "Correct" : "Incorrect"} · {response.points_awarded} pts
              </span>
            </div>
            {result.show_correct_answers && response.correct_option_uuids ? (
              <p className="mt-2 text-slate-600">Correct answers recorded.</p>
            ) : null}
          </div>
        ))}
      </div>
    </div>
  );
}
