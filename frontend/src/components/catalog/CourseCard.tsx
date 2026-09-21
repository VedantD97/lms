import { Link } from "react-router-dom";
import { StatusBadge } from "@/components/shared/PageHeader";
import { coverInitials, coverPaletteFor } from "@/components/catalog/courseCover";
import { cn } from "@/lib/utils/cn";

export type CourseCardCourse = {
  uuid: string;
  title: string;
  short_description?: string | null;
  status: string;
  level: string;
  average_rating?: number | null;
  review_count?: number;
  duration_minutes?: number | null;
  categories?: { name: string }[];
};

export function CourseCard({
  course,
  to,
  action,
  className,
  showStatus = true,
}: {
  course: CourseCardCourse;
  to: string;
  action?: React.ReactNode;
  className?: string;
  showStatus?: boolean;
}) {
  const palette = coverPaletteFor(course.uuid || course.title);
  const category = course.categories?.[0]?.name;
  const hasRating = Boolean(course.review_count && course.average_rating != null);

  return (
    <article
      className={cn(
        "group flex h-full flex-col overflow-hidden rounded-xl border border-line bg-surface-elevated shadow-sm transition duration-200 hover:-translate-y-1 hover:border-brand/30 hover:shadow-lg",
        className,
      )}
    >
      <Link to={to} className="relative block aspect-[16/9] overflow-hidden">
        <div
          className="absolute inset-0 transition duration-300 group-hover:scale-105"
          style={{
            background: `linear-gradient(135deg, ${palette.from} 0%, ${palette.to} 100%)`,
          }}
        />
        <div
          className="absolute inset-0 opacity-30"
          style={{
            backgroundImage:
              "radial-gradient(circle at 20% 20%, white 0.5px, transparent 0.6px), radial-gradient(circle at 80% 60%, white 0.5px, transparent 0.6px)",
            backgroundSize: "18px 18px, 24px 24px",
          }}
        />
        <div className="absolute inset-0 flex items-end justify-between p-4">
          <span className="font-display text-3xl font-bold tracking-tight text-white/90">
            {coverInitials(course.title)}
          </span>
          <span className="rounded-md bg-black/25 px-2 py-1 text-[11px] font-semibold uppercase tracking-wide text-white backdrop-blur-sm">
            {course.level}
          </span>
        </div>
      </Link>

      <div className="flex flex-1 flex-col p-4">
        <div className="flex items-start justify-between gap-2">
          <div className="min-w-0 flex-1">
            {category ? (
              <p className="mb-1 truncate text-xs font-medium text-brand">{category}</p>
            ) : null}
            <Link
              to={to}
              className="line-clamp-2 font-display text-base font-semibold leading-snug text-ink transition group-hover:text-brand"
            >
              {course.title}
            </Link>
          </div>
          {showStatus ? <StatusBadge status={course.status} /> : null}
        </div>

        <p className="mt-2 line-clamp-2 text-sm text-slate-600">
          {course.short_description || "No description yet."}
        </p>

        <div className="mt-auto flex items-center justify-between gap-3 pt-4">
          <div className="flex flex-col gap-0.5">
            {hasRating ? (
              <span className="text-sm font-semibold text-amber-600">
                ★ {course.average_rating!.toFixed(1)}
                <span className="ml-1 font-normal text-slate-500">({course.review_count})</span>
              </span>
            ) : (
              <span className="text-xs text-slate-500">New course</span>
            )}
            {course.duration_minutes ? (
              <span className="text-xs text-slate-500">{course.duration_minutes} min</span>
            ) : null}
          </div>
          {action}
        </div>
      </div>
    </article>
  );
}
