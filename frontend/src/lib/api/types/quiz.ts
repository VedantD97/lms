export type QuestionType = "single_choice" | "multiple_choice" | "true_false";
export type QuizStatus = "draft" | "published";
export type AttemptStatus = "in_progress" | "submitted" | "expired";
export type ShowCorrectAnswers = "never" | "after_submit";

export interface QuestionOption {
  uuid: string;
  body: string;
  is_correct?: boolean;
  position: number;
}

export interface Question {
  uuid: string;
  question_type: QuestionType;
  body: string;
  points: number;
  position: number;
  explanation?: string | null;
  quiz_uuid?: string;
  question_options?: QuestionOption[];
}

export interface Quiz {
  uuid: string;
  title: string;
  description?: string | null;
  status: QuizStatus;
  time_limit_minutes?: number | null;
  passing_score: number;
  max_attempts: number;
  shuffle_questions: boolean;
  shuffle_answers: boolean;
  show_correct_answers: ShowCorrectAnswers;
  available_from?: string | null;
  available_until?: string | null;
  course_uuid?: string;
  lesson_uuid?: string | null;
  question_count?: number;
  total_points?: number;
  questions?: Question[];
}

export interface StudentQuiz extends Quiz {
  attempts_used?: number;
  attempts_remaining?: number | null;
  best_percentage?: number | null;
  has_in_progress_attempt?: boolean;
  in_progress_attempt_uuid?: string | null;
  required_for_completion?: boolean;
  passed?: boolean;
}

export interface QuizAttempt {
  uuid: string;
  attempt_number: number;
  status: AttemptStatus;
  started_at: string;
  expires_at?: string | null;
  submitted_at?: string | null;
  score?: number | null;
  max_score?: number | null;
  percentage?: number | null;
  passed?: boolean | null;
  time_spent_seconds?: number | null;
  quiz_uuid?: string;
  enrollment_uuid?: string;
  questions?: Question[];
  responses?: QuizResponseInput[];
}

export interface QuizResponseInput {
  question_uuid: string;
  selected_option_uuids: string[];
}

export interface QuizAttemptResult extends QuizAttempt {
  show_correct_answers?: boolean;
  responses?: Array<
    QuizResponseInput & {
      is_correct?: boolean;
      points_awarded?: number;
      correct_option_uuids?: string[];
      explanation?: string | null;
    }
  >;
}

export interface QuizStatistics {
  uuid: string;
  title: string;
  total_attempts: number;
  completed_attempts: number;
  average_score: number;
  pass_rate: number;
  average_percentage: number;
  unique_students: number;
}
