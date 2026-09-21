import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import {
  createCourseReview,
  deleteReview,
  fetchCourseReviews,
  updateReview,
} from "@/features/student/reviews/api/studentReviewsApi";

export function useCourseReviews(courseUuid: string, params?: Record<string, string | number | undefined>) {
  return useQuery({
    queryKey: ["student", "courses", courseUuid, "reviews", params],
    queryFn: () => fetchCourseReviews(courseUuid, params),
    enabled: Boolean(courseUuid),
  });
}

export function useCreateReview(courseUuid: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: (payload: { rating: number; body?: string }) => createCourseReview(courseUuid, payload),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["student", "courses", courseUuid] });
      queryClient.invalidateQueries({ queryKey: ["student", "courses", courseUuid, "reviews"] });
    },
  });
}

export function useUpdateReview(courseUuid: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: ({ uuid, ...payload }: { uuid: string; rating: number; body?: string }) =>
      updateReview(uuid, payload),
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["student", "courses", courseUuid] });
      queryClient.invalidateQueries({ queryKey: ["student", "courses", courseUuid, "reviews"] });
    },
  });
}

export function useDeleteReview(courseUuid: string) {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: deleteReview,
    onSuccess: () => {
      queryClient.invalidateQueries({ queryKey: ["student", "courses", courseUuid] });
      queryClient.invalidateQueries({ queryKey: ["student", "courses", courseUuid, "reviews"] });
    },
  });
}
