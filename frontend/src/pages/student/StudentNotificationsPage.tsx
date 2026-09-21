import { Link } from "react-router-dom";
import { Button } from "@/components/ui/Button";
import { EmptyState } from "@/components/feedback/EmptyState";
import { LoadingSpinner } from "@/components/feedback/LoadingSpinner";
import { PageHeader } from "@/components/shared/PageHeader";
import {
  useMarkAllNotificationsRead,
  useMarkNotificationRead,
  useNotifications,
} from "@/features/student/notifications/hooks/useStudentNotifications";
import type { Notification } from "@/lib/api/types/notification";

function notificationLabel(type: Notification["notification_type"]) {
  return type.replace(/_/g, " ");
}

export function StudentNotificationsPage() {
  const { data, isLoading } = useNotifications();
  const markRead = useMarkNotificationRead();
  const markAllRead = useMarkAllNotificationsRead();

  return (
    <div>
      <PageHeader
        title="Notifications"
        description="Updates about grades, completions, and announcements."
        action={
          <div className="flex gap-2">
            <Button variant="secondary" onClick={() => markAllRead.mutate()} disabled={markAllRead.isPending}>
              Mark all read
            </Button>
            <Link to="/student/my-courses">
              <Button variant="secondary">My courses</Button>
            </Link>
          </div>
        }
      />

      {isLoading ? (
        <LoadingSpinner label="Loading notifications..." />
      ) : !data?.data.length ? (
        <EmptyState title="No notifications" description="You're all caught up." />
      ) : (
        <div className="space-y-3">
          {data.data.map((notification) => (
            <button
              key={notification.uuid}
              type="button"
              onClick={() => {
                if (!notification.read) markRead.mutate(notification.uuid);
              }}
              className={`block w-full rounded-xl border p-4 text-left transition ${
                notification.read
                  ? "border-slate-200 bg-white"
                  : "border-violet-200 bg-violet-50 hover:border-violet-300"
              }`}
            >
              <div className="flex items-start justify-between gap-3">
                <div>
                  <p className="font-medium text-slate-900">{notification.payload.title}</p>
                  <p className="mt-1 text-sm text-slate-700">{notification.payload.body}</p>
                  {notification.payload.course_title ? (
                    <p className="mt-2 text-xs text-slate-500">{notification.payload.course_title}</p>
                  ) : null}
                </div>
                <span className="shrink-0 text-xs capitalize text-slate-500">
                  {notificationLabel(notification.notification_type)}
                </span>
              </div>
              <p className="mt-2 text-xs text-slate-400">{new Date(notification.created_at).toLocaleString()}</p>
            </button>
          ))}
        </div>
      )}
    </div>
  );
}
