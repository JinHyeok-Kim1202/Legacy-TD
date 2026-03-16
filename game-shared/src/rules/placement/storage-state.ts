import type { OwnedUnitInstance, StorageSlot, StorageState } from "../../types";

export function createStorageState(capacity: number): StorageState {
  const slots: StorageSlot[] = [];
  for (let index = 0; index < capacity; index += 1) {
    slots.push({ index, unit: null });
  }

  return {
    capacity,
    slots,
  };
}

export function getStoredUnits(storage: StorageState): OwnedUnitInstance[] {
  return storage.slots.flatMap((slot) => (slot.unit ? [slot.unit] : []));
}

export function findFirstEmptyStorageSlot(storage: StorageState): StorageSlot | null {
  return storage.slots.find((slot) => slot.unit === null) ?? null;
}

export function addUnitToStorage(storage: StorageState, unit: OwnedUnitInstance): boolean {
  const slot = findFirstEmptyStorageSlot(storage);
  if (!slot) {
    return false;
  }

  slot.unit = unit;
  return true;
}

export function removeUnitFromStorage(storage: StorageState, instanceId: string): OwnedUnitInstance | null {
  const slot = storage.slots.find((entry) => entry.unit?.instanceId === instanceId);
  if (!slot || !slot.unit) {
    return null;
  }

  const removedUnit = slot.unit;
  slot.unit = null;
  return removedUnit;
}
