export interface GameClientConfig {
  readonly targetFrameRate: number;
  readonly defaultDifficultyId: "easy" | "normal" | "hard";
  readonly boardRows: number;
  readonly boardCols: number;
}

export const defaultGameClientConfig: GameClientConfig = {
  targetFrameRate: 60,
  defaultDifficultyId: "normal",
  boardRows: 5,
  boardCols: 5,
};
