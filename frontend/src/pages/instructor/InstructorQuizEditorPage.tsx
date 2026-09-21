import { useEffect, useState } from "react";
import { Link, useParams } from "react-router-dom";
import { Button } from "@/components/ui/Button";
import { Input, Label, Textarea } from "@/components/ui/Field";
import { LoadingSpinner } from "@/components/feedback/LoadingSpinner";
import { PageHeader, StatusBadge } from "@/components/shared/PageHeader";
import {
  useCreateQuestion,
  useCreateQuestionOption,
  useDeleteQuestion,
  useDeleteQuestionOption,
  useInstructorQuiz,
  usePublishInstructorQuiz,
  useQuizAttempts,
  useReorderQuestions,
  useUnpublishInstructorQuiz,
  useUpdateInstructorQuiz,
  useUpdateQuestion,
  useUpdateQuestionOption,
} from "@/features/instructor/quizzes/hooks/useInstructorQuizzes";
import type { Question, QuestionOption, QuestionType } from "@/lib/api/types/quiz";

export function InstructorQuizEditorPage() {
  const { uuid } = useParams();
  const { data: quiz, isLoading } = useInstructorQuiz(uuid ?? "");
  const { data: attemptsData } = useQuizAttempts(uuid ?? "");
  const updateQuiz = useUpdateInstructorQuiz(uuid ?? "");
  const publish = usePublishInstructorQuiz();
  const unpublish = useUnpublishInstructorQuiz();
  const createQuestion = useCreateQuestion(uuid ?? "");
  const updateQuestion = useUpdateQuestion(uuid ?? "");
  const deleteQuestion = useDeleteQuestion(uuid ?? "");
  const reorderQuestions = useReorderQuestions(uuid ?? "");
  const createOption = useCreateQuestionOption(uuid ?? "");
  const updateOption = useUpdateQuestionOption(uuid ?? "");
  const deleteOption = useDeleteQuestionOption(uuid ?? "");

  const [title, setTitle] = useState("");
  const [description, setDescription] = useState("");
  const [passingScore, setPassingScore] = useState(70);
  const [maxAttempts, setMaxAttempts] = useState(1);
  const [timeLimit, setTimeLimit] = useState<number | "">("");
  const [shuffleQuestions, setShuffleQuestions] = useState(false);
  const [shuffleAnswers, setShuffleAnswers] = useState(false);

  useEffect(() => {
    if (!quiz) return;
    setTitle(quiz.title);
    setDescription(quiz.description ?? "");
    setPassingScore(Number(quiz.passing_score));
    setMaxAttempts(quiz.max_attempts);
    setTimeLimit(quiz.time_limit_minutes ?? "");
    setShuffleQuestions(quiz.shuffle_questions);
    setShuffleAnswers(quiz.shuffle_answers);
  }, [quiz]);

  if (isLoading || !quiz) return <LoadingSpinner label="Loading quiz..." />;

  function moveQuestion(questions: Question[], index: number, direction: -1 | 1) {
    const nextIndex = index + direction;
    if (nextIndex < 0 || nextIndex >= questions.length) return;
    const ordered = [...questions];
    [ordered[index], ordered[nextIndex]] = [ordered[nextIndex], ordered[index]];
    reorderQuestions.mutate(ordered.map((item) => item.uuid));
  }

  return (
    <div>
      <PageHeader
        title={quiz.title}
        action={
          <Link to={`/instructor/courses/${quiz.course_uuid}`}>
            <Button variant="secondary">Back to course</Button>
          </Link>
        }
      />

      <div className="mb-6 flex flex-wrap items-center gap-3">
        <StatusBadge status={quiz.status} />
        {quiz.status === "draft" ? (
          <Button variant="secondary" onClick={() => publish.mutate(quiz.uuid)}>Publish</Button>
        ) : (
          <Button variant="secondary" onClick={() => unpublish.mutate(quiz.uuid)}>Unpublish</Button>
        )}
      </div>

      <form
        className="mb-8 max-w-3xl space-y-4 rounded-xl border border-slate-200 bg-white p-6"
        onSubmit={(event) => {
          event.preventDefault();
          updateQuiz.mutate({
            title,
            description,
            passing_score: passingScore,
            max_attempts: maxAttempts,
            time_limit_minutes: timeLimit === "" ? null : Number(timeLimit),
            shuffle_questions: shuffleQuestions,
            shuffle_answers: shuffleAnswers,
          });
        }}
      >
        <div>
          <Label htmlFor="title">Title</Label>
          <Input id="title" value={title} onChange={(e) => setTitle(e.target.value)} required />
        </div>
        <div>
          <Label htmlFor="description">Description</Label>
          <Textarea id="description" value={description} onChange={(e) => setDescription(e.target.value)} />
        </div>
        <div className="grid gap-4 md:grid-cols-3">
          <div>
            <Label htmlFor="passing_score">Passing %</Label>
            <Input id="passing_score" type="number" min={0} max={100} value={passingScore} onChange={(e) => setPassingScore(Number(e.target.value))} />
          </div>
          <div>
            <Label htmlFor="max_attempts">Max attempts (0 = unlimited)</Label>
            <Input id="max_attempts" type="number" min={0} value={maxAttempts} onChange={(e) => setMaxAttempts(Number(e.target.value))} />
          </div>
          <div>
            <Label htmlFor="time_limit">Time limit (minutes)</Label>
            <Input id="time_limit" type="number" min={1} value={timeLimit} onChange={(e) => setTimeLimit(e.target.value ? Number(e.target.value) : "")} />
          </div>
        </div>
        <div className="flex flex-wrap gap-4">
          <label className="flex items-center gap-2 text-sm">
            <input type="checkbox" checked={shuffleQuestions} onChange={(e) => setShuffleQuestions(e.target.checked)} />
            Shuffle questions
          </label>
          <label className="flex items-center gap-2 text-sm">
            <input type="checkbox" checked={shuffleAnswers} onChange={(e) => setShuffleAnswers(e.target.checked)} />
            Shuffle answers
          </label>
        </div>
        <Button type="submit">Save settings</Button>
      </form>

      <section className="mb-8">
        <div className="mb-4 flex items-center justify-between">
          <h2 className="text-lg font-semibold text-slate-900">Questions</h2>
          <div className="flex gap-2">
            {(["single_choice", "multiple_choice", "true_false"] as QuestionType[]).map((type) => (
              <Button
                key={type}
                variant="secondary"
                onClick={() =>
                  createQuestion.mutate({
                    question_type: type,
                    body: `New ${type.replace("_", " ")} question`,
                    points: 1,
                  })
                }
              >
                Add {type.replace("_", " ")}
              </Button>
            ))}
          </div>
        </div>

        <div className="space-y-4">
          {quiz.questions?.map((question, index) => (
            <QuestionEditor
              key={question.uuid}
              question={question}
              onMoveUp={() => moveQuestion(quiz.questions ?? [], index, -1)}
              onMoveDown={() => moveQuestion(quiz.questions ?? [], index, 1)}
              onUpdate={(payload) => updateQuestion.mutate({ uuid: question.uuid, payload })}
              onDelete={() => deleteQuestion.mutate(question.uuid)}
              onCreateOption={(payload) => createOption.mutate({ questionUuid: question.uuid, payload })}
              onUpdateOption={(optionUuid, payload) => updateOption.mutate({ uuid: optionUuid, payload })}
              onDeleteOption={(optionUuid) => deleteOption.mutate(optionUuid)}
            />
          ))}
        </div>
      </section>

      <section className="rounded-xl border border-slate-200 bg-white p-6">
        <h2 className="text-lg font-semibold text-slate-900">Student attempts</h2>
        <div className="mt-4 space-y-2">
          {attemptsData?.data?.length ? (
            attemptsData.data.map((attempt) => (
              <div key={attempt.uuid} className="flex items-center justify-between rounded-lg bg-slate-50 px-3 py-2 text-sm">
                <span>Attempt #{attempt.attempt_number}</span>
                <span>{attempt.status}</span>
                <span>{attempt.percentage != null ? `${attempt.percentage}%` : "—"}</span>
                <span>{attempt.passed ? "Passed" : attempt.passed === false ? "Failed" : "—"}</span>
              </div>
            ))
          ) : (
            <p className="text-sm text-slate-600">No attempts yet.</p>
          )}
        </div>
      </section>
    </div>
  );
}

function QuestionEditor({
  question,
  onMoveUp,
  onMoveDown,
  onUpdate,
  onDelete,
  onCreateOption,
  onUpdateOption,
  onDeleteOption,
}: {
  question: Question;
  onMoveUp: () => void;
  onMoveDown: () => void;
  onUpdate: (payload: Partial<Question>) => void;
  onDelete: () => void;
  onCreateOption: (payload: Partial<QuestionOption>) => void;
  onUpdateOption: (uuid: string, payload: Partial<QuestionOption>) => void;
  onDeleteOption: (uuid: string) => void;
}) {
  const [body, setBody] = useState(question.body);
  const [points, setPoints] = useState(question.points);

  useEffect(() => {
    setBody(question.body);
    setPoints(question.points);
  }, [question.body, question.points]);

  return (
    <div className="rounded-xl border border-slate-200 bg-white p-5">
      <div className="flex flex-wrap gap-2">
        <Input value={body} onChange={(e) => setBody(e.target.value)} className="min-w-[280px] flex-1" />
        <Input type="number" min={0} value={points} onChange={(e) => setPoints(Number(e.target.value))} className="w-24" />
        <Button variant="secondary" onClick={() => onUpdate({ body, points })}>Save</Button>
        <Button variant="secondary" onClick={onMoveUp}>Up</Button>
        <Button variant="secondary" onClick={onMoveDown}>Down</Button>
        <Button variant="danger" onClick={onDelete}>Delete</Button>
      </div>
      <p className="mt-2 text-xs uppercase text-slate-500">{question.question_type.replace("_", " ")}</p>

      <div className="mt-4 space-y-2">
        {question.question_options?.map((option) => (
          <OptionRow
            key={option.uuid}
            option={option}
            onSave={(payload) => onUpdateOption(option.uuid, payload)}
            onDelete={() => onDeleteOption(option.uuid)}
          />
        ))}
      </div>

      {question.question_type !== "true_false" ? (
        <Button
          className="mt-3"
          variant="secondary"
          onClick={() => onCreateOption({ body: "New option", is_correct: false })}
        >
          Add option
        </Button>
      ) : null}
    </div>
  );
}

function OptionRow({
  option,
  onSave,
  onDelete,
}: {
  option: QuestionOption;
  onSave: (payload: Partial<QuestionOption>) => void;
  onDelete: () => void;
}) {
  const [body, setBody] = useState(option.body);
  const [isCorrect, setIsCorrect] = useState(option.is_correct ?? false);

  return (
    <div className="flex flex-wrap items-center gap-2 rounded-lg bg-slate-50 px-3 py-2">
      <Input value={body} onChange={(e) => setBody(e.target.value)} className="max-w-md" />
      <label className="flex items-center gap-2 text-sm">
        <input type="checkbox" checked={isCorrect} onChange={(e) => setIsCorrect(e.target.checked)} />
        Correct
      </label>
      <Button variant="secondary" onClick={() => onSave({ body, is_correct: isCorrect })}>Save</Button>
      <Button variant="danger" onClick={onDelete}>Delete</Button>
    </div>
  );
}
