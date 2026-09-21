import { Link } from "react-router-dom";
import { LoadingSpinner } from "@/components/feedback/LoadingSpinner";
import { PageHeader } from "@/components/shared/PageHeader";
import { useAdminQuizzes, useQuizStatistics } from "@/features/admin/quizzes/hooks/useAdminQuizzes";
import { useState } from "react";

export function AdminQuizzesPage() {
  const [page, setPage] = useState(1);
  const { data, isLoading } = useAdminQuizzes({ page });
  const [selectedQuiz, setSelectedQuiz] = useState<string>("");
  const { data: stats, isLoading: statsLoading } = useQuizStatistics(selectedQuiz);

  return (
    <div>
      <PageHeader title="Quiz statistics" description="Review quiz performance across the platform." />

      {isLoading ? (
        <LoadingSpinner label="Loading quizzes..." />
      ) : (
        <div className="grid gap-6 lg:grid-cols-2">
          <div className="rounded-xl border border-slate-200 bg-white">
            <div className="border-b border-slate-100 px-4 py-3 font-medium text-slate-900">Quizzes</div>
            <ul className="divide-y divide-slate-100">
              {data?.data.map((quiz) => (
                <li key={quiz.uuid}>
                  <button
                    type="button"
                    className="flex w-full items-center justify-between px-4 py-3 text-left text-sm hover:bg-slate-50"
                    onClick={() => setSelectedQuiz(quiz.uuid)}
                  >
                    <span>{quiz.title}</span>
                    <span className="text-slate-500">{quiz.question_count ?? 0} questions</span>
                  </button>
                </li>
              ))}
            </ul>
          </div>

          <div className="rounded-xl border border-slate-200 bg-white p-6">
            {!selectedQuiz ? (
              <p className="text-sm text-slate-600">Select a quiz to view statistics.</p>
            ) : statsLoading ? (
              <LoadingSpinner label="Loading statistics..." />
            ) : stats ? (
              <div className="space-y-3 text-sm">
                <h2 className="text-lg font-semibold text-slate-900">{stats.title}</h2>
                <p>Total attempts: {stats.total_attempts}</p>
                <p>Completed attempts: {stats.completed_attempts}</p>
                <p>Average score: {stats.average_score}</p>
                <p>Average percentage: {stats.average_percentage}%</p>
                <p>Pass rate: {stats.pass_rate}%</p>
                <p>Unique students: {stats.unique_students}</p>
                <Link to={`/admin/courses/${stats.uuid}`} className="hidden" />
              </div>
            ) : null}
          </div>
        </div>
      )}

      {data?.meta && data.meta.total > data.meta.per_page ? (
        <div className="mt-6 flex gap-2">
          <button type="button" className="rounded-lg border px-3 py-2 text-sm" disabled={page <= 1} onClick={() => setPage(page - 1)}>
            Previous
          </button>
          <button
            type="button"
            className="rounded-lg border px-3 py-2 text-sm"
            disabled={page * data.meta.per_page >= data.meta.total}
            onClick={() => setPage(page + 1)}
          >
            Next
          </button>
        </div>
      ) : null}
    </div>
  );
}
