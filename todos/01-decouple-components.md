# TODO: Decouple Components / Make Them Testable

## Idea

Components currently reach into and get reached into by sibling components
and by lots of unrelated call sites, all through direct concrete references
(`entity.stat_component.xxx`, `entity.equipment_component.xxx`). There's no
boundary saying "only actions are allowed to orchestrate across
components" — so a rename or removal ripples everywhere. Loosening this
coupling is what makes individual components removable/rewritable and
testable in isolation.

## Steps

1. **Add `set_owner(entity)` to `Component`**, replacing
   `@onready var entity := get_parent() as Entity`. `Entity` calls it
   explicitly right after each `add_child(component)`. Remove the
   special-case manual `equipment_component.entity = self` workaround — it's
   no longer needed once every component gets wired the same way.

2. **Move cross-component orchestration out of the components and into
   `Action`s.** Audit `InventoryComponent.drop()` and
   `EquipmentComponent.get_save_data()` (and any other component that reads
   `entity.other_component`) and relocate that logic into the relevant
   `Action` (`DropAction`, `EquipAction`, etc.). Components should only ever
   touch their own state afterward.

3. **Add a `get_component(type)` (or typed helper) accessor on `Entity`**,
   and migrate the scattered `if entity.equipment_component: ...` guard
   checks across the codebase to go through it. One place owns "what if
   this entity doesn't have that component."

4. **Split the generic `entity.changed` signal into purpose-specific
   signals** (`health_changed`, `inventory_changed`, etc.), matching the
   pattern `EquipmentComponent.equipment_changed` already uses. Update UI
   listeners (`character_panel.gd`, `detail_panel.gd`, etc.) to the new
   signals as you go.

5. **Build the next new component (`HealthComponent`) against the new
   injection pattern**, to validate the approach end-to-end before
   retrofitting older components.

6. **Retrofit one existing component at a time** (start with whichever
   you're about to rewrite anyway) rather than a big-bang pass — each
   retrofit is: apply step 1's injection, remove any sibling-component
   reads per step 2.
