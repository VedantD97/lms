import { useEffect, useRef, useState } from "react";
import { Link, useParams } from "react-router-dom";
import { Button } from "@/components/ui/Button";
import { LoadingSpinner } from "@/components/feedback/LoadingSpinner";
import { PageHeader } from "@/components/shared/PageHeader";
import {
  useCompleteLesson,
  useDownloadLessonResource,
  useStudentLesson,
  useUpdateLessonProgress,
} from "@/features/student/learning/hooks/useStudentLearning";
import { useDebounce } from "@/lib/hooks/useDebounce";

export function StudentLessonPage() {
  const { enrollmentUuid, lessonUuid } = useParams();
  const { data: lesson, isLoading } = useStudentLesson(enrollmentUuid ?? "", lessonUuid ?? "");
  const updateProgress = useUpdateLessonProgress(enrollmentUuid ?? "", lessonUuid ?? "");
  const completeLesson = useCompleteLesson(enrollmentUuid ?? "", lessonUuid ?? "");
  const downloadResource = useDownloadLessonResource();

  const videoRef = useRef<HTMLVideoElement>(null);
  const [videoPosition, setVideoPosition] = useState(0);
  const debouncedPosition = useDebounce(videoPosition, 1000);

  useEffect(() => {
    if (!lesson || lesson.content_type !== "video") return;
    if (debouncedPosition <= 0) return;

    const duration = lesson.duration_seconds ?? 1;
    const percent = Math.min(100, Math.round((debouncedPosition / duration) * 100));
    updateProgress.mutate({ progress_percent: percent, last_position_seconds: debouncedPosition });
  }, [debouncedPosition, lesson]);

  useEffect(() => {
    if (!lesson?.progress?.last_position_seconds || !videoRef.current) return;
    if (videoRef.current.currentTime > 0) return;
    videoRef.current.currentTime = lesson.progress.last_position_seconds;
  }, [lesson]);

  if (isLoading || !lesson) return <LoadingSpinner label="Loading lesson..." />;

  const isCompleted = lesson.progress.status === "completed";

  return (
    <div>
      <PageHeader
        title={lesson.title}
        description={`${lesson.module_title} · ${lesson.content_type.replace("_", " ")}`}
        action={
          <Link to={`/student/courses/${lesson.course_uuid}`}>
            <Button variant="secondary">Back to course</Button>
          </Link>
        }
      />

      <div className="mb-6 flex flex-wrap items-center gap-3 text-sm text-slate-600">
        <span>Progress: {lesson.progress.progress_percent}%</span>
        <span className="capitalize">{lesson.progress.status.replace("_", " ")}</span>
      </div>

      <div className="mb-8 rounded-xl border border-slate-200 bg-white p-6">
        {lesson.content_type === "text" || lesson.content_type === "mixed" ? (
          <div className="prose prose-sm max-w-none whitespace-pre-wrap text-slate-800">
            {lesson.content || "No written content for this lesson yet."}
          </div>
        ) : null}

        {lesson.content_type === "video" || lesson.content_type === "mixed" ? (
          <div className="mt-4">
            {lesson.content ? (
              <video
                ref={videoRef}
                controls
                className="w-full max-w-3xl rounded-lg bg-black"
                src={lesson.content}
                onTimeUpdate={(event) => setVideoPosition(Math.floor(event.currentTarget.currentTime))}
              />
            ) : (
              <p className="text-sm text-slate-600">Video content is attached as a lesson resource below.</p>
            )}
          </div>
        ) : null}

        {lesson.content_type === "document" ? (
          <p className="text-sm text-slate-600">Download the documents attached to this lesson below.</p>
        ) : null}
      </div>

      {lesson.resources?.length ? (
        <section className="mb-8">
          <h2 className="mb-4 text-lg font-semibold text-slate-900">Resources</h2>
          <ul className="space-y-2">
            {lesson.resources.map((resource) => (
              <li
                key={resource.uuid}
                className="flex items-center justify-between rounded-lg border border-slate-200 bg-white px-4 py-3 text-sm"
              >
                <div>
                  <p className="font-medium text-slate-900">{resource.title}</p>
                  <p className="text-slate-500 capitalize">{resource.resource_type}</p>
                </div>
                {resource.downloadable ? (
                  <Button
                    variant="secondary"
                    disabled={downloadResource.isPending}
                    onClick={() =>
                      downloadResource.mutate({
                        enrollmentUuid: enrollmentUuid ?? "",
                        resource: {
                          uuid: resource.uuid,
                          title: resource.title,
                          resource_type: resource.resource_type,
                        },
                      })
                    }
                  >
                    Download
                  </Button>
                ) : null}
              </li>
            ))}
          </ul>
        </section>
      ) : null}

      <div className="flex gap-3">
        {!isCompleted ? (
          <Button
            onClick={() => completeLesson.mutate()}
            disabled={completeLesson.isPending}
          >
            {completeLesson.isPending ? "Marking complete..." : "Mark as complete"}
          </Button>
        ) : (
          <span className="text-sm font-medium text-emerald-700">Lesson completed</span>
        )}
      </div>
    </div>
  );
}
