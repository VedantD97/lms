import { useEffect, useState } from "react";
import { Link, useNavigate, useParams } from "react-router-dom";
import { Button } from "@/components/ui/Button";
import { Input, Label, Select, Textarea } from "@/components/ui/Field";
import { LoadingSpinner } from "@/components/feedback/LoadingSpinner";
import { PageHeader } from "@/components/shared/PageHeader";
import {
  useCreateInstructorCourse,
  useCreateLesson,
  useCreateModule,
  useDeleteLesson,
  useDeleteLessonResource,
  useDeleteModule,
  useInstructorCourse,
  usePublishInstructorCourse,
  useReorderLessons,
  useReorderModules,
  useUnpublishInstructorCourse,
  useUpdateInstructorCourse,
  useUpdateLesson,
  useUpdateModule,
  useUploadLessonResource,
} from "@/features/instructor/courses/hooks/useInstructorCourses";
import { createLessonQuiz } from "@/features/instructor/quizzes/api/instructorQuizzesApi";
import { createLessonAssignment } from "@/features/instructor/assignments/api/instructorAssignmentsApi";
import {
  useCourseAnnouncements,
  useCreateCourseAnnouncement,
  useDeleteInstructorAnnouncement,
  usePublishInstructorAnnouncement,
} from "@/features/instructor/announcements/hooks/useInstructorAnnouncements";
import type { CourseLevel, CourseModule, Lesson } from "@/lib/api/types/course";

export function InstructorCourseEditorPage() {
  const { uuid } = useParams();
  const isNew = uuid === "new";
  const navigate = useNavigate();
  const { data: course, isLoading } = useInstructorCourse(isNew ? "" : (uuid ?? ""));

  const createCourse = useCreateInstructorCourse();
  const updateCourse = useUpdateInstructorCourse(uuid ?? "");
  const publish = usePublishInstructorCourse();
  const unpublish = useUnpublishInstructorCourse();
  const createModule = useCreateModule(uuid ?? "");
  const updateModule = useUpdateModule(uuid ?? "");
  const deleteModule = useDeleteModule(uuid ?? "");
  const reorderModules = useReorderModules(uuid ?? "");
  const createLesson = useCreateLesson(uuid ?? "");
  const updateLesson = useUpdateLesson(uuid ?? "");
  const deleteLesson = useDeleteLesson(uuid ?? "");

  const [title, setTitle] = useState("");
  const [shortDescription, setShortDescription] = useState("");
  const [description, setDescription] = useState("");
  const [level, setLevel] = useState<CourseLevel>("beginner");
  const [newModuleTitle, setNewModuleTitle] = useState("");

  useEffect(() => {
    if (!course) return;
    setTitle(course.title);
    setShortDescription(course.short_description ?? "");
    setDescription(course.description ?? "");
    setLevel(course.level);
  }, [course]);

  async function handleSave(event: React.FormEvent) {
    event.preventDefault();
    const payload = { title, short_description: shortDescription, description, level };

    if (isNew) {
      const response = await createCourse.mutateAsync(payload);
      navigate(`/instructor/courses/${response.data.uuid}`);
      return;
    }

    await updateCourse.mutateAsync(payload);
  }

  function moveModule(modules: CourseModule[], index: number, direction: -1 | 1) {
    const nextIndex = index + direction;
    if (nextIndex < 0 || nextIndex >= modules.length) return;
    const ordered = [...modules];
    [ordered[index], ordered[nextIndex]] = [ordered[nextIndex], ordered[index]];
    reorderModules.mutate(ordered.map((item) => item.uuid));
  }

  if (!isNew && isLoading) return <LoadingSpinner label="Loading course..." />;

  return (
    <div>
      <PageHeader
        title={isNew ? "Create course" : "Course editor"}
        action={
          <div className="flex gap-2">
            {!isNew && uuid ? (
              <Link to={`/instructor/courses/${uuid}/students`}>
                <Button variant="secondary">View students</Button>
              </Link>
            ) : null}
            <Link to="/instructor/courses">
              <Button variant="secondary">Back to list</Button>
            </Link>
          </div>
        }
      />

      <form onSubmit={handleSave} className="mb-8 max-w-3xl space-y-5 rounded-xl border border-slate-200 bg-white p-6">
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
          <Textarea id="description" rows={4} value={description} onChange={(e) => setDescription(e.target.value)} />
        </div>
        <div>
          <Label htmlFor="level">Level</Label>
          <Select id="level" value={level} onChange={(e) => setLevel(e.target.value as CourseLevel)}>
            <option value="beginner">Beginner</option>
            <option value="intermediate">Intermediate</option>
            <option value="advanced">Advanced</option>
          </Select>
        </div>
        <Button type="submit">{isNew ? "Create course" : "Save course"}</Button>
      </form>

      {!isNew && course ? (
        <>
          <div className="mb-8 flex gap-2">
            {course.status === "draft" ? (
              <Button variant="secondary" onClick={() => publish.mutate(course.uuid)}>
                Publish course
              </Button>
            ) : (
              <Button variant="secondary" onClick={() => unpublish.mutate(course.uuid)}>
                Unpublish course
              </Button>
            )}
          </div>

          <section className="space-y-4">
            <div className="flex items-center justify-between">
              <h2 className="text-xl font-semibold text-slate-900">Modules</h2>
              <form
                className="flex gap-2"
                onSubmit={(event) => {
                  event.preventDefault();
                  if (!newModuleTitle.trim()) return;
                  createModule.mutate({ title: newModuleTitle }, { onSuccess: () => setNewModuleTitle("") });
                }}
              >
                <Input
                  value={newModuleTitle}
                  onChange={(e) => setNewModuleTitle(e.target.value)}
                  placeholder="New module title"
                />
                <Button type="submit">Add module</Button>
              </form>
            </div>

            {course.modules?.map((module, index) => (
              <ModuleEditor
                key={module.uuid}
                courseUuid={course.uuid}
                module={module}
                onMoveUp={() => moveModule(course.modules ?? [], index, -1)}
                onMoveDown={() => moveModule(course.modules ?? [], index, 1)}
                onUpdate={(payload) => updateModule.mutate({ uuid: module.uuid, payload })}
                onDelete={() => deleteModule.mutate(module.uuid)}
                onCreateLesson={(payload) => createLesson.mutate({ moduleUuid: module.uuid, payload })}
                onUpdateLesson={(lessonUuid, payload) => updateLesson.mutate({ uuid: lessonUuid, payload })}
                onDeleteLesson={(lessonUuid) => deleteLesson.mutate(lessonUuid)}
              />
            ))}
          </section>

          <CourseAnnouncements courseUuid={course.uuid} />
        </>
      ) : null}
    </div>
  );
}

function ModuleEditor({
  courseUuid,
  module,
  onMoveUp,
  onMoveDown,
  onUpdate,
  onDelete,
  onCreateLesson,
  onUpdateLesson,
  onDeleteLesson,
}: {
  courseUuid: string;
  module: CourseModule;
  onMoveUp: () => void;
  onMoveDown: () => void;
  onUpdate: (payload: Partial<CourseModule>) => void;
  onDelete: () => void;
  onCreateLesson: (payload: Partial<Lesson>) => void;
  onUpdateLesson: (lessonUuid: string, payload: Partial<Lesson>) => void;
  onDeleteLesson: (lessonUuid: string) => void;
}) {
  const reorderLessons = useReorderLessons(courseUuid, module.uuid);
  const [title, setTitle] = useState(module.title);
  const [newLessonTitle, setNewLessonTitle] = useState("");

  useEffect(() => setTitle(module.title), [module.title]);

  function moveLesson(lessons: Lesson[], index: number, direction: -1 | 1) {
    const nextIndex = index + direction;
    if (nextIndex < 0 || nextIndex >= lessons.length) return;
    const ordered = [...lessons];
    [ordered[index], ordered[nextIndex]] = [ordered[nextIndex], ordered[index]];
    reorderLessons.mutate(ordered.map((item) => item.uuid));
  }

  return (
    <div className="rounded-xl border border-slate-200 bg-white p-5">
      <div className="flex flex-wrap items-center gap-2">
        <Input value={title} onChange={(e) => setTitle(e.target.value)} className="max-w-md" />
        <Button variant="secondary" onClick={() => onUpdate({ title })}>
          Save module
        </Button>
        <Button variant="secondary" onClick={onMoveUp}>
          Up
        </Button>
        <Button variant="secondary" onClick={onMoveDown}>
          Down
        </Button>
        <Button variant="danger" onClick={onDelete}>
          Delete
        </Button>
      </div>

      <div className="mt-4 space-y-3">
        {module.lessons?.map((lesson, index) => (
          <LessonEditor
            key={lesson.uuid}
            lesson={lesson}
            courseUuid={courseUuid}
            onMoveUp={() => moveLesson(module.lessons ?? [], index, -1)}
            onMoveDown={() => moveLesson(module.lessons ?? [], index, 1)}
            onUpdate={(payload) => onUpdateLesson(lesson.uuid, payload)}
            onDelete={() => onDeleteLesson(lesson.uuid)}
          />
        ))}
      </div>

      <form
        className="mt-4 flex gap-2"
        onSubmit={(event) => {
          event.preventDefault();
          if (!newLessonTitle.trim()) return;
          onCreateLesson({ title: newLessonTitle });
          setNewLessonTitle("");
        }}
      >
        <Input value={newLessonTitle} onChange={(e) => setNewLessonTitle(e.target.value)} placeholder="New lesson title" />
        <Button type="submit">Add lesson</Button>
      </form>
    </div>
  );
}

function LessonEditor({
  lesson,
  courseUuid,
  onMoveUp,
  onMoveDown,
  onUpdate,
  onDelete,
}: {
  lesson: Lesson;
  courseUuid: string;
  onMoveUp: () => void;
  onMoveDown: () => void;
  onUpdate: (payload: Partial<Lesson>) => void;
  onDelete: () => void;
}) {
  const navigate = useNavigate();
  const uploadResource = useUploadLessonResource(courseUuid);
  const removeResource = useDeleteLessonResource(courseUuid);
  const [title, setTitle] = useState(lesson.title);
  const [content, setContent] = useState(lesson.content ?? "");
  const [creatingQuiz, setCreatingQuiz] = useState(false);
  const [creatingAssignment, setCreatingAssignment] = useState(false);

  useEffect(() => {
    setTitle(lesson.title);
    setContent(lesson.content ?? "");
  }, [lesson.title, lesson.content]);

  return (
    <div className="rounded-lg border border-slate-100 bg-slate-50 p-4">
      <div className="flex flex-wrap gap-2">
        <Input value={title} onChange={(e) => setTitle(e.target.value)} className="max-w-sm" />
        <Button variant="secondary" onClick={() => onUpdate({ title, content })}>
          Save lesson
        </Button>
        <Button variant="secondary" onClick={onMoveUp}>
          Up
        </Button>
        <Button variant="secondary" onClick={onMoveDown}>
          Down
        </Button>
        <Button variant="danger" onClick={onDelete}>
          Delete
        </Button>
        <Button
          variant="secondary"
          disabled={creatingQuiz}
          onClick={async () => {
            setCreatingQuiz(true);
            try {
              const response = await createLessonQuiz(lesson.uuid, { title: `${lesson.title} Quiz` });
              navigate(`/instructor/quizzes/${response.data.uuid}`);
            } finally {
              setCreatingQuiz(false);
            }
          }}
        >
          Create quiz
        </Button>
        <Button
          variant="secondary"
          disabled={creatingAssignment}
          onClick={async () => {
            setCreatingAssignment(true);
            try {
              const response = await createLessonAssignment(lesson.uuid, { title: `${lesson.title} Assignment` });
              navigate(`/instructor/assignments/${response.data.uuid}`);
            } finally {
              setCreatingAssignment(false);
            }
          }}
        >
          Create assignment
        </Button>
      </div>
      <Textarea className="mt-3" rows={3} value={content} onChange={(e) => setContent(e.target.value)} />

      <div className="mt-3">
        <Label>Resources</Label>
        <ul className="mt-2 space-y-1 text-sm text-slate-600">
          {lesson.resources?.map((resource) => (
            <li key={resource.uuid} className="flex items-center justify-between gap-2">
              <span>{resource.title}</span>
              <Button variant="danger" onClick={() => removeResource.mutate(resource.uuid)}>
                Remove
              </Button>
            </li>
          ))}
        </ul>
        <form
          className="mt-3 flex flex-wrap items-end gap-2"
          onSubmit={(event) => {
            event.preventDefault();
            const form = event.currentTarget;
            const formData = new FormData(form);
            uploadResource.mutate(
              { lessonUuid: lesson.uuid, formData },
              { onSuccess: () => form.reset() },
            );
          }}
        >
          <Input name="resource[title]" placeholder="Resource title" required />
          <Select name="resource[resource_type]" defaultValue="document">
            <option value="document">Document</option>
            <option value="pdf">PDF</option>
            <option value="video">Video</option>
            <option value="image">Image</option>
            <option value="link">Link</option>
          </Select>
          <Input name="resource[file]" type="file" />
          <Button type="submit" disabled={uploadResource.isPending}>
            Upload
          </Button>
        </form>
      </div>
    </div>
  );
}

function CourseAnnouncements({ courseUuid }: { courseUuid: string }) {
  const { data: announcements } = useCourseAnnouncements(courseUuid);
  const createAnnouncement = useCreateCourseAnnouncement(courseUuid);
  const publish = usePublishInstructorAnnouncement(courseUuid);
  const remove = useDeleteInstructorAnnouncement(courseUuid);
  const [title, setTitle] = useState("");
  const [body, setBody] = useState("");

  return (
    <section className="mt-10 space-y-4">
      <h2 className="text-xl font-semibold text-slate-900">Course announcements</h2>
      <form
        className="flex flex-col gap-3 rounded-xl border border-slate-200 bg-white p-5 md:max-w-2xl"
        onSubmit={async (event) => {
          event.preventDefault();
          if (!title.trim() || !body.trim()) return;
          await createAnnouncement.mutateAsync({ title, body });
          setTitle("");
          setBody("");
        }}
      >
        <Input value={title} onChange={(e) => setTitle(e.target.value)} placeholder="Announcement title" required />
        <Textarea value={body} onChange={(e) => setBody(e.target.value)} rows={3} placeholder="Message for enrolled students" required />
        <Button type="submit" disabled={createAnnouncement.isPending}>
          Create draft
        </Button>
      </form>
      <div className="space-y-3">
        {announcements?.map((announcement) => (
          <div key={announcement.uuid} className="rounded-xl border border-slate-200 bg-white p-4">
            <div className="flex items-start justify-between gap-3">
              <div>
                <p className="font-medium text-slate-900">{announcement.title}</p>
                <p className="mt-1 text-sm text-slate-700">{announcement.body}</p>
              </div>
              <span className="text-xs text-slate-500">{announcement.published ? "Published" : "Draft"}</span>
            </div>
            <div className="mt-3 flex gap-2">
              {!announcement.published ? (
                <Button variant="secondary" onClick={() => publish.mutate(announcement.uuid)}>
                  Publish
                </Button>
              ) : null}
              <Button variant="danger" onClick={() => remove.mutate(announcement.uuid)}>
                Delete
              </Button>
            </div>
          </div>
        ))}
      </div>
    </section>
  );
}
