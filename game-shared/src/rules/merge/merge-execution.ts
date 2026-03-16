import type { OwnedUnitInstance, PlayerRosterState, RecipeCatalog, RecipeDefinition } from "../../types";
import { addOwnedUnitToRosterStorage } from "../placement/roster-state";

function getAllOwnedUnits(roster: PlayerRosterState): OwnedUnitInstance[] {
  const storageUnits = roster.storage.slots.flatMap((slot) => (slot.unit ? [slot.unit] : []));
  const boardUnits = roster.board.occupants.map((occupant) => occupant.unit);
  return [...storageUnits, ...boardUnits];
}

function countOwnedUnitsByDefinition(roster: PlayerRosterState): Map<string, number> {
  const counts = new Map<string, number>();
  for (const owned of getAllOwnedUnits(roster)) {
    counts.set(owned.definition.id, (counts.get(owned.definition.id) ?? 0) + 1);
  }
  return counts;
}

export function findRecipesForAnchorUnit(
  recipes: RecipeCatalog,
  roster: PlayerRosterState,
  anchorDefinitionId: string
): RecipeDefinition[] {
  const counts = countOwnedUnitsByDefinition(roster);

  return recipes.recipes.filter((recipe) => {
    const includesAnchor = recipe.inputs.some((input) => input.unit_id === anchorDefinitionId);
    if (!includesAnchor) {
      return false;
    }

    return recipe.inputs.every((input) => (counts.get(input.unit_id) ?? 0) >= input.count);
  });
}

function consumeUnitInstance(roster: PlayerRosterState, definitionId: string): OwnedUnitInstance | null {
  const storageSlot = roster.storage.slots.find((slot) => slot.unit?.definition.id === definitionId);
  if (storageSlot?.unit) {
    const owned = storageSlot.unit;
    storageSlot.unit = null;
    return owned;
  }

  const boardIndex = roster.board.occupants.findIndex((occupant) => occupant.unit.definition.id === definitionId);
  if (boardIndex >= 0) {
    const [removed] = roster.board.occupants.splice(boardIndex, 1);
    return removed.unit;
  }

  return null;
}

export interface ExecuteMergeParams {
  roster: PlayerRosterState;
  recipe: RecipeDefinition;
  outputUnit: OwnedUnitInstance;
}

export function executeMergeRecipe(params: ExecuteMergeParams): boolean {
  const consumedUnits: OwnedUnitInstance[] = [];

  for (const input of params.recipe.inputs) {
    for (let index = 0; index < input.count; index += 1) {
      const consumed = consumeUnitInstance(params.roster, input.unit_id);
      if (!consumed) {
        for (const rollbackUnit of consumedUnits) {
          addOwnedUnitToRosterStorage(params.roster, rollbackUnit);
        }
        return false;
      }
      consumedUnits.push(consumed);
    }
  }

  return addOwnedUnitToRosterStorage(params.roster, params.outputUnit);
}
