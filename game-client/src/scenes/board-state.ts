export interface BoardCellState {
  readonly row: number;
  readonly col: number;
  unitId: string | null;
}

export interface BoardState {
  readonly rows: number;
  readonly cols: number;
  readonly cells: BoardCellState[];
  leakedEnemyCount: number;
  currentRound: number;
}

export function createInitialBoardState(rows: number, cols: number): BoardState {
  const cells: BoardCellState[] = [];

  for (let row = 0; row < rows; row += 1) {
    for (let col = 0; col < cols; col += 1) {
      cells.push({
        row,
        col,
        unitId: null,
      });
    }
  }

  return {
    rows,
    cols,
    cells,
    leakedEnemyCount: 0,
    currentRound: 1,
  };
}
