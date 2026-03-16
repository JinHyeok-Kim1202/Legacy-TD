export interface ModelRegistryEntry {
  id: string;
  assetPath: string;
}

export const initialModelRegistry: ModelRegistryEntry[] = [
  { id: "units/robin_hood", assetPath: "assets/models/units/robin_hood.glb" },
  { id: "units/nikola_tesla", assetPath: "assets/models/units/nikola_tesla.glb" },
  { id: "enemies/runner", assetPath: "assets/models/enemies/runner.glb" },
];
