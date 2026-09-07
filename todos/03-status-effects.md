# TODO: Buff / Debuff (Status Effect) System

## Idea

Model status effects the same way Actions and Consumable components already
work: small polymorphic objects with apply/tick/remove hooks, managed by a
new component, ticked once per turn (the game is turn-based, so duration is
just an integer decremented per turn - no delta-time timers needed). Stat
modifiers slot in cleanly because StatComponent's stats are already computed
getters rather than stored values, so a buff/debuff never needs to "remember"
to undo itself - removing it from the active list is enough.

Stacking: effects of the same type stack independently (separate durations
per instance), up to a stack limit that is a property of the effect type
itself (not a global constant), since e.g. Bleeding and Confused need very
different caps. When a new stack would exceed the limit, replace whichever
existing instance of that type has the least remaining duration rather than
rejecting the new application or evicting the oldest.

This is also the prerequisite for the shelved body-part-health idea - body
part destruction debuffs are just another StatusEffect once this exists,
rather than bespoke code to build (and rebuild) twice.

## Steps

1. **Add a `StatusEffect` base class** (new `entities/status_effects/`
   folder, matching the `actions/`/`consumables/` pattern) with
   `effect_key`, `duration` (remaining turns), `stack_limit`, and virtual
   `on_apply(entity)`, `on_tick(entity)`, `on_remove(entity)`.

2. **Add `StatusEffectComponent`** (extends `Component`, same shape as the
   other components), holding `var active_effects: Array[StatusEffect] =
   []`.

3. **Implement `add_effect(effect: StatusEffect)`** on it: count existing
   active effects of the same type; if that count is at
   `effect.stack_limit`, find the existing instance of that type with the
   least remaining duration and replace it (`on_remove()` the old one, add
   the new one, `on_apply()`); otherwise just append and `on_apply()`.

4. **Implement `tick()`** on it: for each active effect, call
   `on_tick(entity)`, decrement its duration, and for any that hit 0, call
   `on_remove(entity)` and drop it from the array.

5. **Wire `tick()` into the turn loop** - call it from `Entity.end_turn()`
   so it fires once per entity per round, for player and enemies alike.

6. **Add a `get_modifier(stat_key: String) -> float`** on
   `StatusEffectComponent` that sums the contribution of all active effects
   for a given stat - the read side the stat getters will call into.

7. **Thread it into `StatComponent`'s relevant getters** (`accuracy`,
   `dodge_chance`, `protection`, etc.) - each adds
   `entity.status_effect_component.get_modifier("accuracy")` on top of its
   existing math, guarded with the same null-check pattern already used for
   `equipment_component`.

8. **Add `status_effect_component` to `Entity`** and wire it into
   `set_entity_definition_by_resource()`.

9. **Migrate confusion onto the new system.** Add a `ConfusionStatusEffect`
   (`stack_limit = 1`) whose `on_apply`/`on_remove` do the existing
   `ai_component` swap that `ConfusedEnemyAIComponent` currently does
   directly; update `ConfusionConsumableComponent.activate()` to call
   `target.status_effect_component.add_effect(ConfusionStatusEffect.new(number_of_turns))`
   instead of adding the AI component itself.

10. **Add save/restore to `StatusEffectComponent`** (array of
    `{effect_key, remaining_duration}`), following the same pattern every
    other component already uses, and hook it into `Entity.get_save_data()`
    / `restore()`.

Status-effect UI (aggregating same-type stacks into one display line) is a
separate, lower-priority pass once the mechanics above work - not blocking.
