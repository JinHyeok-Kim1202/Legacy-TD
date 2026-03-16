import { readFileSync } from "fs";
import { resolve } from "path";

const rootDir = resolve(process.cwd());

const dataFiles = {
  unitCatalog: "game-shared/data/units/units.json",
  rarityCatalog: "game-shared/data/units/unit_ranks.json",
  enemyCatalog: "game-shared/data/enemies/enemies.json",
  bossCatalog: "game-shared/data/enemies/bosses.json",
  recipeCatalog: "game-shared/data/progression/recipes.json",
  waveCatalog: "game-shared/data/progression/waves.json",
  difficultyCatalog: "game-shared/data/progression/difficulties.json",
  rewardCatalog: "game-shared/data/progression/rewards.json",
  boardDefinition: "game-shared/data/boards/board_5x5.json",
  pathCatalog: "game-shared/data/boards/paths.json",
};

function loadJson(relativePath) {
  const absolutePath = resolve(rootDir, relativePath);
  const text = readFileSync(absolutePath, "utf8");
  return JSON.parse(text);
}

function assert(condition, message) {
  if (!condition) {
    throw new Error(message);
  }
}

function uniqueIds(items, label) {
  const seen = new Set();
  for (const item of items) {
    assert(typeof item.id === "string" && item.id.length > 0, `${label} has an item with missing id`);
    assert(!seen.has(item.id), `${label} contains duplicate id "${item.id}"`);
    seen.add(item.id);
  }
}

function validateBoard(board, paths) {
  assert(board.rows === 7, "Board rows must be 7");
  assert(board.cols === 7, "Board cols must be 7");
  const path = paths.find((entry) => entry.id === board.path_id);
  assert(path, `Board path_id "${board.path_id}" does not exist`);
  assert(Array.isArray(path.tiles), `Path "${board.path_id}" tiles must be an array`);
  assert(path.tiles.length === 24, `Outer ring path must contain 24 tiles, received ${path.tiles.length}`);

  for (const tile of path.tiles) {
    assert(Array.isArray(tile) && tile.length === 2, `Invalid tile coordinate in path "${path.id}"`);
    const [row, col] = tile;
    assert(Number.isInteger(row) && row >= 0 && row < 7, `Invalid row ${row} in path "${path.id}"`);
    assert(Number.isInteger(col) && col >= 0 && col < 7, `Invalid col ${col} in path "${path.id}"`);
    const isOuterRing = row === 0 || row === 6 || col === 0 || col === 6;
    assert(isOuterRing, `Path "${path.id}" contains non-outer-ring tile [${row}, ${col}]`);
  }
}

function validateReferences({
  units,
  enemies,
  bosses,
  recipes,
  waves,
  difficulties,
  rewards,
  board,
  paths,
  rarities,
}) {
  const unitIds = new Set(units.map((item) => item.id));
  const rarityIds = new Set(rarities.map((item) => item.id));
  const enemyIds = new Set(enemies.map((item) => item.id));
  const bossIds = new Set(bosses.map((item) => item.id));
  const pathIds = new Set(paths.map((item) => item.id));

  for (const unit of units) {
    assert(rarityIds.has(unit.rarity), `Unit "${unit.id}" uses unknown rarity "${unit.rarity}"`);
    assert(pathIds.has(board.path_id), `Board references missing path "${board.path_id}"`);
    assert(unit.placement.board_allowed || unit.placement.storage_allowed, `Unit "${unit.id}" cannot be placed anywhere`);
  }

  for (const enemy of enemies) {
    assert(pathIds.has(enemy.movement.path_id), `Enemy "${enemy.id}" uses unknown path "${enemy.movement.path_id}"`);
  }

  for (const boss of bosses) {
    assert(pathIds.has(boss.movement.path_id), `Boss "${boss.id}" uses unknown path "${boss.movement.path_id}"`);
    assert(boss.spawn_round % 10 === 0, `Boss "${boss.id}" spawn_round must be a multiple of 10`);
  }

  for (const recipe of recipes) {
    assert(unitIds.has(recipe.output_unit_id), `Recipe "${recipe.id}" outputs unknown unit "${recipe.output_unit_id}"`);
    for (const input of recipe.inputs) {
      assert(unitIds.has(input.unit_id), `Recipe "${recipe.id}" references unknown input "${input.unit_id}"`);
      assert(input.count > 0, `Recipe "${recipe.id}" has non-positive input count`);
    }
  }

  for (const wave of waves) {
    assert(wave.round > 0, `Wave round must be greater than 0`);
    for (const entry of wave.entries) {
      assert(enemyIds.has(entry.enemy_id), `Wave ${wave.round} references unknown enemy "${entry.enemy_id}"`);
      assert(entry.count > 0, `Wave ${wave.round} entry count must be greater than 0`);
    }
    if (wave.boss_id !== null) {
      assert(bossIds.has(wave.boss_id), `Wave ${wave.round} references unknown boss "${wave.boss_id}"`);
      assert(wave.round % 10 === 0, `Wave ${wave.round} cannot reference a boss outside 10-round interval`);
    }
  }

  const difficultyIds = difficulties.map((item) => item.id);
  assert(difficultyIds.includes("easy"), 'Difficulty list must include "easy"');
  assert(difficultyIds.includes("normal"), 'Difficulty list must include "normal"');
  assert(difficultyIds.includes("hard"), 'Difficulty list must include "hard"');

  assert(
    rewards.round_draw_rules.base_common_draws_per_round === 2,
    "Base common draws per round must stay at 2 for the current design"
  );
}

function main() {
  const unitCatalog = loadJson(dataFiles.unitCatalog);
  const rarityCatalog = loadJson(dataFiles.rarityCatalog);
  const enemyCatalog = loadJson(dataFiles.enemyCatalog);
  const bossCatalog = loadJson(dataFiles.bossCatalog);
  const recipeCatalog = loadJson(dataFiles.recipeCatalog);
  const waveCatalog = loadJson(dataFiles.waveCatalog);
  const difficultyCatalog = loadJson(dataFiles.difficultyCatalog);
  const rewardCatalog = loadJson(dataFiles.rewardCatalog);
  const boardDefinition = loadJson(dataFiles.boardDefinition);
  const pathCatalog = loadJson(dataFiles.pathCatalog);

  uniqueIds(unitCatalog.units, "units");
  uniqueIds(rarityCatalog.rarities, "rarities");
  uniqueIds(enemyCatalog.enemies, "enemies");
  uniqueIds(bossCatalog.bosses, "bosses");
  uniqueIds(recipeCatalog.recipes, "recipes");
  uniqueIds(pathCatalog.paths, "paths");
  uniqueIds(difficultyCatalog.difficulties, "difficulties");

  validateBoard(boardDefinition, pathCatalog.paths);
  validateReferences({
    units: unitCatalog.units,
    enemies: enemyCatalog.enemies,
    bosses: bossCatalog.bosses,
    recipes: recipeCatalog.recipes,
    waves: waveCatalog.waves,
    difficulties: difficultyCatalog.difficulties,
    rewards: rewardCatalog,
    board: boardDefinition,
    paths: pathCatalog.paths,
    rarities: rarityCatalog.rarities,
  });

  console.log("Legacy TD data validation passed.");
}

try {
  main();
} catch (error) {
  console.error("Legacy TD data validation failed.");
  console.error(error instanceof Error ? error.message : error);
  process.exit(1);
}
