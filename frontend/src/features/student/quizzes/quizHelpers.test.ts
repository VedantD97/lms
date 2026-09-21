import { describe, expect, it } from "vitest";
import type { QuestionType } from "@/lib/api/types/quiz";

function buildResponsePayload(
  answers: Record<string, string[]>,
): Array<{ question_uuid: string; selected_option_uuids: string[] }> {
  return Object.entries(answers).map(([question_uuid, selected_option_uuids]) => ({
    question_uuid,
    selected_option_uuids,
  }));
}

function toggleAnswer(
  current: Record<string, string[]>,
  questionType: QuestionType,
  questionUuid: string,
  optionUuid: string,
): Record<string, string[]> {
  const existing = current[questionUuid] ?? [];
  if (questionType === "multiple_choice") {
    const next = existing.includes(optionUuid)
      ? existing.filter((id) => id !== optionUuid)
      : [...existing, optionUuid];
    return { ...current, [questionUuid]: next };
  }
  return { ...current, [questionUuid]: [optionUuid] };
}

describe("quiz answer helpers", () => {
  it("builds response payload from answer map", () => {
    const payload = buildResponsePayload({ q1: ["a1"], q2: ["b1", "b2"] });
    expect(payload).toEqual([
      { question_uuid: "q1", selected_option_uuids: ["a1"] },
      { question_uuid: "q2", selected_option_uuids: ["b1", "b2"] },
    ]);
  });

  it("toggles single choice answers", () => {
    const next = toggleAnswer({}, "single_choice", "q1", "a1");
    expect(next).toEqual({ q1: ["a1"] });
  });

  it("toggles multiple choice answers", () => {
    const first = toggleAnswer({}, "multiple_choice", "q1", "a1");
    const second = toggleAnswer(first, "multiple_choice", "q1", "a2");
    expect(second).toEqual({ q1: ["a1", "a2"] });
  });
});
