# GAME_BRIEF

## Tech
- Godot 4.6, GL Compatibility. Main scene `main_menu.tscn`. Autoloads: `Global`, `SaveManager`, `DialogueManager`, `BeatClock` (hazard rhythm).
- Folders: `mechanics/`, `enemies/`, `npc/`, `ui/`, `autoload/`, `test/` (`test_*.gd` + `.tscn` runner), `tools/`, `levels/` (room chapters: `c1/`–`c7/`, `test_chapter/`). Player + old levels at root.
- Naming: snake_case scene+script pairs, Czech comments/UI, PascalCase `class_name`. Groups: `player`, `enemies`, `grapple_points`, `celeste_keys`, `spawn_points`, `room_reset`.
- Layers (unnamed): 1 world+player, 2 enemies, 3 (bit 4) pickups/NPCs, 4 (bit 8) bullets. Triggers: layer 0, mask 1.
- Legacy, ignore: `enemy`, `spikes`, `zip_block`, `moving_platform`.
- New `class_name` → `godot --headless --import` before headless tests.

## Screen
- Tile 16 px. 320×180 viewport (→1280×720), zoom 1 → **20×11.25 tiles/screen**.

## Exists
- Moves: run, jump (coyote 0.1 s, jump-cut), double jump, wall slide/climb/jump (8 s stamina), crouch, 8-dir dash, mouse-aimed grapple, gravity flip (`gravity_anomaly`: toggle orb, or with `size` a rectangular field that inverts gravity only inside). Walking climbs steps < 1 tile (`STEP_HEIGHT` 12 px: room seams), 16 px+ blocks.
- Dash/hook/melee/drill need `gravity_coil`/`grapple_hook`/`wrench`/`drill` **in one of the 2 tool slots** (any tool in either slot, swapped in the backpack window (Tab, anywhere) or at a chest, so only two tools work at once; no room may need three). The drill (LMB, aimed at the mouse) freezes the player in place, even mid-air, shakes the screen for 2 s and breaks the cracked rock; a hit cancels it. `health_pack` is used with Q and works from the backpack; items come only from chests (`Chapter.start_items` = `SupplyChest` at the first room's respawn with the items the player lacks).
- Player API: `refill_dash()`, `launch(v, lock)`, `set_lift_velocity(v)` (jump ≤0.1 s later adds it), `release_grapple()`, `set_abilities_blocked()`, `start/end_glide()`, `apply_wind(v)`.
- Attacks (2 dmg each): wrench melee, hook hit, dash contact.
- 3 HP, 1 s i-frames.
- Hazards: `GridSpikes`, `steam_vent`, `crumbling_platform`, `piston_crusher`, `cog_saw`, `tesla_arc`, `falling_rock`, `molten_slag`, `crystal_spikes` (`HazardKill` overlap, `BeatClock` rhythm), void. Obstacles: `celeste_key`+`key_block`, `grapple_point`, `pressure_spring`, `dash_shard`, `mine_cart`, `conveyor_belt`, `bellows_wind` (`bellows = false` = mountain gusts), `rhythm_block`, `anomaly_wall`, `dampener_field`, `drillable_rock`. Secrets: `FakeWall` (builder draws it with the surrounding wall tile, ASCII `c` = crystal hidden under it), `GateSwitch`+`Gate`.
- Enemies: `patrol_guard`, `shooter`, `drone` (sight → lock → charge → stun), `pressure_mine`, `cave_crawler`, `anomaly_echo`, boss `reactor_warden` (armoured; volley + piston slam, core exposed after a slam; phase 2 flips arena gravity; player death restarts the current phase); `take_hit`, `EnemyContact` (stomp = bounce + dash).
- `crystal`: NORMAL/WINGED/HIDDEN/GRAND, trail, counts after 0.15 s on safe ground, id = room_id_index; 6×4 grid inventory, `chest`, `health_pack`, `mine_key`.
- NPCs Otis, Rusty, Vesper, Mira, Brann, Elda, Tobi, Hron (`npc/*.tscn`, sprites `tools/create_story_npcs.py`); `event_trigger`.
- Room look: tileset `mechanics/room_tileset.tres` (row 0 solid: stone, brass, planks, scrap, roof, blight soil, dead-grass ground, brick; row 1 back walls, no collision; row 2 solid: mountain rock, rock with snow cap, basalt, hot rock), `RoomDecor` backdrop (smog sky, corp rigs, blight cracks; style Outpost / Village / City / Mountain / Foundry (the great shaft's far wall, redder with depth) / Mines (seam wall, crystal veins, old gallery mouths) / Reactor (the shaft again, cold with violet anomaly glow), `altitude` = horizon sinks as rooms climb), `DecorProp` (lantern, banner, antenna, dead tree, blight crystal, corp pylon, corp banner).
- Death: 0.25 s fade → respawn at room entry → `Global.room_reset` rebuilds the room's `enemies` + `room_reset` nodes, returns crystals.
- Save (same in every chapter, tutorial + level1–3 too): arrival in a chapter, checkpoint (Chapter checkpoint rooms; old levels: each new room area after the first safe landing), pause menu → `user://save.json` (position, room_id, inventory, chest contents). Continue: the save beats the carried `Global.has_persistent_player` state; chapter select starts with an empty backpack. Crystals + switches → `user://progress.json` instantly (New Game wipes). Tests touching saves back up + restore `user://`.
- UI: menu, pause, HUD (hotbar 1/2), chest window (backpack + chest), `BackpackWindow` on Tab (backpack + the 2 slots, anywhere; Esc closes an open chest before it pauses), dialogue, end screens. Tutorial instructions = `Guidepost` signs (board with the key, parchment fades in nearby). Flow: `tutorial_level` → c1 Outpost `levels/c1/chapter1.tscn` → c2 Smallville `levels/c2/chapter2.tscn` → c3 Steam City `levels/c3/chapter3.tscn` → c4 North Face `levels/c4/chapter4.tscn` → c5 Foundry `levels/c5/chapter5.tscn` → c6 Crystal Mines `levels/c6/chapter6.tscn` → c7 Mining Complex `levels/c7/chapter7.tscn` → `boss_room.tscn` (Chapter with one room `levels/boss/c7_boss`, from `LEVEL_boss.md`; boss `enemies/reactor_warden.gd`) → `ui/grand_summary_screen`. `level1–3.tscn` are out of the campaign (kept only as test fixtures).

## Movement (tiles)
- Jump: ~3 (2 comfortable).
- Double jump: ~+2.5 → ~5.5 total.
- Running jump: ~5.7 across; ~9 with double.
- Dash: ~5 (no gravity); exit speed carries ~+5 while dropping ~3.
- Dash + jump: ~13 across, ~16 with double; ~10 up.
- Wall jump ~2 up / ~2.7 out; climb-jump ~2.5; climb ~30 per stamina.
- Grapple: 5.5 range, anchors only (line of sight); refunds dash + double jump.
- Spring ~5.6 up; cart: ride-jump adds its speed, else 0.6× fling.
- Drill: passive item; dash breaks `drillable_rock`.

## Rooms
- New chapters: `Chapter` root + `Room` scenes (LEVEL_DESIGN §5). Made from ASCII blueprints `LEVEL_cN.md` (format LEVEL_DESIGN §6): check `python tools/level_check.py LEVEL_cN.md` (player physics sim incl. dash / hook / drill with `kit dash hook drill`, gravity fields, anomaly walls, dampeners; must print OK), build `tools/ascii_room_builder.gd` (editor File > Run, `CHAPTERS` list; skips existing scenes unless `OVERWRITE`) or headless per room `godot --headless --path . -s res://tools/build_rooms_cli.gd -- LEVEL_cN.md res://levels/cN/ <room_id>...` (overwrites). Screenshots: `godot --path . -s res://tools/shots_cli.gd -- <out_dir> <scene> <room_id | x,y | hint:room_id>...`. Example `levels/test_chapter/`.
- 0.3 s transition freeze; edge with no room behind: sides/top = invisible wall (24 px overshoot up), bottom = death; only current + neighbour rooms process; checkpoint rooms autosave; layout `hint_up_exits` (c3, c4) = `UpExitHint` light + rising motes under ceiling gaps that lead to the room above; `SeamWalls` (all chapters) draws a 6 px strip of the neighbour room's wall where it starts right behind an open screen edge (drawing only, no collision). `Global.room_entered/exited`. Debug: F1 bounds, F2 teleport.
- Old levels use `RoomBackdrop` grid cells.
- Adding a level/chapter: `Global._on_scene_changed`, `level_end.next_level` (chapters: `E` props in the last room), menu `BtnChapters` grid.

## Design rules
- Rules, catalog, chapter plan: `LEVEL_DESIGN.md`.

## Project facts
- School-leaving (maturita) project: 2D story platformer in the style of Celeste, steampunk/fantasy. GDScript, Windows build.
- Story: a megacorporation monopolises the mining of magical gravity crystals. Reckless mining destabilises the planet's core and causes gravity anomalies. The hero, a resistance member, infiltrates the main mining complex to sabotage the reactor.
- Assignment minimums: double jump, grappling hook, gravity swap (energy anomalies), 2+ attack types; 3+ levels; 3+ enemy types and 10+ placed enemies; a boss with 2+ attacks/phases; 3+ environmental hazards and 3+ movement/platform obstacles; 3+ item types + inventory UI; 3 NPCs, 5 dialogue scenes; menu (start/continue/quit), position saving, event triggers, end screen.
- Also planned: dash, wall climbing, drill.

## Session rules
- Godot 4, typed GDScript, follow the existing conventions.
- Open only the files the task needs; don't scan the whole project.
- Output only new or changed code; never reprint unchanged files.
- Don't stop to ask unless truly blocked: pick the sensible option and note it.
- No sprites yet → placeholder shapes. Deadly = red/orange, helpful = teal/brass.
- End with max 5 bullets and append 3 lines to PROGRESS.md: added / files touched / what to test.
- Running out of room → finish the current file, then write CONTINUE FROM: <step>.
