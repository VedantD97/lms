import type { ContentType, LessonResource } from "@/lib/api/types/course";
import type { EnrollmentCertificate } from "@/lib/api/types/certificate";

export interface ContinueLearning {
  lesson_uuid: string;
  lesson_title: string;
  module_title: string;
  content_type: ContentType;
  progress_percent: number;
  last_position_seconds: number;
  status: string;
}

export interface ProgressSummary {
  total_items: number;
  completed_items: number;
  completed_lessons: number;
  total_lessons: number;
  passed_quizzes: number;
  total_quizzes: number;
  passed_assignments: number;
  total_assignments: number;
}

export interface StudentEnrollment {
  uuid: string;
  status: string;
  enrolled_at: string;
  completed_at?: string | null;
  progress_percent: number;
  course: {
    uuid: string;
    title: string;
    slug: string;
    short_description?: string | null;
    level: string;
    duration_minutes?: number | null;
  };
  continue_learning?: ContinueLearning | null;
  progress_summary?: ProgressSummary;
  certificate?: EnrollmentCertificate | null;
}

export interface LessonProgress {
  status: "not_started" | "in_progress" | "completed";
  progress_percent: number;
  last_position_seconds: number;
}

export interface StudentLessonDetail {
  uuid: string;
  title: string;
  content?: string;
  content_type: ContentType;
  duration_seconds?: number | null;
  position: number;
  is_preview: boolean;
  status: string;
  module_uuid: string;
  module_title: string;
  course_uuid: string;
  progress: LessonProgress;
  resources?: StudentLessonResource[];
}

export interface StudentLessonResource extends Omit<LessonResource, "file_url"> {
  downloadable?: boolean;
}

export interface ResourceDownloadResponse {
  external_url?: string;
  external?: boolean;
}
