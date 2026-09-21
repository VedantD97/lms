import { useState } from "react";
import { Link } from "react-router-dom";
import { Button } from "@/components/ui/Button";
import { EmptyState } from "@/components/feedback/EmptyState";
import { LoadingSpinner } from "@/components/feedback/LoadingSpinner";
import { PageHeader, Pagination, SearchInput, StatusBadge } from "@/components/shared/PageHeader";
import {
  useAdminCourses,
  useArchiveAdminCourse,
  usePublishAdminCourse,
  useUnpublishAdminCourse,
} from "@/features/admin/courses/hooks/useAdminCourses";
import { useDebounce } from "@/lib/hooks/useDebounce";

export function AdminCoursesPage() {
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState("");
  const [status, setStatus] = useState("");
  const debouncedSearch = useDebounce(search);

  const { data, isLoading } = useAdminCourses({
    page,
    q: debouncedSearch || undefined,
    status: status || undefined,
  });

  const publish = usePublishAdminCourse();
  const unpublish = useUnpublishAdminCourse();
  const archive = useArchiveAdminCourse();

  return (
    <div>
      <PageHeader
        title="Courses"
        description="Create, publish, and manage all courses."
        action={
          <Link to="/admin/courses/new">
            <Button>New course</Button>
          </Link>
        }
      />

      <div className="mb-6 flex flex-wrap gap-4">
        <SearchInput value={search} onChange={setSearch} placeholder="Search courses..." />
        <select
          value={status}
          onChange={(e) => {
            setStatus(e.target.value);
            setPage(1);
          }}
          className="rounded-lg border border-slate-300 px-3 py-2 text-sm"
        >
          <option value="">All statuses</option>
          <option value="draft">Draft</option>
          <option value="published">Published</option>
          <option value="archived">Archived</option>
        </select>
      </div>

      {isLoading ? (
        <LoadingSpinner label="Loading courses..." />
      ) : !data?.data.length ? (
        <EmptyState title="No courses found" description="Create a course to get started." />
      ) : (
        <div className="overflow-hidden rounded-xl border border-slate-200 bg-white">
          <table className="min-w-full divide-y divide-slate-200 text-sm">
            <thead className="bg-slate-50">
              <tr>
                <th className="px-4 py-3 text-left font-medium text-slate-600">Title</th>
                <th className="px-4 py-3 text-left font-medium text-slate-600">Status</th>
                <th className="px-4 py-3 text-left font-medium text-slate-600">Level</th>
                <th className="px-4 py-3 text-right font-medium text-slate-600">Actions</th>
              </tr>
            </thead>
            <tbody className="divide-y divide-slate-100">
              {data.data.map((course) => (
                <tr key={course.uuid}>
                  <td className="px-4 py-3">
                    <Link to={`/admin/courses/${course.uuid}`} className="font-medium text-blue-700 hover:underline">
                      {course.title}
                    </Link>
                  </td>
                  <td className="px-4 py-3">
                    <StatusBadge status={course.status} />
                  </td>
                  <td className="px-4 py-3 capitalize">{course.level}</td>
                  <td className="px-4 py-3">
                    <div className="flex justify-end gap-2">
                      {course.status === "draft" ? (
                        <Button variant="secondary" onClick={() => publish.mutate(course.uuid)}>
                          Publish
                        </Button>
                      ) : null}
                      {course.status === "published" ? (
                        <Button variant="secondary" onClick={() => unpublish.mutate(course.uuid)}>
                          Unpublish
                        </Button>
                      ) : null}
                      {course.status !== "archived" ? (
                        <Button variant="danger" onClick={() => archive.mutate(course.uuid)}>
                          Archive
                        </Button>
                      ) : null}
                    </div>
                  </td>
                </tr>
              ))}
            </tbody>
          </table>
        </div>
      )}

      <Pagination meta={data?.meta} onPageChange={setPage} />
    </div>
  );
}
