# LEVEL c3 — Steam City (the climb)

High above Smallville the mountain trail ends at the lowest wall of Steam City, the corporation's seat. The city climbs the upper slopes of the mountain tier upon tier: slums and freight yards against the walls, factory tiers of presses and refineries, the Upper City with the Corporate Plaza and the Clock Tower, and on the very summit the corp citadel over the mouth of the great shaft that is drilled down to the planet's core. Brick, brass pipes and domes, gas lamps, corp banners and searchlights, yellow smog. The hero **climbs** the city to the summit; at the shaft mouth the descent into the core begins (→ `level1`, Otis in the old workshops above the shaft).

- **Kit:** run, jump, double jump (DJ), wall climb/jump (8 s stamina), wrench. No dash, no hook.
- **New here:** **piston press** (`P`, a05). Develops: conveyor belts (`~`), steam vents, springs (pneumatic lifts), grates, guards, turrets, drones (introduced in Smallville), crystal spikes (refinery spills).
- **Signature:** **climbing a machine city.** Travel is ↑ and →. Presses slam in rhythm over the landings you climb through, belts and lifts carry you, steam from every pipe joint.
- **Look:** `&` brick (factories, walls, towers), `B` brass (pipes, machinery, catwalks), `#` stone (city walls, plaza, citadel), `Z` scrap (slums, crates), `W` planks (scaffolds, crates), `R` roofs; back walls `q` brick, `o` lit windows (many — the city is awake), `b` boarded, `d` doors, `z` scrap, `k` dark rock/shadow. Decor `l` gas lamps (plenty), `g` corp banners, `p` corp pylons/searchlights, `x` blight spills, `a` antennas and `t` tarps in the slums, `f` resistance banner only at Vesper's hideout. Leave air `.` where the smog sky should show. Every room shows the corp or the blight.
- **Rules:** LEVEL_DESIGN §1–2, §5, ASCII format §6. Crystals: 12, route types never repeat back to back.

## Celeste rules for this chapter (read before drawing)

- **One idea per room**, small rooms: mostly 1×1, climbs 1×2, the Clock Tower 1×3, one 2×2 courtyard. Death is cheap (respawn at the room entry in <1 s), so rooms may be tight — but the main path stays 2–3/5 and always readable.
- **Teach → test:** the press first appears where you only watch it (a05); the next rooms add stakes.
- **Climbing:** never require more than ~4 s of continuous wall climbing without a ledge to stand on (stamina 8 s); a 1×2 climb gets at least one rest ledge per screen.
- **Up-exits:** a top exit is an opening ≥3 tiles wide in the top row; the room above has a matching hole in its bottom row and a ledge with `@` right beside it (the game gives a small upward boost when you jump up through a room edge).
- **No invisible deaths:** walking, jumping or climbing out of a room where no room exists kills. Close every outer wall and give every room a solid top row except at its exits. Floor pits over nothing are allowed as visible stakes in 1×1 rooms, never under a respawn.
- **Secrets must be invisible.** Fill the whole secret pocket with `F` (the builder draws it with the surrounding wall's tile) and put its crystal as `c` — nothing of the pocket may show, and keep a solid tile between the pocket and the room edge. Hint only with geometry (a ledge into a wall, a dead-end shelf, a lone lamp), never with a different tile or dark back tile.
- Other crystal types (skill, key, gauntlet, trick) stay visible from the main path. Key cages: one key opens one `L` block, so make the block the player touches first the one that frees the crystal.

## Element rules

- **Press `P`:** a horizontal run of `P` = the press housing (solid 1 tile, width = run length, 2 is standard). The head strikes **down only**, `reach` tiles = the number of air tiles between the housing and the floor under it: set `P reach = n` (default 4; per press `P2 reach = 3`, numbered in reading order: top row first, then left to right). Cycle (period 2.0 s): 0.4 s red shake (safe) → slam + hold 0.45 s (deadly) → 0.6 s retract + idle (safe). So ~1.55 s safe per 2.0 s. Several presses in a room share the clock: `P2 offset = 0.6` makes a wave you can follow.
  - Never make the player stand or wait under a head. Each press column needs ≥3 safe tiles before and after it on the main path. Period ≥ 1.6. A 2-wide head takes ~0.3 s to run through.
  - Housings are solid: you can stand on top of them.
  - The checker treats `P` as a solid block and ignores the head: write the timing (period, offsets, safe tiles) in the room notes.
- **Belt `~`:** default speed 60 px/s to the right (`~ speed = -60` for left). The checker treats it as plain floor: never *require* the belt's speed, run belts along the travel direction, and keep spikes ≥6 tiles past a belt's end.
- **Vent `V`:** blasts 4 tiles up (idle 2.0 s, warn 0.5 s, blast 1.0 s), 1 HP + knockback, not death. `V2 offset = 1.0` staggers them.
- **Spring `S`:** launches ~5.6 tiles up and refills DJ (`S direction = Vector2(1, -1)` for an angled launch).
- **Turret `T`:** falls with gravity, so it must stand on a floor; needs line of sight; give the player cover (a solid block) on its approach; a perch wider than 1 tile right under it blinds it. **Drone `D`:** hovers, patrols ±50 px around its cell (`D patrol_distance = 24.0`), sees 120 px, charges straight, stuns on walls: give it a wall/boiler to crash into.

## Dialogue (place via props, text verbatim)

- **a01** `!` speaker_name `"Parní město"`, dialogue_pages `Array[String](["Horská stezka končí pod hradbami Parního města. Město šplhá po svahu hory patro nad patrem — továrny, komíny a nahoře, na samém vrcholu, citadela korporace.", "Brána je zavřená. Dovnitř vedou jen odpadní stoky a nákladní pásy, které svážejí fialové krystaly."])`
- **a07** `7` Vesper dialogue_pages `Array[String](["Pst! Sem, než tě chytí reflektor. Ty jsi ten kluk z odboje? Mira hlásila, že přijdeš.", "Jsem Vesper. Dřív jsem korporaci stavěla lisy, teď je rozebírám. Krystaly ze Smallville jedou po pásech do rafinerií a odtud nahoru do citadely.", "Na vrcholu hory je ústí velké šachty — vede až k jádru. Lez přes továrny a Horní město, Otis tě čeká ve starých dílnách u šachty. Já tě najdu dole u reaktoru."])`, repeat_dialogue_pages `Array[String](["Lisy bijí v rytmu. Počkej, až se zvednou, a pak běž."])`
- **b01** `!` speaker_name `"Hlas Korporace"`, dialogue_pages `Array[String](["Pracovníci! Týdenní kvóta byla navýšena o třicet procent. Korporace děkuje za vaši oddanost.", "Hlaste každou podezřelou osobu. Odboj je nemoc. Korporace je lék."])`
- **b04** `8` Hron dialogue_pages `Array[String](["Nový? Neboj, křičet nebudu. Dvanáct hodin u lisu a za to talíř polévky.", "Ty krystaly, co tu lisujeme, v noci svítí. A lidi z rafinerie kašlou fialově.", "Jestli jdeš proti nim, jdi přes rafinerii a výtahovou šachtou nahoru na střechy."])`, repeat_dialogue_pages `Array[String](["Já tě neviděl. Nikdo tě tu neviděl."])`
- **c01** `!` speaker_name `"Poplach"`, dialogue_pages `Array[String](["Sirény! Nad Náměstím Korporace se rozblikaly rudé majáky — někdo tě nahlásil.", "Nahoru k citadele vede jediná cesta: Hodinovou věží a po vnitřní hradbě."])`
- **c04** `!` speaker_name `"Vesper (vysílačka)"`, portrait_texture `"res://assets/npc/vesper_portrait.png"`, dialogue_pages `Array[String](["Vidím tě z rafinerie! Nad tebou je už jen citadela a ústí velké šachty.", "Otis čeká ve starých dílnách u šachty. A Matěji... v citadele tě korporace nebude jen hledat. Bude tě lovit."])`
- **d04** `!` speaker_name `"Deník vrtu"`, dialogue_pages `Array[String](["Vrt 7: hloubka 11 400 m. Gravitační anomálie v okolí jádra rostou o dvanáct procent denně.", "Rozkaz vedení: těžbu nezastavovat. Evakuaci Smallville urychlit."])`
- **d06** `!` speaker_name `"Vrchol hory"`, dialogue_pages `Array[String](["Pod tebou leží celá hora — rokle, Smallville, Parní město v páře. Před tebou zeje černé ústí šachty, která vede až k jádru planety.", "Odtud už vede cesta jen dolů."])`
- **d07** `E` next_level `"res://level1.tscn"`, stage_title `"KAPITOLA 3: PARNÍ MĚSTO"`, stage_index `3`, max_stage_crystals `12`
- **a01, b01, c01, d01**: `room checkpoint = true`

## Layout

Fixed positions (screens, top-left; y grows downward, so the climb goes to negative y). Don't move or resize rooms.

```layout
chapter res://levels/c3/chapter3.tscn
start_items wrench
c3_a01 0 0
c3_a02 1 -2
c3_a03 2 -2
c3_a04 3 -4
c3_a05 4 -4
c3_a06 5 -5
c3_a07 5 -6
c3_b01 6 -6
c3_b02 8 -7
c3_b03 8 -8
c3_b04 9 -8
c3_b05 9 -9
c3_b05b 10 -10
c3_b06 11 -10
c3_b07 11 -11
c3_c01 12 -11
c3_c02 13 -12
c3_c03 14 -14
c3_c04 14 -15
c3_c05 15 -15
c3_c06 15 -16
c3_d01 16 -16
c3_d02 18 -17
c3_d03 19 -19
c3_d04 20 -19
c3_d05 20 -21
c3_d06 21 -21
c3_d07 22 -21
```

## Rooms

Fixed section boundaries: **a07 → b01**, **b07 → c01** and **c06 → d01** all open at h1: row 0 solid across the edge, rows 1–4 open on both sides of the edge (rows 5+ may be wall). All other entries/exits are agreed inside a section. "floor hole" = you arrive by jumping up through the bottom row; "top" = you leave through the top row.

| id | size | from → to | challenge | elements | diff | crystal | CP |
|---|---|---|---|---|---|---|---|
| c3_a01 | 2×1 | start (L, h1) → a02 (top, right screen) | The mountain trail ends under the lowest city wall: banners, a searchlight pylon, a rubble ramp and scaffold up to a drain opening high in the wall. | scaffold, `!` | 1 | — | ✔ |
| c3_a02 | 1×2 | a01 (floor hole) → a03 (R, top screen) | Drainage culvert climbing up inside the wall: steam pipes vent upward (time the climb), a turret on the top ledge — approach behind a pipe block (cover). | vents, turret, climb | 2 | — | — |
| c3_a03 | 2×1 | a02 (L) → a04 (top, right screen) | Freight yard terrace: belts carry ore crates; climb crate stacks; a guard on a container roof; the gantry crane. | belts, guard, crates | 2 | **Skill detour**: crystal on top of the crane, a harder wall-jump line up its legs. | — |
| c3_a04 | 1×2 | a03 (floor hole) → a05 (R, top screen) | Pipe wall: wall jumps between giant vertical pipes, grates on brackets, vents out of pipe joints. | wall jumps, grates, vents | 3 | **Secret passage**: hidden pocket in the wall (`F` + `c`). | — |
| c3_a05 | 1×1 | a04 (L) → a06 (R) | **Press** intro in the gate's cargo tunnel: from the entry you watch a demo press slam a crate on a dead-end shelf; then one press over the path (period 2.4, 3+ safe tiles both sides); then two as a wave. | **presses**, belt | 2 | — | — |
| c3_a06 | 1×2 | a05 (L bottom) → a07 (top) | Slum stacks: scrap shacks clinging to the inner wall, stacked up; DIY spring lifts (`S`), grates, tarps. Left wall of the top screen closed. | springs, grates, climb | 2 | **Key/backtrack**: key on a shack roof off the path, caged crystal by the top exit. | — |
| c3_a07 | 1×1 | a06 (floor hole) → b01 (R, h1 fixed) | Breather: Vesper's hideout in a shack under the pipes, health pack. | Vesper `7`, `H` | 1 | — | — |
| c3_b01 | 2×1 | a07 (L, h1 fixed) → b02 (R) | Factory gate: loudspeaker pylon (`!` Hlas Korporace), banners, a belt line, a guard on the loading dock. | belt, guard, `!` | 2 | — | ✔ |
| c3_b02 | 1×2 | b01 (L bottom) → b03 (top) | Press stairs: a stair of belts and landings climbing up through a column of presses (each press over a belt, stop on the brass plates between them). | presses, belts | 3 | **Mechanic trick**: stand on a press housing (solid) to reach a crystal on a pipe ledge. | — |
| c3_b03 | 1×1 | b02 (floor hole) → b04 (R) | Boiler hall: a drone patrols between boilers, vents on the boiler tops; bait it into a boiler, stomp it or slip past. | drone, vents | 3 | — | — |
| c3_b04 | 1×1 | b03 (L) → b05 (top) | Breather: workers' canteen, Hron, health pack; beams up through a hatch. | Hron `8`, `H` | 1 | — | — |
| c3_b05 | 2×1 | b04 (floor hole, left screen) → b06 (R); branch up to b05b | Refinery: blight spills burst from the floor (`I`), belts with ore, one press over a belt, a turret on a catwalk; a ceiling hole in the right screen leads up to b05b. | crystal spikes, belt, press, turret | 3 | — | — |
| c3_b05b | 1×1 | b05 (floor hole) ↔ b05 | Side gauntlet, the stamping room: presses over grates, wall jumps, crystal at the end; drop back down the hole. Left, right and top walls closed. | presses, grates, wall jumps | 4 | **Side gauntlet** | — |
| c3_b06 | 1×2 | b05 (L bottom) → b07 (top) | Freight lift shaft: springs (pneumatic lifts), grates, vents. Left wall of the top screen closed (b05b is there). | springs, grates, vents | 3 | **Secret passage**: hidden maintenance niche (`F` + `c`). | — |
| c3_b07 | 1×1 | b06 (floor hole) → c01 (R, h1 fixed) | Refinery roof: belts on the roof, a guard, grates; step down to the street. | belts, guard, grates | 2 | — | — |
| c3_c01 | 2×1 | b07 (L, h1 fixed) → c02 (top, right screen) | Corporate Plaza under alarm (`!`): the CEO statue, plaza steps with 2 guards, a drone over the fountain; climb the grand stair to a balcony hole. | guards ×2, drone, `!` | 2 | — | ✔ |
| c3_c02 | 1×1 | c01 (floor hole) → c03 (R) | Barricade street: a turret standing on a crate behind the barricade, burst pipes venting, crates as cover. | turret, vents | 3 | — | — |
| c3_c03 | 1×3 | c02 (L bottom) → c04 (top) | Clock Tower: climb the inside; the clock's hammer presses strike the beams you climb (time each step), brass gear platforms, grates; a rest floor every screen. Left walls of the two upper screens closed. | presses, grates, wall jumps | 3 | **Skill detour**: crystal off the climb near the clock face. | — |
| c3_c04 | 1×1 | c03 (floor hole) → c05 (R) | Breather on the tower gallery: Vesper on the radio (`!`), health pack, the citadel above. | `!`, `H` | 1 | — | — |
| c3_c05 | 1×1 | c04 (L) → c06 (top) | Cable gantry over the abyss: belts on narrow gantries, crumbling grates, pits into the void (nothing below). | belts, grates, pits | 3 | **Key/backtrack** | — |
| c3_c06 | 1×1 | c05 (floor hole) → d01 (R, h1 fixed) | Top of the inner wall: a guard on the wall walk, a searchlight pylon; short. | guard | 2 | — | — |
| c3_d01 | 2×1 | c06 (L, h1 fixed) → d02 (R) | Citadel gate under sirens: blast-door presses in the gateway, a turret. | presses, turret | 3 | — | ✔ |
| c3_d02 | 2×2 | d01 (L, bottom-left screen) → d03 (top, top-right screen) | Security court: climb a two-screen courtyard of pillars and balconies; two drones, a guard, cover pillars to bait the drones into. | drones ×2, guard | 3 | **Secret passage**: hidden pocket behind a balcony wall (`F` + `c`). | — |
| c3_d03 | 1×2 | d02 (floor hole) → d04 (R, top screen) | Press shaft: climb a narrow shaft past presses that slam over every ledge; faster rhythm (period 1.6–1.8), wave offsets. | presses, wall jumps | 3 | **Skill detour** | — |
| c3_d04 | 1×1 | d03 (L) → d05 (top) | Breather: an abandoned control room, the drill log terminal (`!` Deník vrtu), health pack. | `!`, `H` | 1 | — | — |
| c3_d05 | 1×2 | d04 (floor hole) → d06 (R, top screen) | Steam elevator: springs and vents up the citadel tower, a turret on a balcony. | springs, vents, turret | 3 | **Mechanic trick**: an angled spring or a press housing launches you to a high crystal (must also be reachable by the checker). | — |
| c3_d06 | 1×1 | d05 (L) → d07 (R) | Summit terrace: the whole mountain below (`!` Vrchol hory); short and safe; open air under a solid top row. | `!` | 1 | — | — |
| c3_d07 | 2×1 | d06 (L) → E (R) | The old workshops above the great shaft: last presses and belts, a guard; `E` at the shaft mouth on the right. | presses, belts, guard | 3 | **Key/backtrack** | — |

Crystal route order: skill (a03) → secret (a04) → key (a06) → trick (b02) → gauntlet (b05b) → secret (b06) → skill (c03) → key (c05) → secret (d02) → skill (d03) → trick (d05) → key (d07).
Enemies: guards a03, b01, b07, c01 ×2, c06, d02, d07 = 8; turrets a02, b05, c02, d01, d05 = 5; drones b03, c01, d02 ×2 = 4 → 17.
Travel: ↑ and → only; the chapter climbs 21 screens to the summit.

## Sketches

### c3_a01 — city wall verge
```
   0123456789012345678901234567890123456789
10 &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&...&&
 9 #...........................qqqbqqqqqqq&
 8 #...........................qqoqqoqqqoq&
 7 #...........................qqlqgqqqqql&
 6 #...........................&&&&&&&&&&&&
 5 #....................WWWW...&&&&&&&&&&&&
 4 #..............WWW....W.....&&&&&&&&&&&&
 3 #..............W......W.....&&&&&&&&&&&&
 2 #.........ZZZ..W..WW..W.....&&&&&&&&&&&&
 1 #l@.g.!ZZZZZZ.pW..WWx.W...xl&&&&&&&&&&&&
 0 #________________%%%%_______&&&&&&&&&&&&
```
```props
room checkpoint = true
! speaker_name = "Parní město"
! dialogue_pages = Array[String](["Horská stezka končí pod hradbami Parního města. Město šplhá po svahu hory patro nad patrem — továrny, komíny a nahoře, na samém vrcholu, citadela korporace.", "Brána je zavřená. Dovnitř vedou jen odpadní stoky a nákladní pásy, které svážejí fialové krystaly."])
```
- Start ledge cols 1-5 h1 (`@` col 2). Rubble ramp h2 (cols 7-9) and h3 (cols 10-12), scaffold h5 (cols 15-17) and h6 (cols 21-24), wall-walk ledge h7 (cols 28-38): every rise is 1-2, every gap 2-3, a fall only drops to the ground.
- Exit: top-row hole cols 35-37 above the h7 ledge (a02 floor hole cols 15-17), flanked by lamps; corp banners and pylon on the verge, blight patches in the ground.

### c3_a02 — drainage culvert
```
   01234567890123456789
21 &&&&&&&&&&&&&&&&&&&&
20 &qqqqqqqqqqqqqqqqqq&
19 &qqqqqqqbqqqqqqqqqq&
18 &qqqqqqqqqqqoqqqqqq&
17 &qqqqqqqqqqqqqqqqqq&
16 &qqqqoqqqqqqqqqqqqq&
15 &qqqqqqqqqbqqqqqqqq.
14 &qqqoqqqqqqqqqqqqqq.
13 &qqqqqqqqqqqqBBoqqq.
12 &qqqqqbqqqqlqBBqqTq.
11 &qqqqqqqqqqBBBBBBBB&
10 &qqqqoqqqqqqqqqqqqq&
 9 &qlqqqqqqVqqqqoqqqq&
 8 &BBBBBBBqBqqqqqqqqq&
 7 &qqqqqqqqqqqqqqoqqq&
 6 &qqqoqqqqVqqqqqqqlq&
 5 &qqqqqqqqBqBBBBBBBB&
 4 &qqqoqqqqqqqqqqqqqq&
 3 &qlqqqqqqVqqqqqqqqq&
 2 &BBBBBBBqBqqqqqqqqq&
 1 &qlxqqgqqqq@qqqqqqq&
 0 BBBBBBBBBBBBBBB...BB
```
```props
V idle_time = 2.0
V2 offset = 1.0
V3 offset = 2.0
```
- Entry: floor hole cols 15-17 (a01 cols 35-37), ledge cols 3-14 h1 (`@` col 11). Slabs h3 (cols 1-7), h6 (cols 11-18), h9 (cols 1-7), h12 (cols 11-18): rises 2/3/3/3 across 3-wide gaps (cols 8-10) that each hold a pipe stub with a vent (idle 2.0 / warn 0.5 / blast 1.0 s, offsets 0 / 1.0 / 2.0): jump in the quiet window; a hit is 1 HP + knockback, never death.
- Top slab h12: 2-high pipe block (cols 13-14) is the cover from the turret (col 17); hop it, then jump or stomp the turret to the exit R at h12-h15 (a03 h1-h4). A fall always lands on a lower slab or the entry floor.

### c3_a03 — freight yard
```
   0123456789012345678901234567890123456789
10 &&&&&&&&&&&&&&&&&&&&&&&&&&&&&...&&&&&&&B
 9 &qqqqqqqqqqqqqqqqqqqqqqqqqq............B
 8 &qqqqoqqqqqqqqqqqqqqqoqqqqq............B
 7 &qbqqqqqqqqqqqoqqqqqqqqqqqq...........CB
 6 &qqqqqqqqoqqqqqqqqqqqqqoqqq..l..g....BBB
 5 &qqqqqqqqqqqqqqqqbqqqqqqqqq.&&&&&....BBB
 4 .qqqqqqqqqqqoqqqqqqqqGqqqqq.&&&&&....BBB
 3 .qqqoqqqqqqqqqqqqZZZoZZZZZq.&&&&&....BBB
 2 .qqqqqqqqqqqqWWqqZZZZZZZZZq.&&&&&....BBB
 1 .l@gqqqqqWqqqWWlqZZZZZZZZZx.&&&&&xl.gBBB
 0 &ZZZZ~~~~~~~ZZZZZZZZZZZZZZ%%&&&&&ZZZZBBB
```
- Entry ledge cols 1-4 h1, belt cols 5-11 (along the travel direction; a crate at col 9 to hop), crate stack h3 (cols 13-14), container roof h4 (cols 17-25) with the guard (hop or stomp), gap 2, terrace h6 (cols 28-32) under the top hole cols 29-31 (a04 floor hole cols 9-11). Falls land on the yard floor.
- Skill crystal: crane tower (cols 37-39, top h7, crystal col 38) is visible from the whole yard; reach it with a running jump from the terrace edge (4-tile gap, +1) or climb the tower face from the yard floor.

### c3_a04 — pipe wall
```
   01234567890123456789
21 &&&&&&&&&&&&&&&&&&&&
20 &qqqqqqqqqqqqqqqqqq&
19 &qqbqqqqqqqqoqqqqqq&
18 &qqqqqqqoqqqqqqqqqq&
17 &qqqqqqqqqqqqVqqqoq&
16 &qqqoqqqqqqqBBBqqqq&
15 &qqqqqqqqqoqBBBqqqq.
14 &qqqVqqqqqqqBBBqqqq.
13 &&&BBBBBBqqqBBBqqqq.
12 &&&BFFFFFqqqBBBlqVq.
11 &&&BFcFFFqqqBBBBBBB&
10 &&&BBBBBBqqBBBBBBBB&
 9 &&&BBBBBBqqqBBBBBBB&
 8 &&&BBBBBBqqqBBBBBBB&
 7 &&&BBBBBBq==BBBBBBB&
 6 &&&BBBBBBqqqBBBBBBB&
 5 &&&BBBBBBqqqBBBBBBB&
 4 &qqqqqqqqqqqqqqqqqq&
 3 &qqqqqqqqqqqqqqoqqq&
 2 &qqoqqqqqqqqqqqqqqq&
 1 &qgqq@qlqqqqqqxqlqq&
 0 BBBBBBBBB...BBBBBBBB
```
```props
V idle_time = 1.6
V2 offset = 0.8
V3 offset = 1.6
```
- Entry: floor hole cols 9-11 (a03 cols 29-31), ledges cols 1-8 and 12-18 h1 (`@` col 5), pipes hang 4 above them. Chimney cols 9-11 between two giant pipes (wall jumps / climbing, grate bracket h8 cols 10-11), rest on the left pipe top h14 (cols 3-8, vent col 4), then climb the tall right pipe face to its top h17 (cols 12-14, vent col 13) and step off onto the exit ledge h12 (cols 15-18, vent col 17) to exit R (rows 12-15). Vents idle 1.6 s, offsets 0 / 0.8 / 1.6.
- Secret: the brass stub on the right face (col 11, standing h11) points into the left pipe; the whole pocket (cols 4-8, h11-h12, crystal col 5) is `F`, solid pipe cols 1-3 between it and the room edge.

### c3_a05 — cargo tunnel presses
```
   01234567890123456789
10 &&&&&&&&&&&&&&&&&&&&
 9 &qqqqqqqqqqPP&&&&&&&
 8 &qqqqqoqqqqqq&&&&&&&
 7 &qoqoqqqqbqqq&&&&&&&
 6 &qqqqqqqqqqqW&&&&&&&
 5 &qqqqB~~~~~~~&&&&&&&
 4 .qqqqPPqqqPPqqqPPqq.
 3 .qqoqqqqoqqqqoqqqqq.
 2 .qqqqqqqqqqqqqqqqqq.
 1 .l@gqqqqlqqqqqqqqlq.
 0 &BBBBBBBBBBB~~~BBBBB
```
```props
P reach = 3
P1 reach = 2
P period = 2.4
P3 offset = 0.6
P4 offset = 1.2
```
- Entry hall cols 1-4 h1 (`@` col 2). P1 = demo press on the dead-end shelf (h6, belt cols 6-12 into the wall at col 13; housing cols 11-12 at h9, reach 3) slams the crate; it is in view from the entry and off the walking line. Shelf reached by a 5-high jump, never needed.
- Walking tunnel 4 tall (3 under heads): P2 cols 5-6 alone (period 2.4: 0.4 s shake, 0.45 s slam, rest safe; 3 safe tiles before cols 2-4, 3 after cols 7-9), then the wave P3 cols 10-11 (offset 0.6) and P4 cols 15-16 (offset 1.2) with 3 safe tiles between (cols 12-14, floor belt there) and 3 after (cols 17-19). All reach 3.

### c3_a06 — slum stacks
```
   01234567890123456789
21 &&&&&&&&&&&&&&...&&&
20 Zzzzzzzzzzzzzzzzzzz&
19 ZzzzztzzzzzzzzzzzWW&
18 ZzzzzzzzzzzzzzzzzLz&
17 ZzzzzzzzzzzzzzlzzLC&
16 ZzzzzzzzzzzzzRRRRRR&
15 ZzzzzzztzzzzzWWWWWW&
14 ZzzzzzzzzzzzzWWoWWW&
13 Zzzztzzzzz==zWWWWoW&
12 ZzzzzzzzzzzzzWWWWWW&
11 ZzzSzzlzzzzzzzzzzzz&
10 ZRRRRRRRzzzzzzzzzzz&
 9 ZWWWWWWWzzzzzzzzzzz&
 8 ZWWWoWWWzzzzzzzzzzz&
 7 ZWWWWWWbzzzztzzzzzz&
 6 ZWWWWWWWzzzzSzlzzzz&
 5 ZzzzzzzzzzRRRRRRzzz&
 4 .zzzztzzzzWoWWWWzKz&
 3 .zztzzzzzzWWWWWWRRR&
 2 .zzzzzzzzzWWWbWWWWW&
 1 .lz@zgzzSzWWWWWWWWW&
 0 ZZZZZZZZZZZZZZZZZZZ&
```
- Entry L at h1 (rows 1-4), ledge cols 1-7 (`@` col 3). Spring 1 (col 8) lifts onto shack roof h6 (cols 10-15); spring 2 (col 12) onto the left shack roof h11 (cols 1-7); then spring 3 (col 3) or the grate step h14 (cols 10-11) up to the top shack roof h17 (cols 13-18) under the exit hole cols 14-16 (a07 floor hole cols 14-16). Left wall of the top screen closed.
- Key/backtrack: key `K` on the low side-shack roof (h4, cols 16-18, a 2-drop from the first roof); the caged crystal sits at col 18 on the top roof behind key block `L` (col 17) under a plank slab, next to the exit hole.

### c3_a07 — Vesper's hideout
```
   01234567890123456789
10 &&&&&&&&&&&&&&&&&&&&
 9 &BBBBBBBBBBBBBBBBBB&
 8 &qqqqqqqqqqqqqqqqqq&
 7 &qoqqqoqqoqqqqqoqqq&
 6 &qqqqqqqqqqqqqqqqqq&
 5 &qqZZZZZZZZZZqqqqqq&
 4 &qqWqqqqqqqqqqqqqqq.
 3 &qqWqqoqqqbqqqqqqqq.
 2 &qqWqqqqqqqqqqqqqqq.
 1 &qxWqqfq7qHqqlqqqg@.
 0 &ZZZZZZZZZZZZZ...ZZZ
```
```props
7 dialogue_pages = Array[String](["Pst! Sem, než tě chytí reflektor. Ty jsi ten kluk z odboje? Mira hlásila, že přijdeš.", "Jsem Vesper. Dřív jsem korporaci stavěla lisy, teď je rozebírám. Krystaly ze Smallville jedou po pásech do rafinerií a odtud nahoru do citadely.", "Na vrcholu hory je ústí velké šachty — vede až k jádru. Lez přes továrny a Horní město, Otis tě čeká ve starých dílnách u šachty. Já tě najdu dole u reaktoru."])
7 repeat_dialogue_pages = Array[String](["Lisy bijí v rytmu. Počkej, až se zvednou, a pak běž."])
```
- Entry: floor hole cols 14-16 (a06 cols 14-16), ledge cols 17-19 h1 (`@` col 18) and floor cols 1-13. Vesper (col 8) in the tarp shack (roof h6, cols 3-12), health pack col 10, resistance banner col 6, blight col 2, corp banner col 17, lit windows, pipes under the ceiling. No hazards.
- Exit R at h1: row 0 solid across the edge, rows 1-4 open at col 19 (b01 fixed boundary); top row solid.

### c3_b01 — factory gate
```
   0123456789012345678901234567890123456789
10 &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
 9 &qqqqqqqqqqqqqqqqqBBBBBBBBBBBBBBqqqqqqq&
 8 &qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq&
 7 &qqoqqqoqqqoqqqqoqqqqqoqqqoqqqoqqqoqqqq&
 6 &qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq&
 5 &qqqqqqqqoqqqqqqqqqqqqqqoqqqqqqqoqqqqqq&
 4 .qqqqqqqqqqqqqqqqqqqqqlqqGqqgqqqqqqqqqq.
 3 .qqqqqqqqqqqqqqqqqqqBBBBBBBBBBqqqqqqqqq.
 2 .qqqqqqqqqqqqqqqqqWWZZZZZZZZZZqqqqqqqqq.
 1 .g@q!pqqqqqqqlqxqqWWZZZZZZZZZZqqgqqqlql.
 0 &BBBBBB~~~~~~~BBBBBBBBBBBBBBBBBBBBBBBBB&
```
```props
room checkpoint = true
! speaker_name = "Hlas Korporace"
! dialogue_pages = Array[String](["Pracovníci! Týdenní kvóta byla navýšena o třicet procent. Korporace děkuje za vaši oddanost.", "Hlaste každou podezřelou osobu. Odboj je nemoc. Korporace je lék."])
```
- Entry h1 (col 0, rows 1-4 open, row 0 solid), safe plate cols 0-6 with `@`, the loudspeaker pylon and a corp banner; exit h1 at col 39 (rows 1-4 open) into the bottom screen of b02. Belt cols 7-13 (optional, runs right).
- Loading dock: crate stairs h2 -> h3, steel deck h4 (cols 20-29, 10 wide) with a guard patrolling it (hop or stomp), then a 3-tile drop to the street plate cols 30-39.

### c3_b02 — press stairs
```
   01234567890123456789
21 &&&&&&&&&&&&&....&&&
20 &qqqqqqqPPqqqqqqqqq&
19 &qqqqqqqqqqoqqqqqqq&
18 &qqoqqqqqqqqqqqqoqq&
17 &qqqqqqqqqqqqWWWWqq&
16 &qqqqlqqqqqqqWWWWql&
15 &qqqqB~~~~~~BBBBBBB&
14 &qqqqqqqqqqqqqqCBq<&
13 &qqqqqqqqqqqqqqqBq<&
12 &WWWWqqqqqqqqqqqqq<&
11 &WWWWqqqqqqqqqqqqq<&
10 &WWWWqqqqqPPqqqqoq<&
 9 &WWWWqqqqqqqqqqqqq<&
 8 &WWWWWWqqqqqqqqqqq<&
 7 &WWWWWWqlqqqqqlqqq<&
 6 &BBBBBBBB~~~~~Bqqqq&
 5 &qqqqqqPPqqqqqqqqpq&
 4 .qqqqqqqqqqqqqqqWWW&
 3 .qoqqqqqqqoqqqqqWWW&
 2 .qqqqqqqqqqqqWWqWWW&
 1 .@qgqqqqqqqqlWWqWWW&
 0 &BBBB~~~~~~BBBBBBBB&
```
```props
P1 offset = 1.2
P2 reach = 3
P2 offset = 0.6
~2 speed = -60
```
- Press stairs, three switchbacks (right, left, right), each 7-8 tiles above the last: tier 1 floor h1, tier 2 floor h7, tier 3 floor h16. Every tier = brass plate, belt under ONE press (housing 2 wide), brass plate, then a crate stack under the next ceiling gap that you jump up through (gap cols 15-18, cols 1-4, exit hole cols 13-16). Belts run with you (right / left / right).
- Timing (period 2.0 s: 0.4 s red shake, slam + hold to 0.85 s, then retract; safe 0.85-2.0 s): P3 housing cols 7-8 (reach 4), P2 cols 10-11 (reach 3, offset 0.6), P1 cols 8-9 (reach 4, offset 1.2). Each head has >=3 free tiles before and after (belt tiles count, the head only covers its 2 columns): stop on the plate, watch the head fall, run on retract. You never have to stand under a head.
- Trick crystal (col 15, h14, hanging beside a pipe over the shaft): too high from the floor (h7 + DJ) and too far from the steps, spikes on the shaft wall (col 18) stop wall-climbing, so run to the belt, jump onto the press housing (cols 10-11, top h11, solid, 4 free tiles above it) and leap from it across the shaft. Standing on the housing is safe.

### c3_b03 — boiler hall
```
   01234567890123456789
10 &&&&&&&&&&&&&&&&&&&&
 9 &qqqqqqqqqqqqqqoqqq.
 8 &qqqoqqqoqqDqoqqqqq.
 7 BBBqqqqqVqqqqqqqqqV.
 6 BBBqqqBBBBBBBqqqqBBB
 5 BBBqqqqqqqqqqqqqqBBB
 4 BBBqqoqqqqoqqqqoqBBB
 3 BBBlqqqqqqqqqqqqqBBB
 2 BBBWWWqqqqqqqqqqqBBB
 1 BBBWWWxlq@qglqqqqBBB
 0 BBBBBBBBBBBBB....BBB
```
```props
V2 offset = 1.0
D patrol_distance = 24.0
```
- Arrive through the floor hole (cols 13-16) onto the ledge cols 6-12 (`@`). Climb: crate stack (cols 3-5, h3), jump up through the gap in the catwalk (cols 3-5), cross the catwalk (cols 6-12, h7), running jump over the hole (4 tiles) onto boiler 2 (cols 17-19, top h7) and out through the right wall (rows 7-9, h7). A miss drops you back into b02.
- Drone hovers above the catwalk (col 11, sees 7.5 tiles): when it locks onto you on the crates or the gap it charges into boiler 1 / the catwalk (stun, stomp it) - or slip across the catwalk while it recovers. Vents on the catwalk (col 8) and boiler 2 (col 18): 1 HP, not death; second one offset 1.0 s.

### c3_b04 — workers' canteen
```
   01234567890123456789
10 &&&&&&&&&&&&&&&....&
 9 .qqqqqqqqqqqqqqqqoq&
 8 .qqqqqqqqqqqqqqqqqq&
 7 .g@lqqoqqoqqoqqWWWW&
 6 BBBBBqqqqqqqqqqqqqq&
 5 &&&&&qqqqqqoqqlqqqq&
 4 &&&&&qqoqqqqqWWqqoq&
 3 &&&&&qoqqqqqqqqqqqq&
 2 &&&&&HqqqqqWWqqqqqq&
 1 &&&&&WWlq8qqgqqqqxq&
 0 &&&&&BBBBBBBBBBBBBB&
```
```props
8 dialogue_pages = Array[String](["Nový? Neboj, křičet nebudu. Dvanáct hodin u lisu a za to talíř polévky.", "Ty krystaly, co tu lisujeme, v noci svítí. A lidi z rafinerie kašlou fialově.", "Jestli jdeš proti nim, jdi přes rafinerii a výtahovou šachtou nahoru na střechy."])
8 repeat_dialogue_pages = Array[String](["Já tě neviděl. Nikdo tě tu neviděl."])
```
- Breather, no hazards. Enter left at h7 (rows 7-9 open) on the brass mezzanine cols 0-4 (`@`), drop to the canteen floor, Hron at col 9, health pack on the table. Then up the plank beams (h3, h5, h8) to the hatch in the ceiling (cols 15-18).
- A corp banner and a blight crack in the corner show the corp and the damage.

### c3_b05 — refinery
```
   0123456789012345678901234567890123456789
10 &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&....&&
 9 &BBBBBBBBBBBBqqqqqqqqqqqqqqqqqqoqqqqoqq&
 8 &qqqqqqqqqqqqqqqqqqqqqqqqoqqqqqqqqqllqq&
 7 &qqqoqqqqqgqqqqqqoqqqqqqgqqqqBBBBBBBBBq&
 6 &qqoqqqqoqqqqoqqqqqqqqqoqqqqqqqqqBBqqTq&
 5 &qqqqqqqqqqqqqqqqqqqqqoqqqqqqqqqqPPqqBB&
 4 &qqqqqqqqqqqqqqqqqqqqqqqqqqBBqqqqqqqqqq.
 3 &qqqoqqqqoqqqqqqqqqqqWWqqqqqqqqqqqqqqqq.
 2 &qqqqqqqqqqqqqqqqqqqqWWqqqqqqZqqqqqqqqq.
 1 &qgqqpqlqqq@qlqqqqqqlWWxIIIxqZqlqqqqqqq.
 0 &BBBBBBBBBBBBBB....BBBBBBBBBBB~~~~~~~~B&
```
```props
P reach = 4
```
- Arrive through the floor hole (cols 15-18) onto the ledge cols 5-14 (`@`), cross it (4 tiles), plate cols 19-20, then the crate stack (cols 21-22, h4) - cover from the turret - and the blight spills (`I`, cols 24-26) in their 2 s cycle; belt cols 30-37 (runs right) with ONE press (housing cols 33-34, reach 4, period 2.0, slam 0.4-0.85 s): 3 free tiles before (30-32), 3 after (35-37). Exit h1 at col 39. Cover stub col 29 (h3) hides you from the turret on the shelf (cols 37-38, h6, turret at the left end of the perch so it sees the floor); the pipe above the press blocks its line to the catwalk.
- Branch (optional): crate stack h4 -> bracket h5 (cols 27-28) -> catwalk h8 (cols 29-37, lamps frame the hole), then jump + DJ through the ceiling hole (cols 34-37) up to b05b.

### c3_b05b — stamping floor
```
   01234567890123456789
10 &&&&&&&&&&&&&&&&&&&&
 9 &qqqPPqqqPPqqqqqoqq&
 8 &qqqqqqqqqqqqqqqqqq&
 7 &Cqqqqqqoqqqqqoqqoq&
 6 &BBqqqqqqqqqqqqqqqq&
 5 &BB=========qqqgqqq&
 4 &BB<qqqqqqqqqqqqqqq&
 3 &BB<qqqqqqqqlqqoqqq&
 2 &BB<qqoqqqoqWWqqqqq&
 1 &BB<qqqlq@qqWWqqqlq&
 0 &BBBBBBBBBBBBB....B&
```
```props
P reach = 3
```
- Side gauntlet (4/5), walls closed. You pop up out of the b05 hole (cols 14-17) next to the ledge cols 4-13 (`@`, floor tunnel under the bridge). Crate step (cols 12-13, h3) -> grate bridge (cols 3-11, h6, 2-tile grates fall 0.5 s after landing, so keep running) under TWO presses (housings cols 9-10 and 4-5, reach 3, period 2.0, same offset). Free tiles: crate + col 11 before P2, cols 6-8 between, cols 1-3 after.
- You run left, so P2 comes first: cross it in its safe window (>= 0.85 s into its cycle) and you reach P1 ~0.6 s later, still inside its safe 0.85-2.0 s. Crystal on the pillar (cols 1-2, h7); spikes on its face under the bridge stop you from wall-climbing it from the floor. Return: jump off the pillar, walk right along the floor and drop into the hole.

### c3_b06 — freight lift shaft
```
   01234567890123456789
21 &&&&&&&....&&&&&&&&&
20 &qqqoqqqqqqqoqqqqqq&
19 &qqqqqqqqqqqqqqqqqq&
18 &qqqoqqqqqqqoqqqoqq&
17 &qqqqqqqqqqqqqqqqqq&
16 &qqqqqqqqSqgqVqqgqq&
15 &qqqqqqBBBBBBBBqqqq&
14 &qqqqqqqqqqqqqqqq&&&
13 &qqoqqqqqqqqqqoqq&&&
12 &qqqqqqqqqqqqqqoq&&&
11 &qqSqqqqqqlqqlqqq&&&
10 &======qqqqqqqqqqFF&
 9 &qqqqqqqqqqoqqqlqFc&
 8 &qqoqqqqqqqqqBBBB&&&
 7 &qqqqqoqqqqqqqqqq&&&
 6 &qqqqqqqlSqVqqqqq&&&
 5 &qqqqqqqBBBBBBBqqqq&
 4 .qqqqqqqqqqqqqqqqqq&
 3 .qqoqqqqqqoqqqqoqqq&
 2 .qqqqqqqqqqqqqqqqqq&
 1 .@qlqSqgqqqqlqqqxqq&
 0 &BBBBBBBBBBBBBBBBBB&
```
```props
V2 offset = 1.0
```
- Enter left h1 (rows 1-4 open), `@` on the entry ledge. Pneumatic lifts: spring 1 (col 5) -> platform A (h6, cols 8-14, vent col 11) -> spring 2 (col 9) -> grate ledge (h11, cols 1-6) -> spring 3 (col 3) -> platform C (h16, cols 7-14, vent col 13) -> spring 4 (col 9) straight up through the exit hole (cols 7-10), DJ off the spring to land on b07. Rest ledge on each platform; a miss drops you to the one below.
- Secret (2x2 `F` pocket, crystal `c` at col 18 row 9): in the thick right wall past the dead-end shelf (cols 13-16, h9, a lone lamp) - jump from platform A to the shelf and walk into the wall; col 19 stays solid next to the edge. Nothing else marks it.

### c3_b07 — refinery roof
```
   01234567890123456789
10 &&&&&&&&&&&&&&&&&&&&
 9 &..................&
 8 &qqqqqqqqqq........&
 7 &qqqqqqqqqq........&
 6 &qqoqqoqqoq........&
 5 &qqqqqqqqqq........&
 4 &qqqqqqqqqq..l..G...
 3 &qqoqqqqqoq..RR~~~=.
 2 &qqqqqqqqqq..WW.....
 1 &xqqpqgqaqql@WW.....
 0 &BBBBBB....BBBBBBBB&
```
- Arrive through the floor hole (cols 7-10) onto the ledge cols 11-13 (`@`) or the left ledge cols 1-6. Hop the crates (cols 13-14, h3) onto the roof deck (h4): belt cols 15-17 (runs right) with a guard patrolling it, then a rotten grate (col 18) and a 3-tile drop to the street at the right wall (exit h1, rows 1-4 open, row 0 solid).
- Open smog sky above the roof, refinery facade behind, a corp pylon and a blight crack on the left ledge.

### c3_c01 — Plaza under alarm
```
   0123456789012345678901234567890123456789
10 #######################.....############
 9 #............qqqqqqqqqqqqqqqqqqqqq###qq#
 8 #qoqqqqqoqqqoqqqoqqqqqgqqqoqGqlqqq###qo#
 7 #qqqqqqqqqqqqqqqqqqqqq#########gpq###ql#
 6 #qoqqqqoqqqoqqqqqqq#####################
 5 #qqqqqqqqqqqqqqqqqq#####################
 4 .qqqqqBBBqqqDqqq########################
 3 .qqoqqBBBqqqqqGq########################
 2 .qqqqBBBBBqqq###########################
 1 .@q!gBBBBBlpq###########################
 0 ########################################
```
```props
room checkpoint = true
! speaker_name = "Poplach"
! dialogue_pages = Array[String](["Sirény! Nad Náměstím Korporace se rozblikaly rudé majáky — někdo tě nahlásil.", "Nahoru k citadele vede jediná cesta: Hodinovou věží a po vnitřní hradbě."])
D patrol_distance = 24.0
```
- Entry h1 (cols 0-4, `@` col 1, rows 1-4 open at col 0, row 0 solid). Fountain tiers h2/h4 (cols 5-9), the drone hovers behind it (col 12, out of sight of the entry ledge): step onto the fountain, it locks and charges into the stone, stunned 1 s - stomp it or slip by. Grand stair: landings h2 (cols 13-15, guard), h4 (16-18), h6 (19-21), balcony h7 (22-30, guard); every rise is 2 or less, stomp-bounce the guards.
- Exit: hole in the top row (cols 23-27) above the balcony - jump up through it (c3_c02 floor hole cols 3-7). Right of the balcony the CEO statue on its pedestal (cols 31-38) fills the corner; the whole facade is lit windows, banners and a searchlight pylon.

### c3_c02 — Barricade street
```
   01234567890123456789
10 ####################
 9 #qqqqqqqqqqqqqqqqqq#
 8 #qqqoqqqqqoqqqqoqqq#
 7 #qqqqqqqqqqqqqqqqqq#
 6 #qoqqqoqqbqqoqqqoqq#
 5 #qqqqqqqqqqqqqqqqqq#
 4 #qqqqqqqqqqqqqqqqqq.
 3 #qqoqqqqqoqqbqqWWqq.
 2 #qqqqqqqqqqWWqqWWqT.
 1 #gqqqqqql@qWWqVWWqW.
 0 &&&.....&&&&&&&&&&&&
```
```props
V idle_time = 2.0
T detection_range = 160.0
```
- Arrive through the floor hole (cols 3-7); safe ledge cols 8-10 with `@` col 9 and a lamp. Cover 1 (cols 11-12, h2) hides you from the turret; the gap cols 13-14 has a burst pipe (`V` col 14: idle 2.0 / warn 0.5 / blast 1.0, 1 HP, not death); cover 2 (cols 15-16, h3) shields the last stretch.
- Turret on a 1-wide crate at col 18 (floor, line of sight along the street, range 10 tiles so the ledge is out of reach). Exit right at h1 (rows 1-4 open): hop the crate stack past the turret or stomp it (c3_c03 bottom screen, same height).

### c3_c03 — Clock Tower
```
   01234567890123456789
32 #######.....########
31 #qqqqqqqooooqqqqqqq#
30 #qqqqqooqkkqooqqqqq#
29 #qqqqoqqBBBBBqo^^qC#
28 #qqqqoqqkkkkqqoBBBB#
27 #qqBBBBoqkkqooqqqqq#
26 #qlqqqqqoooolqqqqqq#
25 #&&&&&&&&&&&&&qqqqq#
24 #&&&&&&&&&PP&&qqqqq#
23 #qqqqqqqqqqqoqqqqqq#
22 #qqoqqqqqqqqqqqBBBq#
21 #qqqqqqqlqqqqgqBBBq#
20 #qqqqq&&&&&&&&&&&&&#
19 #qqqqq&&&PP&&&&&&&&#
18 #qqqoqqqqqqqqqqqqqq#
17 #====qqqqqqqqoqqqqq#
16 #qqqqqqqqqqqlqqqgqq#
15 #&&&&&&&&&&&&&qqqqq#
14 #&&&&&&&&&PP&&qqqqq#
13 #qqoqlqqqqqqqqqqqqq#
12 #qqqqqqqqqqqoqqBBBq#
11 #qqqqqqgqqqqqqqBBBq#
10 #qqqqq&&&&&&&&&&&&&#
 9 #qqqqq&&&PP&&&&&&&&#
 8 #qqqqqqqqqqqqqqoqqq#
 7 #qBBBqqqqqqqqqqqqqq#
 6 #qBBBqqqqqqqlqqqgqq#
 5 #&&&&&&&&&&&&&qqqqq#
 4 .&&&&&&PP&&&&&qqqqq#
 3 .qqqqqqqqqqqqqqqqqq#
 2 .qqqoqqqqqoqqqqBBBq#
 1 .q@qlqqqqqgqlqqBBBq#
 0 &&&&&&&&&&&&&&&&&&&&
```
```props
P reach = 3
P period = 2.0
P1 period = 1.8
P2 period = 1.8
P2 offset = 0.9
P3 offset = 1.0
P4 offset = 0.5
```
- Entry h1 (rows 1-4 open at col 0, `@` col 2). Climb = five stacked floors of the tower, each a 3-tall corridor under a slab with a hammer: floor 0 -> hole + gear step (cols 14-18) -> floor 5 -> hole + step (cols 1-5) -> floor 10 -> ... -> clock chamber (floor 25). Every floor is a rest floor; a fall lands on the floor below. Left walls of both upper screens and the whole right wall are closed.
- Hammers (`P`, solid housing in the slab, head fills the 3 air tiles, reach 3). Reading order: P1 = floor 20 corridor (cols 10-11), P2 = floor 15 (cols 9-10), P3 = floor 10 (cols 10-11), P4 = floor 5 (cols 9-10), P5 = floor 0 (cols 7-8). Periods 1.8 s (P1, P2) / 2.0 s (P3-P5), offsets P2 0.9, P3 1.0, P4 0.5: 0.4 s shake (safe), slam + hold 0.45 s (deadly), then retract: ~1.4 s safe. Wait on the 3-4 safe tiles before each head, watch the shake, run under on retract; never stand under a head. Safe tiles before/after: floor 0 cols 1-6 / 9-13; floor 5 cols 11-13 / 5-8; floor 10 cols 6-9 / 12-18; floor 15 cols 11-13 / 6-8; floor 20 cols 6-9 / 12-18.
- Skill crystal (4/5) at the clock face: from the gear platform (row 29, cols 8-12) jump the gap and two spikes (cols 15-16) to the ledge cols 15-18, crystal at col 18. Exit through the top hole (cols 7-11) from the gear platform; c3_c04 floor hole cols 7-11.

### c3_c04 — Tower gallery
```
   01234567890123456789
10 ####################
 9 #qqqq........kkkkk.#
 8 #qqoq........kkkkk.#
 7 #qqqq.........kkk..#
 6 #qoqq.........kkk..#
 5 #qqqq.........kkk..#
 4 #qqqqq........kkk...
 3 #qqqoq........kkk...
 2 #qoqqq........kkk...
 1 #qpqgq.......l@.!Hl.
 0 &&&&&&&.....&&&&&&&&
```
```props
! speaker_name = "Vesper (vysílačka)"
! portrait_texture = "res://assets/npc/vesper_portrait.png"
! dialogue_pages = Array[String](["Vidím tě z rafinerie! Nad tebou je už jen citadela a ústí velké šachty.", "Otis čeká ve starých dílnách u šachty. A Matěji... v citadele tě korporace nebude jen hledat. Bude tě lovit."])
```
- Breather on the tower gallery: arrive through the floor hole (cols 7-11), ledge right of it with `@` col 14, Vesper's radio `!` col 16, health pack col 17, exit right at h1. The citadel is the dark silhouette beyond the open balustrade; no hazards.

### c3_c05 — Cable gantry
```
   01234567890123456789
10 ######.....#########
 9 #qqqLqqqqqqqqqqqqoq#
 8 #qCqLqqqqqqqlqqoqqq#
 7 #BBBB~~~~~~~~~qqqqq#
 6 #qqqqqqqqqqqqqqqqlq#
 5 #qKqqqqqqqqqqqqqBBB#
 4 .BBBqqqqqqqq====qqq#
 3 .....kkkkkkkkkkkkkk#
 2 .....k~~~~~kkkkkkkk#
 1 ..@.lkkkkkkkkkkkkkk#
 0 &&&&&kkkkkkkkkkkkkk#
```
```props
~1 speed = -60
```
- Enter h1 (ledge cols 0-4, `@` col 2) over the abyss: everything below row 1 is a deadly pit (dark `k` void). Gantries rise by 2: belt h2 (cols 6-10, ->), crumbling grates h4 (cols 12-15), brass h5 (cols 16-18), then the return belt h7 (cols 5-13, <- toward the exit) and up through the top hole (cols 6-10; c3_c06 floor hole). Belts only add speed.
- Key/backtrack: the key `K` lies on a shelf above the start ledge (cols 1-3, h4, jump from col 4); the cage `L` (col 4, rows 8-9) seals the nook at the end of the return belt (cols 1-3, crystal col 2). Take the key first, walk the gantries, touch the block when the belt delivers you: it frees the crystal.

### c3_c06 — Inner wall walk
```
   01234567890123456789
10 ####################
 9 #qqqqqqqqqq........#
 8 #qqqqqqqqqq........#
 7 #qqqqqqqqqq........#
 6 #qqoqqqqoqq........#
 5 #qqqqqqqqqqqqqqqqqq#
 4 #qqqqqqqqqqqqqqqqqq.
 3 #qqoqqqqqoqqqqqqqqq.
 2 #qqqqqqqqqqqqqqqqqq.
 1 #lqgqqqqqqql@qBqGqp.
 0 &&&&&&.....&&&&&&&&&
```
- Arrive through the floor hole (cols 6-10); ledge right of it with `@` col 12; the guard patrols the wall walk (cols 15-18, merlon at col 14) - hop or stomp. Searchlight pylon at the end; exit right at h1 (rows 1-4 open, row 0 solid) into d01.

### c3_d01 — citadel gate
```
   0123456789012345678901234567890123456789
10 ########################################
 9 #qqqqq###################qqqqqqqqqqqqq##
 8 #qqqqq###################qqqqqqqqqqqqq##
 7 #qqqqq###################qqqqqqTqqqqqq##
 6 #qqoqo###################qqqqoqBBBBBBB##
 5 #qqqqq####PP#######PP####qqqqqqqqqqqqqq.
 4 .qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq.
 3 .qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq.
 2 .qqqqqqqqqqqqqqqqqqqqqqqqqqZZqqqqqqqgqq.
 1 .q@lgqqqpqqqqqlqqqqqqqgqqqlZZqqqqq######
 0 ########################################
```
```props
room checkpoint = true
P reach = 4
P2 reach = 4
P2 offset = 0.6
```
- Entry h1 (floor cols 0-5, `@` col 2, row 0 solid / rows 1-4 open at col 0) in the forecourt under the banners; then the gateway under the citadel wall (tunnel cols 6-24, 4 high). Two blast-door presses (`P` cols 10-11 and 19-20, reach 4, period 2.0): head down 0.4-0.85 s into each cycle, so run through right after a slam; P2 offset 0.6 slams just after P1, so follow the wave. Safe tiles: 3 before P1 (cols 7-9), 7 between (12-18), 5+ after (21-24).
- Past the gate the turret (col 31, on the slab of the right tower, floor under it) covers the yard: step out, duck behind the 2-high crate (cols 27-28), hop it and run under the slab (cols 31-37), where it cannot see you. The last 6 tiles of floor are one tile higher (h2): exit R at h2 (rows 2-5 open at col 39) drops 12 px into d02.

### c3_d02 — security court
```
   0123456789012345678901234567890123456789
21 ############################....########
20 ####qqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq#
19 ####qqqqqqqqqqqqqqqgqqqqqqqqqqlqqgqqqqq#
18 ####qqqqqqqqqqqqqBBBBBBBBBBBBBBBBBBqqqq#
17 ####qqoqqqqqgqqqqqqqq###qqqqqqqqqqqqqqq#
16 #FFFqqqqqqqqBBBBqqqqq###qqqqqqqqqqqqqqq#
15 #FcFqqqqlqqqqqqqqqqqq###qqqqqqoqqqqqqqq#
14 #BBBBBBBBBBqqqqqqqqqqqqqqqqqDqqqqqqqqqq#
13 #qqqqqqqqqqqqqpqqqqqqqqqqqqqqqqqqqqqqqq#
12 #qqqqqqqqqqqBBBBqqqqqqqqqqoqqqqqqqqoqqq#
11 #qqqqqqqqqqqqqqqqqqqGqqqqqqqqqqqqqqqqqq#
10 #qqqqqqqqqqqqqqqqBBBBBBBqqqqqqqqqqqqqqq#
 9 #qqqqqqqqqqqqqoqqqqqqqqqqqlqqqqqqqqqqqq#
 8 #qqqqqqqqqoqqqqqqqqqDqqqBBBBBBqqqqqqqqq#
 7 #qqqqqqqqqqqqqqqqqqqqqpqqqqqqqqqqqqqqqq#
 6 #qqqqqqqqqqqqqqqqqBBBBBqqqqqqqqqqqqoqqq#
 5 #qqqqoqqqqqqqqlqqqqqqqqqqqqqqqqqqqqqqqq#
 4 .qqqqqqqqqqqBBBBBqqqqqqqqqqqqqqqqqqqqqq#
 3 .qqqqqqqlqqqqqqqqqqqqqqqqqqqqqqqqqqqqqq#
 2 .qqqqqBBBBBqqqqqqqqqqqqqqqqqqqqqqqqqqqq#
 1 .q@qgqqqqqqqqqqqqqqqqqqqqqqqqqxqqqxqqqq#
 0 ########################################
```
```props
D patrol_distance = 24.0
```
- Entry h1 (floor cols 0-5, `@` col 2, rows 1-4 open at col 0), rows of the lower-left screen. Brass balconies climb in a zigzag, every hop rises 2: S1-S4 up to the right (h2/4/6/8), then back left over S5 (wide, a guard patrols it), S6, S7 (dead-end shelf into the wall), and right again over S8 to the terrace S9 (h18, cols 17-34) under the 4-wide hole (cols 28-31, top row of the top-right screen). Jump + double jump from S9 through the hole into d03.
- Drones: D1 hovers in the notch between S3 and S5, D2 in the open middle of the top-right screen; bait them into the balconies, the hanging bracket (cols 21-23) or the right wall and stomp. The floor is open everywhere, so a fall only costs the climb.
- Secret: S7 ends in a 3x2 stub of wall (cols 1-3, h15-16) = whole pocket `F` with the crystal `c` inside; col 0 stays solid. Hint only by the dead-end shelf running into the wall.

### c3_d03 — press shaft
```
   01234567890123456789
21 ####################
20 ####################
19 ####################
18 ####################
17 ####################
16 ##########PP#####...
15 ###qCqqqqqqqqqqqo...
14 ###qqqqqqqqqqqqqq...
13 ###qqqqqgqqqqqqql...
12 ###qqqBBBPPBBBBBB###
11 ###qoqqqqqqqqqqoq###
10 ###qqqqqqqqqqqqqq###
 9 ###qgqqqqqqqlqqqq###
 8 ###BBBBBBPPBBBqqq###
 7 ###oqqqqqqqqqqqqq###
 6 ###qqqqqqqqqqqqqo###
 5 ###qqxlqqqqqqqxqq###
 4 ###qqqBBBBBBBBBBB###
 3 ###qqqoqqqqqqoqqq###
 2 ###qqqqqqqqqqqqqq###
 1 ###q@qqqqqqqqqglq###
 0 ########....########
```
```props
P period = 1.8
P2 period = 1.8
P3 period = 1.8
P reach = 3
P2 reach = 3
P3 reach = 3
P2 offset = 0.6
P3 offset = 1.2
```
- Arrive through the floor hole (cols 8-11, from d02): ledges cols 3-7 (`@` col 4) and 12-16. Three brass slabs (A h4 cols 6-16, B h8 cols 3-13, C h12 cols 6-19) zigzag up the shaft, each rising 4 through a 3-wide gap by the wall (double jump / wall jump off the shaft wall). Each walkway has one press (period 1.8, 2-wide, reach 3) in the slab above: P1 cols 9-10 over A, P2 cols 9-10 over B (offset 0.6), P3 cols 10-11 over C (offset 1.2), a wave one step behind you. Heads are down 0.4-0.85 s of every 1.8 s; safe tiles: 3 before and 3 after P1/P2 (6-8 / 11-13), 4 before and 5 after P3.
- Exit R on the top screen at h12 (rows 5-8 open at col 19, floor row 9) into d04. Skill detour: the crystal at the top of the left gap (col 4, h15) is a wall-jump up the left shaft wall from slab B; drop onto C afterwards. Left wall of both screens, right wall of the bottom screen closed.

### c3_d04 — drill log control room
```
   01234567890123456789
10 ##############....##
 9 #qqqqqqqqqqqqqqqoq##
 8 #qqqqqqqqqqqoqlqqq##
 7 #qqdqqdqoqqqqq######
 6 #qqqqqqqqqqHqx######
 5 .qqoqqqqqq##########
 4 .qgqqqq!lq##########
 3 .qqqqq##############
 2 .q@qlq##############
 1 ####################
 0 ####################
```
```props
! speaker_name = "Deník vrtu"
! dialogue_pages = Array[String](["Vrt 7: hloubka 11 400 m. Gravitační anomálie v okolí jádra rostou o dvanáct procent denně.", "Rozkaz vedení: těžbu nezastavovat. Evakuaci Smallville urychlit."])
```
- Breather (no hazards): entry plate at row 9 (floor cols 0-5, `@` col 2, rows 5-8 open at col 0) matching d03's exit; the abandoned control room: three steps up (rows 7, 5, 3, rises 2) with the drill log terminal (`!`, col 7) and a health pack (col 11), corp banner, blight crystal in a crack.
- Exit through the 4-wide hatch (cols 14-17, top row) over the top step (cols 14-19, row 3): double jump up into d05 (its floor is 24 px above this room's top row). Right wall closed.

### c3_d05 — steam elevator
```
   01234567890123456789
21 ####################
20 ##qqqqqqqqqqqqqqqq##
19 ##qqqqqqTqqqqqqqoq..
18 ##qqqqqBBBqqqqqqqq..
17 ##qoqqqqqqqqZZqqqq..
16 ##qqqpqqqlqqZZqglq..
15 ##qqqBBBBBBBBBBBBBBB
14 ##qqqqqqqqqqqqqqqq##
13 ##qqqqqqqqoqqqqqqq##
12 ##qqqqqqqqqqqoqqqq##
11 ##qSqqVqqxqqqqqqqq##
10 ##BBBBBBBBqqqqqqqq.#
 9 ##qqqqqqqqqqqqqqqq.#
 8 ##qqoqqqqqqqqqqoqqC#
 7 ##qqqqqqqqqqqqqqqq##
 6 ##qqqqqqVqqSqSqqqq##
 5 ##qqqBBBBBBBBBqqqq##
 4 ##qqqqqqqqqqqqqqqq##
 3 ##qqqqqoqqqqqqqqqq##
 2 ##qqqqqqqqqqqqqqqq##
 1 ##gSqqqlqq@qlqqqqq##
 0 ##############....##
```
```props
S3 direction = Vector2(1, -1)
V2 offset = 1.0
```
- Arrive through the floor hole (cols 14-17), ledge cols 2-13 with `@` (col 10). Steam elevator in 3 beats: spring S4 (col 3) -> brass deck E1 (h5, cols 5-13) with a vent (col 8, 2 s idle / 0.5 warn / 1 s blast) -> spring S2 (col 11) -> deck E2 (h10, cols 2-9) with a vent (col 6, offset 1.0) -> spring S1 (col 3) -> the top deck E3 (h15, cols 5-19) = d06's floor. Safe tiles: 3 before each vent. Springs are numbered in reading order (S1 top, S4 bottom).
- Turret on the balcony (cols 7-9, h18, floor under it): the balcony blinds it for the left half of E3, the 2x2 crate stack (cols 12-13) covers the run to the exit. Exit R at h15 (rows 16-19 open at cols 18-19). Trick crystal (col 18, h8, visible from E1): the angled spring S3 (`Vector2(1, -1)`, col 13) flings you across the shaft into the wall niche; the checker reaches it with the spring sim.

### c3_d06 — summit terrace
```
   01234567890123456789
10 ####################
 9 ....................
 8 ....................
 7 ....................
 6 ....................
 5 .g@.l.!..p.x........
 4 ############.l.x....
 3 ################.g..
 2 ####################
 1 ####################
 0 ####################
```
```props
! speaker_name = "Vrchol hory"
! dialogue_pages = Array[String](["Pod tebou leží celá hora — rokle, Smallville, Parní město v páře. Před tebou zeje černé ústí šachty, která vede až k jádru planety.", "Odtud už vede cesta jen dolů."])
```
- Summit terrace, short and safe: open sky under a solid top row, `!` Vrchol hory at col 6, lamps, a corp pylon and banners. Entry h5 from d05 (plate cols 0-11, `@` col 2, rows 1-5 open at col 0), then two small steps down (h4, h3) to the exit R at h3 (rows 3-9 open at col 19) into d07.

### c3_d07 — old workshops at the shaft mouth
```
   0123456789012345678901234567890123456789
10 ########################################
 9 #qqqLqqqqqq#####################qqqqqqq#
 8 #qqqLqoqqqq###o######o##########qqqqoqo#
 7 #qCqLqqqqqq####PP#####PP########qqqqqqq#
 6 #BBBBBBqqqqqqqqqqqqqqqqqqqqqqqqqqqKqqqq#
 5 .qqqqqqqqqqqqoqqqqoqqqqqqoqqqqoqqBBBBqq#
 4 .qqoqqqqq##qqqqqqqqqqqqqqqqqqqqqqqqqqqq#
 3 .g@qqlqqq##qlqqqqqqgqqqqqqlqqqGqxqplqEl#
 2 ###########################~~~~~~#######
 1 ########################################
 0 ########################################
```
```props
P reach = 4
P2 reach = 4
P2 offset = 0.6
E next_level = "res://level1.tscn"
E stage_title = "KAPITOLA 3: PARNÍ MĚSTO"
E stage_index = 3
E max_stage_crystals = 12
```
- Entry h2 (hall floor cols 0-10, `@` col 2). The old workshops: workshop corridor (cols 11-31, 4 high) with the last two presses (cols 15-16 and 22-23, reach 4, period 2.0, P2 offset 0.6; safe: 4 tiles before P1, 5 between, 8 after), a belt along the travel direction (cols 27-32), a guard patrolling from the belt to the shaft mouth. `E` at col 37 (lamps frame it), right wall closed.
- Key/backtrack: the key `K` sits on a shelf at col 34 (h5, a double jump from the floor, visible from the corridor). The caged crystal is in the hall: mezzanine (cols 1-6, h6) reached by the steps (cols 9-10, then up-left), the single block `L` (col 4) in front of it. Take the key, run back through the presses to the hall (the block touched first frees the crystal), then return to `E`.
