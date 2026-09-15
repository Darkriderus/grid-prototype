# TODO: Grid-Based Drag-and-Drop Inventory (Mouse Support)

## Idea

Add mouse-driven, grid-based inventory interaction (drag items between the
player's inventory and a container) as a uniform slot grid rather than the
current keyboard-shortcut vertical lists (`inventory_menu.gd`, `loot_menu.gd`).
Godot's Control nodes already provide the drag-and-drop mechanism
(`_get_drag_data`/`_can_drop_data`/`_drop_data`), and the actual item
transfer logic already exists (`InventoryComponent.drop()`/`pickup()`,
already used by `LootMenu.button_pressed()`) — this is mostly UI plumbing
around existing logic, not new game logic.

Explicitly the simple version: uniform one-item-per-cell slots, no
Tetris/footprint-style item shapes, no data model change to `ItemComponent`.

Goal is depth without Cataclysm: Dark Days Ahead's UX problems — many item
types and detailed stats are fine, as long as the interaction stays one
consistent, visual, low-friction pattern (this same slot grid) reused
everywhere, with detail on demand (tooltip) rather than crammed into the
default view. Filtering/sorting/category tabs are a likely follow-up once
item variety grows, but out of scope for this pass.

## Steps

1. **Add a new grid-slot scene/script** (e.g. `inventory_slot.gd` extending
   a `Control`/`TextureButton`), replacing the current per-item `Button`
   (`inventory_menu_item_scene`) used in `inventory_menu.gd`/`loot_menu.gd`.
   Holds a reference to the slot's `Entity` item (or null if empty) and
   displays `item.texture`.

2. **Implement `_get_drag_data(position)`** on the slot: if it holds an
   item, build a drag payload (`{"item": item, "source_inventory":
   inventory_component}`) and call `set_drag_preview()` with a copy of the
   icon.

3. **Implement `_can_drop_data(position, data)`**: validate the payload has
   an `"item"` key and that the target inventory has room — reuses
   `InventoryComponent.has_space_for_item()`, which already exists.

4. **Implement `_drop_data(position, data)`**: call the existing
   `drop()`/`pickup()` pair on the source/target `InventoryComponent`s —
   the same calls `LootMenu.button_pressed()` already makes today — then
   refresh both grids.

5. **Replace `inventory_menu.gd`'s `VBoxContainer`/`_register_item()`
   list-building with a `GridContainer`** of a fixed slot count,
   instantiating one slot scene per cell; empty cells get slot scenes with
   no item.

6. **Update `loot_menu.gd` the same way** — two `GridContainer`s (player +
   container) instead of the two `VBoxContainer`s, reusing the same slot
   scene for both.

7. **Decide and implement the keyboard fallback explicitly** — either keep
   the existing letter-shortcut selection (`a`/`b`/`c`) working alongside
   drag-and-drop on the same slots, or drop it for inventory screens
   specifically.

8. **Add a rich stat tooltip per slot**, overriding `_make_custom_tooltip()`
   (rather than plain `tooltip_text`) so it can return a small formatted
   panel instead of one line of text — showing `get_item_name()`, weight,
   and the relevant stats (`protection`, `min_damage`/`max_damage`,
   `dodge_chance`, etc. depending on item type) pulled straight from the
   hovered item's components.

9. **Add equipped-item comparison to that same tooltip.** When the hovered
   item `is_equippable()`, look up whatever's currently in that
   `EquippableComponent.equipment_type` slot via
   `entity.equipment_component.get_item_from_slot()`, and render a stat
   delta line per relevant stat (protection, damage range, dodge chance)
   against the hovered item — this works identically whether hovering in
   the player's own inventory or in a loot container, since it's always
   comparing against what the *player* has equipped.

10. **Test:** drag an item between inventories and confirm the transfer +
    rejection-when-full behavior from before; confirm tooltips show
    correct values for equippable, non-equippable, and empty slots without
    crashing; confirm the comparison delta only appears for equippable
    items and matches the actual difference when you go ahead and equip
    the item.
