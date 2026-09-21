import type { Review } from "@/lib/api/types/review";

export type CourseStatus = "draft" | "published" | "archived";
export type CourseLevel = "beginner" | "intermediate" | "advanced";
export type ContentType = "video" | "document" | "text" | "mixed";
export type ResourceType = "video" | "pdf" | "document" | "image" | "link";

export interface Category {
  uuid: string;
  name: string;
  slug: string;
  description?: string;
  position: number;
  parent_uuid?: string | null;
  children?: Category[];
}

export interface LessonResource {
  uuid: string;
  title: string;
  resource_type: ResourceType;
  external_url?: string | null;
  position: number;
  metadata?: Record<string, unknown>;
  file_url?: string | null;
}

export interface Lesson {
  uuid: string;
  title: string;
  content?: string;
  content_type: ContentType;
  duration_seconds?: number | null;
  position: number;
  is_preview: boolean;
  status: "draft" | "published";
  module_uuid?: string;
  resources?: LessonResource[];
}

export interface CourseModule {
  uuid: string;
  title: string;
  description?: string;
  position: number;
  status: "draft" | "published";
  course_uuid?: string;
  lessons?: Lesson[];
}

export interface Course {
  uuid: string;
  title: string;
  slug: string;
  description?: string;
  short_description?: string;
  status: CourseStatus;
  level: CourseLevel;
  duration_minutes?: number | null;
  published_at?: string | null;
  created_by_uuid?: string;
  category_uuids?: string[];
  instructor_uuids?: string[];
  categories?: Category[];
  modules?: CourseModule[];
  average_rating?: number | null;
  review_count?: number;
  my_review?: Review | null;
}

export interface User {
  uuid: string;
  email: string;
  first_name: string;
  last_name: string;
  roles: string[];
  highest_role?: string;
}

export interface AuthSession {
  access_token: string;
  token_type: string;
  user: User;
}

export interface PaginationMeta {
  page: number;
  per_page: number;
  total: number;
}
