import { useAtomValue } from "@effect/atom-react";
import {
  EMPTY_SKILL_USAGE,
  recordSkillUses,
  type SkillUsage,
} from "@t3tools/client-runtime/skillUsage";
import type { InlineSkill } from "@t3tools/shared/inlineSkills";
import { AsyncResult } from "effect/reactivity";

import { appAtomRegistry } from "./atom-registry";
import { mobilePreferencesAtom, updateMobilePreferencesAtom } from "./preferences";

export function useSkillUsage(): SkillUsage {
  const preferences = useAtomValue(mobilePreferencesAtom);
  return AsyncResult.isSuccess(preferences)
    ? (preferences.value.skillUsage ?? EMPTY_SKILL_USAGE)
    : EMPTY_SKILL_USAGE;
}

export function recordSkillUsage(text: string, skills: ReadonlyArray<InlineSkill>) {
  if (recordSkillUses(EMPTY_SKILL_USAGE, text, skills, 0) === EMPTY_SKILL_USAGE) return;
  const at = Date.now();
  appAtomRegistry.set(updateMobilePreferencesAtom, {
    transform: (current) => ({
      skillUsage: recordSkillUses(current.skillUsage ?? EMPTY_SKILL_USAGE, text, skills, at),
    }),
  });
}
