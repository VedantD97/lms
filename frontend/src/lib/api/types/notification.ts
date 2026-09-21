export type NotificationType =
  | "assignment_graded"
  | "course_completed"
  | "certificate_issued"
  | "announcement";

export interface NotificationPayload {
  title: string;
  body: string;
  course_uuid?: string;
  course_title?: string;
  assignment_uuid?: string;
  enrollment_uuid?: string;
  certificate_uuid?: string;
  certificate_number?: string;
  announcement_uuid?: string;
  audience?: string;
  percentage?: number;
  passed?: boolean;
}

export interface Notification {
  uuid: string;
  notification_type: NotificationType;
  payload: NotificationPayload;
  read_at?: string | null;
  read: boolean;
  created_at: string;
}

export interface Announcement {
  uuid: string;
  title: string;
  body: string;
  audience: "global" | "course";
  published: boolean;
  published_at?: string | null;
  course_uuid?: string | null;
  author?: {
    uuid: string;
    first_name: string;
    last_name: string;
  };
}
