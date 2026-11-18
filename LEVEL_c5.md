# LEVEL c5 — The Foundry (Slévárna)

Behind the HQ gate (end of c4) the corporation's mountain is hollow: the **great shaft** drops from the HQ to the planet's core, and the corp's **foundry** is built in tiers into its walls. Here they melt the gravity crystals from Smallville into coils for the reactor; slag runs down the shaft wall. The hero meets Otis in the old workshops walled off at the shaft head, gets the stolen **Gravity Coil** (dash), and **descends** the shaft: the shaft head and its scaffolds, the foundry tiers (slag, dash shards, belts), the casting halls (cog saws, mould presses) and the slag sluice, where the corp floods the shaft with slag and the hero outruns it down to the crystal mines (→ `level2`, chapter 6).

- **Kit:** run, jump, double jump (DJ), wall climb/jump (8 s stamina), wrench; **dash from a01** (Otis's chest). No hook.
- **New here:** **dash** (a01–a03), **molten slag** `m` (b02), **dash shards** `*` (b03), **cog saws** `Q` (c01), **slag flood** `u` (d06 finale). Develops: spikes, falling rocks, grates, belts, vents, presses, guards, turrets, drones.
- **Signature:** **dash lines down the shaft.** Travel is ↓ and →. Gaps too wide to jump, diagonal dashes between ledges, shard chains over slag.
- **Look:** `U` basalt (the shaft rock — the default terrain), `Y` hot rock (basalt with glowing cracks: around slag, furnaces, the sluice), `#` carved stone (foundry foundations, walls), `B` brass (machinery, crucibles, valves, the sluice), `Z` scrap/iron plates (catwalks, braces), `W` planks (old scaffolds of the shaft head), `&` brick (furnaces, the old workshops); back walls `q` brick, `k` dark rock (sparingly), `z` iron, `o` lit windows, `d` doors. Decor `l` lamps, `g` corp banners, `p` corp searchlight pylons, `h` furnace fire (harmless), `x` blight crystals (deeper down, d section), `a` antennas. Mostly air `.`: the backdrop (the far shaft wall with furnace tiers, chains, slag falls, rising embers; redder the deeper you go) must show in every room.
- **Rules:** LEVEL_DESIGN §1–2, §5, ASCII format §6. Crystals: 12, route types never repeat back to back.

## Open rooms in the shaft — not boxes (read first)

A room edge with **no neighbouring room** is an invisible wall (left, right, top). Only falling out the **bottom** where no room continues kills. The great shaft is huge, so like Celeste:

- **Rooms are ledges, scaffolds, galleries and foundry tiers on the shaft wall, with the shaft's open air in front of them.** No solid frame around a room: never a solid top row or a full-height side wall just to close it. Draw terrain as masses: rock outcrops, overhangs, pillars, a tier floor with its underside visible, a lone ledge in the air. At least a third of every room is open air (backdrop visible).
- **Buildings and halls stand in the shaft:** the workshops, Hron's corner, the guard booth are structures inside the room with air around them; a casting hall is a floor with machinery and a few pillars, not a closed box.
- **Down-exits (new, the main way between rooms):** a gap ≥3 tiles wide in the bottom row (air above it) over the room below. The room below has the **same columns open in its top row** and, right under the gap, a safe landing ledge with `@` at most ~6 tiles below its top (no hazard, no enemy in the landing zone; a gust of falling is fine). Everywhere else the two rooms' shared edge is closed with terrain on both sides (otherwise it is a second exit).
- **Side exits:** where two rooms share a side edge, the terrain on both sides matches exactly (same floor height, same solid rows), ≥3 tiles open.
- **Pits:** a bottom-row gap with **no room below** = bottomless pit (death into the shaft). Allowed as stakes, never under a respawn. A 2-wide room above a 1-wide room: only the half above the lower room can be an exit; gaps over the other half are pits.
- **Respawns:** every entrance gets a ≥3-tile safe ledge with `@`. The game respawns you at the `@` nearest to where you entered, so put it right at the entrance (side) or under the drop (top).
- **No backtracking up:** a down-exit is one-way in practice. Never require climbing back up through a down-exit; every room must be finishable from each of its `@`.
- **Secrets must be invisible:** fill the whole pocket with `F` (drawn like the surrounding wall) and put its crystal as `c`; keep a solid tile between the pocket and the room edge. Hint only by geometry (a ledge running into the wall, a dead-end shelf, a lamp where nothing seems to be).
- Other crystals (skill, key, trick, winged, gauntlet) are visible from the main path. Key cages: one key opens one `L` block.

## Element rules

- **Dash** (new): `Mezerník` + direction, 8 directions, ~5 tiles (400 px/s for 0.2 s, no gravity), then the speed carries: a horizontal dash from a run covers ~8–9 tiles before you land from floor height; dash + jump ~13 across, ~16 with DJ; ~10 up (jump + dash up + DJ). Recharges **only on the ground**, on a spring, or from a dash shard — one dash per airtime otherwise. No dash down from standing (crouch).
  - Teach (a01): the first gap that needs a dash has a **safe floor ~4 tiles below** with steps back up (failure = climb out and retry) and a low ceiling (3 tiles of air) so a plain jump falls short. a02 adds stakes. Before a01's chest the path must not need a dash.
  - Size gaps so a plain running jump + DJ **fails** where a dash is meant: **13–14 tiles** between floors (checker: jump + DJ + a wall grab on the far face clears ≤12 in the open, ≤11 under a 3-tile ceiling; a dash clears ≤17, so 15+ is too tight).
- **Molten slag `m`** (b02+): a death pool, **one row only**, a solid tile under every `m`; the surface sits 3 px below the tile top (kills 6 px below it). Treat as spikes in a floor channel. Glow is red-orange; keep it out of landing zones. First appearance (b02): a narrow channel you can just jump, then one that needs a dash.
- **Dash shard `*`** (b03+): floating teal crystal, refills the dash when touched in the air (not the DJ), regrows 2.5 s. First appearance over a safe floor; chains of 2–3 over slag later. Place shards ~4–5 tiles apart along the dash line (the checker branches on them).
- **Cog saw `Q`** (c01+): a saw moving on a visible rail, ping-pong (or `loop`), kills on touch (radius 10 px). One `Q` per saw at the rail's start cell; props `Q2 rail = PackedVector2Array(0, 0, 0, -64)` (px, relative to the cell centre, flat x, y pairs), `Q2 period = 3.0`, `Q2 loop = true` (for loops give ≥3 points), `Q2 offset = 1.0`. **The checker ignores saws:** leave a clear lane outside each rail's path (rail + 12 px each side is deadly), and never make the player wait inside a rail's reach.
- **Slag flood `u`** (d06 only): one `u` anywhere in the room = slag pours from the room's top edge downward over the whole width after 2 s, ~30 px/s. The checker ignores it; the room must be a non-stop descent (no climbing back up, no long waits).
- **Belt `~`:** 60 px/s right (`~ speed = -60` left). The checker treats it as floor; never require its speed; no slag or spikes within 6 tiles past its end.
- **Vent `V`:** blasts 4 tiles up (idle 2.0 s, warn 0.5 s, blast 1.0 s), 1 HP + knockback, not death; `V2 offset = 1.0` staggers them.
- **Press `P`** (c03, d03): housing solid, head strikes down `reach` tiles (`P reach = 3`), period 2.0 s, ~1.55 s safe; `P2 offset = 0.6`; never make the player wait under a head; 3 safe tiles before/after.
- **Falling rock `O`:** hangs under a ceiling/overhang, drops once when you pass under. **Grate `=`** (2-tile pieces): collapses 0.5 s after landing, returns; the checker treats it as solid: never chain more than two without a solid rest. **Spring `S`:** ~5.6 tiles up, refills dash + DJ (`S direction = Vector2(1, -1)` for angled).
- **Turret `T`:** falls with gravity, stand it on a floor; cover on its approach; a perch wider than 1 tile under it blinds it. **Drone `D`:** hovers, patrols ±50 px (`D patrol_distance = 24.0`), sees 120 px, charges straight, stuns on walls: give it rock to crash into. **Guard `G`:** patrols a floor, turns at walls and ledges. Dashing into an enemy hits it (2 dmg).
- **Crystals:** `C` normal; **winged** = `C` + props `C variant = 1` (flies away if the player dashes anywhere in its room): its route must work **without dash** (`--nodash`), from the room's entrance, before the dash is needed.

## Dialogue (place via props, text verbatim)

- **a01** `1` (Otis) `dialogue_pages = Array[String](["Matěji! Ty jsi vážně prošel hlavní branou? Vítej ve starých dílnách. Korporace je zazdila, když prorazila velkou šachtu.", "Pod námi je slévárna. Tam taví krystaly ze Smallville na cívky pro reaktor. Jednu jsem jim ukradl z vagonu.", "Gravitační cívka. Stiskni [Mezerník] se směrem a vyrazíš kamkoli, i ve vzduchu. Nabije se, až se dotkneš země.", "Vezmi si ji z truhly. A pak dolů, šachta vede až k jádru."])`, `repeat_dialogue_pages = Array[String](["Dash: [Mezerník] + směr. Ve vzduchu jednou, na zemi se cívka nabije."])`
- **a01** `X` `initial_items = Array[String](["gravity_coil", "health_pack"])`
- **a07** `!` speaker_name `"Pohled do propasti"`, dialogue_pages `Array[String](["Šachta padá stovky metrů do tmy. Ve stěnách hoří patra pecí a po skále stéká struska.", "Někde hluboko dole hučí reaktor."])`
- **b01** `!` speaker_name `"Hlas Korporace"`, dialogue_pages `Array[String](["Směna slévárny, pozor. Kvóta cívek pro reaktor se zvyšuje o třetinu.", "Kdo se dotkne strusky, nebude odškodněn. Korporace děkuje za vaši obětavost."])`
- **b04** `8` (Hron) `dialogue_pages = Array[String](["Ty? Tady dole? Mě přeložili z lisovny. Prý za flákání.", "Ty modré úlomky, co odletují od pecí, chytni ve vzduchu a cívka se ti nabije znovu. Sbíráme je, aby nepropálily pásy.", "A na strusku nešlapej. Nikdy."])`, `repeat_dialogue_pages = Array[String](["Úlomky nabíjejí cívku. Struska zabíjí. Víc ti neřeknu."])`
- **c04** `!` speaker_name `"Vesper (vysílačka)"`, portrait_texture `"res://assets/npc/vesper_portrait.png"`, dialogue_pages `Array[String](["Matěji? Konečně signál! Otis říkal, že máš cívku. Bez ní by ses přes licí haly nedostal.", "Pod slévárnou jsou krystalové doly, Rusty tam má tábor. Ale pozor: korporace pouští strusku stavidlem rovnou do šachty. Až uslyšíš sirénu, utíkej dolů."])`
- **d01** `!` speaker_name `"Hlas Korporace"`, dialogue_pages `Array[String](["Narušitel ve slévárně. Uzavřít licí haly. Připravit stavidlo."])`
- **d04** `!` speaker_name `"Deník tavírny"`, dialogue_pages `Array[String](["Den 112. Krystaly ze Smallville se taví hůř. Prý jsou živé. Pece praskají.", "Vedení nařídilo pouštět strusku rovnou do šachty. Doly pod námi to prý vydrží."])`
- **d05** `!` speaker_name `"Siréna"`, dialogue_pages `Array[String](["STAVIDLO OTEVŘENO. Struska padá šachtou. Všem pracovníkům: opustit spodní patra!"])`
- **d07** `E` next_level `"res://levels/c6/chapter6.tscn"`, stage_title `"KAPITOLA 5: SLÉVÁRNA"`, stage_index `5`, max_stage_crystals `12`
- **a01, b01, c01, d01**: `room checkpoint = true`

## Layout

Fixed positions (screens, top-left; y grows downward, so the descent goes to positive y). Don't move or resize rooms. Rooms touch only their neighbours in the chain (plus the b05b branch), so every shared edge below is a real connection.

```layout
chapter res://levels/c5/chapter5.tscn
start_items wrench
kit dash
c5_a01 0 0
c5_a02 2 0
c5_a03 2 1
c5_a04 3 2
c5_a05 4 3
c5_a06 5 4
c5_a07 5 5
c5_b01 6 5
c5_b02 7 6
c5_b03 8 7
c5_b04 9 8
c5_b05 10 8
c5_b05b 11 8
c5_b06 10 10
c5_c01 12 10
c5_c02 13 11
c5_c03 14 12
c5_c04 15 13
c5_c05 16 13
c5_c06 17 14
c5_c07 18 15
c5_d01 19 15
c5_d02 20 16
c5_d03 21 17
c5_d04 22 18
c5_d05 23 18
c5_d06 23 19
c5_d07 23 22
```

## Rooms

Fixed section boundaries: **a07 → b01**, **b06 → c01** and **c07 → d01** are right-edge crossings with the floor at **h2** (rows 0–1 solid on both sides of the edge), rows 2–6 open on both sides; rows 7+ free. All other connections are agreed inside a section. "top" = you arrive by falling in through the top edge; "bottom" = you leave by dropping through the bottom edge. A 2×1 room's "right screen" = columns 20–39; a 1×2 room's "bottom screen" = rows 0–10 (labels 10…0).

| id | size | from → to | challenge | elements | diff | crystal | CP |
|---|---|---|---|---|---|---|---|
| c5_a01 | 2×1 | start (L, by the gate) → a02 (R) | The old workshops walled off at the shaft head: a brick-and-plank workshop standing in a rock cave (lit windows, Otis `1`, chest `X` with the coil) — no dash needed up to the chest. Out the back door: the first dash gap (13 tiles) under a low rock ceiling, **safe failure** (a dry pit 4 tiles deep with steps back up on the near side), then the cave mouth opens onto the shaft. | Otis, chest, **dash** | 1 | — | ✔ |
| c5_a02 | 1×1 | a01 (L) → a03 (bottom) | The shaft lip: the ore-car track is broken over a spike bed; dash to the last track stub, then drop off its end into the shaft. | dash, spikes | 2 | **Skill detour**: crystal on a rock perch high over the spikes, reached by a jump + diagonal-up dash; from the perch you glide down to the stub. | — |
| c5_a03 | 1×2 | a02 (top) → a04 (R, bottom screen) | Down the shaft-head scaffolding, a zig-zag in open air: landing scaffold (right) → wide scaffold with a guard (middle) → off its left end to a rock outcrop → a 13-tile dash over the bottomless shaft, passing under the scaffold's two hanging rocks, to the outcrop at the exit. | dash, falling rocks, guard | 2 | — | — |
| c5_a04 | 2×1 | a03 (L) → a05 (bottom, right screen) | Old ore chute: a rail bridge over the shaft (bottomless under the left screen) — two crumbling grates, a guard on the iron span, then the broken section: a 13-tile dash to the chute pier (spiked rubble under its near half). The pier's raised lip is cover from the turret on the far pier; hop it and drop down the chute. | grates, dash, pits, turret, guard | 3 | **Secret passage**: hidden pocket in the far pier, entered from the dead-end shelf at the bottom of the chute (`F` + `c`). | — |
| c5_a05 | 1×2 | a04 (top) → a06 (R, bottom screen) | A crevice between the shaft wall and a split-off rock flake: two drop chutes with spikes on alternating faces (steer or dash across mid-fall), a rest ledge with a lamp between them. | spikes, dash | 2 | — | — |
| c5_a06 | 1×1 | a05 (L) → a07 (bottom) | Winch platform: the winch drum hangs low with teeth on its underside over a spike pit — no room to jump, a flat dash under the teeth carries you into the lift shaft. A **winged** crystal waits on the planks above the entrance — grab it before you dash. | dash, spikes, winged crystal | 2 | **Winged**: reachable from the entrance without dash (`--nodash`). | — |
| c5_a07 | 1×1 | a06 (top) → b01 (R, h2 fixed) | Breather: the old lift station on a ledge over the shaft (a structure with air around it), health pack, `!` Pohled do propasti. | `!`, `H` | 1 | — | — |
| c5_b01 | 2×1 | a07 (L, h2 fixed) → b02 (bottom, right screen) | Upper foundry tier: belts carry ingot crates along the tier, loudspeaker `!` Hlas Korporace, a guard on the floor, a turret on a gantry (cover), dash over a gap between the tier's two halves. | belts, guard, turret, `!` | 2 | — | ✔ |
| c5_b02 | 1×2 | b01 (top) → b03 (R, bottom screen) | **Slag** intro: slag channels cut across the tier floors — the first narrow (jump), then one that needs a dash; steam vents on the way down. | **slag**, vents, dash | 2 | **Key/backtrack**: key on a ledge off the path, caged crystal (`L`) near the exit. | — |
| c5_b03 | 2×1 | b02 (L) → b04 (bottom, right screen) | **Dash shard** intro: first a shard hanging over a safe floor (dash → shard → dash up to a ledge), then over a slag channel (dash → shard → dash across). | **shards**, slag, dash | 3 | **Mechanic trick**: a shard used unexpectedly (e.g. dash up through a shard to a crystal high above the slag). | — |
| c5_b04 | 1×1 | b03 (top) → b05 (R) | Breather: Hron's corner by the cooling tanks (a hut of scrap with a lamp), Hron `8`, health pack. | NPC, `H` | 1 | — | — |
| c5_b05 | 1×2 | b04 (L, top screen) → b06 (bottom); branch R (top screen) ↔ b05b | Crucible tier: a great brass crucible over a slag pool, belts, a drone patrolling the drop; down through the tier. | slag, belts, drone, dash | 3 | **Secret passage**: hidden niche in the crucible's stone foundation (`F` + `c`). | — |
| c5_b05b | 1×1 | b05 (its R edge, top screen) ↔ b05 | Side gauntlet: a shard chain over a wide slag pool to a crystal at the far right; return the same way (left edge back to b05). Its right and top edges have no room (invisible walls), bottom edge = pit. | shards, slag | 4 | **Side gauntlet** | — |
| c5_b06 | 2×1 | b05 (top, left screen) → c01 (R, h2 fixed) | Ingot conveyors over slag: belts running both ways, a guard, a turret on a platform with cover; dash between the belts. | belts, slag, guard, turret, dash | 3 | — | — |
| c5_c01 | 2×1 | b06 (L, h2 fixed) → c02 (bottom, right screen) | Casting hall entrance: **cog saw** intro — one saw on a horizontal rail along a raised floor, safe lane beside it; mould racks; a turret at the far end with cover. | **saws**, turret | 2 | — | ✔ |
| c5_c02 | 1×2 | c01 (top) → c03 (R, bottom screen) | Saw shaft: saws on vertical rails flank a dash descent between ledges. | saws, dash | 3 | **Skill detour**: crystal on a ledge between two saw rails. | — |
| c5_c03 | 2×1 | c02 (L) → c04 (bottom, right screen) | Mould presses over a belt line, shards over a slag gap, a drone in the hall. | presses, belts, shards, slag, drone | 3 | — | — |
| c5_c04 | 1×1 | c03 (top) → c05 (R) | Breather: a maintenance niche in the rock behind the hall, Vesper on the radio (`!`), health pack. | `!`, `H` | 1 | — | — |
| c5_c05 | 2×1 | c04 (L) → c06 (bottom, right screen) | Saw loop around a stone pillar over slag; shard chain across the hall. | saws, shards, slag, dash | 4 | **Key/backtrack**: key on the pillar's far side, caged crystal near the exit. | — |
| c5_c06 | 1×2 | c05 (top) → c07 (R, bottom screen) | Cooling shaft: vents blasting up between ledges, drop and dash between them; shards. | vents, shards, dash | 3 | — | — |
| c5_c07 | 1×1 | c06 (L) → d01 (R, h2 fixed) | Gantry over the abyss: a drone over the gantry, a shard, slag dripping into a trough. | drone, shard, slag | 3 | **Mechanic trick**: a spring or shard used to reach a crystal under the gantry roof. | — |
| c5_d01 | 2×1 | c07 (L, h2 fixed) → d02 (bottom, right screen) | Sluice gallery: alarm `!`, two guards on the gallery, a turret on a buttress (cover), hot rock everywhere. | guards ×2, turret, `!` | 3 | — | ✔ |
| c5_d02 | 1×2 | d01 (top) → d03 (R, bottom screen) | Slag cascade: slag pools on stepped tiers, dash down between them; a saw on the last tier. | slag, saws, dash | 3 | — | — |
| c5_d03 | 2×1 | d02 (L) → d04 (bottom, right screen) | Valve hall: presses and saws combined over a slag channel, shards; a drone. | presses, saws, slag, shards, drone | 4 | **Winged**: reachable without dash from the entrance. | — |
| c5_d04 | 1×1 | d03 (top) → d05 (R) | Breather: an abandoned smelter control booth, health pack, `!` Deník tavírny. | `!`, `H` | 1 | — | — |
| c5_d05 | 1×1 | d04 (L) → d06 (bottom) | Sluice controls: `!` Siréna as you enter; a short drop to a wide hole over the shaft. | `!` | 1 | — | — |
| c5_d06 | 1×3 | d05 (top) → d07 (bottom) | **Finale: the slag flood** pours from the top (`u`): a non-stop 3-screen descent — dashes between ledges, shards, a few spikes; never wait, never climb. | **slag flood**, shards, dash | 4 | — | — |
| c5_d07 | 2×1 | d06 (top, left screen) → `E` (right end) | The bottom of the foundry: the slag drains into a grated sump; the mouth of the crystal mines (blue blight crystals `x`), `E` at the gallery entrance on the right. | — | 1 | **Secret passage**: pocket in the gallery's rock (`F` + `c`). | — |

Crystal route order: skill (a02) → secret (a04) → winged (a06) → key (b02) → trick (b03) → secret (b05) → gauntlet (b05b) → skill (c02) → key (c05) → trick (c07) → winged (d03) → secret (d07).
Enemies: guards a03, a04, b01, b06, d01 ×2 = 6; turrets a04, b01, b06, c01, d01 = 5; drones b05, c03, c07, d03 = 4 → 15.
Travel: ↓ and →; the chapter descends 23 screens to the crystal mines.

## Rooms (ASCII)

### c5_a01 — the old workshops
```
   0123456789012345678901234567890123456789
10 UUUUUUWWWWWWWUUUUUUUUUUUUUUUUUUUUUU.....
 9 UUUWWWWWWWWWWWWWUUUUUUUUUUUUUUUUUU......
 8 B..&&qqqqlqqqq&&UUUUUUUUUUUUUUUUU.......
 7 B.l.dqqoqqqoqqd.........................
 6 B...dqqqqqqqqqd..l.................l....
 5 B.@.dqq1qqqXqqd.........................
 4 UUUUUUUUUUUUUUUUUU.............WWUUUUUUU
 3 UUUUUUUUUUUUUUUUUUU..............UUUUUUU
 2 UUUUUUUUUUUUUUUUUUUU.............UUUUUUU
 1 UUUUUUUUUUUUUUUUUUUUU............UUUUUUU
 0 UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU
```
```props
room checkpoint = true
1 dialogue_pages = Array[String](["Matěji! Ty jsi vážně prošel hlavní branou? Vítej ve starých dílnách. Korporace je zazdila, když prorazila velkou šachtu.", "Pod námi je slévárna. Tam taví krystaly ze Smallville na cívky pro reaktor. Jednu jsem jim ukradl z vagonu.", "Gravitační cívka. Stiskni [Mezerník] se směrem a vyrazíš kamkoli, i ve vzduchu. Nabije se, až se dotkneš země.", "Vezmi si ji z truhly. A pak dolů, šachta vede až k jádru."])
1 repeat_dialogue_pages = Array[String](["Dash: [Mezerník] + směr. Ve vzduchu jednou, na zemi se cívka nabije."])
X initial_items = Array[String](["gravity_coil", "health_pack"])
```

### c5_a02 — the shaft lip
```
   01234567890123456789
10 ....................
 9 .........C..........
 8 ........UUU.........
 7 .........U..........
 6 ....................
 5 @..............l....
 4 UUU...........ZZZ...
 3 UUU.................
 2 UUUU^^^^^^^^^^^^^...
 1 UUUUUUUUUUUUUUUUU...
 0 UUUUUUUUUUUUUUUUU...
```
```props
```

### c5_a03 — shaft-head scaffolding
```
   01234567890123456789
21 UUUUUUUUUUUUUUUUU...
20 UUUUUUUUUUU.........
19 UUUUUU..............
18 UUU.................
17 ....................
16 ...............l.@..
15 .............WWWWWWW
14 ....................
13 ....................
12 ........G...........
11 ....WWWWWWWWW.......
10 .....O.....O........
 9 ....................
 8 ....................
 7 ....................
 6 .l................l.
 5 UUUU.............UUU
 4 UUUU.............UUU
 3 UUU...............UU
 2 UUU...............UU
 1 UU.................U
 0 UU.................U
```
```props
```

### c5_a04 — old ore chute
```
   0123456789012345678901234567890123456789
10 UUUU....................................
 9 UU......................................
 8 .....l............................l.....
 7 ..............................U.........
 6 .@........G...................U.......T.
 5 UUUU====ZZZZZ.............UUUUU.....UUUU
 4 UUU.....Z...Z.............UUUUU.....UUUU
 3 UU......Z...Z.............UUUUU.....FFFU
 2 UU......Z...Z.......^^^^^^UUUUU.....FcFU
 1 U.......Z...Z.......UUUUUUUUUUU...UUUUUU
 0 U.......Z...Z.......UUUUUUUUUUU...UUUUUU
```
```props
```

### c5_a05 — the crevice
```
   01234567890123456789
21 UUUUUUUUUUU...UUUU..
20 UUUUUUUUU......UUU..
19 UUUUUUUU.......UUU..
18 UUUUUUU.....@..UUU..
17 UUUUUU....UUUUUUUU..
16 UUUUUU>...UUUUUUUU..
15 UUUUUU>...UUUUUUUU..
14 UUUUUU...<UUUUUUU...
13 UUUUUU...<UUUUUUU...
12 UUUUU..........UUU..
11 UUUU...........UUU..
10 UUUU.l.........UUU..
 9 UUUUUUUUUUU....UUU..
 8 UUUUUUUUUUU....<UU..
 7 UUUUUUUUUUU....<UU..
 6 UUUUUUUUUUU.........
 5 UUUUUUUUUU..........
 4 UUUUUUUUU.....l..@..
 3 UUUUUUUUUUUUUUUUUUUU
 2 UUUUUUUUUUUUUUUUUUUU
 1 UUUUUUUUUUUUUUUUUUUU
 0 UUUUUUUUUUUUUUUUUUUU
```
```props
```

### c5_a06 — winch platform
```
   01234567890123456789
10 .......BBBBBBBB.....
 9 ...C...BBBBBBBB.....
 8 ..WWW..BBBBBBBB.....
 7 .......vvvvvvvv...l.
 6 ....ZZ..............
 5 ....................
 4 @...................
 3 UUUUUUU.............
 2 UUUUUUU...........UU
 1 UUUUUUU^^^^^^^^...UU
 0 UUUUUUUUUUUUUUU...UU
```
```props
C variant = 1
```

### c5_a07 — the old lift station
```
   01234567890123456789
10 UUUUUUUUUUUUUUU...UU
 9 UUUU................
 8 UUUU.......l........
 7 ....................
 6 .....WWWW...........
 5 .....&&&&.......@...
 4 .....&&&&...WWWWWW..
 3 .....&d&&.l.Z.......
 2 .....&&&&...Z.H...!l
 1 .....UUUUUUUUUUUUUUU
 0 .....UUUUUUUUUUUUUUU
```
```props
! speaker_name = "Pohled do propasti"
! dialogue_pages = Array[String](["Šachta padá stovky metrů do tmy. Ve stěnách hoří patra pecí a po skále stéká struska.", "Někde hluboko dole hučí reaktor."])
```

### c5_b01 — upper foundry tier
```
   0123456789012345678901234567890123456789
10 qqqkkkk......zzzz........BBBBBBBB...UUUU
 9 qqqkkkk......zzzz........ZZZZZZZZ...UUUU
 8 qqqkkkk......zzzz...................UUUU
 7 kkkkkkk..........................T..UUUU
 6 kkkkkkk........................ZZZZZYYYY
 5 kkkkkkk................................Y
 4 .......................................Y
 3 .............................ZZ...l....Y
 2 ..@..!l...................G..ZZ........Y
 1 #######Y...............Y~~~~~######....#
 0 #######Y...............Y###########....#
```
```props
room checkpoint = true
! speaker_name = "Hlas Korporace"
! dialogue_pages = Array[String](["Směna slévárny, pozor. Kvóta cívek pro reaktor se zvyšuje o třetinu.", "Kdo se dotkne strusky, nebude odškodněn. Korporace děkuje za vaši obětavost."])
```

### c5_b02 — first slag
```
   01234567890123456789
21 UUUUUUUUUUUUUUU....U
20 UUUUU...............
19 UU..................
18 .....K..............
17 ...ZZZZZ............
16 ....................
15 ............V.V..@..
14 ...UUUUUYmmYUUUUUUUU
13 ...UUUUUUUUUUUUUUUUU
12 ................UUU.
11 ................UUU.
10 ................UUU.
 9 ................UUU.
 8 ................YCY.
 7 .................L..
 6 ..................l.
 5 ....................
 4 ....................
 3 UUYmmmmmmmmmmmmmYUUU
 2 UUUUUUUUUUUUUUUUUUUU
 1 UUUUUUUUUUUUUUUUUUUU
 0 UUUUUUUUUUUUUUUUUUUU
```
```props
V2 offset = 1.0
```

### c5_b03 — shard stair
```
   0123456789012345678901234567890123456789
10 .............................C..........
 9 ..............l.....*....*........l.....
 8 ............ZZZZ...............<YUUU...U
 7 ........*......................<YUUU...U
 6 ...............................<UUUU...U
 5 ...............................<UUUU...U
 4 ..@............................<UUUU...U
 3 ####...........................<UUUU...U
 2 #####..........YY..............<UUUU...U
 1 ######.........YYmmmmmmmmmmmmmmmUUUU...U
 0 ###############YY###############UUUU...U
```
```props
```

### c5_b04 — Hron's corner
```
   01234567890123456789
10 ....................
 9 UUU.................
 8 UUU.................
 7 UUUZZZZZZZ..........
 6 UUUZ.l...Z.BB.l.....
 5 UUUZ.......BB.......
 4 UUUZ..8.H..BB....@..
 3 ####################
 2 ####################
 1 ####################
 0 ####################
```
```props
8 dialogue_pages = Array[String](["Ty? Tady dole? Mě přeložili z lisovny. Prý za flákání.", "Ty modré úlomky, co odletují od pecí, chytni ve vzduchu a cívka se ti nabije znovu. Sbíráme je, aby nepropálily pásy.", "A na strusku nešlapej. Nikdy."])
8 repeat_dialogue_pages = Array[String](["Úlomky nabíjejí cívku. Struska zabíjí. Víc ti neřeknu."])
```

### c5_b05 — the crucible tier
```
   01234567890123456789
21 ....................
20 ....................
19 .........D..........
18 ....................
17 ....................
16 ....................
15 .@...............@..
14 ######....UUUUUUUUUU
13 ######....UUUUUUUUUU
12 ######....UUUUUUUUUU
11 ######....UUUUUUUUUU
10 ....................
 9 ....................
 8 UUU~~~~~~~UUUU......
 7 UUUUUUUUUUUUUU......
 6 UUUUUUUUUUUUUU...###
 5 .................FF#
 4 ...............l.Fc#
 3 .............<######
 2 .............<######
 1 #...mmmmmmmmmm######
 0 #...################
```
```props
D patrol_distance = 24.0
```

### c5_b05b — slag gauntlet
```
   01234567890123456789
10 ...UUUUUUUUUUUUUUU..
 9 ...YYYYYYYYYYYYYYY..
 8 ....................
 7 ....................
 6 ........*....*......
 5 ....................
 4 ..@................C
 3 ##Y...............Y#
 2 ###...............##
 1 ###mmmmmmmmmmmmmmm##
 0 ####################
```
```props
```

### c5_b06 — ingot conveyors
```
   0123456789012345678901234567890123456789
10 ..........................UUUUUUUU......
 9 ..........................UUUUUUUU......
 8 .................T.........YYYYYY.......
 7 ..............ZZZZZZ....................
 6 ........................................
 5 .@.........ZZ...........................
 4 ####Y...G..ZZ...........................
 3 #####.~~~~~~~....~~~~~..................
 2 #####................................l..
 1 #####mmmmmmmmmmmmmmmmmmmmmmmmmmmmmm#####
 0 ########################################
```
```props
~2 speed = -60
```

### c5_c01 — casting hall entrance
```
   0123456789012345678901234567890123456789
10 UUUUUUUUU......UUUUUUUUUU...UUUUUUUUUUUU
 9 UUUUUUUUU......UUUUUUUUUU...UUUUUUUUUUUU
 8 UUUUUU.U.........UUUUU......UUUUUUUUUUUU
 7 UUUU...............U..........UUUUU.....
 6 .........zz..Q.................U........
 5 ....l....zz.BZZZZZZZZZZZZZB..z......l.l.
 4 .........zz..ZZZZZZZZZZZZZ...z..........
 3 ......zz.zz..................z.ZZ.......
 2 ..@...zz.......................ZZ......T
 1 UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUY...U
 0 UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUY...U
```
```props
room checkpoint = true
Q rail = PackedVector2Array(0, 0, 192, 0)
Q period = 4.0
```

### c5_c02 — saw shaft
```
   01234567890123456789
21 UUUUUUUUUUUUUUUU...U
20 UUUUUU.....UUUUU...U
19 UUUUUU.....UUUUU...U
18 ...................U
17 ...................U
16 ...............l...U
15 .........Q.......@.U
14 ..UUUUU.........UUUU
13 ..UUUUU........QUUUU
12 ..UUU...........UUUU
11 ..UUU...........UUUU
10 ..U.........C...UUUU
 9 ...........UUU..UUUU
 8 ...........UUU..UUUU
 7 ....................
 6 ....................
 5 .................l..
 4 ....................
 3 ....................
 2 UUmmmmmmmmmmmmmmUUUU
 1 UUYYYYYYYYYYYYYYUUUU
 0 UUYYYYYYYYYYYYYYUUUU
```
```props
Q1 rail = PackedVector2Array(0, 0, 0, 80)
Q1 period = 3.0
Q2 rail = PackedVector2Array(0, 0, 0, 64)
Q2 period = 3.4
Q2 offset = 1.2
```

### c5_c03 — mould press hall
```
   0123456789012345678901234567890123456789
10 UUUUUUUUUUUUUUUUUUUUUUUUUUUUUU...UUUUUUU
 9 UUUUUUUUUUUUUUUUUUUUUUUUUUUUUU...UUUUUUU
 8 U.......P.....P.....................UUUU
 7 ....................................UUUU
 6 ........................*....*..........
 5 .....................................D..
 4 ...................................l...l
 3 ..@.....................................
 2 UUUU~~~~~~~~~~UUUUUYmmmmmmmmmmmmmmYU...U
 1 UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU...U
 0 UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU...U
```
```props
P reach = 5
P2 offset = 0.6
```

### c5_c04 — maintenance niche
```
   01234567890123456789
10 UUUUUUUUUUUUUUUU...U
 9 UUUUUUUUUUUUUUUU...U
 8 UUUU...............U
 7 UUUU................
 6 UUUU................
 5 UUUU...H!.l.....l@..
 4 UUUUUUUUUUUUUUUUUUUU
 3 UUUUUUUUUUUUUUUUUUUU
 2 UUUUUUUUUUUUUUUUUUUU
 1 UUUUUUUUUUUUUUUUUUUU
 0 UUUUUUUUUUUUUUUUUUUU
```
```props
! speaker_name = "Vesper (vysílačka)"
! portrait_texture = "res://assets/npc/vesper_portrait.png"
! dialogue_pages = Array[String](["Matěji? Konečně signál! Otis říkal, že máš cívku. Bez ní by ses přes licí haly nedostal.", "Pod slévárnou jsou krystalové doly, Rusty tam má tábor. Ale pozor: korporace pouští strusku stavidlem rovnou do šachty. Až uslyšíš sirénu, utíkej dolů."])
```

### c5_c05 — saw loop
```
   0123456789012345678901234567890123456789
10 UUUUUU........*........*....*..UUUU.UUUU
 9 UUUUUU...*.....................UUUU.UUUU
 8 UUUUUU..........Q...............U...UUUU
 7 ....................................UUUU
 6 ..................UUU.....K.............
 5 ..@...............UUU....UUU....l...l.LC
 4 UUUUmmmmmmmmmmmmmmUUUmmmmUUUmmmUU...UUUU
 3 UUUUYYYYYYYYYYYYYYUUUYYYYYYYYYYUU...UUUU
 2 UUUUYYYYYYYYYYYYYYUUUYYYYYYYYYYUU...UUUU
 1 UUUUYYYYYYYYYYYYYYUUUYYYYYYYYYYUU...UUUU
 0 UUUUYYYYYYYYYYYYYYUUUYYYYYYYYYYUU...UUUU
```
```props
Q rail = PackedVector2Array(0, 0, 96, 0, 96, 48, 0, 48)
Q loop = true
Q period = 6.0
```

### c5_c06 — cooling shaft
```
   01234567890123456789
21 UUUUUUUUUUUUU...UUUU
20 UUUUUUUUUUUUU...UUUU
19 UUUUU...........UUUU
18 ....................
17 ....................
16 ............l.@.....
15 .............UUUUUUU
14 .............UUUUUUU
13 ...V.V.......UUUUUUU
12 ..UUUUU......UUUUUUU
11 ..UUU...........UUUU
10 ..UUU...............
 9 ..UUU.......*.......
 8 .......*............
 7 ....................
 6 ..................l.
 5 ................UUUU
 4 ................UUUU
 3 ................UUUU
 2 UUmmmmmmmmmmmmmmUUUU
 1 UUYYYYYYYYYYYYYYUUUU
 0 UUYYYYYYYYYYYYYYUUUU
```
```props
V2 offset = 1.0
```

### c5_c07 — gantry over the abyss
```
   01234567890123456789
10 BBBBBBBBBBBBBBBBBB..
 9 ................C...
 8 ...........D........
 7 .....l..............
 6 ..@.............*...
 5 UUUUU...............
 4 UUUUU............l..
 3 UUUUU...............
 2 UUUUUBBBYmmmYBB.....
 1 UUUUU....BBB...UUUUU
 0 UUUUU..........UUUUU
```
```props
D patrol_distance = 16.0
```

### c5_d01 — sluice gallery
```
   0123456789012345678901234567890123456789
10 UUUUU......UUUUUUUU...UUUUUUUU..........
 9 UUUU.......UUUUUUUU...UUUUUUUU..........
 8 UUUU.........YYYY.......YYYY............
 7 UUU.....................................
 6 ....................................YYYY
 5 .........l..................T.......YYUU
 4 .............G......B.......B.l.....UUUU
 3 .........ZZZZZZZZZ..B.......B.......UUUU
 2 ..@..!...UUUUUUUUU..B...G...B.......UUUU
 1 UUUUUUUUUUUUUUUUUUUUUUUUUUUUUYY.....YYYY
 0 UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU.....UUUU
```
```props
room checkpoint = true
! speaker_name = "Hlas Korporace"
! dialogue_pages = Array[String](["Narušitel ve slévárně. Uzavřít licí haly. Připravit stavidlo."])
```


### c5_d02 — slag cascade
```
   01234567890123456789
21 UUUUUUUUUUU.....UUUU
20 UUUUUUUUUU......UUUU
19 UUUUUUUU.........UUU
18 ..................UU
17 ....................
16 .............@......
15 UUUUUUUUUUUUUUUUU...
14 ..YYYUUUUUUUUUUU....
13 ....................
12 ....................
11 .....mmmmmmmmmm.....
10 ...YYUUUUUUUUUUYYUUU
 9 ...UUUUUUUUUUUUUUUUU
 8 ....UUUUUUUUUUUUUUUU
 7 ...............UUUUU
 6 ....................
 5 ....................
 4 ....................
 3 ......mm....Q.......
 2 UUUUUYUUYUUUUUUUUUUU
 1 UUUUUUUUUUUUUUUUUUUU
 0 UUUUUUUUUUUUUUUUUUUU
```
```props
Q rail = PackedVector2Array(0, 0, 0, -48)
Q period = 2.6
```


### c5_d03 — valve hall
```
   0123456789012345678901234567890123456789
10 UUUU...............UUU..................
 9 UUUU...............UUU..................
 8 UUUU....Q...C.......Y..D................
 7 UUUU...BBBPBBBPBBB......................
 6 ........................*...............
 5 ...ZZZ..................................
 4 ........................................
 3 ..@...............mmmmmmmmmmmm..l.......
 2 UUUUUUUUUUUUUUUUYYUUUUUUUUUUUUYYUUUU...U
 1 UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU...U
 0 UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU...U
```
```props
C variant = 1
P reach = 4
P2 offset = 0.6
Q rail = PackedVector2Array(0, 0, 128, 0)
Q period = 3.2
```


### c5_d04 — smelter control booth
```
   01234567890123456789
10 UUUUUUUUUUUUUUUU...U
 9 UUUUUUUUUUUUU......U
 8 UUUUUUUU...........U
 7 UUUUUUUUUU.........U
 6 ..ZZZZZZZZZ.....@...
 5 ..Zqqlqqqq...ZZZZZZ.
 4 ..Zqqqoqqq..........
 3 ..Zqqqqqqq.......l..
 2 ..Zqqq!qHq..........
 1 UUUUUUUUUUUUUUUUUUUU
 0 UUUUUUUUUUUUUUUUUUUU
```
```props
! speaker_name = "Deník tavírny"
! dialogue_pages = Array[String](["Den 112. Krystaly ze Smallville se taví hůř. Prý jsou živé. Pece praskají.", "Vedení nařídilo pouštět strusku rovnou do šachty. Doly pod námi to prý vydrží."])
```


### c5_d05 — sluice controls
```
   01234567890123456789
10 UUUUUUUUUUUUU.......
 9 UUUUUUU.............
 8 UUU..............UUU
 7 U................UUU
 6 .........l.......UUU
 5 ........BB.......YUU
 4 ........UU.......YUU
 3 ......UUUU.......YUU
 2 ..@.!.UUUU.......YUU
 1 UUUUUUUUUU.......YUU
 0 UUUUUUUUUU.......YUU
```
```props
! speaker_name = "Siréna"
! dialogue_pages = Array[String](["STAVIDLO OTEVŘENO. Struska padá šachtou. Všem pracovníkům: opustit spodní patra!"])
```


### c5_d06 — the slag flood
```
   01234567890123456789
32 UUUUUUUUUU......uUUU
31 UUUUUUUUU........UUU
30 UUUUUUU..........UUU
29 UUUU..............UU
28 UUU...............UU
27 UUU..........@....UU
26 UUU.UUUUUUUUUUUUUUUU
25 ........UUUUUUUUUUUU
24 ................YYYY
23 ....................
22 ...........*........
21 ....................
20 ......^^^^^^^^^^....
19 UUUUUYUUUUUUUUUU...Y
18 UUUUUUUUUUUUUUUU...U
17 ..UU.....UUU........
16 ....................
15 ..........*.........
14 ....................
13 .....^^^^^^^^^^.....
12 Y....UUUUUUUUUUYUUUU
11 U....UUUUUUUUUUUUUUU
10 .................UU.
 9 ....................
 8 ...........*........
 7 ....................
 6 ......^^^^^^^^^^....
 5 UUUUUYUUUUUUUUUU...Y
 4 UUUUUUUUUUUUUUUU...U
 3 UUUUUUUUUUUUUUUU...U
 2 UUUUUUUUUUUUUUUU...U
 1 UUUUUUUUUUUUUUUU...U
 0 UUUUUUUUUUUUUUUU...U
```
```props
u rise_speed = 26.0
```


### c5_d07 — bottom of the foundry
```
   0123456789012345678901234567890123456789
10 UUUUUUUUUUUUUUUU...U...........UUUUUUUUU
 9 UUUUUUUUUUUUUYY................UUUUUUUUU
 8 UUUUYYYYUU..................l..FFFFUUUUU
 7 UUUU...........................FFcFUUUUU
 6 UUUU.......................UUUUUUUUUUUUU
 5 UUUU.............@.........UUUUUUUUUUUUU
 4 UUUUUUUUUUYYYYUUUUUU...ZZZZUUUU.........
 3 UUUUUUUUUUUUUUUUUUUU....................
 2 UUUUUUUUUUUUUUUUUUUU.x...........x.xlEl.
 1 UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU
 0 UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU
```
```props
E next_level = "res://levels/c6/chapter6.tscn"
E stage_title = "KAPITOLA 5: SLÉVÁRNA"
E stage_index = 5
E max_stage_crystals = 12
```
