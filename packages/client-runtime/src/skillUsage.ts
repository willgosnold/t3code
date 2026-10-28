import { matchInlineSkills, type InlineSkill } from "@t3tools/shared/inlineSkills";
import * as Schema from "effect/Schema";

/** Per-device use counts, keyed by `skillUsageKey`. */
export const SkillUsage = Schema.Record(
  Schema.String,
  Schema.Struct({ count: Schema.Number, lastUsedAt: Schema.Number }),
);
export type SkillUsage = typeof SkillUsage.Type;

export const EMPTY_SKILL_USAGE: SkillUsage = {};

const skillUsageKey = (name: string) => name.trim().toLowerCase();

function usageOf(usage: SkillUsage, name: string | null) {
  if (name === null) return undefined;
  const key = skillUsageKey(name);
  return Object.hasOwn(usage, key) ? usage[key] : undefined;
}

/** Counts each known `$skill` once per message. Returns `usage` itself when none appear. */
export function recordSkillUses(
  usage: SkillUsage,
  text: string,
  skills: ReadonlyArray<InlineSkill>,
  at: number,
): SkillUsage {
  const used = new Set<string>();
  for (const match of matchInlineSkills(text, skills)) {
    used.add(skillUsageKey(match.skill.name));
  }
  if (used.size === 0) return usage;
  return {
    ...usage,
    ...Object.fromEntries(
      [...used].map((key) => [
        key,
        { count: (usageOf(usage, key)?.count ?? 0) + 1, lastUsedAt: at },
      ]),
    ),
  };
}

/** Negative when `a` ranks above `b`. A null name is not a skill and counts as unused. */
export function compareBySkillUsage(usage: SkillUsage, a: string | null, b: string | null): number {
  const usageA = usageOf(usage, a);
  const usageB = usageOf(usage, b);
  if (!usageA || !usageB) return usageA ? -1 : usageB ? 1 : 0;
  return usageB.count - usageA.count || usageB.lastUsedAt - usageA.lastUsedAt;
}

/** Used skills first by rank; every other item keeps its relative order. */
export function promoteUsedSkills<T>(
  items: ReadonlyArray<T>,
  skillNameOf: (item: T) => string | null,
  usage: SkillUsage,
): T[] {
  const used = items.filter((item) => usageOf(usage, skillNameOf(item)) !== undefined);
  if (used.length === 0) return [...items];
  used.sort((a, b) => compareBySkillUsage(usage, skillNameOf(a), skillNameOf(b)));
  return [...used, ...items.filter((item) => usageOf(usage, skillNameOf(item)) === undefined)];
}
