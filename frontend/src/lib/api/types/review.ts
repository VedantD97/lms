export interface ReviewUser {
  uuid: string;
  first_name: string;
  last_name: string;
}

export interface ReviewCourse {
  uuid: string;
  title: string;
}

export interface Review {
  uuid: string;
  rating: number;
  body?: string | null;
  course_uuid: string;
  course?: ReviewCourse;
  user: ReviewUser;
  created_at: string;
  updated_at: string;
}

export interface ReviewListMeta {
  page: number;
  per_page: number;
  total: number;
  average_rating: number | null;
  review_count: number;
}
