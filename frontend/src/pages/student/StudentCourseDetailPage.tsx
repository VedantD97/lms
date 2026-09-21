import { useEffect, useState } from "react";
import { Link, useParams } from "react-router-dom";
import { Button } from "@/components/ui/Button";
import { Label, Textarea } from "@/components/ui/Field";
import { LoadingSpinner } from "@/components/feedback/LoadingSpinner";
import { StatusBadge } from "@/components/shared/PageHeader";
import { StudentFullBleed } from "@/components/layout/DashboardLayouts";
import { coverInitials, coverPaletteFor } from "@/components/catalog/courseCover";
import { useEnrollInCourse, useStudentCourse } from "@/features/student/catalog/hooks/useStudentCourses";
import { useStudentEnrollments } from "@/features/student/learning/hooks/useStudentLearning";
import { useEnrollmentQuizzes } from "@/features/student/quizzes/hooks/useStudentQuizzes";
import { useEnrollmentAssignments } from "@/features/student/assignments/hooks/useStudentAssignments";
import {
  useCourseReviews,
  useCreateReview,
  useDeleteReview,
  useUpdateReview,
} from "@/features/student/reviews/hooks/useStudentReviews";
import { formatRating, starSymbols } from "@/features/student/reviews/reviewHelpers";

function StarPicker({ value, onChange }: { value: number; onChange: (rating: number) => void }) {
  return (
    <div className="flex gap-1">
      {[1, 2, 3, 4, 5].map((rating) => (
        <button
          key={rating}
          type="button"
          onClick={() => onChange(rating)}
          className={`text-2xl transition hover:scale-110 ${rating <= value ? "text-amber-500" : "text-slate-300"}`}
          aria-label={`Rate ${rating} stars`}
        >
          ★
        </button>
      ))}
    </div>
  );
}

export function StudentCourseDetailPage() {
  const { uuid } = useParams();
  const { data: course, isLoading } = useStudentCourse(uuid ?? "");
  const { data: enrollmentsData } = useStudentEnrollments();
  const enroll = useEnrollInCourse();
  const { data: reviewsData, isLoading: reviewsLoading } = useCourseReviews(uuid ?? "");
  const createReview = useCreateReview(uuid ?? "");
  const updateReview = useUpdateReview(uuid ?? "");
  const deleteReview = useDeleteReview(uuid ?? "");

  const [rating, setRating] = useState(5);
  const [body, setBody] = useState("");

  const enrollment = enrollmentsData?.data.find((item) => item.course.uuid === uuid);
  const { data: quizzes } = useEnrollmentQuizzes(enrollment?.uuid ?? "");
  const { data: assignments } = useEnrollmentAssignments(enrollment?.uuid ?? "");
  const myReview = course?.my_review ?? null;

  useEffect(() => {
    if (myReview) {
      setRating(myReview.rating);
      setBody(myReview.body ?? "");
    }
  }, [myReview]);

  if (isLoading) return <LoadingSpinner label="Loading course..." />;
  if (!course) return <p className="text-sm text-slate-600">Course not found.</p>;

  const reviewCount = Number(reviewsData?.meta?.review_count ?? course.review_count ?? 0);
  const averageRating =
    reviewsData?.meta?.average_rating != null
      ? Number(reviewsData.meta.average_rating)
      : course.average_rating;
  const palette = coverPaletteFor(course.uuid || course.title);
  const lessonCount =
    course.modules?.reduce((sum, module) => sum + (module.lessons?.length ?? 0), 0) ?? 0;

  async function handleReviewSubmit(event: React.FormEvent) {
    event.preventDefault();
    const payload = { rating, body: body.trim() || undefined };

    if (myReview) {
      await updateReview.mutateAsync({ uuid: myReview.uuid, ...payload });
    } else {
      await createReview.mutateAsync(payload);
    }
  }

  const reviewPending = createReview.isPending || updateReview.isPending || deleteReview.isPending;

  return (
    <div>
      <StudentFullBleed>
      <section
        className="relative overflow-hidden border-b border-ink-soft text-white"
        style={{
          background: `linear-gradient(135deg, ${palette.to} 0%, #0b1f2a 55%, ${palette.from} 140%)`,
        }}
      >
        <div
          className="pointer-events-none absolute inset-0 opacity-20"
          style={{
            backgroundImage:
              "radial-gradient(circle at 20% 20%, white 0.6px, transparent 0.7px)",
            backgroundSize: "22px 22px",
          }}
        />
        <div className="relative mx-auto max-w-[1400px] px-4 py-10 sm:px-6 sm:py-12">
          <Link
            to="/student/catalog"
            className="inline-flex items-center gap-1 text-sm font-medium text-white/70 transition hover:text-white"
          >
            ← Back to catalog
          </Link>

          <div className="mt-6 grid gap-8 lg:grid-cols-[1fr_320px]">
            <div className="animate-fade-up min-w-0">
              <div className="flex flex-wrap items-center gap-2">
                <StatusBadge status={course.status} />
                <span className="rounded-md bg-white/15 px-2 py-0.5 text-[11px] font-semibold uppercase tracking-wide">
                  {course.level}
                </span>
                {course.categories?.[0] ? (
                  <span className="text-sm text-teal-200">{course.categories[0].name}</span>
                ) : null}
              </div>
              <h1 className="mt-4 font-display text-3xl font-bold tracking-tight sm:text-4xl">
                {course.title}
              </h1>
              {course.short_description ? (
                <p className="mt-3 max-w-2xl text-base text-slate-200">{course.short_description}</p>
              ) : null}
              <div className="mt-5 flex flex-wrap items-center gap-4 text-sm text-slate-200">
                {reviewCount > 0 && averageRating != null ? (
                  <span className="font-semibold text-amber-300">
                    {starSymbols(averageRating)} {formatRating(averageRating, reviewCount)}
                  </span>
                ) : (
                  <span>No reviews yet</span>
                )}
                {course.duration_minutes ? <span>{course.duration_minutes} minutes</span> : null}
                {lessonCount ? <span>{lessonCount} lessons</span> : null}
                {course.modules?.length ? <span>{course.modules.length} modules</span> : null}
              </div>
            </div>

            <aside className="animate-fade-up stagger-2 hidden lg:block" aria-hidden>
              <div
                className="flex aspect-video items-end rounded-2xl p-5 shadow-2xl"
                style={{
                  background: `linear-gradient(145deg, ${palette.from}, ${palette.to})`,
                }}
              >
                <span className="font-display text-4xl font-bold text-white/90">
                  {coverInitials(course.title)}
                </span>
              </div>
            </aside>
          </div>
        </div>
      </section>
      </StudentFullBleed>

        <div className="grid gap-8 lg:grid-cols-[minmax(0,1fr)_320px]">
          <div className="min-w-0 space-y-8">
            {enrollment?.continue_learning ? (
              <div className="animate-fade-up flex flex-wrap items-center justify-between gap-4 rounded-2xl border border-brand/25 bg-brand-muted/60 p-5">
                <div>
                  <p className="font-display text-lg font-semibold text-ink">Continue where you left off</p>
                  <p className="mt-1 text-sm text-slate-700">{enrollment.continue_learning.lesson_title}</p>
                </div>
                <Link
                  to={`/student/enrollments/${enrollment.uuid}/lessons/${enrollment.continue_learning.lesson_uuid}`}
                >
                  <Button>Resume lesson</Button>
                </Link>
              </div>
            ) : null}

            {course.description ? (
              <section className="animate-fade-up rounded-2xl border border-line bg-white p-6 shadow-sm">
                <h2 className="font-display text-xl font-bold text-ink">About this course</h2>
                <p className="mt-3 whitespace-pre-wrap text-sm leading-relaxed text-slate-700">
                  {course.description}
                </p>
              </section>
            ) : null}

            <section className="animate-fade-up">
              <h2 className="mb-4 font-display text-xl font-bold text-ink">Curriculum</h2>
              <div className="space-y-3">
                {course.modules?.map((module, moduleIndex) => (
                  <details
                    key={module.uuid}
                    open={moduleIndex === 0}
                    className="group overflow-hidden rounded-2xl border border-line bg-white shadow-sm open:shadow-md"
                  >
                    <summary className="cursor-pointer list-none px-5 py-4 marker:content-none">
                      <div className="flex items-center justify-between gap-3">
                        <div>
                          <h3 className="font-semibold text-ink">{module.title}</h3>
                          {module.description ? (
                            <p className="mt-1 text-sm text-slate-600">{module.description}</p>
                          ) : null}
                        </div>
                        <span className="shrink-0 text-xs font-medium text-slate-500">
                          {module.lessons?.length ?? 0} lessons
                        </span>
                      </div>
                    </summary>
                    <ul className="border-t border-line px-2 py-2">
                      {module.lessons?.map((lesson) => (
                        <li key={lesson.uuid}>
                          {enrollment ? (
                            <Link
                              to={`/student/enrollments/${enrollment.uuid}/lessons/${lesson.uuid}`}
                              className="flex items-center justify-between rounded-xl px-3 py-2.5 text-sm transition hover:bg-brand-muted/50"
                            >
                              <span className="text-ink">{lesson.title}</span>
                              {lesson.is_preview ? (
                                <span className="text-xs font-medium text-emerald-700">Preview</span>
                              ) : null}
                            </Link>
                          ) : (
                            <div className="flex items-center justify-between rounded-xl px-3 py-2.5 text-sm text-slate-500">
                              <span>{lesson.title}</span>
                              <span className="text-xs">Enroll to access</span>
                            </div>
                          )}
                        </li>
                      ))}
                    </ul>
                  </details>
                ))}
              </div>
            </section>

            {enrollment && assignments?.length ? (
              <section>
                <h2 className="mb-4 font-display text-xl font-bold text-ink">Assignments</h2>
                <div className="space-y-3">
                  {assignments.map((assignment) => (
                    <Link
                      key={assignment.uuid}
                      to={`/student/enrollments/${enrollment.uuid}/assignments/${assignment.uuid}`}
                      className="block rounded-2xl border border-line bg-white p-4 shadow-sm transition hover:border-brand/40 hover:shadow-md"
                    >
                      <div className="flex items-center justify-between gap-3">
                        <div>
                          <span className="font-medium text-ink">{assignment.title}</span>
                          <p className="text-sm text-slate-600">Max {assignment.max_points} points</p>
                        </div>
                        <div className="text-right text-sm">
                          {assignment.passed ? (
                            <span className="font-medium text-emerald-700">Passed</span>
                          ) : assignment.submission_status === "submitted" ? (
                            <span className="text-amber-700">Submitted</span>
                          ) : assignment.required_for_completion === false ? (
                            <span className="text-slate-500">Optional</span>
                          ) : (
                            <span className="text-slate-500">Required</span>
                          )}
                        </div>
                      </div>
                    </Link>
                  ))}
                </div>
              </section>
            ) : null}

            {enrollment && quizzes?.length ? (
              <section>
                <h2 className="mb-4 font-display text-xl font-bold text-ink">Quizzes</h2>
                <div className="space-y-3">
                  {quizzes.map((quiz) => (
                    <Link
                      key={quiz.uuid}
                      to={`/student/enrollments/${enrollment.uuid}/quizzes/${quiz.uuid}`}
                      className="block rounded-2xl border border-line bg-white p-4 shadow-sm transition hover:border-brand/40 hover:shadow-md"
                    >
                      <div className="flex items-center justify-between gap-3">
                        <div>
                          <span className="font-medium text-ink">{quiz.title}</span>
                          <p className="text-sm text-slate-600">
                            {quiz.question_count} questions · pass {quiz.passing_score}%
                          </p>
                        </div>
                        <div className="text-right text-sm">
                          {quiz.passed ? (
                            <span className="font-medium text-emerald-700">Passed</span>
                          ) : quiz.required_for_completion === false ? (
                            <span className="text-slate-500">Optional</span>
                          ) : quiz.best_percentage != null ? (
                            <span className="text-amber-700">Best: {quiz.best_percentage}%</span>
                          ) : (
                            <span className="text-slate-500">Required</span>
                          )}
                        </div>
                      </div>
                    </Link>
                  ))}
                </div>
              </section>
            ) : null}

            <section>
              <h2 className="mb-4 font-display text-xl font-bold text-ink">Reviews</h2>

              {enrollment ? (
                <form
                  onSubmit={handleReviewSubmit}
                  className="mb-6 rounded-2xl border border-line bg-white p-5 shadow-sm"
                >
                  <h3 className="font-medium text-ink">{myReview ? "Update your review" : "Write a review"}</h3>
                  <div className="mt-4">
                    <Label htmlFor="rating">Rating</Label>
                    <StarPicker value={rating} onChange={setRating} />
                  </div>
                  <div className="mt-4">
                    <Label htmlFor="body">Comments (optional)</Label>
                    <Textarea
                      id="body"
                      value={body}
                      onChange={(event) => setBody(event.target.value)}
                      rows={4}
                      placeholder="Share your experience with this course"
                    />
                  </div>
                  <div className="mt-4 flex flex-wrap gap-2">
                    <Button type="submit" disabled={reviewPending}>
                      {myReview ? "Update review" : "Submit review"}
                    </Button>
                    {myReview ? (
                      <Button
                        type="button"
                        variant="secondary"
                        disabled={reviewPending}
                        onClick={() => deleteReview.mutate(myReview.uuid)}
                      >
                        Delete review
                      </Button>
                    ) : null}
                  </div>
                </form>
              ) : (
                <p className="mb-6 text-sm text-slate-600">Enroll in this course to leave a review.</p>
              )}

              {reviewsLoading ? (
                <LoadingSpinner label="Loading reviews..." />
              ) : reviewsData?.data.length ? (
                <div className="space-y-3">
                  {reviewsData.data.map((review) => (
                    <div key={review.uuid} className="rounded-2xl border border-line bg-white p-4 shadow-sm">
                      <div className="flex items-center justify-between gap-3">
                        <div>
                          <p className="font-medium text-ink">
                            {review.user.first_name} {review.user.last_name}
                          </p>
                          <p className="text-sm text-amber-600">
                            {starSymbols(review.rating)} {review.rating}/5
                          </p>
                        </div>
                        <span className="text-xs text-slate-500">
                          {new Date(review.created_at).toLocaleDateString()}
                        </span>
                      </div>
                      {review.body ? <p className="mt-3 text-sm text-slate-700">{review.body}</p> : null}
                    </div>
                  ))}
                </div>
              ) : (
                <p className="text-sm text-slate-600">No reviews yet. Be the first to share feedback.</p>
              )}
            </section>
          </div>

          <aside className="lg:sticky lg:top-24 lg:self-start">
            <div className="animate-fade-up stagger-3 overflow-hidden rounded-2xl border border-line bg-white shadow-lg">
              <div
                className="flex aspect-video items-end p-4 lg:hidden"
                style={{
                  background: `linear-gradient(145deg, ${palette.from}, ${palette.to})`,
                }}
              >
                <span className="font-display text-3xl font-bold text-white/90">
                  {coverInitials(course.title)}
                </span>
              </div>
              <div className="p-5">
                {!enrollment ? (
                  <>
                    <p className="font-display text-lg font-bold text-ink">Ready to start?</p>
                    <p className="mt-1 text-sm text-slate-600">
                      Enroll free and unlock the full curriculum, quizzes, and assignments.
                    </p>
                    <Button
                      className="mt-4 w-full"
                      onClick={() => enroll.mutate(course.uuid)}
                      disabled={enroll.isPending}
                    >
                      {enroll.isPending ? "Enrolling..." : "Enroll now"}
                    </Button>
                  </>
                ) : (
                  <>
                    <p className="font-display text-lg font-bold text-ink">You&apos;re enrolled</p>
                    <p className="mt-1 text-sm text-emerald-700">
                      {enrollment.progress_percent}% complete
                      {enrollment.progress_summary
                        ? ` · ${enrollment.progress_summary.completed_items}/${enrollment.progress_summary.total_items} items`
                        : ""}
                    </p>
                    <div className="mt-3 h-2 overflow-hidden rounded-full bg-slate-100">
                      <div
                        className="h-full rounded-full bg-brand transition-all"
                        style={{ width: `${enrollment.progress_percent}%` }}
                      />
                    </div>
                    {enrollment.continue_learning ? (
                      <Link
                        to={`/student/enrollments/${enrollment.uuid}/lessons/${enrollment.continue_learning.lesson_uuid}`}
                        className="mt-4 block"
                      >
                        <Button className="w-full">Resume lesson</Button>
                      </Link>
                    ) : (
                      <Link to="/student/my-courses" className="mt-4 block">
                        <Button className="w-full" variant="secondary">
                          Go to my learning
                        </Button>
                      </Link>
                    )}
                  </>
                )}

                <ul className="mt-5 space-y-2 border-t border-line pt-4 text-sm text-slate-600">
                  <li className="flex justify-between gap-3">
                    <span>Level</span>
                    <span className="font-medium capitalize text-ink">{course.level}</span>
                  </li>
                  {course.duration_minutes ? (
                    <li className="flex justify-between gap-3">
                      <span>Duration</span>
                      <span className="font-medium text-ink">{course.duration_minutes} min</span>
                    </li>
                  ) : null}
                  <li className="flex justify-between gap-3">
                    <span>Lessons</span>
                    <span className="font-medium text-ink">{lessonCount}</span>
                  </li>
                  <li className="flex justify-between gap-3">
                    <span>Modules</span>
                    <span className="font-medium text-ink">{course.modules?.length ?? 0}</span>
                  </li>
                </ul>
              </div>
            </div>
          </aside>
        </div>
    </div>
  );
}
