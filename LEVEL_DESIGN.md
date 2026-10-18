# LEVEL_DESIGN

## 1. Rules

**Structure**
- Chapter = chain of small rooms: mostly 1 screen, some 2–4 scrolling. One room = one readable challenge. Big = more rooms + branches, never open sprawl.
- Death → respawn at your entry point, <1 s; the room's enemies and grates reset. New resettable hazards join group `room_reset`.
- Arc: teach safely → develop → combine with older elements → twist → finale room.
- Section = 8–12 rooms. Section start = checkpoint: autosave (`SaveManager`) + title card.
- After 2–3 hard rooms: hazard-free breather (NPC, dialogue, view, health pack).

**Teaching**
- No tutorial text. First appearance = safe failure (climbable pit, not spikes); next room adds stakes.
- Main path 2–3/5. Crystal routes 3–5/5.
- Size gaps to the kit owned *in that room* (GAME_BRIEF metrics). Late kit crosses ~16 tiles: cap with low ceilings, wall hazards, dampeners.
- Grapple latches anchors only (walls block it).

**Readability**
- Main path always readable: exits framed by brass lamps/arches; dead ends look closed.
- Deadly = red/orange glow. Helpful = teal/brass. Attacks/activations telegraph ~0.4 s (flash, hiss, shake).
- Deadly hitboxes 2–4 px smaller than visuals; helpful ones larger.

**Enemies**
- Platforming obstacle first, fight second: each forces a movement choice.
- Stomp/hit pays back: bounce + dash and double-jump refill.

## 2. Crystals (gravity crystals)
- Off the main path, never required. Skill/key/gauntlet/trick crystals are visible from it (like Celeste strawberries); secret ones are not.
- Built: `mechanics/crystal.gd` `variant` NORMAL / WINGED / HIDDEN (`reveal_source` signal) / GRAND. Id = room_id + index: don't reorder crystals in a room.
- Route types (mix per chapter):
  - **Skill detour**: visible, harder line.
  - **Secret passage**: `FakeWall` (ASCII `F`, drawn with the surrounding wall's tile) covering the whole pocket, crystal `c` inside, so nothing shows; hinted only by geometry (a ledge into a wall, a dead-end shelf, a gap in a spike row). Drillable rock (c5+) may look cracked.
  - **Mechanic trick**: chapter mechanic used unexpectedly.
  - **Winged**: flies off if you dash in its room.
  - **Key/backtrack**: `GateSwitch` + `Gate` (saved) or `celeste_key` + `key_block`.
  - **Side gauntlet**: whole optional room.
- ~1 branch every 2–3 rooms → ~12 per chapter.
- Big secret per chapter: **Gravity Heart** in a hidden room, counted separately.

## 3. Catalog
✔ = exists.

| Name | Batch | Behavior | Telegraph | Decision | Intro |
|---|---|---|---|---|---|
| Spikes ✔ | A | Instant death | Static red | Route around | c0 |
| Steam vent ✔ | A | Timed burst, 1 HP + knockback | Hiss + puff 0.5 s | Wait or rush | c1 |
| Piston crusher ✔ | A | Slams on a cycle, kills when closed | Shudder, red gap light | Time the run under | c3 |
| Molten slag ✔ | A | Death pool; rises in finales | Orange glow, bubbles | Pace the climb | c4 |
| Cog saw on rail ✔ | A | Saw loops along a rail | Rail glows, sparks | Follow behind it | c4 |
| Falling rocks ✔ | A | Drop once when you pass under | Dust + shake | Keep moving or bait | c1 |
| Unstable crystal spikes ✔ | A | Burst 2 tiles out when near, retract 2 s | Crack glows red | Bait, then pass | c2 |
| Tesla arc ✔ | A | Beam between coils toggles | Coils brighten | Time the crossing | c6 |
| Crumbling grate ✔ | B | Collapses 0.5 s after landing, returns | Shake | Don't linger | c0 |
| Pressure spring ✔ | B | Launches you, refills dash | Coil compresses | Use the angle | c1 |
| Dash-refill shard ✔ | B | Restores dash, regrows 2.5 s | Teal glow; dim when used | Chain air dashes | c4 |
| Conveyor belt ✔ | B | Adds speed while standing | Moving arrows | Jump with or against | c1 |
| Mine cart on rail ✔ | B | Touch → races along rail, flings you | Rail lights, rattle | Jump at the end | c5 |
| Grapple anchor ✔ (fixed / moving / breakable) | B | Breakable ones snap 0.6 s after latch | Brass ring; cracks | Which anchor, when to let go | c5 |
| Drillable rock ✔ | B | Drill breaks it | Darker cracked tile | Drill or go around | c5 |
| Bellows wind ✔ | B | Constant push in one direction | Streaks, dust | Ride or fight it | c5 |
| Gravity anomaly field ✔ | B | Flips gravity (toggle / while inside) | Violet-teal shimmer | When to flip | c6 |
| Anomaly wall ✔ | B | Dash in → glide straight through; blocked exit kills | Teal starfield | Line up the angle | c6 |
| Rhythm blocks ✔ | B | Two sets swap solid/ghost on a beat | Tick + flicker | Move on the beat | c6 |
| Dampener field ✔ | B | Disables chosen abilities inside | Grey tint, crossed icon | Reduced kit | c6 |
| Clockwork guard ✔ | E | Patrols, turns only at walls/ledges; stompable | Wind-up click at turns | Stomp-bounce or hop over | c1 |
| Steam turret ✔ | E | Slow aimed bolt; slash it for a refill | Laser sight | Dodge or slash | c1 |
| Security drone ✔ | E | Locks on, charges straight, stunned on wall hit | Red eye + beep | Bait into a wall, stomp | c2 |
| Pressure mine ✔ | E | Inflates near you, bursts, launches you | Swells, red flash | Ride the blast or avoid | c5 |
| Cave crawler ✔ | E | Crawls walls and ceilings | Clicking, glowing eyes | Time it; flip gravity to stomp | c5 |
| Anomaly echo ✔ | E | Shadow replays your path 1.5 s late; kills | Fades in at entry | Never stop or backtrack | c6 |

Totals: 8 hazards, 12 obstacles, 6 enemies (min 3 each).

## 4. Chapters

**Arc: up the mountain, then down into it.** The corp sits on the mountain; the hero climbs to it (c0–c3, travel ↑ →), then descends into the corp's mine and the planet's core under it (c4–c6, travel ↓). Target length like Celeste: ~25–30 rooms and ~12 crystals per chapter (c2, c3 done; c1 and the old levels to be extended).

**Order:** c0 Surface (tutorial) → **c1 Outpost** → **c2 Smallville** → **c3 Steam City — the climb** (`LEVEL_c3.md`). The corp's seat built up the upper slopes tier upon tier: brick factories under yellow smog, brass pipes and domes, gas lamps, corp banners and searchlights; the citadel on the summit over the mouth of the great shaft. Signature: **presses** (`P`, slam in rhythm over the landings you climb) with belts, lifts and steam; ↑ → 21 screens, altitude backdrop.
- a Walls & lower city (7): wall-base scaffold, culvert climb (vents, turret), freight yard, pipe wall, press intro a05, slum stacks (spring lifts), Vesper's hideout a07.
- b Factory tiers (8): loudspeaker gate b01, press stairs b02, boiler-hall drone, Hron's canteen b04, refinery (+ stamping-room gauntlet b05b), lift shaft, refinery roof.
- c Upper city (6): Corporate Plaza alarm c01, barricade turret, 1×3 Clock Tower hammers c03, Vesper on the radio c04, cable gantry over the abyss, inner wall walk.
- d Citadel (7): blast-door gate d01, 2×2 security court (drones), press shaft, drill log terminal d04, steam elevator, summit terrace view d06, old workshops at the shaft mouth d07 → `level1` (the descent).
- 28 rooms, 12 crystals, 17 enemies, 4 checkpoints.

**c4 Foundry** (`level1`, old c1 plan). Signature: **dash**. Sections as planned before: Foundry yard (coil → dash), furnace halls (crushers, saws, slag), finale (rising slag). Old blueprint section "Outskirts" became c1 a.

**c5 Crystal Mines** (`level2`). Signature: **grapple**, then **drill**.
- a Upper galleries (8): hook at a01, fixed anchors over safe floors; falling rocks; Rusty's camp a08.
- b Crystal veins (10): moving/breakable anchors, crystal spikes, pressure mines, crawlers on walls, bellows.
- c Deep shafts (10): drill at c01; drillable rock, carts + grapple combos, drones.
- d Finale (4): cart run through a collapsing shaft. Heart: geode behind drillable rock, reachable only by cart fling → grapple.

**c6 Mining Complex & Reactor** (`level3` + `boss_room`). Signature: **gravity anomalies**.
- a Security docks (8): fields taught over safe ceilings; tesla arcs, drones.
- b Processing plant (10): anomaly walls, rhythm blocks, crawlers on ceilings + flips, dampener fields.
- c Reactor approach (10): combine everything; echo chase c04–c06; Vesper breather c07.
- d Core (3): finale room → boss intro → arena → ending → end screen. Heart: inverted room above the reactor.

**Boss: Reactor Warden** (corporate mech). Arena `c6_boss`: 2×1 screens, own scene, checkpoint per phase.
- P1: steam-bolt volleys + piston slams; slam exposes the core → wrench/hook it.
- P2: arena gravity flips on a beat, tesla arcs sweep; hook the exposed coils.
- P3: overload: rising slag escape to the sabotage valve.

## 5. Room standard
- Room = own scene `levels/c1/c1_a03.tscn` (copy `levels/room_template.tscn`): `Room` root at its top-left, `screens` 1×1 = **20×11 tiles** (bottom 4 px margin), big rooms 2×1, 1×2, 2×2, up to 4×1. Own `TileMapLayer` (grid per room).
- Chapter `levels/c1/chapter1.tscn`: `Chapter` root, rooms as direct children edge to edge, `Player` in the start room.
- Every entrance: ≥3-tile safe ledge + `RespawnPoint`. Openings ≥3 tiles. An opening with no room behind it kills. Section starts = `checkpoint` rooms.
- Naming: `c1_a03` = chapter 1, section a, room 3. Branch `c1_a03b`. Heart room `c1_c07h`. Prologue `c0_`, boss `c6_boss`.
- `room_id` = scene name = node name in the chapter. Hazards, enemies, crystals live inside the room scene. Don't put `RoomBackdrop` in chapter rooms.
- Travel: c0 →, c1 → with climbs ↑, c2 ↑ → (the climb), c3 ↑ → (the climb to the summit), c4–c6 ↓ (planned rework; old levels still c4 → then ↑, c5 ↓, c6 ↑).

## 6. ASCII rooms (`LEVEL_cN.md` → scenes)
- `### <room_id> — name` heading, then one ``` block: column ruler `   0123…`, rows labelled with the height of their top surface (`10`…`0` for 1 screen tall, `21`…`0` for 2). 1 char = 1 tile; 20×11 tiles per screen.
- Optional ```props block under it: `<target> <property> = <Godot value>`; target `room`, `decor`, a legend symbol (all its nodes) or symbol+index (`S2`). Strings in quotes, dialogue as `Array[String](["…", "…"])`.
- One ```layout block per chapter: `chapter res://levels/cN/chapterN.tscn`, optional `start_items <id> …`, then `<room_id> <sx> <sy>` in screens (top-left), first room = start. Branch rooms end with a letter (`c1_c02b`).
- Legend (full list in `tools/ascii_room_builder.gd` LEGEND): solid `#` stone, `B` brass, `W` planks, `Z` scrap metal, `R` roof, `%` blight soil, `_` dead-grass ground, `&` brick, `L` key block, `~` conveyor, `=` crumbling grate (2-tile pieces). Back wall, no collision: `w` planks, `z` scrap, `o` lit window, `b` boarded window, `d` door, `t` tarp, `q` brick, `k` dark rock. Decor: `l` lantern, `f` banner, `a` antenna, `y` dead tree, `x` blight crystal, `p` corp pylon, `h` fire (harmless). `decor burning = true` adds fire glow and smoke to the backdrop; `*_texture` props take a `"res://..."` path. Play: `@` respawn (air cell on a floor), `^ v < >` spikes, `S` spring, `V` steam vent, `I` crystal spikes (floor), `O` falling rock (hangs under a ceiling), `G` guard, `T` turret, `D` drone, `M` mine, `C` crystal, `*` dash shard, `K` key, `H` health pack, `X` chest, `F` fake wall (drawn like the wall around it), `c` crystal hidden behind fake wall, `!` event trigger, `E` level end, `N` generic NPC, `1` Otis, `2` Mira, `3` Brann, `4` Elda, `5` Tobi, `6` Rusty, `7` Vesper, `8` Hron. Steam City: `P` press housing (head down, `P reach = n`), `g` corp banner.
- Check: `python tools/level_check.py LEVEL_cN.md [--room id] [--map out.png --scale 6]` simulates the player (no dash/hook) and must print `OK` with every crystal reached. Build: run `tools/ascii_room_builder.gd` (File > Run); chapters listed in its `CHAPTERS`.
- Gotchas the checker taught: floor-spike hitboxes reach 18 px above their floor; wall jumps and springs refill the double jump; a solid top row caps a jump at ~h7.9 (1-screen room); rooms at different screen heights are offset by 4 px per screen (row 11+k of a 2-tall room ≈ row k of its neighbour). Turrets `T` fall (gravity): stand them on a floor, never under a ceiling; their line of sight ignores nothing solid, so a perch wider than 1 tile blinds them. Drones `D` hover.
