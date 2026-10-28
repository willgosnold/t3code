import { describe, expect, it } from "vite-plus/test";

import {
  compareBySkillUsage,
  EMPTY_SKILL_USAGE,
  promoteUsedSkills,
  recordSkillUses,
  type SkillUsage,
} from "./skillUsage.ts";

const skills = [{ name: "review" }, { name: "deploy" }, { name: "plan" }];

describe("recordSkillUses", () => {
  it("counts each skill once per message", () => {
    const usage = recordSkillUses(EMPTY_SKILL_USAGE, "$review then $review again", skills, 10);
    expect(usage).toEqual({ review: { count: 1, lastUsedAt: 10 } });
  });

  it("increments existing counts and refreshes recency", () => {
    const first = recordSkillUses(EMPTY_SKILL_USAGE, "$review and $deploy", skills, 10);
    const second = recordSkillUses(first, "run $review", skills, 20);
    expect(second).toEqual({
      review: { count: 2, lastUsedAt: 20 },
      deploy: { count: 1, lastUsedAt: 10 },
    });
    expect(first.review).toEqual({ count: 1, lastUsedAt: 10 });
  });

  it("ignores unknown tokens and currency amounts", () => {
    const usage = { review: { count: 1, lastUsedAt: 1 } };
    expect(recordSkillUses(usage, "costs $5 and $unknown", skills, 10)).toBe(usage);
  });

  it("returns the same reference when nothing matched", () => {
    expect(recordSkillUses(EMPTY_SKILL_USAGE, "no skills here", skills, 10)).toBe(
      EMPTY_SKILL_USAGE,
    );
  });

  it("does not inherit counts from object prototype keys", () => {
    const usage = recordSkillUses(EMPTY_SKILL_USAGE, "$constructor", [{ name: "constructor" }], 5);
    expect(usage).toEqual({ constructor: { count: 1, lastUsedAt: 5 } });
  });
});

describe("compareBySkillUsage", () => {
  const usage: SkillUsage = {
    review: { count: 3, lastUsedAt: 1 },
    deploy: { count: 3, lastUsedAt: 9 },
    plan: { count: 1, lastUsedAt: 50 },
  };

  it("ranks by count, then by most recent use", () => {
    expect(compareBySkillUsage(usage, "deploy", "review")).toBeLessThan(0);
    expect(compareBySkillUsage(usage, "review", "plan")).toBeLessThan(0);
    expect(compareBySkillUsage(usage, "plan", "review")).toBeGreaterThan(0);
  });

  it("puts used skills before unused ones and leaves the rest tied", () => {
    expect(compareBySkillUsage(usage, "plan", "other")).toBeLessThan(0);
    expect(compareBySkillUsage(usage, null, "plan")).toBeGreaterThan(0);
    expect(compareBySkillUsage(usage, "other", "unknown")).toBe(0);
    expect(compareBySkillUsage(usage, null, null)).toBe(0);
  });

  it("matches names case-insensitively", () => {
    expect(compareBySkillUsage(usage, " Deploy ", "REVIEW")).toBeLessThan(0);
  });
});

describe("promoteUsedSkills", () => {
  it("moves used skills to the front by rank and keeps other items in order", () => {
    const usage: SkillUsage = {
      b: { count: 1, lastUsedAt: 1 },
      d: { count: 4, lastUsedAt: 1 },
    };
    const items = [
      { id: "cmd-1", skill: null },
      { id: "a", skill: "a" },
      { id: "b", skill: "b" },
      { id: "cmd-2", skill: null },
      { id: "c", skill: "c" },
      { id: "d", skill: "d" },
    ];
    expect(promoteUsedSkills(items, (item) => item.skill, usage).map((item) => item.id)).toEqual([
      "d",
      "b",
      "cmd-1",
      "a",
      "cmd-2",
      "c",
    ]);
  });

  it("keeps the original order when nothing was used", () => {
    expect(promoteUsedSkills(["x", "y", "z"], (item) => item, EMPTY_SKILL_USAGE)).toEqual([
      "x",
      "y",
      "z",
    ]);
  });
});
