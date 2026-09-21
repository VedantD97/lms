import { useEffect, useState } from "react";
import { Link, useNavigate, useParams } from "react-router-dom";
import { Button } from "@/components/ui/Button";
import { Input, Label, Select, Textarea } from "@/components/ui/Field";
import { LoadingSpinner } from "@/components/feedback/LoadingSpinner";
import { PageHeader } from "@/components/shared/PageHeader";
import {
  useAdminCategories,
  useAdminCourse,
  useAdminInstructors,
  useAssignInstructor,
  useCreateAdminCourse,
  usePublishAdminCourse,
  useUnpublishAdminCourse,
  useUpdateAdminCourse,
} from "@/features/admin/courses/hooks/useAdminCourses";
import type { CourseLevel } from "@/lib/api/types/course";

export function AdminCourseEditorPage() {
  const { uuid } = useParams();
  const isNew = uuid === "new";
  const navigate = useNavigate();
  const { data: course, isLoading } = useAdminCourse(isNew ? "" : (uuid ?? ""));
  const { data: categories } = useAdminCategories();
  const { data: instructors } = useAdminInstructors();

  const createCourse = useCreateAdminCourse();
  const updateCourse = useUpdateAdminCourse(uuid ?? "");
  const assignInstructor = useAssignInstructor();
  const publish = usePublishAdminCourse();
  const unpublish = useUnpublishAdminCourse();

  const [title, setTitle] = useState("");
  const [shortDescription, setShortDescription] = useState("");
  const [description, setDescription] = useState("");
  const [level, setLevel] = useState<CourseLevel>("beginner");
  const [categoryUuids, setCategoryUuids] = useState<string[]>([]);
  const [selectedInstructor, setSelectedInstructor] = useState("");

  useEffect(() => {
    if (!course) return;
    setTitle(course.title);
    setShortDescription(course.short_description ?? "");
    setDescription(course.description ?? "");
    setLevel(course.level);
    setCategoryUuids(course.category_uuids ?? course.categories?.map((c) => c.uuid) ?? []);
  }, [course]);

  async function handleSave(event: React.FormEvent) {
    event.preventDefault();
    const payload = {
      title,
      short_description: shortDescription,
      description,
      level,
      category_uuids: categoryUuids,
    };

    if (isNew) {
      const response = await createCourse.mutateAsync(payload);
      navigate(`/admin/courses/${response.data.uuid}`);
      return;
    }

    await updateCourse.mutateAsync(payload);
  }

  if (!isNew && isLoading) return <LoadingSpinner label="Loading course..." />;

  return (
    <div>
      <PageHeader
        title={isNew ? "Create course" : "Edit course"}
        action={
          <Link to="/admin/courses">
            <Button variant="secondary">Back to list</Button>
          </Link>
        }
      />

      <form onSubmit={handleSave} className="max-w-3xl space-y-5 rounded-xl border border-slate-200 bg-white p-6">
        <div>
          <Label htmlFor="title">Title</Label>
          <Input id="title" value={title} onChange={(e) => setTitle(e.target.value)} required />
        </div>
        <div>
          <Label htmlFor="short_description">Short description</Label>
          <Input id="short_description" value={shortDescription} onChange={(e) => setShortDescription(e.target.value)} />
        </div>
        <div>
          <Label htmlFor="description">Description</Label>
          <Textarea id="description" rows={5} value={description} onChange={(e) => setDescription(e.target.value)} />
        </div>
        <div>
          <Label htmlFor="level">Level</Label>
          <Select id="level" value={level} onChange={(e) => setLevel(e.target.value as CourseLevel)}>
            <option value="beginner">Beginner</option>
            <option value="intermediate">Intermediate</option>
            <option value="advanced">Advanced</option>
          </Select>
        </div>
        <div>
          <Label>Categories</Label>
          <div className="mt-2 flex flex-wrap gap-2">
            {categories?.map((category) => (
              <label key={category.uuid} className="flex items-center gap-2 rounded-lg border border-slate-200 px-3 py-2 text-sm">
                <input
                  type="checkbox"
                  checked={categoryUuids.includes(category.uuid)}
                  onChange={(e) => {
                    setCategoryUuids((current) =>
                      e.target.checked
                        ? [...current, category.uuid]
                        : current.filter((id) => id !== category.uuid),
                    );
                  }}
                />
                {category.name}
              </label>
            ))}
          </div>
        </div>

        <Button type="submit" disabled={createCourse.isPending || updateCourse.isPending}>
          {isNew ? "Create course" : "Save changes"}
        </Button>
      </form>

      {!isNew && course ? (
        <div className="mt-8 max-w-3xl space-y-4 rounded-xl border border-slate-200 bg-white p-6">
          <h2 className="text-lg font-semibold text-slate-900">Course actions</h2>
          <div className="flex flex-wrap gap-2">
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
          </div>

          <div className="border-t border-slate-100 pt-4">
            <Label htmlFor="instructor">Assign instructor</Label>
            <div className="mt-2 flex gap-2">
              <Select
                id="instructor"
                value={selectedInstructor}
                onChange={(e) => setSelectedInstructor(e.target.value)}
                className="max-w-md"
              >
                <option value="">Select instructor</option>
                {instructors?.map((instructor) => (
                  <option key={instructor.uuid} value={instructor.uuid}>
                    {instructor.first_name} {instructor.last_name} ({instructor.email})
                  </option>
                ))}
              </Select>
              <Button
                type="button"
                variant="secondary"
                disabled={!selectedInstructor}
                onClick={() =>
                  assignInstructor.mutate({ courseUuid: course.uuid, userUuid: selectedInstructor })
                }
              >
                Assign
              </Button>
            </div>
            {course.instructor_uuids?.length ? (
              <p className="mt-2 text-sm text-slate-600">{course.instructor_uuids.length} instructor(s) assigned.</p>
            ) : null}
          </div>
        </div>
      ) : null}
    </div>
  );
}
