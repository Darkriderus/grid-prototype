# TODO: Health / Durability Component Split

## Idea

Split "can take damage" from "is a combatant."

A new minimal `HealthComponent` (hp, max hp, flat protection, `take_damage()`,
a `destroyed` signal) becomes the only thing non-combat objects (doors,
crates, breakable props) need. `StatComponent` stops owning health itself
and instead builds on top of `HealthComponent` for the combat-capable case
(accuracy, dodge, damage rolls). Attacks check which component an entity
actually has: full combat resolution against a `stat_component`, direct
unopposed damage against a bare `health_component`. Destruction behavior
(door opens, furniture drops loot, prop despawns) hangs off the `destroyed`
signal per entity type.

## Steps

1. **Add `HealthComponentDefinition`** in `entities/component_definitions/`
   — a `Resource` with `max_health` and `protection` exports. Same pattern
   as the other `*_component_definition.gd` files.

2. **Add `HealthComponent`** in `entities/components/`, extending
   `Component` — port over just the hp/`take_damage`/`heal` logic currently
   in `stat_component.gd` (the `health` setter with clamping +
   `changed.emit()`, `protection`, `take_damage()`). Add a `destroyed`
   signal that fires when health hits 0, plus a virtual `_on_destroyed()`
   for subclasses to override.

3. **Refactor `StatComponent` to hold a `HealthComponent`** rather than
   duplicating those fields — either as a child node it creates in `_init`,
   or by making `StatComponentDefinition extends HealthComponentDefinition`
   so combat stats are additive. `StatComponent.take_damage()`/`.health`
   just delegate to it, so `die()` stays where it is but the hp plumbing
   has one owner.

4. **Update `Entity`** to expose `health_component` alongside
   `stat_component`, and wire it in `set_entity_definition_by_resource()`
   from a new `EntityDefinition.health_definition` export — set
   independently of `stat_definition`, so an entity can have hp without
   full combat stats.

5. **Update `melee_action.gd` / `ranged_action.gd`** (and the fireball
   consumable) to branch on what the target has: if it has
   `stat_component`, keep the existing to-hit/dodge/damage flow; if it only
   has `health_component`, skip straight to a damage roll (no accuracy
   check) and call `take_damage()` directly.

6. **Give doors/furniture/crates their own `EntityDefinition` resources**
   with just `health_definition` set (no `stat_definition`, no `ai_type`)
   — same `.tres` pattern already used for `goblin.tres` etc.

7. **Hook `destroyed` per type** — connect it once per entity kind (e.g. in
   the definition or a small subclass) to whatever "broken" means there: a
   door swaps its `Tile` to open/broken, furniture spawns loot and
   `queue_free()`s, a prop just disappears.

8. **Smoke test:** melee-attack a door entity in a debug scene and confirm
   no accuracy roll happens, hp drops correctly, and `destroyed` fires the
   right behavior — then repeat for a ranged hit to confirm both paths
   share the same `health_component` code.
