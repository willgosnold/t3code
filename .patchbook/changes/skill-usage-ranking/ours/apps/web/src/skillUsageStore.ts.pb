import { EMPTY_SKILL_USAGE, recordSkillUses, SkillUsage } from "@t3tools/client-runtime/skillUsage";
import type { InlineSkill } from "@t3tools/shared/inlineSkills";

import { useLocalStorage, writeLocalStorageValue } from "./hooks/useLocalStorage";

const SKILL_USAGE_STORAGE_KEY = "t3code:skill-usage:v1";

export function useSkillUsage(): SkillUsage {
  return useLocalStorage(SKILL_USAGE_STORAGE_KEY, EMPTY_SKILL_USAGE, SkillUsage)[0];
}

export function recordSkillUsage(text: string, skills: ReadonlyArray<InlineSkill>) {
  if (recordSkillUses(EMPTY_SKILL_USAGE, text, skills, 0) === EMPTY_SKILL_USAGE) return;
  writeLocalStorageValue(
    SKILL_USAGE_STORAGE_KEY,
    (current) => recordSkillUses(current, text, skills, Date.now()),
    EMPTY_SKILL_USAGE,
    SkillUsage,
  );
}
