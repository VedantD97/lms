export type AssignmentStatus = "draft" | "published";
export type SubmissionStatus = "submitted" | "graded";

export interface Assignment {
  uuid: string;
  title: string;
  description?: string | null;
  status: AssignmentStatus;
  due_at?: string | null;
  max_points: number;
  passing_score: number;
  allow_late: boolean;
  allow_resubmit: boolean;
  required_for_completion: boolean;
  course_uuid?: string;
  lesson_uuid?: string | null;
  submission_count?: number;
}

export interface Grade {
  uuid: string;
  points: number;
  percentage: number;
  passed: boolean;
  feedback?: string | null;
  graded_at: string;
  graded_by?: {
    uuid: string;
    first_name: string;
    last_name: string;
  };
}

export interface AssignmentSubmission {
  uuid: string;
  body?: string | null;
  submitted_at?: string | null;
  status: SubmissionStatus;
  late: boolean;
  enrollment_uuid?: string;
  assignment_uuid?: string;
  student?: {
    uuid: string;
    first_name: string;
    last_name: string;
    email: string;
  };
  grade?: Grade | null;
}

export interface StudentAssignment extends Omit<Assignment, "status"> {
  course_uuid?: string;
  past_due?: boolean;
  accepting_submissions?: boolean;
  submission_status?: SubmissionStatus | null;
  submitted_at?: string | null;
  passed?: boolean;
  grade_percentage?: number | null;
  submission_uuid?: string | null;
}

export interface StudentAssignmentSubmission {
  uuid: string;
  body?: string | null;
  submitted_at?: string | null;
  status: SubmissionStatus;
  late: boolean;
  assignment_uuid?: string;
  grade?: Grade | null;
}
