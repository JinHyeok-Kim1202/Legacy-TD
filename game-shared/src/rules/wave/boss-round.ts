import { BOSS_INTERVAL_ROUNDS } from "../../constants/game-constants";

export function isBossRound(round: number): boolean {
  return round > 0 && round % BOSS_INTERVAL_ROUNDS === 0;
}
