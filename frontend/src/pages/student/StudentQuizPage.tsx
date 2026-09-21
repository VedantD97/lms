import { useEffect, useMemo, useState } from "react";
import { Link, useNavigate, useParams } from "react-router-dom";
import { Button } from "@/components/ui/Button";
import { LoadingSpinner } from "@/components/feedback/LoadingSpinner";
import { PageHeader } from "@/components/shared/PageHeader";
import {
  useEnrollmentQuiz,
  useQuizAttempt,
  useSaveQuizResponses,
  useStartQuizAttempt,
  useSubmitQuizAttempt,
} from "@/features/student/quizzes/hooks/useStudentQuizzes";
import type { Question } from "@/lib/api/types/quiz";
import { getErrorMessage } from "@/lib/api/errors";

export function StudentQuizPage() {
  const { enrollmentUuid, quizUuid } = useParams();
  const navigate = useNavigate();
  const { data: quiz, isLoading: quizLoading } = useEnrollmentQuiz(enrollmentUuid ?? "", quizUuid ?? "");
  const startAttempt = useStartQuizAttempt();
  const submitAttempt = useSubmitQuizAttempt();

  const [attemptUuid, setAttemptUuid] = useState<string | null>(null);
  const [answers, setAnswers] = useState<Record<string, string[]>>({});
  const [error, setError] = useState<string | null>(null);

  const { data: attempt, isLoading: attemptLoading } = useQuizAttempt(attemptUuid ?? "");
  const saveResponses = useSaveQuizResponses(attemptUuid ?? "");

  useEffect(() => {
    if (quiz?.in_progress_attempt_uuid && !attemptUuid) {
      setAttemptUuid(quiz.in_progress_attempt_uuid);
    }
  }, [quiz, attemptUuid]);

  useEffect(() => {
    if (!attempt?.responses) return;
    const next: Record<string, string[]> = {};
    attempt.responses.forEach((response) => {
      next[response.question_uuid] = response.selected_option_uuids;
    });
    setAnswers(next);
  }, [attempt]);

  const questions = attempt?.questions ?? [];

  const responsePayload = useMemo(
    () =>
      Object.entries(answers).map(([question_uuid, selected_option_uuids]) => ({
        question_uuid,
        selected_option_uuids,
      })),
    [answers],
  );

  async function handleStart() {
    setError(null);
    try {
      const response = await startAttempt.mutateAsync({
        enrollmentUuid: enrollmentUuid ?? "",
        quizUuid: quizUuid ?? "",
      });
      setAttemptUuid(response.data.uuid);
    } catch (err) {
      setError(getErrorMessage(err));
    }
  }

  function toggleAnswer(question: Question, optionUuid: string) {
    setAnswers((current) => {
      const existing = current[question.uuid] ?? [];
      if (question.question_type === "multiple_choice") {
        const next = existing.includes(optionUuid)
          ? existing.filter((id) => id !== optionUuid)
          : [...existing, optionUuid];
        return { ...current, [question.uuid]: next };
      }
      return { ...current, [question.uuid]: [optionUuid] };
    });
  }

  async function handleSave() {
    if (!attemptUuid) return;
    setError(null);
    try {
      await saveResponses.mutateAsync(responsePayload);
    } catch (err) {
      setError(getErrorMessage(err));
    }
  }

  async function handleSubmit() {
    if (!attemptUuid) return;
    setError(null);
    try {
      await saveResponses.mutateAsync(responsePayload);
      const result = await submitAttempt.mutateAsync({ attemptUuid, responses: responsePayload });
      navigate(`/student/enrollments/${enrollmentUuid}/quizzes/${quizUuid}/results/${result.data.uuid}`);
    } catch (err) {
      setError(getErrorMessage(err));
    }
  }

  if (quizLoading) return <LoadingSpinner label="Loading quiz..." />;

  if (!attemptUuid) {
    return (
      <div>
        <PageHeader title={quiz?.title ?? "Quiz"} description={quiz?.description ?? undefined} />
        <div className="max-w-2xl rounded-xl border border-slate-200 bg-white p-6">
          <ul className="space-y-2 text-sm text-slate-700">
            <li>Questions: {quiz?.question_count ?? 0}</li>
            <li>Passing score: {quiz?.passing_score}%</li>
            <li>Max attempts: {quiz?.max_attempts === 0 ? "Unlimited" : quiz?.max_attempts}</li>
            {quiz?.time_limit_minutes ? <li>Time limit: {quiz.time_limit_minutes} minutes</li> : null}
            {quiz?.attempts_remaining != null ? <li>Attempts remaining: {quiz.attempts_remaining}</li> : null}
          </ul>
          {error ? <p className="mt-4 text-sm text-red-600">{error}</p> : null}
          <Button className="mt-6" onClick={handleStart} disabled={startAttempt.isPending || quiz?.has_in_progress_attempt}>
            {quiz?.has_in_progress_attempt ? "Attempt in progress" : "Start quiz"}
          </Button>
        </div>
      </div>
    );
  }

  if (attemptLoading || !attempt) return <LoadingSpinner label="Loading attempt..." />;

  return (
    <div>
      <PageHeader
        title={quiz?.title ?? "Quiz"}
        action={
          <Link to={`/student/courses/${quiz?.course_uuid ?? ""}`}>
            <Button variant="secondary">Back to course</Button>
          </Link>
        }
      />

      {attempt.expires_at ? (
        <p className="mb-4 text-sm text-slate-600">Expires at {new Date(attempt.expires_at).toLocaleString()}</p>
      ) : null}

      <div className="space-y-4">
        {questions.map((question, index) => (
          <div key={question.uuid} className="rounded-xl border border-slate-200 bg-white p-5">
            <p className="font-medium text-slate-900">
              {index + 1}. {question.body}
            </p>
            <p className="mt-1 text-xs text-slate-500">{question.points} mark(s)</p>
            <div className="mt-4 space-y-2">
              {question.question_options?.map((option) => {
                const selected = answers[question.uuid]?.includes(option.uuid);
                const inputType = question.question_type === "multiple_choice" ? "checkbox" : "radio";
                return (
                  <label
                    key={option.uuid}
                    className={`flex cursor-pointer items-center gap-3 rounded-lg border px-3 py-2 text-sm ${
                      selected ? "border-blue-500 bg-blue-50" : "border-slate-200"
                    }`}
                  >
                    <input
                      type={inputType}
                      name={question.uuid}
                      checked={selected}
                      onChange={() => toggleAnswer(question, option.uuid)}
                    />
                    {option.body}
                  </label>
                );
              })}
            </div>
          </div>
        ))}
      </div>

      {error ? <p className="mt-4 text-sm text-red-600">{error}</p> : null}

      <div className="mt-6 flex gap-3">
        <Button variant="secondary" onClick={handleSave} disabled={saveResponses.isPending}>
          Save answers
        </Button>
        <Button onClick={handleSubmit} disabled={submitAttempt.isPending}>
          Submit quiz
        </Button>
      </div>
    </div>
  );
}
