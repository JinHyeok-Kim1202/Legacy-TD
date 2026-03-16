import type { DifficultyDefinition } from "../../types";

export function isGameOverFromLeaks(currentLeaks: number, difficulty: DifficultyDefinition): boolean {
  return currentLeaks >= difficulty.max_active_enemies;
}
