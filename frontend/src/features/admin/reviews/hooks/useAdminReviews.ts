import { useMutation, useQuery, useQueryClient } from "@tanstack/react-query";
import { deleteAdminReview, fetchAdminReviews } from "@/features/admin/reviews/api/adminReviewsApi";

export function useAdminReviews(params?: Record<string, string | number | undefined>) {
  return useQuery({
    queryKey: ["admin", "reviews", params],
    queryFn: () => fetchAdminReviews(params),
  });
}

export function useDeleteAdminReview() {
  const queryClient = useQueryClient();
  return useMutation({
    mutationFn: deleteAdminReview,
    onSuccess: () => queryClient.invalidateQueries({ queryKey: ["admin", "reviews"] }),
  });
}
