import { Link } from "react-router-dom";
import { Button } from "@/components/ui/Button";
import { LoadingSpinner } from "@/components/feedback/LoadingSpinner";
import { CourseCard } from "@/components/catalog/CourseCard";
import { StudentFullBleed } from "@/components/layout/DashboardLayouts";
import { useAuth } from "@/lib/auth/AuthContext";
import { useStudentDashboard } from "@/features/student/dashboard/hooks/useStudentDashboard";
import { useCategories, useStudentCourses } from "@/features/student/catalog/hooks/useStudentCourses";
import { pendingActionsLabel } from "@/features/student/dashboard/studentDashboardHelpers";
import { coverInitials, coverPaletteFor } from "@/components/catalog/courseCover";
import { cn } from "@/lib/utils/cn";

function MetricLink({
  to,
  label,
  value,
  hint,
  accent,
}: {
  to: string;
  label: string;
  value: string | number;
  hint?: string;
  accent?: string;
}) {
  return (
    <Link
      to={to}
      className="group flex min-w-0 flex-1 items-center gap-3 rounded-2xl border border-line bg-white px-4 py-3.5 shadow-sm transition hover:-translate-y-0.5 hover:border-brand/30 hover:shadow-md"
    >
      <span
        className={cn(
          "flex h-10 w-10 shrink-0 items-center justify-center rounded-xl font-display text-sm font-bold text-white",
          accent ?? "bg-brand",
        )}
      >
        {typeof value === "number" ? (value > 99 ? "99+" : value) : value.toString().slice(0, 3)}
      </span>
      <span className="min-w-0">
        <span className="block truncate text-sm font-semibold text-ink group-hover:text-brand">{label}</span>
        {hint ? <span className="mt-0.5 block truncate text-xs text-slate-500">{hint}</span> : null}
      </span>
    </Link>
  );
}

function SectionHeading({
  title,
  description,
  action,
}: {
  title: string;
  description?: string;
  action?: React.ReactNode;
}) {
  return (
    <div className="mb-4 flex items-end justify-between gap-3">
      <div>
        <h2 className="font-display text-xl font-bold tracking-tight text-ink">{title}</h2>
        {description ? <p className="mt-0.5 text-sm text-slate-600">{description}</p> : null}
      </div>
      {action}
    </div>
  );
}

export function StudentDashboardPage() {
  const { user } = useAuth();
  const { data, isLoading } = useStudentDashboard();
  const { data: catalog } = useStudentCourses({ page: 1, per_page: 8 });
  const { data: categories } = useCategories();

  const firstName = user?.first_name?.trim() || "there";
  const featured = data?.continue_learning[0];
  const featuredPalette = featured ? coverPaletteFor(featured.course_title) : null;
  const moreContinue = data?.continue_learning.slice(1) ?? [];
  const hasPending =
    Boolean(data) && (data!.pending_actions.quizzes > 0 || data!.pending_actions.assignments > 0);

  return (
    <div>
      <StudentFullBleed>
        <section className="relative overflow-hidden border-b border-line bg-ink text-white">
          <div
            className="pointer-events-none absolute inset-0"
            style={{
              background:
                "radial-gradient(ellipse at 12% 0%, rgb(15 118 110 / 0.5), transparent 48%), radial-gradient(ellipse at 92% 40%, rgb(14 116 144 / 0.28), transparent 42%)",
            }}
          />
          <div className="relative mx-auto max-w-[1400px] px-4 py-8 sm:px-6 sm:py-10">
            {isLoading || !data ? (
              <div className="py-8">
                <LoadingSpinner label="Loading your dashboard..." />
              </div>
            ) : (
              <div className="grid items-stretch gap-8 lg:grid-cols-[minmax(0,1.15fr)_minmax(280px,0.85fr)]">
                <div className="animate-fade-up flex flex-col justify-center">
                  <p className="text-sm font-semibold uppercase tracking-[0.2em] text-teal-200/90">
                    Welcome back
                  </p>
                  <h1 className="mt-3 font-display text-3xl font-bold tracking-tight sm:text-4xl">
                    Hi {firstName}, let&apos;s keep learning
                  </h1>
                  <p className="mt-3 max-w-xl text-sm text-slate-300 sm:text-base">
                    {featured
                      ? `You're ${featured.progress_percent}% through “${featured.lesson_title}” in ${featured.course_title}.`
                      : data.enrollments.total
                        ? "No active lesson right now — jump back into a course or explore something new."
                        : "Browse the catalog and enroll to start your first course."}
                  </p>
                  <div className="mt-6 flex flex-wrap gap-3">
                    {featured ? (
                      <Link
                        to={`/student/enrollments/${featured.enrollment_uuid}/lessons/${featured.lesson_uuid}`}
                      >
                        <Button className="bg-white text-ink hover:bg-teal-50">Resume lesson</Button>
                      </Link>
                    ) : (
                      <Link to="/student/catalog">
                        <Button className="bg-white text-ink hover:bg-teal-50">Browse courses</Button>
                      </Link>
                    )}
                    <Link to="/student/my-courses">
                      <Button
                        variant="secondary"
                        className="border-white/20 bg-white/10 text-white hover:bg-white/20"
                      >
                        My learning
                      </Button>
                    </Link>
                  </div>
                </div>

                {featured ? (
                  <Link
                    to={`/student/enrollments/${featured.enrollment_uuid}/lessons/${featured.lesson_uuid}`}
                    className="animate-fade-up stagger-2 group block overflow-hidden rounded-2xl border border-white/15 bg-white/10 shadow-2xl backdrop-blur transition hover:bg-white/15"
                  >
                    <div
                      className="relative flex aspect-[16/9] items-end p-5 sm:aspect-[21/9] lg:aspect-[16/10]"
                      style={{
                        background: `linear-gradient(135deg, ${featuredPalette!.from}, ${featuredPalette!.to})`,
                      }}
                    >
                      <div className="absolute inset-0 bg-gradient-to-t from-black/55 via-black/10 to-transparent" />
                      <div className="relative">
                        <p className="text-xs font-semibold uppercase tracking-wide text-white/75">
                          Continue learning
                        </p>
                        <p className="mt-1 font-display text-xl font-bold text-white">
                          {featured.course_title}
                        </p>
                        <p className="mt-1 text-sm text-white/85">
                          {featured.module_title} · {featured.lesson_title}
                        </p>
                      </div>
                    </div>
                    <div className="p-4">
                      <div className="h-1.5 overflow-hidden rounded-full bg-white/20">
                        <div
                          className="h-full rounded-full bg-teal-300 transition-all"
                          style={{ width: `${featured.progress_percent}%` }}
                        />
                      </div>
                      <div className="mt-3 flex items-center justify-between gap-3 text-sm">
                        <span className="text-slate-200">{featured.progress_percent}% complete</span>
                        <span className="font-semibold text-teal-200 group-hover:underline">
                          Resume →
                        </span>
                      </div>
                    </div>
                  </Link>
                ) : (
                  <div className="animate-fade-up stagger-2 flex flex-col justify-center rounded-2xl border border-dashed border-white/25 bg-white/5 p-6">
                    <p className="font-display text-lg font-semibold text-white">Start something new</p>
                    <p className="mt-2 text-sm text-slate-300">
                      Discover courses by topic and enroll in minutes.
                    </p>
                    <Link to="/student/catalog" className="mt-4 inline-flex">
                      <Button className="bg-white text-ink hover:bg-teal-50">Explore catalog</Button>
                    </Link>
                  </div>
                )}
              </div>
            )}
          </div>
        </section>
      </StudentFullBleed>

      {isLoading || !data ? null : (
        <>
          <div className="scrollbar-thin -mx-1 flex gap-3 overflow-x-auto px-1 pb-1">
            <MetricLink
              to="/student/my-courses"
              label="Enrolled"
              value={data.enrollments.total}
              hint={`${data.enrollments.active} active · ${data.enrollments.completed} done`}
              accent="bg-brand"
            />
            <MetricLink
              to="/student/my-courses"
              label="Avg progress"
              value={`${data.average_progress.toFixed(0)}%`}
              hint="Across your courses"
              accent="bg-ink-soft"
            />
            <MetricLink
              to="/student/certificates"
              label="Certificates"
              value={data.certificates.active}
              hint={`${data.certificates.total} issued`}
              accent="bg-emerald-700"
            />
            <MetricLink
              to="/student/notifications"
              label="Notifications"
              value={data.notifications.unread_count}
              hint={data.notifications.unread_count ? "Unread" : "You're caught up"}
              accent="bg-sky-700"
            />
          </div>

          {categories?.length ? (
            <section className="mt-8">
              <SectionHeading
                title="Browse by topic"
                description="Jump into a category that matches your goals"
                action={
                  <Link to="/student/catalog" className="text-sm font-semibold text-brand hover:underline">
                    All courses
                  </Link>
                }
              />
              <div className="scrollbar-thin -mx-1 flex gap-2 overflow-x-auto px-1 pb-1">
                {categories.map((category) => (
                  <Link
                    key={category.uuid}
                    to={`/student/catalog?category=${encodeURIComponent(category.slug)}`}
                    className="shrink-0 rounded-full border border-line bg-white px-4 py-2 text-sm font-medium text-ink shadow-sm transition hover:-translate-y-0.5 hover:border-brand/40 hover:bg-brand-muted hover:text-brand"
                  >
                    {category.name}
                  </Link>
                ))}
              </div>
            </section>
          ) : null}

          <div className="mt-10 grid gap-8 xl:grid-cols-[minmax(0,1fr)_320px]">
            <div className="min-w-0 space-y-10">
              {moreContinue.length > 0 ? (
                <section>
                  <SectionHeading
                    title="More in progress"
                    description="Pick up another course where you left off"
                    action={
                      <Link
                        to="/student/my-courses"
                        className="text-sm font-semibold text-brand hover:underline"
                      >
                        View all
                      </Link>
                    }
                  />
                  <div className="scrollbar-thin -mx-1 flex gap-4 overflow-x-auto px-1 pb-2">
                    {moreContinue.map((item) => {
                      const palette = coverPaletteFor(item.course_title);
                      return (
                        <article
                          key={item.enrollment_uuid}
                          className="w-[min(100%,280px)] shrink-0 overflow-hidden rounded-2xl border border-line bg-white shadow-sm transition hover:-translate-y-1 hover:shadow-lg"
                        >
                          <Link
                            to={`/student/enrollments/${item.enrollment_uuid}/lessons/${item.lesson_uuid}`}
                            className="block"
                          >
                            <div
                              className="flex aspect-[16/9] items-end p-4"
                              style={{
                                background: `linear-gradient(135deg, ${palette.from}, ${palette.to})`,
                              }}
                            >
                              <span className="font-display text-2xl font-bold text-white/90">
                                {coverInitials(item.course_title)}
                              </span>
                            </div>
                            <div className="p-4">
                              <p className="line-clamp-2 font-display font-semibold text-ink">
                                {item.course_title}
                              </p>
                              <p className="mt-1 line-clamp-1 text-sm text-slate-600">
                                {item.lesson_title}
                              </p>
                              <div className="mt-3 h-1.5 overflow-hidden rounded-full bg-slate-100">
                                <div
                                  className="h-full rounded-full bg-brand"
                                  style={{ width: `${item.progress_percent}%` }}
                                />
                              </div>
                              <p className="mt-2 text-xs font-medium text-brand">
                                Resume · {item.progress_percent}%
                              </p>
                            </div>
                          </Link>
                        </article>
                      );
                    })}
                  </div>
                </section>
              ) : null}

              {catalog?.data.length ? (
                <section>
                  <SectionHeading
                    title="Recommended for you"
                    description="Fresh picks from the catalog"
                    action={
                      <Link
                        to="/student/catalog"
                        className="text-sm font-semibold text-brand hover:underline"
                      >
                        See all
                      </Link>
                    }
                  />
                  <div className="grid gap-5 sm:grid-cols-2">
                    {catalog.data.slice(0, 4).map((course) => (
                      <CourseCard
                        key={course.uuid}
                        course={course}
                        to={`/student/courses/${course.uuid}`}
                        showStatus={false}
                      />
                    ))}
                  </div>
                </section>
              ) : null}
            </div>

            <aside className="space-y-5 xl:sticky xl:top-24 xl:self-start">
              {hasPending ? (
                <div className="rounded-2xl border border-amber-200 bg-amber-50 p-5 shadow-sm">
                  <p className="text-xs font-semibold uppercase tracking-wide text-amber-800">
                    Needs attention
                  </p>
                  <p className="mt-2 font-display text-lg font-bold text-amber-950">
                    {pendingActionsLabel(data.pending_actions)}
                  </p>
                  <p className="mt-1 text-sm text-amber-900">
                    Finish these to keep your course completion on track.
                  </p>
                  <Link to="/student/my-courses" className="mt-4 inline-block">
                    <Button variant="secondary">Open my courses</Button>
                  </Link>
                </div>
              ) : (
                <div className="rounded-2xl border border-emerald-200 bg-emerald-50 p-5 shadow-sm">
                  <p className="text-xs font-semibold uppercase tracking-wide text-emerald-800">
                    Status
                  </p>
                  <p className="mt-2 font-display text-lg font-bold text-emerald-950">You&apos;re caught up</p>
                  <p className="mt-1 text-sm text-emerald-900">
                    No pending quizzes or assignments right now.
                  </p>
                </div>
              )}

              <div className="rounded-2xl border border-line bg-white p-5 shadow-sm">
                <div className="flex items-center justify-between gap-3">
                  <h3 className="font-display text-base font-bold text-ink">Notifications</h3>
                  <Link
                    to="/student/notifications"
                    className="text-xs font-semibold text-brand hover:underline"
                  >
                    View all
                  </Link>
                </div>
                {data.recent_notifications.length ? (
                  <ul className="mt-4 space-y-3">
                    {data.recent_notifications.slice(0, 4).map((notification) => (
                      <li key={notification.uuid}>
                        <Link
                          to="/student/notifications"
                          className={cn(
                            "block rounded-xl border px-3 py-2.5 transition hover:border-brand/40",
                            notification.read
                              ? "border-transparent bg-slate-50"
                              : "border-brand/20 bg-brand-muted/40",
                          )}
                        >
                          <p className="line-clamp-1 text-sm font-medium text-ink">
                            {notification.title ?? notification.notification_type}
                          </p>
                          <p className="mt-0.5 text-[11px] text-slate-500">
                            {new Date(notification.created_at).toLocaleDateString()}
                          </p>
                        </Link>
                      </li>
                    ))}
                  </ul>
                ) : (
                  <p className="mt-4 text-sm text-slate-600">No notifications yet.</p>
                )}
              </div>

              <div className="rounded-2xl border border-line bg-white p-5 shadow-sm">
                <h3 className="font-display text-base font-bold text-ink">Quick links</h3>
                <div className="mt-4 grid gap-2">
                  {[
                    ["/student/catalog", "Browse catalog"],
                    ["/student/my-courses", "My learning"],
                    ["/student/certificates", "Certificates"],
                    ["/student/notifications", "Notifications"],
                  ].map(([href, label]) => (
                    <Link
                      key={href}
                      to={href}
                      className="rounded-xl px-3 py-2.5 text-sm font-medium text-slate-700 transition hover:bg-brand-muted hover:text-brand"
                    >
                      {label} →
                    </Link>
                  ))}
                </div>
              </div>
            </aside>
          </div>
        </>
      )}
    </div>
  );
}
