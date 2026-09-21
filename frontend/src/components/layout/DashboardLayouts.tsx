import { Link, Outlet, useNavigate } from "react-router-dom";
import { useAuth } from "@/lib/auth/AuthContext";
import { Button } from "@/components/ui/Button";
import { StudentNavLinks } from "@/components/layout/StudentNavLinks";
import { CategoryMegaMenu } from "@/components/layout/CategoryMegaMenu";
import { HeaderSearch } from "@/components/layout/HeaderSearch";

function BrandMark({ to, label, accentClass }: { to: string; label: string; accentClass: string }) {
  return (
    <Link to={to} className="group flex shrink-0 items-center gap-2">
      <span
        className={`flex h-8 w-8 items-center justify-center rounded-lg font-display text-sm font-bold text-white shadow-sm ${accentClass}`}
      >
        LH
      </span>
      <span className="font-display text-lg font-bold tracking-tight text-ink">
        LearnHub
        <span className="ml-1.5 hidden text-xs font-semibold uppercase tracking-wider text-slate-500 sm:inline">
          {label}
        </span>
      </span>
    </Link>
  );
}

export function AdminLayout() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();
  const isSuperAdmin = user?.roles.includes("super_admin");

  return (
    <div className="min-h-screen">
      <header className="sticky top-0 z-40 border-b border-line bg-white/90 backdrop-blur-md">
        <div className="mx-auto flex max-w-7xl items-center justify-between gap-4 px-4 py-3 sm:px-6">
          <div className="flex min-w-0 items-center gap-5">
            <BrandMark to="/admin/dashboard" label="Admin" accentClass="bg-blue-700" />
            <nav className="hidden items-center gap-1 overflow-x-auto text-sm lg:flex">
              {[
                ["/admin/dashboard", "Dashboard"],
                ["/admin/reports", "Reports"],
                ["/admin/courses", "Courses"],
                ["/admin/categories", "Categories"],
                ["/admin/quizzes", "Quizzes"],
                ["/admin/certificates", "Certificates"],
                ["/admin/announcements", "Announcements"],
                ["/admin/reviews", "Reviews"],
              ].map(([href, label]) => (
                <Link
                  key={href}
                  to={href}
                  className="rounded-lg px-2.5 py-1.5 text-slate-700 transition hover:bg-blue-50 hover:text-blue-700"
                >
                  {label}
                </Link>
              ))}
              {isSuperAdmin ? (
                <Link
                  to="/admin/audit-logs"
                  className="rounded-lg px-2.5 py-1.5 text-slate-700 transition hover:bg-blue-50 hover:text-blue-700"
                >
                  Audit logs
                </Link>
              ) : null}
            </nav>
          </div>
          <div className="flex items-center gap-3">
            <span className="hidden text-sm text-slate-600 md:inline">{user?.email}</span>
            <Button
              variant="secondary"
              onClick={async () => {
                await logout();
                navigate("/login");
              }}
            >
              Logout
            </Button>
          </div>
        </div>
      </header>
      <main className="mx-auto max-w-7xl px-4 py-8 sm:px-6">
        <Outlet />
      </main>
    </div>
  );
}

export function InstructorLayout() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();

  return (
    <div className="min-h-screen">
      <header className="sticky top-0 z-40 border-b border-line bg-white/90 backdrop-blur-md">
        <div className="mx-auto flex max-w-7xl items-center justify-between gap-4 px-4 py-3 sm:px-6">
          <div className="flex items-center gap-5">
            <BrandMark to="/instructor/dashboard" label="Instructor" accentClass="bg-emerald-700" />
            <nav className="hidden items-center gap-1 text-sm sm:flex">
              {[
                ["/instructor/dashboard", "Dashboard"],
                ["/instructor/courses", "My Courses"],
                ["/instructor/grading", "Grading"],
              ].map(([href, label]) => (
                <Link
                  key={href}
                  to={href}
                  className="rounded-lg px-2.5 py-1.5 text-slate-700 transition hover:bg-emerald-50 hover:text-emerald-700"
                >
                  {label}
                </Link>
              ))}
            </nav>
          </div>
          <div className="flex items-center gap-3">
            <span className="hidden text-sm text-slate-600 md:inline">{user?.email}</span>
            <Button
              variant="secondary"
              onClick={async () => {
                await logout();
                navigate("/login");
              }}
            >
              Logout
            </Button>
          </div>
        </div>
      </header>
      <main className="mx-auto max-w-7xl px-4 py-8 sm:px-6">
        <Outlet />
      </main>
    </div>
  );
}

export function StudentLayout() {
  const { user, logout } = useAuth();
  const navigate = useNavigate();

  return (
    <div className="min-h-screen">
      <header className="sticky top-0 z-40 border-b border-line bg-white/95 shadow-sm backdrop-blur-md">
        <div className="mx-auto flex max-w-[1400px] items-center gap-3 px-4 py-3 sm:gap-5 sm:px-6">
          <BrandMark to="/student/dashboard" label="" accentClass="bg-brand" />
          <CategoryMegaMenu />
          <HeaderSearch />
          <nav className="ml-auto flex items-center gap-1 overflow-x-auto scrollbar-thin">
            <StudentNavLinks />
          </nav>
          <div className="hidden items-center gap-3 border-l border-line pl-3 xl:flex">
            <span className="max-w-[160px] truncate text-sm text-slate-600" title={user?.email}>
              {user?.email}
            </span>
            <Button
              variant="secondary"
              onClick={async () => {
                await logout();
                navigate("/login");
              }}
            >
              Logout
            </Button>
          </div>
          <Button
            variant="secondary"
            className="xl:hidden"
            onClick={async () => {
              await logout();
              navigate("/login");
            }}
          >
            Logout
          </Button>
        </div>
      </header>
      <main className="mx-auto max-w-[1400px] px-4 py-8 sm:px-6">
        <Outlet />
      </main>
    </div>
  );
}

export function StudentFullBleed({ children }: { children: React.ReactNode }) {
  return (
    <div className="relative left-1/2 right-1/2 -mx-[50vw] -mt-8 mb-8 w-screen max-w-[100vw]">
      {children}
    </div>
  );
}
