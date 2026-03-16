import type { GameClientConfig } from "./game-client-config";
import { createInitialBoardState, type BoardState } from "../scenes/board-state";
import { createHudViewModel, type HudViewModel } from "../ui/hud-model";

export interface GameClient {
  readonly config: GameClientConfig;
  readonly boardState: BoardState;
  readonly hud: HudViewModel;
}

export function createGameClient(config: GameClientConfig): GameClient {
  return {
    config,
    boardState: createInitialBoardState(config.boardRows, config.boardCols),
    hud: createHudViewModel(config.defaultDifficultyId),
  };
}
