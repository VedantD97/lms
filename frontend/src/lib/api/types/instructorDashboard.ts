export interface InstructorDashboardSummary {
  courses: {
    total: number;
    published: number;
    draft: number;
  };
  enrollments: {
    total: number;
    active: number;
    completed: number;
  };
  pending_submissions: number;
  recent_enrollments_30d: number;
  course_breakdown: Array<{
    course_uuid: string;
    course_title: string;
    status: string;
    enrollments: number;
    pending_submissions: number;
  }>;
}

export interface InstructorEnrollment {
  uuid: string;
  status: string;
  enrolled_at: string;
  completed_at?: string | null;
  progress_percent: number;
  course_uuid: string;
  student: {
    uuid: string;
    first_name: string;
    last_name: string;
    email: string;
  };
  progress_summary?: {
    total_items: number;
    completed_items: number;
    completed_lessons: number;
    total_lessons: number;
    passed_quizzes: number;
    total_quizzes: number;
    passed_assignments: number;
    total_assignments: number;
  };
}

export interface InstructorPendingSubmission {
  uuid: string;
  body?: string | null;
  submitted_at: string;
  status: string;
  late: boolean;
  enrollment_uuid: string;
  assignment_uuid: string;
  assignment_title: string;
  course_uuid: string;
  course_title: string;
  student: {
    uuid: string;
    first_name: string;
    last_name: string;
    email: string;
  };
}
