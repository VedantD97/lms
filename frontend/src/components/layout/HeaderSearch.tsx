import { useState } from "react";
import { useNavigate } from "react-router-dom";

export function HeaderSearch() {
  const navigate = useNavigate();
  const [query, setQuery] = useState("");

  function handleSubmit(event: React.FormEvent) {
    event.preventDefault();
    const trimmed = query.trim();
    const params = new URLSearchParams();
    if (trimmed) params.set("q", trimmed);
    navigate(`/student/catalog${params.toString() ? `?${params}` : ""}`);
  }

  return (
    <form onSubmit={handleSubmit} className="relative hidden min-w-0 flex-1 max-w-xl lg:block">
      <label htmlFor="header-search" className="sr-only">
        Search for courses
      </label>
      <input
        id="header-search"
        value={query}
        onChange={(event) => setQuery(event.target.value)}
        placeholder="Search for anything"
        className="w-full rounded-full border border-line bg-surface py-2.5 pl-11 pr-4 text-sm text-ink outline-none transition placeholder:text-slate-400 focus:border-brand focus:bg-white focus:ring-2 focus:ring-brand/20"
      />
      <svg
        className="pointer-events-none absolute left-4 top-1/2 h-4 w-4 -translate-y-1/2 text-slate-400"
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
    </form>
  );
}
