# TODO: Support Going Back Up Floors

## Idea

Going up currently isn't possible, and regenerating a previously-visited
floor from its seed wouldn't give the right result anyway (killed monsters
would respawn, looted items would reappear, opened doors would reset). The
floor's actual state already lives in its `MapData.tiles`/`.entities`
arrays as real `Tile`/`Entity` node references — so instead of destroying
and regenerating a floor when leaving it, park those live objects in an
in-memory cache and re-attach them when the player comes back, only
generating a floor the first time it's visited.

This also covers persisting multiple floors to the on-disk save file
(currently only the active floor is saved), so quit-and-reload remembers
previously-visited floors too, not just the one the player was standing on.

## Steps

1. **Add `up_stairs_location: Vector2i` to `MapData`**, right alongside the
   existing `down_stairs_location`.

2. **In `preset_dungeon_generator.gd`, set `dungeon.up_stairs_location =
   coord`** when the generator places the `UP_STAIRS` tile — mirror
   whatever currently sets `down_stairs_location` for `DOWN_STAIRS` (worth
   double-checking that assignment actually exists today; add it if it
   doesn't).

3. **Add a floor cache to `Map`**: `var floor_cache: Dictionary[int,
   MapData] = {}`.

4. **Before a floor gets discarded, park it instead.** Remove the player
   from that floor's `MapData.entities` array first (same trick
   `get_save_data()` already uses — skip player when iterating), then
   store the `MapData` object itself in
   `floor_cache[map_data.current_floor]` rather than `queue_free()`-ing its
   tiles and entities.

5. **Generalize `next_floor()` into `change_floor(target_floor: int,
   arrival_location: Vector2i)`.** It checks `floor_cache` first — if the
   floor's cached, `add_child()` its stored tiles/entities back into the
   scene and reuse that `MapData` directly; otherwise fall back to
   `dungeon_generator.generate_dungeon()` like today. Either path ends by
   placing the player at `arrival_location` and refreshing FOV.

6. **Update `TakeStairsAction`** to check both `down_stairs_location` and
   `up_stairs_location`, and call `change_floor()` with the right target:
   down stairs -> `current_floor + 1` at that floor's `up_stairs_location`;
   up stairs -> `current_floor - 1` at that floor's `down_stairs_location`.

7. **Extend the signal side** — add a `player_ascended` signal next to
   `player_descended` (or generalize both into one signal carrying a
   direction), and update `Map`'s connection to route into
   `change_floor()`.

8. **Test the round trip:** descend, kill/loot something, go back up,
   confirm the floor matches what you left rather than a fresh
   regeneration — then descend again and confirm the deeper floor also
   comes back correctly (not double-cached or lost).

## Additional Steps: Persist All Floors to the Save File

9. **Move save/load ownership from `MapData` to `Map`.**
   `MapData.get_save_data()`/`.restore()` stay as-is (they already
   serialize one floor correctly) — `Map` becomes the thing that knows
   about *all* floors, since it's the one holding `floor_cache`.

10. **`Map.save_game()` serializes every floor, not just the active one.**
    Build `{"player": player.get_save_data(), "current_floor":
    map_data.current_floor, "floors": {...}}`, where `floors` is every
    entry in `floor_cache` plus the currently-active `map_data`, each
    floor's dict keyed by its floor number (as a string — JSON keys have
    to be strings, so convert on the way out and back).

11. **`Map.load_game()` restores the active floor fully** (same as today —
    live `MapData`, tiles/entities attached to the scene) **but keeps the
    other floors lazy.** Store their raw serialized dictionaries in a
    `pending_floor_data: Dictionary[int, Dictionary]` rather than
    reconstructing every floor's `Tile`/`Entity` nodes up front — no
    reason to pay that cost for floors the player hasn't walked back onto
    yet.

12. **Update `change_floor()` to check three sources in order:**
    `floor_cache` first (already live this session), then
    `pending_floor_data` (from a loaded save, not yet touched —
    deserialize it into a real `MapData` here and move it into
    `floor_cache`), and only fall back to
    `dungeon_generator.generate_dungeon()` for a floor that's genuinely
    never been visited.

13. **Double check `player.map_data` gets reassigned correctly** on every
    one of those three paths, not just the "generate fresh" one.

14. **Test:** descend a couple floors, save and quit, reload — confirm you
    land back on the right floor; go up and confirm the earlier floor is
    exactly as left (not regenerated); descend again to a floor you
    haven't touched since reloading, and confirm it lazily restores from
    `pending_floor_data` correctly.
