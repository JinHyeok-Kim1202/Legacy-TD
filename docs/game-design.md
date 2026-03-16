# Legacy TD Game Design

## High Concept
- Genre: grid-based tower defense
- Platforms: PC and mobile
- Visual direction: 3D low-poly
- Core loop: draw units, place units, merge units, survive waves

## Win / Loss
- Win target: survive through round 100
- Post-win mode: endless mode begins after round 100
- Loss condition: game over when leaked enemy count reaches the active difficulty limit

## Board
- The battlefield is a fixed 5x5 grid.
- Enemies move only on the outer ring path.
- The outer ring path rotates in one direction and never changes by player placement.
- Units can exist on the board or in storage.

## Round Flow
1. Draw 2 common units.
2. Reorganize storage and board placement.
3. Merge units if recipe requirements are met.
4. Start wave combat.
5. Resolve rewards and next round state.

## Unit Rarity
- Common
- Rare
- Unique
- Legendary
- Terminal branches after Legendary:
  - Transcendent
  - Immortal
  - God
  - Liberator

## Stats
- Strength increases physical damage.
- Agility increases attack speed and critical chance.
- Intelligence increases magic damage.

## Combat Types
- Physical damage
- Magic damage

## Boss Rule
- A boss appears every 10 rounds.

## Data Rules
- Recipes are defined in JSON data.
- Waves are defined in JSON data.
- Difficulty rules are defined in JSON data.
- Unit and enemy content is defined in JSON data.
