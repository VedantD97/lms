import { useState } from "react";
import { Link } from "react-router-dom";
import { Button } from "@/components/ui/Button";
import { EmptyState } from "@/components/feedback/EmptyState";
import { LoadingSpinner } from "@/components/feedback/LoadingSpinner";
import { CourseCard, PageHeader, Pagination, SearchInput } from "@/components/shared/PageHeader";
import {
  useInstructorCourses,
  usePublishInstructorCourse,
  useUnpublishInstructorCourse,
} from "@/features/instructor/courses/hooks/useInstructorCourses";
import { useDebounce } from "@/lib/hooks/useDebounce";

export function InstructorCoursesPage() {
  const [page, setPage] = useState(1);
  const [search, setSearch] = useState("");
  const debouncedSearch = useDebounce(search);

  const { data, isLoading } = useInstructorCourses({ page, q: debouncedSearch || undefined });
  const publish = usePublishInstructorCourse();
  const unpublish = useUnpublishInstructorCourse();

  return (
    <div>
      <PageHeader
        title="My courses"
        description="Create and manage your course content."
        action={
          <Link to="/instructor/courses/new">
            <Button>New course</Button>
          </Link>
        }
      />

      <div className="mb-6">
        <SearchInput value={search} onChange={setSearch} placeholder="Search your courses..." />
      </div>

      {isLoading ? (
        <LoadingSpinner label="Loading courses..." />
      ) : !data?.data.length ? (
        <EmptyState title="No courses yet" description="Create your first course to begin." />
      ) : (
        <div className="grid gap-5 sm:grid-cols-2 xl:grid-cols-3">
          {data.data.map((course) => (
            <CourseCard
              key={course.uuid}
              course={course}
              to={`/instructor/courses/${course.uuid}`}
              action={
                <div className="flex gap-2">
                  {course.status === "draft" ? (
                    <Button variant="secondary" onClick={() => publish.mutate(course.uuid)}>
                      Publish
                    </Button>
                  ) : (
                    <Button variant="secondary" onClick={() => unpublish.mutate(course.uuid)}>
                      Unpublish
                    </Button>
                  )}
                </div>
              }
            />
          ))}
        </div>
      )}

      <Pagination meta={data?.meta} onPageChange={setPage} />
    </div>
  );
}
