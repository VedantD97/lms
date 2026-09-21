import { useState } from "react";
import { Button } from "@/components/ui/Button";
import { LoadingSpinner } from "@/components/feedback/LoadingSpinner";
import { PageHeader } from "@/components/shared/PageHeader";
import { formatRating, starSymbols } from "@/features/student/reviews/reviewHelpers";
import { useAdminReviews, useDeleteAdminReview } from "@/features/admin/reviews/hooks/useAdminReviews";

export function AdminReviewsPage() {
  const [page, setPage] = useState(1);
  const { data, isLoading } = useAdminReviews({ page });
  const remove = useDeleteAdminReview();

  return (
    <div>
      <PageHeader title="Reviews" description="Moderate course reviews from enrolled students." />

      {isLoading ? (
        <LoadingSpinner label="Loading reviews..." />
      ) : (
        <div className="overflow-hidden rounded-xl border border-slate-200 bg-white">
          <table className="min-w-full divide-y divide-slate-200 text-sm">
            <thead className="bg-slate-50">
              <tr>
                <th className="px-4 py-3 text-left font-medium text-slate-700">Course</th>
                <th className="px-4 py-3 text-left font-medium text-slate-700">Student</th>
                <th className="px-4 py-3 text-left font-medium text-slate-700">Rating</th>
                <th className="px-4 py-3 text-left font-medium text-slate-700">Review</th>
                <th className="px-4 py-3 text-left font-medium text-slate-700">Date</th>
                <th className="px-4 py-3 text-right font-medium text-slate-700">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {data?.data.map((review) => (
                <tr key={review.uuid}>
                  <td className="px-4 py-3">{review.course?.title ?? review.course_uuid}</td>
                  <td className="px-4 py-3">
                    {review.user.first_name} {review.user.last_name}
                  </td>
                  <td className="px-4 py-3">
                    <span className="text-amber-500">{starSymbols(review.rating)}</span>
                    <span className="ml-2 text-slate-600">{formatRating(review.rating, 1)}</span>
                  </td>
                  <td className="max-w-xs truncate px-4 py-3 text-slate-700">{review.body || "—"}</td>
                  <td className="px-4 py-3">{new Date(review.created_at).toLocaleDateString()}</td>
                  <td className="px-4 py-3 text-right">
                    <Button variant="danger" disabled={remove.isPending} onClick={() => remove.mutate(review.uuid)}>
                      Delete
                    </Button>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      {data?.meta && data.meta.total > data.meta.per_page ? (
        <div className="mt-4 flex gap-2">
          <Button variant="secondary" disabled={page <= 1} onClick={() => setPage((p) => p - 1)}>
            Previous
          </Button>
          <Button
            variant="secondary"
            disabled={page * data.meta.per_page >= data.meta.total}
            onClick={() => setPage((p) => p + 1)}
          >
            Next
          </Button>
        </div>
      ) : null}
    </div>
  );
}
