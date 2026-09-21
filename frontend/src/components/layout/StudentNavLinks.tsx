import { Link, useLocation } from "react-router-dom";
import { useUnreadNotificationCount } from "@/features/student/notifications/hooks/useStudentNotifications";
import { cn } from "@/lib/utils/cn";

const links = [
  { to: "/student/dashboard", label: "Home" },
  { to: "/student/catalog", label: "Browse" },
  { to: "/student/my-courses", label: "My learning" },
  { to: "/student/certificates", label: "Certificates" },
  { to: "/student/notifications", label: "Notifications", badge: true },
] as const;

export function StudentNavLinks() {
  const { data: unreadCount } = useUnreadNotificationCount();
  const location = useLocation();

  return (
    <>
      {links.map((link) => {
        const active =
          location.pathname === link.to ||
          (link.to !== "/student/dashboard" && location.pathname.startsWith(link.to));

        return (
          <Link
            key={link.to}
            to={link.to}
            className={cn(
              "relative whitespace-nowrap rounded-lg px-2.5 py-1.5 text-sm font-medium transition",
              active
                ? "bg-brand-muted text-brand"
                : "text-slate-700 hover:bg-slate-100 hover:text-ink",
            )}
          >
            {link.label}
            {"badge" in link && unreadCount ? (
              <span className="ml-1.5 inline-flex min-w-[1.25rem] items-center justify-center rounded-full bg-brand px-1.5 py-0.5 text-[10px] font-bold text-white">
                {unreadCount}
              </span>
            ) : null}
          </Link>
        );
      })}
    </>
  );
}
