import { Link } from "react-router-dom";
import { Button } from "@/components/ui/Button";
import { EmptyState } from "@/components/feedback/EmptyState";
import { LoadingSpinner } from "@/components/feedback/LoadingSpinner";
import { PageHeader } from "@/components/shared/PageHeader";
import { coverInitials, coverPaletteFor } from "@/components/catalog/courseCover";
import { useStudentEnrollments } from "@/features/student/learning/hooks/useStudentLearning";

function progressDetail(enrollment: {
  progress_summary?: {
    completed_items: number;
    total_items: number;
    passed_quizzes: number;
    total_quizzes: number;
    passed_assignments: number;
    total_assignments: number;
  };
  progress_percent: number;
}) {
  const summary = enrollment.progress_summary;
  if (!summary) return `${enrollment.progress_percent}% complete`;

  const items = `${summary.completed_items}/${summary.total_items} items`;
  const pendingQuizzes = summary.total_quizzes > 0 && summary.passed_quizzes < summary.total_quizzes;
  const pendingAssignments =
    summary.total_assignments > 0 && summary.passed_assignments < summary.total_assignments;

  if (pendingQuizzes || pendingAssignments) {
    const parts = [items];
    if (pendingQuizzes) parts.push(`${summary.passed_quizzes}/${summary.total_quizzes} quizzes passed`);
    if (pendingAssignments) parts.push(`${summary.passed_assignments}/${summary.total_assignments} assignments passed`);
    return parts.join(" · ");
  }

  return items;
}

export function StudentMyCoursesPage() {
  const { data, isLoading } = useStudentEnrollments();

  return (
    <div>
      <PageHeader
        title="My learning"
        description="Continue learning where you left off."
        action={
          <Link to="/student/catalog">
            <Button variant="secondary">Browse catalog</Button>
          </Link>
        }
      />

      {isLoading ? (
        <LoadingSpinner label="Loading your courses..." />
      ) : !data?.data.length ? (
        <EmptyState
          title="No enrolled courses"
          description="Browse the catalog and enroll in a course to start learning."
        />
      ) : (
        <div className="grid gap-5 md:grid-cols-2 xl:grid-cols-3">
          {data.data.map((enrollment) => {
            const pendingQuizzes =
              enrollment.progress_summary &&
              enrollment.progress_summary.total_quizzes > 0 &&
              enrollment.progress_summary.passed_quizzes < enrollment.progress_summary.total_quizzes &&
              !enrollment.continue_learning;
            const pendingAssignments =
              enrollment.progress_summary &&
              enrollment.progress_summary.total_assignments > 0 &&
              enrollment.progress_summary.passed_assignments < enrollment.progress_summary.total_assignments &&
              !enrollment.continue_learning;
            const palette = coverPaletteFor(enrollment.course.uuid || enrollment.course.title);

            return (
              <article
                key={enrollment.uuid}
                className="overflow-hidden rounded-2xl border border-line bg-white shadow-sm transition hover:-translate-y-1 hover:shadow-lg"
              >
                <Link to={`/student/courses/${enrollment.course.uuid}`} className="block">
                  <div
                    className="flex aspect-[16/9] items-end p-4"
                    style={{
                      background: `linear-gradient(135deg, ${palette.from}, ${palette.to})`,
                    }}
                  >
                    <span className="font-display text-2xl font-bold text-white/90">
                      {coverInitials(enrollment.course.title)}
                    </span>
                  </div>
                </Link>
                <div className="p-5">
                  <div className="flex items-start justify-between gap-3">
                    <Link
                      to={`/student/courses/${enrollment.course.uuid}`}
                      className="font-display text-lg font-semibold text-ink hover:text-brand"
                    >
                      {enrollment.course.title}
                    </Link>
                    <span className="shrink-0 text-sm font-semibold text-brand">
                      {enrollment.progress_percent}%
                    </span>
                  </div>

                  <p className="mt-1 text-sm text-slate-600">
                    {enrollment.course.short_description || "Keep going — you're making progress."}
                  </p>

                  <p className="mt-2 text-xs text-slate-500">{progressDetail(enrollment)}</p>

                  <div className="mt-4 h-2 overflow-hidden rounded-full bg-slate-100">
                    <div
                      className="h-full rounded-full bg-brand transition-all"
                      style={{ width: `${enrollment.progress_percent}%` }}
                    />
                  </div>

                  {enrollment.continue_learning ? (
                    <div className="mt-4 rounded-xl bg-brand-muted/50 p-3 text-sm">
                      <p className="font-medium text-ink">
                        Continue: {enrollment.continue_learning.lesson_title}
                      </p>
                      <p className="text-slate-600">{enrollment.continue_learning.module_title}</p>
                      <Link
                        to={`/student/enrollments/${enrollment.uuid}/lessons/${enrollment.continue_learning.lesson_uuid}`}
                        className="mt-3 inline-block"
                      >
                        <Button>Resume lesson</Button>
                      </Link>
                    </div>
                  ) : pendingQuizzes || pendingAssignments ? (
                    <div className="mt-4 rounded-xl bg-amber-50 p-3 text-sm">
                      <p className="font-medium text-amber-900">
                        Lessons complete — finish required{" "}
                        {pendingQuizzes && pendingAssignments
                          ? "quizzes and assignments"
                          : pendingQuizzes
                            ? "quizzes"
                            : "assignments"}{" "}
                        to complete the course
                      </p>
                      <Link to={`/student/courses/${enrollment.course.uuid}`} className="mt-3 inline-block">
                        <Button variant="secondary">View course</Button>
                      </Link>
                    </div>
                  ) : enrollment.status === "completed" ? (
                    <div className="mt-4 rounded-xl bg-emerald-50 p-3 text-sm">
                      <p className="font-medium text-emerald-900">Course completed.</p>
                      {enrollment.certificate ? (
                        <Link
                          to="/student/certificates"
                          className="mt-2 inline-block text-emerald-800 hover:underline"
                        >
                          View certificate ({enrollment.certificate.certificate_number})
                        </Link>
                      ) : null}
                    </div>
                  ) : (
                    <p className="mt-4 text-sm text-slate-600">All required items completed.</p>
                  )}
                </div>
              </article>
            );
          })}
        </div>
      )}
    </div>
  );
}
