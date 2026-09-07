# TODO: Convert Doors from Tiles to Entities

## Idea

Doors currently live as `Tile` state (`TileTypeKeys.DOOR`/`DOOR_OPEN`), which
means they can never have HP, take a status effect, or be anything more than
static terrain — a `Tile` isn't an `Entity` and can't host a `Component`.
Once `02-health-rewrite` lands, a door becomes exactly the kind of object
that split was built for: something with `HealthComponent` (breakable,
choppable) that isn't a full combatant. Doors-as-entities also ride for free
on `04-floor-navigation`'s per-floor entity caching/save machinery, since
that already treats "every entity on a floor" generically.

The underlying tile stays a plain walkable `FLOOR`; a `Door` entity sits on
top of it and owns its own open/closed state, visuals, and blocking.

The one genuinely new piece of work, not a freebie: `FieldOfView._cast_light()`
and `MapData.setup_pathfinding()` currently only consult the `Tile` grid for
transparency/walkability. Doors-as-entities means both need to also account
for blocking/opaque entities at a coordinate, not just the tile underneath.

Not urgent — lower priority than the other todos, and has no real dependency
on `03`/`04` in either direction, so it's parked last on purpose rather than
by necessity.

## Steps

1. **Add a `DoorComponent`** (extends `Component`, same shape as
   `EquipmentComponent`/`InventoryComponent`) owning `is_open: bool`,
   `open_texture`/`closed_texture`, and `open()`/`close()`/`toggle()`.

2. **Each of those methods handles its own entity's state only:** swap
   `entity.texture`, flip `entity.blocks_movement`, and update the
   transparency flag FOV will read (per step 8).

3. **Add a `Door` entity definition** (`.tres`, same pattern as
   `goblin.tres` etc.) with `door_definition` wired into
   `EntityDefinition`/`set_entity_definition_by_resource()`.

4. **Add `MapData.get_door_at_location(coord)`**, mirroring the existing
   `get_actor_at_location()`/`get_blocking_entity_at_location()` pattern —
   filter entities at a coordinate for `door_component != null`.

5. **Retarget `OpenDoorAction`/`CloseDoorAction`** from
   `target_tile.set_tile_type(...)` to finding the door entity via step 4
   and calling `door_entity.door_component.open()`/`close()`.

6. **Update `main_game_input_handler.gd`'s door lookup** — currently
   `get_visible_tiles_by_type(Tile.TileTypeKeys.DOOR)` /
   `DOOR_OPEN` for the open/close input actions — to filter
   `get_visible_entities()` by `door_component` and open/closed state
   instead.

7. **Wire pathfinding sync into `open()`/`close()`** — call the existing
   `register_blocking_entity()`/`unregister_blocking_entity()`, the same
   weight-scale mechanism actors already use. No new pathfinding logic
   needed.

8. **Update `FieldOfView._cast_light()`** to also check for an opaque
   blocking entity at each coordinate, not just `current_tile.is_transparent()`
   — this is the one piece of real new logic in this todo.

9. **Add `DoorComponent.get_save_data()`/`.restore()`** (just `is_open`),
   following the same per-component pattern every other component uses —
   replaces the bespoke door state currently baked into `Tile`'s save data.

10. **Update `preset_dungeon_generator.gd`** — where the ascii-map loop
    currently places a `DOOR` tile, place a plain `FLOOR` tile instead and
    spawn a `Door` entity at that coordinate.

11. **Test:** open and close a door as the player, confirm pathfinding
    routes around a closed one and through an open one, confirm FOV is
    blocked through a closed door and not through an open one, and confirm
    door state survives a floor-cache round trip (leave and come back) and
    a save/reload.
