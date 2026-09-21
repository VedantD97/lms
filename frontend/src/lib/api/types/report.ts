export interface DashboardSummary {
  users: {
    students: number;
    instructors: number;
    admins: number;
  };
  courses: {
    total: number;
    published: number;
    draft: number;
    archived: number;
  };
  enrollments: {
    total: number;
    active: number;
    completed: number;
    dropped: number;
  };
  certificates: {
    total: number;
    active: number;
    revoked: number;
  };
  reviews: {
    total: number;
    average_rating: number | null;
  };
  recent_enrollments_30d: number;
}

export interface EnrollmentsReport {
  summary: {
    total: number;
    active: number;
    completed: number;
    dropped: number;
    expired: number;
  };
  by_course: Array<{
    course_uuid: string;
    course_title: string;
    total: number;
    active: number;
    completed: number;
    dropped: number;
  }>;
  recent: Array<{ date: string; count: number }>;
}

export interface CourseCompletionRow {
  course_uuid: string;
  course_title: string;
  status: string;
  total_enrollments: number;
  completed_enrollments: number;
  active_enrollments: number;
  completion_rate: number;
  average_progress: number;
}
