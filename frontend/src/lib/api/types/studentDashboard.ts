export interface StudentDashboardSummary {
  enrollments: {
    total: number;
    active: number;
    completed: number;
  };
  certificates: {
    total: number;
    active: number;
  };
  notifications: {
    unread_count: number;
  };
  average_progress: number;
  continue_learning: Array<{
    enrollment_uuid: string;
    course_uuid: string;
    course_title: string;
    lesson_uuid: string;
    lesson_title: string;
    module_title: string;
    progress_percent: number;
  }>;
  pending_actions: {
    quizzes: number;
    assignments: number;
  };
  recent_notifications: Array<{
    uuid: string;
    notification_type: string;
    title?: string;
    body?: string;
    read: boolean;
    created_at: string;
  }>;
}
