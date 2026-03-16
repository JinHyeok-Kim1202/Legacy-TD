import type { RecipeDefinition } from "../../types";

export interface UnitInventoryCounts {
  [unitId: string]: number;
}

export function canCraftRecipe(recipe: RecipeDefinition, inventory: UnitInventoryCounts): boolean {
  return recipe.inputs.every((input) => (inventory[input.unit_id] ?? 0) >= input.count);
}
