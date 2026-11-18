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
| Molten slag ✔ | A | Death pool; rises in finales | Orange glow, bubbles | Pace the climb | c5 |
| Cog saw on rail ✔ | A | Saw loops along a rail | Rail glows, sparks | Follow behind it | c5 |
| Falling rocks ✔ | A | Drop once when you pass under | Dust + shake | Keep moving or bait | c1 |
| Unstable crystal spikes ✔ | A | Burst 2 tiles out when near, retract 2 s | Crack glows red | Bait, then pass | c2 |
| Tesla arc ✔ | A | Beam between coils toggles | Coils brighten | Time the crossing | c7 |
| Crumbling grate ✔ | B | Collapses 0.5 s after landing, returns | Shake | Don't linger | c0 |
| Pressure spring ✔ | B | Launches you, refills dash | Coil compresses | Use the angle | c1 |
| Dash-refill shard ✔ | B | Restores dash, regrows 2.5 s | Teal glow; dim when used | Chain air dashes | c5 |
| Conveyor belt ✔ | B | Adds speed while standing | Moving arrows | Jump with or against | c1 |
| Mine cart on rail ✔ | B | Touch → races along rail, flings you | Rail lights, rattle | Jump at the end | c6 |
| Grapple anchor ✔ (fixed / moving / breakable) | B | Breakable ones snap 0.6 s after latch | Brass ring; cracks | Which anchor, when to let go | c6 |
| Drillable rock ✔ | B | Drill breaks it | Darker cracked tile | Drill or go around | c6 |
| Bellows wind ✔ | B | Constant push in one direction; bellows-less mountain gusts `}` on a cycle | Streaks, dust; first snow streaks | Ride or fight it; wait out gusts in shelter | c4 |
| Gravity anomaly field ✔ | B | Flips gravity (toggle / while inside) | Violet-teal shimmer | When to flip | c7 |
| Anomaly wall ✔ | B | Dash in → glide straight through; blocked exit kills | Teal starfield | Line up the angle | c7 |
| Rhythm blocks ✔ | B | Two sets swap solid/ghost on a beat | Tick + flicker | Move on the beat | c7 |
| Dampener field ✔ | B | Disables chosen abilities inside | Grey tint, crossed icon | Reduced kit | c7 |
| Clockwork guard ✔ | E | Patrols, turns only at walls/ledges; stompable | Wind-up click at turns | Stomp-bounce or hop over | c1 |
| Steam turret ✔ | E | Slow aimed bolt; slash it for a refill | Laser sight | Dodge or slash | c1 |
| Security drone ✔ | E | Locks on, charges straight, stunned on wall hit | Red eye + beep | Bait into a wall, stomp | c2 |
| Pressure mine ✔ | E | Inflates near you, bursts, launches you | Swells, red flash | Ride the blast or avoid | c6 |
| Cave crawler ✔ | E | Crawls walls and ceilings | Clicking, glowing eyes | Time it; flip gravity to stomp | c6 |
| Anomaly echo ✔ | E | Shadow replays your path 1.5 s late; kills | Fades in at entry | Never stop or backtrack | c7 |

Totals: 8 hazards, 12 obstacles, 6 enemies (min 3 each).

## 4. Chapters

**Arc: up the mountain, then down into it.** The corp's HQ is carved into the cliff under the summit; the hero climbs to it (c0–c4, travel ↑ →; more mountain chapters may be added before the descent), then descends into the corp's mine and the planet's core under it (c5–c7, travel ↓). Target length like Celeste: ~25–30 rooms and ~12 crystals per chapter (c2, c3, c4 done; c1 and the old levels to be extended).

**Order:** c0 Surface (tutorial) → **c1 Outpost** → **c2 Smallville** → **c3 Steam City — the climb** (`LEVEL_c3.md`). The corp's seat built up the upper slopes tier upon tier: brick factories under yellow smog, brass pipes and domes, gas lamps, corp banners and searchlights; the citadel at the top, under the bare north face. Signature: **presses** (`P`, slam in rhythm over the landings you climb) with belts, lifts and steam; ↑ → 21 screens, altitude backdrop.
- a Walls & lower city (7): wall-base scaffold, culvert climb (vents, turret), freight yard, pipe wall, press intro a05, slum stacks (spring lifts), Vesper's hideout a07.
- b Factory tiers (8): loudspeaker gate b01, press stairs b02, boiler-hall drone, Hron's canteen b04, refinery (+ stamping-room gauntlet b05b), lift shaft, refinery roof.
- c Upper city (6): Corporate Plaza alarm c01, barricade turret, 1×3 Clock Tower hammers c03, Vesper on the radio c04, cable gantry over the abyss, inner wall walk.
- d Citadel (7): blast-door gate d01, 2×2 security court (drones), press shaft, drill log terminal d04, steam elevator, terrace view d06, back workshops d07 → c4.
- 28 rooms, 12 crystals, 17 enemies, 4 checkpoints.

**c4 The North Face — the climb to the HQ** (`LEVEL_c4.md`). Bare rock, snow and wind above the city; the corp cable car hauls crystals up to the HQ gate in the cliff. First chapter with **open rooms** (no ceilings or framing walls; edges without a neighbour are invisible walls). Signature: **mountain wind** (`}` gusts across a room: telegraph, gust, calm) on open faces; ↑ → 19 screens, altitude backdrop (STYLE_MOUNTAIN).
- a Scree above the city (7): citadel back gate a01, scree field, wind intro a03, miners' trail, chimney, overhang, refuge hut a07.
- b Cable car (7): lower station b01, first pylon (springs), catwalks under the cable (drone), maintenance shed b04, second pylon (+ frozen-pulley gauntlet b05b), upper station.
- c The ridge (7): knife-edge tailwind c01, avalanche couloirs, ice wall, Vesper radio in a cave c04, blighted ridge (drone), summit buttress, the saddle view c07.
- d The HQ gate (7): fortifications d01, lift shaft in the cliff, searchlight walkway (drones), guardroom log d04, blast-door presses, cliff gallery, the main gate d07 → `level1` (the descent).
- 28 rooms, 12 crystals, 15 enemies, 4 checkpoints.

**c5 The Foundry — down the great shaft** (`LEVEL_c5.md`, `levels/c5`, replaces `level1` in the campaign). The corp's foundry is built in tiers into the walls of the great shaft under the HQ; Otis gives the stolen Gravity Coil in the old workshops at the shaft head. Signature: **dash**, then **slag** `m`, **dash shards** `*`, **cog saws** `Q`; finale = slag flood `u` pouring down the shaft (1×3 chase). Open shaft rooms (ledges, tiers, scaffolds over the shaft's air), **down-exits** (gap in the bottom row over the room below, `@` right under it). ↓ → 23 screens, backdrop STYLE_FOUNDRY (redder with depth).
- a Shaft head (7): Otis + coil a01, dash with stakes a02, scaffolds a03, ore chute a04, crevice a05, winch (winged crystal) a06, lift-station view a07.
- b Foundry tiers (7): loudspeaker tier b01, slag intro b02, shard intro b03, Hron b04, crucible b05 (+ shard gauntlet b05b), ingot conveyors b06.
- c Casting halls (7): saw intro c01, saw shaft c02, mould presses c03, Vesper radio c04, saw loop c05, cooling shaft c06, gantry c07.
- d Slag sluice (7): alarm gallery d01, slag cascade d02, valve hall d03, smelter log d04, siren d05, slag-flood chase d06 (1×3), the mines' mouth d07 → c6.
- 28 rooms, 12 crystals, 15 enemies, 4 checkpoints.

**c6 The Crystal Mines** (`LEVEL_c6.md`, `levels/c6`, replaces `level2`). Under the foundry's sump: timbered galleries, living crystal veins, deep corp shafts. Signature: **grapple** (anchors `+`, Rusty's chest a01), then **drill** (rock plugs `r`, chest c01); finale = the collapsing shaft (1×3). ↓ → 23 screens, backdrop STYLE_MINES.
- a Upper galleries (7): Rusty + hook a01, broken gallery, old lift shaft, timber bridge (anchor chain), first vein (crystal spikes), tooth over the pit (winged), lift cage a07.
- b Crystal veins (7): sector B catwalks b01, mines + crawler intro b02, moving anchors b03, miner's niche b04, the great geode b05 (+ breakable-anchor gauntlet b05b), vein gallery b06.
- c Deep shafts (7): drill station c01, bore shaft, hook-and-drill line, Vesper radio c04, crawler pillars, blast shaft, gantry c07.
- d Sector D (7): gate gallery d01, crystal cascade, charge hall, blasting booth d04, detonator d05, collapsing shaft d06 (1×3), the blast door d07 → c7.
- 28 rooms, 12 crystals, 18 enemies, 4 checkpoints.

**c7 The Mining Complex & Reactor** (`LEVEL_c7.md`, `levels/c7`, replaces `level3`). The corp's machine complex over the failing core. Signature: **gravity fields** `:` (fall upward inside, walk the ceiling), then tesla arcs `i`, anomaly walls `n`, rhythm blocks `[` `]`, dampeners `-`, the echo `?`. ↓ → 23 screens, backdrop STYLE_REACTOR.
- a Security docks (7): first field over a safe pit a01, stakes a02, field lifts a03, tesla intro a04, ceiling spikes a05, winged a06, guard post a07.
- b Processing plant (7): belts b01, anomaly wall intro b02, floating blocks b03, technician's booth b04, sorting hall with ceiling crawlers b05 (+ gauntlet b05b), rhythm blocks b06.
- c Reactor approach (7): dampener intro c01, pump shaft, arc hall, Vesper in person c04, echo chases c05–c06, gantry c07.
- d Core (7): gate gallery d01, field cascade, coolant hall, control booth d04, shaft rim d05, the reactor shaft d06 (1×3), the reactor door d07 → `boss_room`.
- 28 rooms, 12 crystals, 15 enemies, 4 checkpoints. Not built yet: Gravity Hearts.

**Boss: Reactor Warden** (corporate mech). BUILT (P1 + P2): arena `c7_boss` is one screen (`LEVEL_boss.md` → `boss_room.tscn`), checkpoint per phase; P3 below is still only a plan.
- P1: steam-bolt volleys + piston slams; slam exposes the core → wrench/hook it.
- P2: arena gravity flips on a beat, tesla arcs sweep; hook the exposed coils.
- P3: overload: rising slag escape to the sabotage valve.

## 5. Room standard
- Room = own scene `levels/c1/c1_a03.tscn` (copy `levels/room_template.tscn`): `Room` root at its top-left, `screens` 1×1 = **20×11 tiles** (bottom 4 px margin), big rooms 2×1, 1×2, 2×2, up to 4×1. Own `TileMapLayer` (grid per room).
- Chapter `levels/c1/chapter1.tscn`: `Chapter` root, rooms as direct children edge to edge, `Player` in the start room.
- Every entrance: ≥3-tile safe ledge + `RespawnPoint`. Openings ≥3 tiles. An edge with no room behind it: left/right/top = invisible wall (you may jump 24 px over the top), bottom = death (pit). So rooms need not be closed boxes (c4+: open sky, open sides). Section starts = `checkpoint` rooms.
- Naming: `c1_a03` = chapter 1, section a, room 3. Branch `c1_a03b`. Heart room `c1_c07h`. Prologue `c0_`, boss `c7_boss`.
- `room_id` = scene name = node name in the chapter. Hazards, enemies, crystals live inside the room scene. Don't put `RoomBackdrop` in chapter rooms.
- Travel: c0 →, c1 → with climbs ↑, c2 ↑ → (the climb), c3 ↑ → (the climb to the citadel), c4 ↑ → (the north face to the HQ gate), c5 ↓ → (the Foundry, down the great shaft), c6 ↓ → (the mines), c7 ↓ → (the complex, down to the reactor door).

## 6. ASCII rooms (`LEVEL_cN.md` → scenes)
- `### <room_id> — name` heading, then one ``` block: column ruler `   0123…`, rows labelled with the height of their top surface (`10`…`0` for 1 screen tall, `21`…`0` for 2). 1 char = 1 tile; 20×11 tiles per screen.
- Optional ```props block under it: `<target> <property> = <Godot value>`; target `room`, `decor`, a legend symbol (all its nodes) or symbol+index (`S2`). Strings in quotes, dialogue as `Array[String](["…", "…"])`.
- One ```layout block per chapter: `chapter res://levels/cN/chapterN.tscn`, optional `start_items <id> …`, then `<room_id> <sx> <sy>` in screens (top-left), first room = start. Branch rooms end with a letter (`c1_c02b`).
- Legend (full list in `tools/ascii_room_builder.gd` LEGEND): solid `#` stone, `J` mountain rock (snow cap added on exposed tops), `B` brass, `W` planks, `Z` scrap metal, `R` roof, `%` blight soil, `_` dead-grass ground, `&` brick, `L` key block, `~` conveyor, `=` crumbling grate (2-tile pieces). Back wall, no collision: `w` planks, `z` scrap, `o` lit window, `b` boarded window, `d` door, `t` tarp, `q` brick, `k` dark rock. Decor: `l` lantern, `f` banner, `a` antenna, `y` dead tree, `x` blight crystal, `p` corp pylon, `h` fire (harmless). `decor burning = true` adds fire glow and smoke to the backdrop; `*_texture` props take a `"res://..."` path. Play: `@` respawn (air cell on a floor), `^ v < >` spikes, `S` spring, `V` steam vent, `I` crystal spikes (floor), `O` falling rock (hangs under a ceiling), `G` guard, `T` turret, `D` drone, `M` mine, `C` crystal, `*` dash shard, `K` key, `H` health pack, `X` chest, `F` fake wall (drawn like the wall around it), `c` crystal hidden behind fake wall, `!` event trigger, `E` level end, `N` generic NPC, `1` Otis, `2` Mira, `3` Brann, `4` Elda, `5` Tobi, `6` Rusty, `7` Vesper, `8` Hron. Steam City: `P` press housing (head down, `P reach = n`), `g` corp banner. North Face: `}` wind gusts across the whole room (`} direction`, `strength`, `period`, `on_time`, `offset`). Foundry (c5): `U` basalt, `Y` hot rock, `m` molten slag (one row, solid under it), `Q` cog saw (`Q rail = PackedVector2Array(0, 0, 64, 0)` flat px pairs, `Q period`, `Q loop`, `Q offset`), `u` slag flood pouring from the room's top (finale). Mines (c6): `+` grapple anchor (`+2 rail_end`, `+3 breakable`), `r` drillable rock (vertical run = one block), `e` cave crawler. Complex (c7): `:` gravity field and `-` dampener field (one node per connected group, its bounding rectangle), `n` anomaly wall and `[` `]` rhythm blocks A / B (filled rectangles), `i` tesla arc (a run, coil at each end), `?` echo (top-left of its 3×8 start zone).
- Check: `python tools/level_check.py LEVEL_cN.md [--room id] [--map out.png --scale 6]` simulates the player and must print `OK` with every crystal reached. Dash (8 directions, refills on ground, springs, shards `*`) only with `kit dash` in the layout block or `--dash`; `--nodash` turns it off (winged crystals); same for `hook` (anchors, 5.5 tiles, line of sight) and `drill`. Gravity fields, anomaly walls (dash-through, blocked exit = death) and dampeners are simulated; rhythm blocks count as solid; tesla arcs and the echo are ignored. `--room` also lists bottom drops (`propad dnem B<col>`: a down-exit or a pit). Build: run `tools/ascii_room_builder.gd` (File > Run); chapters listed in its `CHAPTERS`.
- Gotchas the checker taught: floor-spike hitboxes reach 18 px above their floor; wall jumps and springs refill the double jump; a solid top row caps a jump at ~h7.9 (1-screen room); rooms at different screen heights are offset by 4 px per screen (row 11+k of a 2-tall room ≈ row k of its neighbour); the player walks over that seam step (`STEP_HEIGHT` 12 px), but keep floors flush across screen edges: no 1-2 tile lips or crates right at an exit, walking through a seam must never need a jump (hazards/enemies at an exit are fine). Turrets `T` fall (gravity): stand them on a floor, never under a ceiling; their line of sight ignores nothing solid, so a perch wider than 1 tile blinds them. Drones `D` hover.
