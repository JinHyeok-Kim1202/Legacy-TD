export type RoundPhase = "draft" | "arrange" | "combat" | "reward";

export interface RoundSessionState {
  round: number;
  phase: RoundPhase;
  availableCommonDraws: number;
}

export function createInitialRoundSession(): RoundSessionState {
  return {
    round: 1,
    phase: "draft",
    availableCommonDraws: 2,
  };
}
