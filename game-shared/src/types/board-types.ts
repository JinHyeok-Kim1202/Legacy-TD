export type GridCoordinate = [row: number, col: number];

export interface BoardStorageConfig {
  base_slots: number;
}

export interface BoardDefinition {
  board_id: string;
  rows: number;
  cols: number;
  path_id: string;
  storage: BoardStorageConfig;
}

export interface PathDefinition {
  id: string;
  tiles: GridCoordinate[];
}

export interface PathCatalog {
  paths: PathDefinition[];
}
