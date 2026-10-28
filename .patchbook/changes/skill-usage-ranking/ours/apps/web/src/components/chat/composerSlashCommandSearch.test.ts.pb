import type { SkillUsage } from "@t3tools/client-runtime/skillUsage";
import type { ProviderDriverKind } from "@t3tools/contracts";
import { describe, expect, it } from "vite-plus/test";

import type { ComposerCommandItem } from "./ComposerCommandMenu";
import { searchSlashCommandItems } from "./composerSlashCommandSearch";

const provider = "codex" as ProviderDriverKind;

const skillItem = (name: string): ComposerCommandItem => ({
  id: `skill:${name}`,
  type: "skill",
  provider,
  skill: { name, path: `/tmp/${name}/SKILL.md`, enabled: true },
  label: `/skill:${name}`,
  description: "",
});

const modelItem: ComposerCommandItem = {
  id: "slash:model",
  type: "slash-command",
  command: "model",
  label: "/model",
  description: "Switch response model",
};

const searchable = (items: ComposerCommandItem[]) =>
  items.filter((item) => item.type === "slash-command" || item.type === "skill");

const usage = (entries: Record<string, number>): SkillUsage =>
  Object.fromEntries(
    Object.entries(entries).map(([name, count]) => [name, { count, lastUsedAt: count }]),
  );

describe("searchSlashCommandItems usage", () => {
  const items = searchable([modelItem, skillItem("alpha"), skillItem("beta")]);

  it("puts used skills above built-in commands for an empty query", () => {
    expect(searchSlashCommandItems(items, "", usage({ beta: 2 })).map((item) => item.id)).toEqual([
      "skill:beta",
      "slash:model",
      "skill:alpha",
    ]);
  });

  it("breaks ties between equal scores by usage", () => {
    const tied = searchable([skillItem("review-a"), skillItem("review-b")]);

    expect(
      searchSlashCommandItems(tied, "review", usage({ "review-b": 1 })).map((item) => item.id),
    ).toEqual(["skill:review-b", "skill:review-a"]);
  });

  it("keeps a better match ahead of a heavily used skill", () => {
    const mixed = searchable([skillItem("deploy"), modelItem]);

    expect(
      searchSlashCommandItems(mixed, "model", usage({ deploy: 99 })).map((item) => item.id)[0],
    ).toBe("slash:model");
  });
});
