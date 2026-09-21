import { useEffect, useState } from "react";
import { useSearchParams } from "react-router-dom";
import { EmptyState } from "@/components/feedback/EmptyState";
import { LoadingSpinner } from "@/components/feedback/LoadingSpinner";
import { CourseCard } from "@/components/catalog/CourseCard";
import { StudentFullBleed } from "@/components/layout/DashboardLayouts";
import { Pagination } from "@/components/shared/PageHeader";
import { useCategories, useStudentCourses } from "@/features/student/catalog/hooks/useStudentCourses";
import { useDebounce } from "@/lib/hooks/useDebounce";
import { cn } from "@/lib/utils/cn";

const LEVELS = [
  { value: "", label: "All levels" },
  { value: "beginner", label: "Beginner" },
  { value: "intermediate", label: "Intermediate" },
  { value: "advanced", label: "Advanced" },
] as const;

export function StudentCatalogPage() {
  const [searchParams, setSearchParams] = useSearchParams();
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState(searchParams.get("q") ?? "");
  const [level, setLevel] = useState("");
  const [category, setCategory] = useState(searchParams.get("category") ?? "");
  const debouncedSearch = useDebounce(search);

  useEffect(() => {
    const nextQ = searchParams.get("q") ?? "";
    const nextCategory = searchParams.get("category") ?? "";
    setSearch((current) => (current === nextQ ? current : nextQ));
    setCategory((current) => (current === nextCategory ? current : nextCategory));
    setPage(1);
  }, [searchParams]);

  useEffect(() => {
    const currentQ = searchParams.get("q") ?? "";
    const currentCategory = searchParams.get("category") ?? "";
    if (debouncedSearch === currentQ && category === currentCategory) return;

    const params = new URLSearchParams();
    if (debouncedSearch) params.set("q", debouncedSearch);
    if (category) params.set("category", category);
    setSearchParams(params, { replace: true });
  }, [debouncedSearch, category, searchParams, setSearchParams]);

  const { data, isLoading } = useStudentCourses({
    page,
    q: debouncedSearch || undefined,
    level: level || undefined,
    category: category || undefined,
  });
  const { data: categories } = useCategories();

  function selectCategory(slug: string) {
    setCategory(slug);
    setPage(1);
  }

  return (
    <div>
      <StudentFullBleed>
        <section className="relative overflow-hidden border-b border-line bg-ink text-white">
          <div
            className="pointer-events-none absolute inset-0 opacity-40"
            style={{
              background:
                "radial-gradient(ellipse at 15% 20%, rgb(15 118 110 / 0.55), transparent 45%), radial-gradient(ellipse at 90% 10%, rgb(14 116 144 / 0.35), transparent 40%)",
            }}
          />
          <div className="relative mx-auto max-w-[1400px] px-4 py-10 sm:px-6 sm:py-14">
            <p className="animate-fade-up text-sm font-semibold uppercase tracking-[0.2em] text-teal-200/90">
              Course catalog
            </p>
            <h1 className="animate-fade-up stagger-1 mt-3 max-w-2xl font-display text-3xl font-bold tracking-tight sm:text-4xl">
              What do you want to learn today?
            </h1>
            <p className="animate-fade-up stagger-2 mt-3 max-w-xl text-sm text-slate-300 sm:text-base">
              Browse published courses, filter by topic and level, and start learning in minutes.
            </p>

            <div className="animate-fade-up stagger-3 relative mt-8 max-w-2xl">
              <input
                value={search}
                onChange={(event) => {
                  setSearch(event.target.value);
                  setPage(1);
                }}
                placeholder="Search courses, skills, topics..."
                className="w-full rounded-full border border-white/15 bg-white/10 py-3.5 pl-12 pr-4 text-sm text-white outline-none backdrop-blur placeholder:text-slate-400 focus:border-teal-300/50 focus:bg-white/15 focus:ring-2 focus:ring-teal-400/30"
              />
              <svg
                className="pointer-events-none absolute left-4 top-1/2 h-5 w-5 -translate-y-1/2 text-slate-300"
                viewBox="0 0 20 20"
                fill="currentColor"
                aria-hidden
              >
                <path
                  fillRule="evenodd"
                  d="M9 3.5a5.5 5.5 0 100 11 5.5 5.5 0 000-11zM2 9a7 7 0 1112.452 4.391l3.328 3.329a.75.75 0 11-1.06 1.06l-3.329-3.328A7 7 0 012 9z"
                  clipRule="evenodd"
                />
              </svg>
            </div>

            {categories?.length ? (
              <div className="animate-fade-up stagger-4 mt-6 flex gap-2 overflow-x-auto pb-1 scrollbar-thin">
                <button
                  type="button"
                  onClick={() => selectCategory("")}
                  className={cn(
                    "shrink-0 rounded-full px-4 py-2 text-sm font-medium transition",
                    !category ? "bg-white text-ink" : "bg-white/10 text-slate-200 hover:bg-white/20",
                  )}
                >
                  All topics
                </button>
                {categories.map((item) => (
                  <button
                    key={item.uuid}
                    type="button"
                    onClick={() => selectCategory(item.slug)}
                    className={cn(
                      "shrink-0 rounded-full px-4 py-2 text-sm font-medium transition",
                      category === item.slug
                        ? "bg-white text-ink"
                        : "bg-white/10 text-slate-200 hover:bg-white/20",
                    )}
                  >
                    {item.name}
                  </button>
                ))}
              </div>
            ) : null}
          </div>
        </section>
      </StudentFullBleed>

      <div className="flex flex-col gap-8 lg:flex-row">
        <aside className="shrink-0 lg:sticky lg:top-24 lg:w-56 lg:self-start">
          <div className="rounded-2xl border border-line bg-white p-5 shadow-sm">
            <h2 className="font-display text-sm font-semibold uppercase tracking-wide text-slate-500">
              Filters
            </h2>

            <div className="mt-4">
              <p className="text-sm font-semibold text-ink">Level</p>
              <ul className="mt-2 space-y-1">
                {LEVELS.map((item) => (
                  <li key={item.value || "all"}>
                    <button
                      type="button"
                      onClick={() => {
                        setLevel(item.value);
                        setPage(1);
                      }}
                      className={cn(
                        "w-full rounded-lg px-3 py-2 text-left text-sm transition",
                        level === item.value
                          ? "bg-brand-muted font-medium text-brand"
                          : "text-slate-700 hover:bg-slate-50",
                      )}
                    >
                      {item.label}
                    </button>
                  </li>
                ))}
              </ul>
            </div>

            {categories?.length ? (
              <div className="mt-6 border-t border-line pt-5 lg:hidden">
                <p className="text-sm font-semibold text-ink">Category</p>
                <select
                  value={category}
                  onChange={(event) => {
                    selectCategory(event.target.value);
                  }}
                  className="mt-2 w-full rounded-lg border border-line px-3 py-2 text-sm"
                >
                  <option value="">All categories</option>
                  {categories.map((item) => (
                    <option key={item.uuid} value={item.slug}>
                      {item.name}
                    </option>
                  ))}
                </select>
              </div>
            ) : null}
          </div>
        </aside>

        <div className="min-w-0 flex-1">
          <div className="mb-5 flex items-end justify-between gap-3">
            <div>
              <h2 className="font-display text-xl font-bold text-ink">
                {data?.meta?.total != null ? `${data.meta.total} courses` : "Courses"}
              </h2>
              <p className="text-sm text-slate-600">
                {category || level || debouncedSearch ? "Matching your filters" : "All published courses"}
              </p>
            </div>
          </div>

          {isLoading ? (
            <LoadingSpinner label="Loading catalog..." />
          ) : !data?.data.length ? (
            <EmptyState title="No courses available" description="Try a different search or filter." />
          ) : (
            <div className="grid gap-5 sm:grid-cols-2 xl:grid-cols-3">
              {data.data.map((course, index) => {
                const stagger =
                  ["stagger-1", "stagger-2", "stagger-3", "stagger-4", "stagger-5", "stagger-6"][
                    Math.min(index, 5)
                  ] ?? "stagger-1";
                return (
                  <div key={course.uuid} className={cn("animate-fade-up", stagger)}>
                    <CourseCard course={course} to={`/student/courses/${course.uuid}`} showStatus={false} />
                  </div>
                );
              })}
            </div>
          )}

          <Pagination meta={data?.meta} onPageChange={setPage} />
        </div>
      </div>
    </div>
  );
}
