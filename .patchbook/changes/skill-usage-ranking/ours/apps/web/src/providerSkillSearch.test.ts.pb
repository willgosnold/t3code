import { describe, expect, it } from "vite-plus/test";

import type { ServerProviderSkill } from "@t3tools/contracts";

import type { SkillUsage } from "@t3tools/client-runtime/skillUsage";

import { searchProviderSkills } from "./providerSkillSearch";

function makeSkill(input: Partial<ServerProviderSkill> & Pick<ServerProviderSkill, "name">) {
  return {
    path: `/tmp/${input.name}/SKILL.md`,
    enabled: true,
    ...input,
  } satisfies ServerProviderSkill;
}

describe("searchProviderSkills", () => {
  // regression: #12098 unicode currency symbols must work as skill aliases
  it.each(["$", "€", "£", "¥", "₹", "₩", "₿", "𑿝"])(
    "searches skills with a %s prefix",
    (prefix) => {
      const skill = makeSkill({ name: "review" });
      expect(searchProviderSkills([skill], `${prefix}review`)).toEqual([skill]);
    },
  );

  it("uses fuzzy ranking for abbreviated queries", () => {
    const skills = [
      makeSkill({ name: "gh-fix-ci", displayName: "Gh Fix Ci" }),
      makeSkill({ name: "github", displayName: "Github" }),
      makeSkill({ name: "agent-browser", displayName: "Agent Browser" }),
    ];

    expect(searchProviderSkills(skills, "gfc").map((skill) => skill.name)).toEqual(["gh-fix-ci"]);
  });

  it("returns the first enabled definition for each skill name", () => {
    const skills = [
      makeSkill({ name: "branch-audit", path: "/Users/matt/.codex/skills/branch-audit/SKILL.md" }),
      makeSkill({ name: "browser" }),
      makeSkill({ name: "branch-audit", path: "/Users/matt/.agents/skills/branch-audit/SKILL.md" }),
    ];

    expect(searchProviderSkills(skills, "").map((skill) => skill.path)).toEqual([
      "/Users/matt/.codex/skills/branch-audit/SKILL.md",
      "/tmp/browser/SKILL.md",
    ]);
  });

  describe("usage", () => {
    const usage = (entries: Record<string, number>): SkillUsage =>
      Object.fromEntries(
        Object.entries(entries).map(([name, count]) => [name, { count, lastUsedAt: count }]),
      );

    it("lists used skills first when the query is empty", () => {
      const skills = [
        makeSkill({ name: "alpha" }),
        makeSkill({ name: "beta" }),
        makeSkill({ name: "gamma" }),
      ];

      expect(
        searchProviderSkills(skills, "", undefined, usage({ gamma: 5, beta: 1 })).map(
          (skill) => skill.name,
        ),
      ).toEqual(["gamma", "beta", "alpha"]);
    });

    it("breaks ties between equal scores by usage", () => {
      const skills = [
        makeSkill({ name: "review-a" }),
        makeSkill({ name: "review-b" }),
        makeSkill({ name: "review-c" }),
      ];

      expect(
        searchProviderSkills(skills, "review", undefined, usage({ "review-c": 2 })).map(
          (skill) => skill.name,
        ),
      ).toEqual(["review-c", "review-a", "review-b"]);
    });

    it("keeps a better match ahead of a heavily used skill", () => {
      const skills = [makeSkill({ name: "ship-review" }), makeSkill({ name: "review" })];

      expect(
        searchProviderSkills(skills, "review", undefined, usage({ "ship-review": 50 })).map(
          (skill) => skill.name,
        ),
      ).toEqual(["review", "ship-review"]);
    });
  });
});
