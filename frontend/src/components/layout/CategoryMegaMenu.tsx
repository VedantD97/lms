import { useEffect, useRef, useState } from "react";
import { Link } from "react-router-dom";
import { useCategories } from "@/features/student/catalog/hooks/useStudentCourses";

export function CategoryMegaMenu() {
  const { data: categories } = useCategories();
  const [open, setOpen] = useState(false);
  const rootRef = useRef<HTMLDivElement>(null);

  useEffect(() => {
    function onPointerDown(event: MouseEvent) {
      if (!rootRef.current?.contains(event.target as Node)) {
        setOpen(false);
      }
    }
    function onKeyDown(event: KeyboardEvent) {
      if (event.key === "Escape") setOpen(false);
    }
    document.addEventListener("mousedown", onPointerDown);
    document.addEventListener("keydown", onKeyDown);
    return () => {
      document.removeEventListener("mousedown", onPointerDown);
      document.removeEventListener("keydown", onKeyDown);
    };
  }, []);

  if (!categories?.length) return null;

  return (
    <div ref={rootRef} className="relative hidden md:block">
      <button
        type="button"
        aria-expanded={open}
        aria-haspopup="true"
        onClick={() => setOpen((value) => !value)}
        className="inline-flex items-center gap-1.5 rounded-lg px-2.5 py-1.5 text-sm font-medium text-ink transition hover:bg-brand-muted hover:text-brand"
      >
        Categories
        <svg
          className={`h-3.5 w-3.5 transition ${open ? "rotate-180" : ""}`}
          viewBox="0 0 20 20"
          fill="currentColor"
          aria-hidden
        >
          <path
            fillRule="evenodd"
            d="M5.23 7.21a.75.75 0 011.06.02L10 11.17l3.71-3.94a.75.75 0 111.08 1.04l-4.25 4.5a.75.75 0 01-1.08 0l-4.25-4.5a.75.75 0 01.02-1.06z"
            clipRule="evenodd"
          />
        </svg>
      </button>

      {open ? (
        <div className="absolute left-0 top-full z-50 mt-2 w-72 animate-fade-in rounded-xl border border-line bg-white p-2 shadow-xl">
          <p className="px-3 py-2 text-xs font-semibold uppercase tracking-wide text-slate-500">
            Browse by topic
          </p>
          <ul className="max-h-80 overflow-y-auto scrollbar-thin">
            {categories.map((category) => (
              <li key={category.uuid}>
                <Link
                  to={`/student/catalog?category=${encodeURIComponent(category.slug)}`}
                  onClick={() => setOpen(false)}
                  className="block rounded-lg px-3 py-2.5 text-sm text-ink transition hover:bg-brand-muted hover:text-brand"
                >
                  <span className="font-medium">{category.name}</span>
                  {category.description ? (
                    <span className="mt-0.5 block truncate text-xs text-slate-500">
                      {category.description}
                    </span>
                  ) : null}
                </Link>
              </li>
            ))}
          </ul>
          <Link
            to="/student/catalog"
            onClick={() => setOpen(false)}
            className="mt-1 block rounded-lg px-3 py-2.5 text-sm font-semibold text-brand hover:bg-brand-muted"
          >
            Explore all courses →
          </Link>
        </div>
      ) : null}
    </div>
  );
}
