export interface HudViewModel {
  difficultyId: "easy" | "normal" | "hard";
  currentRoundLabel: string;
  leakLabel: string;
  storageCountLabel: string;
}

export function createHudViewModel(difficultyId: "easy" | "normal" | "hard"): HudViewModel {
  return {
    difficultyId,
    currentRoundLabel: "Round 1",
    leakLabel: "Leaks 0",
    storageCountLabel: "Storage 0",
  };
}
