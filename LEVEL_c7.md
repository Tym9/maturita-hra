# LEVEL c7 — The Mining Complex & Reactor (Těžební komplex a reaktor)

Behind the blast door at the bottom of the crystal mines (end of c6) lies the corp's **main mining complex**: security docks, the crystal processing plant, and under them the **reactor** that drives the drills into the planet's core. The core is failing: **gravity anomalies** leak through the whole complex. Fields of violet light where everything falls upward, turquoise walls that are only half there, machines that phase in and out on the beat of the pumps. Vesper has been inside for three days disguised as a maintenance technician; she meets the hero in person before the reactor. The chapter ends at the reactor door (→ `boss_room`, the Reactor Warden).

- **Kit:** everything: run, jump, double jump (DJ), wall climb/jump (8 s stamina), wrench, dash, hook (anchors `+` only where drawn), drill. The player has **two tool slots** and carries hook + coil here (the drill is a slot tool too): a room may need at most two of hook / coil / drill, never the wrench.
- **New here:** **gravity fields** `:` (a01–a03), **tesla arcs** `i` (a04), **anomaly walls** `n` (b02), **rhythm blocks** `[` `]` (b06), **dampener fields** `-` (c01), the **anomaly echo** `?` (c05–c06). Develops: spikes, belts, guards, turrets, drones, crawlers (on ceilings), dash shards, a few anchors and rock plugs.
- **Signature:** **falling upward.** Travel is ↓ and →. Ceiling walks over pits, field "lifts", flipping to stomp what crawls on the ceiling, dashing through walls that are not quite there.
- **Look:** a corp machine complex, not a cave. `B` brass (machinery, the reactor), `Z` iron (catwalks, braces, gantries), `&` brick (docks, gates, halls), `U` basalt (the raw shaft rock the complex is built into), `#` stone (rare); back walls `z` iron, `q` brick, `o` lit windows, `d` doors, `k` dark rock (sparingly). Decor `l` lanterns, `p` corp pylons, `g` corp banners, `a` antenna, `x` blight crystals (growing through the floors where the anomalies leak). Mostly air `.`: the backdrop (the great shaft's far wall) must show in every room.
- **Rules:** LEVEL_DESIGN §1–2, §5, ASCII format §6. Crystals: 12, route types never repeat back to back.

## Open rooms — not boxes (read first)

Same as c5/c6. A room edge with **no neighbouring room** is an invisible wall (left, right, top). Only falling out the **bottom** where no room continues kills.

- **Rooms are catwalks, gantries, machine blocks and rock shelves in the big shaft, with open air around them.** No solid frame around a room: never a full-height side wall just to close it. Draw terrain as masses: machine housings, hanging gantries, pillars, a lone ledge. At least a third of every room is open air. (Exception to "no solid top row": a **ceiling above a gravity field is required**, see below; make it a hanging gantry or machine underside, only as wide as it needs to be.)
- **Down-exits (the main way between rooms):** a gap ≥3 tiles wide in the bottom row (air above it) over the room below. The room below has the **same columns open in its top row** and, right under the gap, a safe landing ledge with `@` at most ~6 tiles below its top (no hazard, no enemy, no field in the landing zone). Everywhere else the two rooms' shared edge is closed with terrain **in the upper room's bottom row**.
- **Side exits:** where two rooms share a side edge, the terrain on both sides matches exactly (same floor height, same solid rows), ≥3 tiles open, floors flush (no lip or crate at the edge).
- **Pits:** a bottom-row gap with **no room below** = bottomless pit (death). Allowed as stakes, never under a respawn.
- **Respawns:** every entrance gets a ≥3-tile safe ledge with `@`, right at the entrance (side) or under the drop (top). The player always respawns with **normal gravity**.
- **No backtracking up:** never require climbing back up through a down-exit; every room must be finishable from each of its `@`.
- **Secrets must be invisible:** fill the whole pocket with `F` and put its crystal as `c`; keep a solid tile between the pocket and the room edge. Hint only by geometry.
- Other crystals are visible from the main path. Key cages: one key opens one `L` block.

## Element rules

- **Gravity field `:`** (new): a rectangle of violet light. **Inside it gravity points up**: the player falls to the ceiling, walks and jumps on it upside down (a jump goes downward), and falls back down the moment they leave the field. The flip happens as soon as any part of the player touches the field, and halves the vertical speed.
  - Draw the field as a **filled rectangle of `:`**. Other symbols may sit inside it (crystals, spikes, anchors, platforms); the builder and the checker use the **bounding rectangle of each connected group** of `:` (diagonals connect), so keep each field a clean rectangle and keep two fields ≥1 air tile apart.
  - **A field needs a ceiling**: solid tiles (or `v` spikes on solid) along the whole top of the field, directly above its top row. Never let a field reach a room's top edge or an open sky.
  - The player is 18 px tall: an upside-down walkway needs ≥2 free tiles under the ceiling.
  - Keep fields **≥2 tiles away from every exit opening and every `@`**: every room edge is crossed in normal gravity.
  - **Lift:** a field column from a floor up to a ceiling carries the player up; walk off the field's side onto a ledge whose top is ≥2 tiles below the ceiling. **Ceiling walk:** a wide field under a ceiling crosses a pit. **Cushion:** falling into the top of a field from above is not possible (it has a ceiling); falling into its side flips you up.
  - Leaving a field at the ceiling you start falling: you have your double jump and dash (they refill on the ceiling like on a floor).
  - **Teach (a01):** the first field spans a **safe pit** (floor ~4 tiles below, steps back up on the near side, the far wall overhangs so it cannot be climbed). The gap must be too wide for jump + DJ + dash (≥ 20 tiles). a02 adds stakes (spikes).
  - Ceiling spikes `v` threaten the upside-down walker; floor spikes `^` under a field are only stakes for falling out.
- **Tesla arc `i`** (a04+): a straight run of **3–6 `i`** (horizontal or vertical): a coil at each end, a deadly beam between them, on for 1 s in every 2 s (0.4 s warning). `i2 offset = 1.0` shifts the second arc by half a cycle, `i period = 2.4` slows all. The checker ignores them: there must be a safe place to wait (≥2 tiles of floor or ceiling walkway) **before and after** each arc; never across a 1-tile landing, never within 3 tiles of an exit or `@`. The first one (a04) crosses a corridor over a safe floor.
- **Anomaly wall `n`** (b02+): a turquoise starfield block, **solid** to walk and climb on. **Dash into it and you fly straight through** in the dash direction (no gravity, no control) and come out with the **dash and double jump refilled**. If the way out is blocked by anything solid, you die.
  - Draw **filled rectangles** of `n`, 2–4 tiles thick along the dash direction. Behind the wall (along the line of flight) leave ≥3 tiles of free air. Horizontal, vertical and diagonal dashes all work; you can dash **down** through a floor of `n` (jump first) or **up** through a ceiling of `n`.
  - Uses: a plug that closes a passage (must dash through), a floating block chain over a pit (each exit refills the dash), a floor you dash down through.
  - First one (b02) plugs a corridor over a safe floor.
- **Rhythm blocks `[` (set A) and `]` (set B)** (b06+): platforms that are solid only half the time: A in the first second of every 2 s, B in the second (they blink 0.4 s before switching, and never solidify around the player). Draw each block as a run 2–3 tiles wide, 1 tall (`[[[` or `]]`), alternating A, B, A, B along the path, with **1–3 tiles of air between neighbours** and air above them. Platforms only: never as a wall, a door or a ceiling over a walkway. The checker treats them as always solid, so keep every hop easy (≤3 tiles across, ≤2 up). First ones (b06) over a safe floor.
- **Dampener field `-`** (c01+): a grey rectangle (filled with `-`, bounding rectangle of the group like `:`). **Inside it the dash and the hook do not work.** Jumps, double jump and wall climbing still do, and gravity fields still flip. The checker respects it. Do not let a dampener's rectangle overlap a gravity field's rectangle (put them side by side). Never over an `@`.
- **Anomaly echo `?`** (c05, c06 only): place `?` so that the 3-wide × 8-tall rectangle whose **top-left cell is the `?`** contains the room's entrance `@`. When the player leaves that rectangle, a shadow starts replaying their exact path 1.5 s later; touching it kills. In echo rooms the path must **flow forward**: no waiting (no tesla arcs, no rhythm blocks, no crystal spikes), no doubling back along the same line, no dead ends on the main path. The checker ignores the echo.
- **Cave crawler `e`** on ceilings: start it on the floor cell (air with solid below) of a **free-standing block** (≥3 tiles around, air on all sides) that hangs in or next to a gravity field: it circles the block, and upside down the player can stomp it "from below". Checker ignores it: leave room to time a pass.
- **Dash:** 8 directions, ~5 tiles, recharges on the ground (or ceiling in a field), on a spring, a dash shard `*`, a hook latch, or leaving an anomaly wall. Winged crystals (`C variant = 1`) fly away if the player dashes anywhere in the room: their route must work with `--nodash`.
- **Anchors `+`**, **rock plugs `r`** (c6 rules, `LEVEL_c6.md`): allowed sparingly as old friends (at most one room per section).
- **Spikes `^ v < >`**, **conveyor `~`**, **grate `=`** (2-tile pieces), **spring `S`**, **turret `T`** (stand it on a floor, give cover on the approach), **drone `D`** (hovers, charges straight, stuns on walls), **guard `G`** (patrols a floor, turns at walls and ledges), **shard `*`** as before.

## Dialogue (place via props, text verbatim)

- **a01** `!` speaker_name `"Výstražná tabule"`, dialogue_pages `Array[String](["POZOR: GRAVITAČNÍ ANOMÁLIE. Ve fialovém poli padáš vzhůru. Po stropě se dá chodit.", "Jakmile z pole vystoupíš, padáš zase dolů. Korporace za úrazy neručí."])`
- **a07** `!` speaker_name `"Deník strážného"`, dialogue_pages `Array[String](["Třetí směna hlásí, že v docích padá nářadí ke stropu. Velení odpovědělo: pokračujte v těžbě.", "Cívky mezi sloupy jiskří v pravidelném rytmu. Kdo počká na ticho, projde."])`
- **b01** `!` speaker_name `"Hlas Korporace"`, dialogue_pages `Array[String](["Úpravna krystalů. Anomální stěny jsou majetkem Korporace.", "Průchod skrz ně je zakázán. A samozřejmě nemožný."])`
- **b02** `!` speaker_name `"Poznámka technika"`, dialogue_pages `Array[String](["Ta tyrkysová stěna není tak docela tady. Když do ní vletíš cívkou, proletíš rovně skrz.", "Venku se ti cívka nabije znovu. Jen ať je na druhé straně volno, jinak v ní zůstaneš."])`
- **b04** `!` speaker_name `"Deník technika"`, dialogue_pages `Array[String](["Bloky v hale 6 se přepínají v rytmu čerpadel. Oranžové, modré, oranžové. Kdo neumí počítat, spadne.", "Lezci se naučili chodit po stropech. V poli na ně jde skočit shora. Tedy zdola. Však víš."])`
- **c01** `!` speaker_name `"Hlas Korporace"`, dialogue_pages `Array[String](["Předpolí reaktoru. Tlumicí pole aktivní.", "Cívky a háky jsou v šedé zóně mimo provoz. Děkujeme za pochopení."])`
- **c04** `7` (Vesper) `dialogue_pages = Array[String](["Matěji! Tak jsi to dokázal až sem. Jsem tu tři dny jako technik údržby.", "Reaktor je přímo pod námi. Jádro už se neudrží, anomálie se šíří celým komplexem.", "Dál tě bude pronásledovat tvoje vlastní ozvěna. Stín z anomálie, opakuje každý tvůj krok. Nezastavuj se a nevracej se.", "Dole u reaktoru hlídá Strážce. Sabotážní ventil je za ním. Hodně štěstí."])`, `repeat_dialogue_pages = Array[String](["Ozvěna jde po tvých stopách. Nezastavuj se."])`
- **d01** `!` speaker_name `"Hlas Korporace"`, dialogue_pages `Array[String](["Narušitel v jádru komplexu. Strážce reaktoru aktivován. Všechny jednotky k šachtě reaktoru."])`
- **d04** `!` speaker_name `"Protokol reaktoru"`, dialogue_pages `Array[String](["Stabilita jádra 12 %. Doporučení inženýrů: okamžitě zastavit těžbu.", "Rozhodnutí vedení: těžbu zdvojnásobit."])`
- **d05** `!` speaker_name `"Šachta reaktoru"`, dialogue_pages `Array[String](["Pod tebou hučí reaktor. Gravitace se tu láme každým metrem. Dolů!"])`
- **d07** `E` next_level `"res://boss_room.tscn"`, stage_title `"KAPITOLA 7: TĚŽEBNÍ KOMPLEX"`, stage_index `7`, max_stage_crystals `12`
- **a01, b01, c01, d01**: `room checkpoint = true`

## Layout

Fixed positions (screens, top-left; y grows downward). Don't move or resize rooms. Rooms touch only their neighbours in the chain (plus the b05b branch).

```layout
chapter res://levels/c7/chapter7.tscn
start_items wrench gravity_coil grapple_hook drill
kit dash hook drill
c7_a01 0 0
c7_a02 2 0
c7_a03 2 1
c7_a04 3 2
c7_a05 4 3
c7_a06 5 4
c7_a07 5 5
c7_b01 6 5
c7_b02 7 6
c7_b03 8 7
c7_b04 9 8
c7_b05 10 8
c7_b05b 11 8
c7_b06 10 10
c7_c01 12 10
c7_c02 13 11
c7_c03 14 12
c7_c04 15 13
c7_c05 16 13
c7_c06 17 14
c7_c07 18 15
c7_d01 19 15
c7_d02 20 16
c7_d03 21 17
c7_d04 22 18
c7_d05 23 18
c7_d06 23 19
c7_d07 23 22
```

## Rooms

Fixed section boundaries: **a07 → b01**, **b06 → c01** and **c07 → d01** are right-edge crossings with the floor at **h2** (rows 0–1 solid on both sides of the edge), rows 2–6 open on both sides; rows 7+ free. All other connections are agreed inside a section. "top" = you arrive by falling in through the top edge; "bottom" = you leave by dropping through the bottom edge. A 2×1 room's "right screen" = columns 20–39; a 1×2 room's "bottom screen" = rows labelled 10…0.

| id | size | from → to | challenge | elements | diff | crystal | CP |
|---|---|---|---|---|---|---|---|
| c7_a01 | 2×1 | start (L) → a02 (R, floor h4) | The security docks: the blast door from the mines in a brick-and-iron wall on the left (`d`, `q`), the warning board `!`. Past it the dock floor is gone: the **first gravity field** under a hanging iron gantry spans a **safe pit** (floor ~4 tiles below, steps back up on the near side, far wall overhanging), gap ≥ 20 tiles: walk across on the gantry's underside. | **gravity field**, `!` | 1 | — | ✔ |
| c7_a02 | 1×1 | a01 (L, floor h4) → a03 (bottom, columns 15–17) | The same with stakes: a ceiling walk in a field over a spike bed; a hanging machine block splits the ceiling, so you hop (downward) from one stretch of ceiling to the next. | field, spikes | 2 | **Skill detour**: crystal low over the spikes under the field's far edge: drop out of the field, grab it, dash back up into the field. | — |
| c7_a03 | 1×2 | a02 (top, columns 15–17) → a04 (R, bottom screen, floor h5) | The cargo lift shaft, open air: **field lifts**. Landings zig-zag down; twice the way on is a ledge above you, reached by stepping into a field column and walking off its side. A guard on one landing. | field lifts, guard | 2 | — | — |
| c7_a04 | 2×1 | a03 (L, floor h5) → a05 (bottom, right screen, columns 31–33) | The coil gallery: **tesla arcs** intro. First arc across the corridor over a safe floor (watch, wait, pass), then one over a gap, then a vertical one beside a field lift. A turret at the far end behind cover. | **tesla arcs**, field, turret | 2 | **Secret passage**: hidden pocket (`F` + `c`) in the machine block above the exit, hinted by a dead-end shelf a small field lifts you to. | — |
| c7_a05 | 1×2 | a04 (top, columns 11–13) → a06 (R, bottom screen, floor h3) | The loading crevice: shelves with fields over them and **ceiling spikes** in the fields: ride up beside the teeth, slip sideways along the clean ceiling, drop to the next shelf. A drone in the open part. | fields, ceiling spikes, drone | 3 | — | — |
| c7_a06 | 1×1 | a05 (L, floor h3) → a07 (bottom, columns 15–17) | A field over a spike pit under a low machine ceiling. A **winged** crystal on a high ledge: reach it by riding a field, without dashing. | field, spikes, winged crystal | 2 | **Winged**: reachable from the entrance with `--nodash`. | — |
| c7_a07 | 1×1 | a06 (top, columns 15–17) → b01 (R, h2 fixed) | Breather: a guard post (an iron booth with air around it), health pack, `!` Deník strážného. | `!`, `H` | 1 | — | — |
| c7_b01 | 2×1 | a07 (L, h2 fixed) → b02 (bottom, right screen) | The processing plant: loudspeaker `!`, conveyor belts carrying crystal ore, a guard on the belt line, a turret on a gantry; a field under the gantry lets you pass above the guard, in the turret's sight. | belts, guard, turret, field, `!` | 2 | — | ✔ |
| c7_b02 | 1×2 | b01 (top) → b03 (R, bottom screen) | **Anomaly walls** intro: `!` Poznámka technika, then a turquoise plug closing a corridor over a safe floor (dash through), then a floor of it you dash **down** through to the lower level. | **anomaly walls**, `!` | 2 | **Key/backtrack**: key on a ledge behind a second wall off the path, caged crystal (`L`) near the exit. | — |
| c7_b03 | 2×1 | b02 (L) → b04 (bottom, right screen) | Floating anomaly blocks over a long spike channel: dash block to block, each exit gives the dash back. | anomaly walls, spikes | 3 | **Mechanic trick**: dash diagonally up through a block to a crystal above the channel. | — |
| c7_b04 | 1×1 | b03 (top) → b05 (R) | Breather: a technician's booth (iron lean-to with air around it), health pack, `!` Deník technika. | `!`, `H` | 1 | — | — |
| c7_b05 | 1×2 | b04 (L, top screen) → b06 (bottom); branch R (top screen) ↔ b05b | The sorting hall: hanging machine blocks with **crawlers** circling them, fields beside them so you can walk the ceiling and stomp them upside down; a drone in the drop. | fields, crawlers, drone, spikes | 3 | **Secret passage**: hidden niche in a block's base (`F` + `c`). | — |
| c7_b05b | 1×1 | b05 (its R edge, top screen) ↔ b05 | Side gauntlet: a chain of anomaly blocks over a spike bed with a ceiling-walk field in the middle (ceiling spikes), crystal at the far right; return the same way. Right and top edges have no room, bottom edge = spikes. | anomaly walls, field, spikes | 4 | **Side gauntlet** | — |
| c7_b06 | 2×1 | b05 (top, left screen) → c01 (R, h2 fixed) | The pump hall: **rhythm blocks** intro. First three over a safe floor (a raised path to a ledge), then a line of them over a spike channel; a turret behind cover at the far end. | **rhythm blocks**, spikes, turret | 3 | — | — |
| c7_c01 | 2×1 | b06 (L, h2 fixed) → c02 (bottom, right screen) | The reactor approach: loudspeaker `!`, then the first **dampener field** over a gap that a dash would clear: inside it you only have your jumps (stepping blocks in the gap). Then a second dampener beside a gravity field: the ceiling walk replaces the dash. | **dampener**, field, `!` | 2 | — | ✔ |
| c7_c02 | 1×2 | c01 (top) → c03 (R, bottom screen) | The pump shaft: rhythm blocks as steps between ledges, a field lift, a guard-free descent. | rhythm blocks, field, spikes | 3 | **Key/backtrack**: key in a niche behind an anomaly plug, caged crystal near the exit. | — |
| c7_c03 | 2×1 | c02 (L) → c04 (bottom, right screen) | The arc hall: a long ceiling walk in a field with tesla arcs across it (wait upside down), a drone below. | field, tesla arcs, drone, spikes | 3 | — | — |
| c7_c04 | 1×1 | c03 (top) → c05 (R) | Breather: a maintenance niche, Vesper in person (`7`), health pack. | `7`, `H` | 1 | — | — |
| c7_c05 | 2×1 | c04 (L) → c06 (bottom, right screen) | **Echo chase 1**: `?` at the entrance. A flowing run: floor, a field ceiling walk over spikes, an anomaly plug, a drop to the exit. Nothing to wait for. | **echo**, field, anomaly wall, spikes | 3 | **Skill detour**: crystal on a higher line through the room (taken on the run, rejoining the path forward, never back). | — |
| c7_c06 | 1×2 | c05 (top) → c07 (R, bottom screen) | **Echo chase 2**: `?` at the landing. A zig-zag descent that never doubles back on itself: ledges, a field toss, a dash through an anomaly floor, a shard. | echo, field, anomaly wall, shard | 4 | — | — |
| c7_c07 | 1×1 | c06 (L) → d01 (R, h2 fixed) | Gantry over the reactor shaft: a drone over the gantry, a field under its roof, an anomaly block in the roof. | drone, field, anomaly wall | 3 | **Mechanic trick**: ride the field up under the gantry roof and dash up through the anomaly block to the crystal on top. | — |
| c7_d01 | 2×1 | c07 (L, h2 fixed) → d02 (bottom, right screen) | The core gate gallery: alarm `!`, two guards on the gallery floor, a turret on a buttress (cover); a field under the gallery roof as the high road, in the turret's sight. | guards ×2, turret, field, `!` | 3 | — | ✔ |
| c7_d02 | 1×2 | d01 (top) → d03 (R, bottom screen) | The field cascade: stepped shelves, each with a field that tosses you up to the next ceiling; ceiling spikes, a tesla arc, a crawler on a hanging block. | fields, ceiling spikes, tesla, crawler | 3 | — | — |
| c7_d03 | 2×1 | d02 (L) → d04 (bottom, right screen) | The coolant hall: everything combined over a spike channel: a ceiling walk, anomaly blocks, two rhythm blocks, a dampener, a crawler. | field, anomaly walls, rhythm blocks, dampener, crawler, spikes | 4 | **Winged**: reachable with `--nodash` from the entrance. | — |
| c7_d04 | 1×1 | d03 (top) → d05 (R) | Breather: the reactor control booth, health pack, `!` Protokol reaktoru. | `!`, `H` | 1 | — | — |
| c7_d05 | 1×1 | d04 (L) → d06 (bottom) | The rim of the reactor shaft: `!` Šachta reaktoru as you enter; a short drop to a wide hole over the shaft. | `!` | 1 | — | — |
| c7_d06 | 1×3 | d05 (top) → d07 (bottom) | **Finale: the reactor shaft**: a 3-screen descent — fields that throw you sideways onto the next ledge, tesla arcs across the shaft (with a ledge to wait on before each), anomaly floors you dash down through, a pair of rhythm blocks, a few spikes. Keep it flowing and readable. | fields, tesla arcs, anomaly walls, rhythm blocks, spikes | 4 | — | — |
| c7_d07 | 2×1 | d06 (top, left screen) → `E` (right end) | The reactor antechamber: quiet; the great brass reactor door in a brick-and-brass wall, `E` at the door on the right. | — | 1 | **Secret passage**: pocket in the machine block left of the door (`F` + `c`). | — |

Crystal route order: skill (a02) → secret (a04) → winged (a06) → key (b02) → trick (b03) → secret (b05) → gauntlet (b05b) → key (c02) → skill (c05) → trick (c07) → winged (d03) → secret (d07).
Enemies: guards a03, b01, d01 = 3; turrets a04, b01, b06, d01 = 4; drones a05, b05, c03, c07 = 4; crawlers b05 ×2, d02, d03 = 4 → 15 (+ the echo in c05, c06).
Travel: ↓ and →; the chapter descends 23 screens to the reactor door.

## Rooms (ASCII)

### c7_a01 — the security docks
```
   0123456789012345678901234567890123456789
10 &&&&.....ZZZZZZZZZZZZZZZZZZZZZZZZZ......
 9 &&&&.....Z:::::::::::::::::::...........
 8 Zqqqqqq...:::::::::::::::::::...........
 7 qddqqqq...:::::::::::::::::::ZZZZZZZ....
 6 qddq@q!...:::::::::::::::::::ZZZZZZZ....
 5 &&&&&&&...:::::::::::::::::::...BBBB....
 4 &&&&&&&...:::::::::::::::::::...BBBB.l..
 3 &&&&&&&&&.:::::::::::::::::::...BBBB&&&&
 2 &&&&&&&&&.......................BBBB&&&&
 1 &&&&&&&&&&&.....x.......x.......BBBB&&&&
 0 &&&&&&&&&&&BBBBBBBBBBBBBBBBBBBBBBBBB&&&&
```
```props
room checkpoint = true
! speaker_name = "Výstražná tabule"
! dialogue_pages = Array[String](["POZOR: GRAVITAČNÍ ANOMÁLIE. Ve fialovém poli padáš vzhůru. Po stropě se dá chodit.", "Jakmile z pole vystoupíš, padáš zase dolů. Korporace za úrazy neručí."])
```

### c7_a02 — the spike bed
```
   01234567890123456789
10 ..ZZZZZZZZZZ........
 9 ..ZZZZZZZZZZ........
 8 ..ZZZZZZZZZZ........
 7 ..ZZZZZZZZZZ........
 6 ....::BBBBBB........
 5 ....::BBBBBB.C......
 4 .@..::BBBBBB........
 3 &&&.::::::::......l.
 2 &&&...............BB
 1 &&&^^^^^^^^^BBB...BB
 0 &&&BBBBBBBBBBBB...BB
```
```props

```

### c7_a03 — the cargo lift shaft
```
   01234567890123456789
21 ....................
20 ....................
19 ...........B........
18 .....l..G..B....@...
17 Z...ZZZZZZZZZZZZZZZZ
16 Z...ZZZZZZZZZZZZZZZZ
15 .....::::::::::.....
14 .....::::::::::l....
13 .....:::::::<BBBB...
12 .....:::::::<BBBB...
11 .....:::::::<BBBB...
10 .....:::::::<BBBB...
 9 .....:::::::<BBBB...
 8 .....:::::::<BBBB...
 7 .....:::::::<BBBB...
 6 .....:::::::<BBBB...
 5 .....:::::::<BBBB.l.
 4 .....:::::::<BBBBBBB
 3 BBBBB.......<BBBBBBB
 2 BBBBB...x.x.<BBBBBBB
 1 BBBBBBBBBBBBBBBBBBBB
 0 BBBBBBBBBBBBBBBBBBBB
```
```props
```

### c7_a04 — the coil gallery
```
   0123456789012345678901234567890123456789
10 ...ZZZZZZZZZZZZZZZZZZZZZZZZZBBBBBBBBZZZZ
 9 ...ZZZZZZZZZZZZZZZZZZZZZZZZZBBBFcFBBZZZZ
 8 ........i.............i.....BBBFFFBBZZZZ
 7 ........i......iii....i...........::....
 6 ........i.............i...Z.......::..T.
 5 ..@.....i..l.......l..i...Z..l....::ZZZZ
 4 BBBBBBBBBBBBBB.....BBBBBBBBBBBB...BBBBBB
 3 BBBBBBBBBBBBBB.....BBBBBBBBBBBB...BBBBBB
 2 BBBBBBBBBBBBBB.....BBBBBBBBBBBB...BBBBBB
 1 BBBBBBBBBBBBBB.....BBBBBBBBBBBB...BBBBBB
 0 BBBBBBBBBBBBBB.....BBBBBBBBBBBB...BBBBBB
```
```props

```

### c7_a05 — the loading crevice
```
   01234567890123456789
21 ....................
20 ....................
19 ....................
18 ....................
17 ............@..l....
16 ....ZZZZZZZZZZZZZZ..
15 ....ZZZZZZZZZZZZZZ..
14 .....vvvvv::::::::..
13 .....:::::::::::::..
12 .....::::::::<BBB:..
11 .....::::::::<BBB:..
10 .............<BBB...
 9 ..l..........<BBB...
 8 BBBBBBBBBBBBBB......
 7 BBBBBBBBBBBBBB......
 6 ........vvv:::......
 5 ........::::::......
 4 ..........D.........
 3 ..................l.
 2 ........BBBBBBBBBBBB
 1 ........BBBBBBBBBBBB
 0 ........BBBBBBBBBBBB
```
```props
D patrol_distance = 24.0
```

### c7_a06 — the spike pit
```
   01234567890123456789
10 ....ZZZZZZZZZ.......
 9 ....ZZZZZZZZZ.......
 8 ......::::::........
 7 ....C.::::::........
 6 ...BBB::::::........
 5 ...BBB::::::........
 4 ......::::::........
 3 ..@...::::::......l.
 2 BBBBB........l....BB
 1 BBBBB^^^^^^^BBB...BB
 0 BBBBBBBBBBBBBBB...BB
```
```props
C variant = 1
```

### c7_a07 — the guard post
```
   01234567890123456789
10 ....................
 9 ....................
 8 ....................
 7 ....................
 6 .............l.@....
 5 ...ZZZZZZZ..BBBBBB..
 4 ...ZzzzzzZ..BBBBBB..
 3 ...Zzzzzz...BBBBBB..
 2 ...ZzHz!z...BBBBBBl.
 1 &&&&&&&&&&&&&&&&&&&&
 0 &&&&&&&&&&&&&&&&&&&&
```
```props
! speaker_name = "Deník strážného"
! dialogue_pages = Array[String](["Třetí směna hlásí, že v docích padá nářadí ke stropu. Velení odpovědělo: pokračujte v těžbu.", "Cívky mezi sloupy jiskří v pravidelném rytmu. Kdo počká na ticho, projde."])
```

### c7_b01 — the processing plant
```
   0123456789012345678901234567890123456789
10 .BBBBB.........Z......................ZZ
 9 .BBBBB....ZZZZZZZZZZZ.................ZZ
 8 .BBBBB....ZZZZZZZZZZZ.................ZZ
 7 ...Z......::::::::::..................ZZ
 6 ..........::::::::::..............lT..ZZ
 5 ........l.::::::::::..............BBBBBB
 4 ..........::::::::::.........l....BBBBBB
 3 .........................ZZ.......BBBBBB
 2 ..@...!..................ZZ.......BBBBBB
 1 &&&&&&&&&&....G.....&&&~~~~~~&....BBBBBB
 0 &&&&&&&&&&~~~~~~~~~~&&&&&&&&&&....BBBBBB
```
```props
room checkpoint = true
! speaker_name = "Hlas Korporace"
! dialogue_pages = Array[String](["Úpravna krystalů. Anomální stěny jsou majetkem Korporace.", "Průchod skrz ně je zakázán. A samozřejmě nemožný."])
```

### c7_b02 — anomaly walls
```
   01234567890123456789
21 ....................
20 ZZZZZZZZ......ZZZZZZ
19 ZZZZZZZZ......ZZZZZZ
18 ZZZZZZZZ....l.ZZZZZZ
17 .....nnn......nnn...
16 .....nnn.!.@..nnn.K.
15 .....ZZZZZZZZZZZZZZZ
14 .....ZZZ.BBBBBB..ZZ.
13 .....Z....BBBB...Z..
12 .....Z.........B....
11 ...........l........
10 nnnnnnnnnnZZZZZZZZZZ
 9 nnnnnnnnnnZZZZZBBZZZ
 8 nnnnnnnnnnZZZZZBBZZZ
 7 nnnnnnnnnnZZZZZZZZZZ
 6 ..........ZZZZZZZZZZ
 5 ..........ZZZZZCZZZZ
 4 ...............L..l.
 3 ....................
 2 ....................
 1 &&&&&&&&&&&&&&&&&&&&
 0 &&&&&&&&&&&&&&&&&&&&
```
```props
! speaker_name = "Poznámka technika"
! dialogue_pages = Array[String](["Ta tyrkysová stěna není tak docela tady. Když do ní vletíš cívkou, proletíš rovně skrz.", "Venku se ti cívka nabije znovu. Jen ať je na druhé straně volno, jinak v ní zůstaneš."])
```

### c7_b03 — the floating blocks
```
   0123456789012345678901234567890123456789
10 ZZZZZZZZZZ..............ZZZZZZZZZZZ.....
 9 ZZZ............C........ZZZZZZZZZZZ.....
 8 ZZZ..........................Z..........
 7 ZZZ.........nnn.........................
 6 ZZZ.........nnn.........................
 5 ZZZ............nnn.........nnn..........
 4 ....l....nnn...nnn...nnn...nnn...l......
 3 .........nnn.........nnn................
 2 ..@.....................................
 1 &&&&&&^^^^^^^^^^^^^^^^^^^^^^^^^&&&&....&
 0 &&&&&&UUUUUUUUUUUUUUUUUUUUUUUUU&&&&....&
```
```props
```

### c7_b04 — the technician's booth
```
   01234567890123456789
10 ....................
 9 ....................
 8 ....................
 7 .ZZZZZZZ............
 6 .Z..l...Z.....@.....
 5 .Z.........ZZZZZZZ..
 4 .Z.........Z.....Zl.
 3 .Z.H.!.....Z.....Z..
 2 &&&&&&&&&&&&&&&&&&&&
 1 &&&&&&&&&&&&&&&&&&&&
 0 &&&&&&&&&&&&&&&&&&&&
```
```props
! speaker_name = "Deník technika"
! dialogue_pages = Array[String](["Bloky v hale 6 se přepínají v rytmu čerpadel. Oranžové, modré, oranžové. Kdo neumí počítat, spadne.", "Lezci se naučili chodit po stropech. V poli na ně jde skočit shora. Tedy zdola. Však víš."])
```

### c7_b05 — the sorting hall
```
   01234567890123456789
21 .........Z..........
20 .........Z..........
19 ....ZZZZZZZZZZZ.....
18 ....ZZZZZZZZZZZ.....
17 ..............D.....
16 ....................
15 ....................
14 ..@.........l....l..
13 &&&&&&&&&&&&.....&&&
12 &&&&&&&&&&&&.....FF&
11 &&&.Z............Fc&
10 ....Z..........ZZ&&&
 9 ....BBBBBBBB........
 8 ....BBBBBBBB........
 7 .....:::::::........
 6 .....:::::::........
 5 .....:e:::e:&&&&&&&&
 4 .....:BB:BB:&&&&&&&&
 3 .....:BB:BB:&&&&&&&&
 2 .....:::::::&&&&&&&&
 1 .......^^^^^&&&&&&&&
 0 ...UUUUUUUUU&&&&&&&&
```
```props
D patrol_distance = 24.0
```

### c7_b05b — the anomaly gauntlet
```
   01234567890123456789
10 .........Z..........
 9 .........Z..........
 8 ........BBBB........
 7 ........BBBB........
 6 ........::v:........
 5 ....nnn.::::.nnn..C.
 4 ....nnn.::::.nnn.&&&
 3 .@.lnnn.::::.nnn.&&&
 2 &&&..............&&&
 1 &&&^^^^^^^^^^^^^^&&&
 0 &&&UUUUUUUUUUUUUU&&&
```
```props
```

### c7_b06 — the pump hall
```
   0123456789012345678901234567890123456789
10 ........ZZZZZZZZZZZZZZZZZZZZZZZZZ.......
 9 ............BB..........BB..............
 8 ............BB..........BB..............
 7 .................ZZZZ...................
 6 ....l.........[[.ZZZZ.]]]...............
 5 .@.........]]....ZZZZ.....[[[...........
 4 &&&&&&.[[[.......ZZZZ.........]].l.ZZ...
 3 &&&&&&...........ZZZZ..............ZZ...
 2 &&&&&&...........ZZZZ..............ZZ.T.
 1 &&&&&&&&&&&&&&&&&&&&&&^^^^^^^^^^&&&&&&&&
 0 &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&
```
```props
```

### c7_c01 — the reactor approach
```
   0123456789012345678901234567890123456789
10 &&&&&&&...............ZZZZZZZZZZZZ......
 9 &&&&&&&......---------ZZZZZZZZZZZZ......
 8 ..&---------.---------::::::::::........
 7 ...---------.---------::::::::::........
 6 ...---------.---------::::::::::........
 5 ...---------.---------::::::::::........
 4 ...---------.---------::::::::::........
 3 ...---------.ZZZ......::::::::::........
 2 .@!----ZZZ--.ZZZ...................l...l
 1 ZZZZZ........ZZZ^^^^^^^^^^^^^^^^ZZZZ...Z
 0 ZZZZZ........ZZZUUUUUUUUUUUUUUUUZZZZ...Z
```
```props
room checkpoint = true
! speaker_name = "Hlas Korporace"
! dialogue_pages = Array[String](["Předpolí reaktoru. Tlumicí pole aktivní.", "Cívky a háky jsou v šedé zóně mimo provoz. Děkujeme za pochopení."])
```

### c7_c02 — the pump shaft
```
   01234567890123456789
21 &&&&&...............
20 &&&&&...............
19 &&&&&...............
18 &&&&&...............
17 ..&&................
16 ..&&.............@.l
15 ............ZZZZZZZZ
14 ........]]].ZZZZZZZZ
13 ....................
12 ....................
11 ZZZZZZZ.............
10 Z....ZZ....ZZZZZZ...
 9 Z....ZZ....ZZZZZZ...
 8 Z.K..ZZ.[[[.:::.....
 7 ZnnnZZZ.....:::..l..
 6 ZnnnZZZ.....:::ZZZLZ
 5 ZnnnZZZ.....:::ZZZCZ
 4 ............:::ZZZZZ
 3 ............:::ZZZZZ
 2 ....^^^.....:::ZZZZZ
 1 ZZZZZZZZZZZZZZZZZZZZ
 0 ZZZZZZZZZZZZZZZZZZZZ
```
```props

```

### c7_c03 — the arc hall
```
   0123456789012345678901234567890123456789
10 ....ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ......
 9 ....ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ......
 8 ......:::::::i::::::i::::::i:::.........
 7 ..@.l.:::::::i::::::i::::::i:::.........
 6 ZZZZZZ:::::::i::::::i::::::i:::.........
 5 ZZZZZZ:::::::i::::::i::::::i:::.........
 4 ZZZZZZ::::::::::::D::::::::::::.........
 3 ZZZZZZ:::::::::::::::::::::::::.........
 2 ZZZZZZ..^^^^^^^^^^^^^^^^^^^^^^...l....l.
 1 ZZZZZZUUUUUUUUUUUUUUUUUUUUUUUUUZZZZ...ZZ
 0 ZZZZZZUUUUUUUUUUUUUUUUUUUUUUUUUZZZZ...ZZ
```
```props
i2 offset = 1.0
```

### c7_c04 — the maintenance niche
```
   01234567890123456789
10 ....................
 9 ....................
 8 ....................
 7 ZZZZZZZZZ...........
 6 ZZZZZZZZZ...........
 5 .....l.ZZ.......@...
 4 .......ZZ..ZZZZZZZ..
 3 .......zz...........
 2 ..H.7..zz...p......l
 1 ZZZZZZZZZZZZZZZZZZZZ
 0 ZZZZZZZZZZZZZZZZZZZZ
```
```props
7 dialogue_pages = Array[String](["Matěji! Tak jsi to dokázal až sem. Jsem tu tři dny jako technik údržby.", "Reaktor je přímo pod námi. Jádro už se neudrží, anomálie se šíří celým komplexem.", "Dál tě bude pronásledovat tvoje vlastní ozvěna. Stín z anomálie, opakuje každý tvůj krok. Nezastavuj se a nevracej se.", "Dole u reaktoru hlídá Strážce. Sabotážní ventil je za ním. Hodně štěstí."])
7 repeat_dialogue_pages = Array[String](["Ozvěna jde po tvých stopách. Nezastavuj se."])
```

### c7_c05 — echo chase I
```
   0123456789012345678901234567890123456789
10 .....ZZZZZZZZZZZZZZZZZZZZZZBBBBBBBBBBBBB
 9 .?...ZZZZZZZZZZZZZZZZZZZZZZBBBBBBBBBBBBB
 8 ......::::::::::::::::::::.BBBBBBBBBBBBB
 7 ......::::::::::::::::::::.BBBBBBBBBBBBB
 6 ......::::::::::::::::::::.BBBBBBBBBBBBB
 5 ......:::::::::C::::::::::.....nnn......
 4 ......::::::::::::::::::::.....nnn......
 3 ......::::::::::::::::::::.....nnn......
 2 ..@.l.^^^^^^^^^^^^^^^^^^^^...l.nnn......
 1 ZZZZZZUUUUUUUUUUUUUUUUUUUUZZZZZZZZ......
 0 ZZZZZZUUUUUUUUUUUUUUUUUUUUZZZZZZZZ......
```
```props

```

### c7_c06 — echo chase II
```
   01234567890123456789
21 ...............?....
20 ....................
19 ....................
18 ....................
17 ....................
16 ................@..l
15 ............ZZZZZZZZ
14 ............ZZZZZZZZ
13 ....................
12 ....................
11 ......*.............
10 ................BBBB
 9 ................BBBB
 8 ZZZnnnnnnZZZZZZZZZZZ
 7 ZZZnnnnnnZZZZZZZZZZZ
 6 ZZZnnnnnnZZZZZZZZZZZ
 5 ............:::::...
 4 ............:::::.l.
 3 ............:::::ZZZ
 2 ............^^^^^ZZZ
 1 ZZZZZZZZZZZZUUUUUZZZ
 0 ZZZZZZZZZZZZUUUUUZZZ
```
```props

```

### c7_c07 — gantry over the shaft
```
   01234567890123456789
10 ...........ZZZZZZZ..
 9 .........D.ZZZZZZZ..
 8 ...........Z.....Z..
 7 ...........Z..C..Z..
 6 ...........Z.....Z..
 5 .l.........ZZnnnZZ..
 4 ..@........ZZnnnZZ..
 3 ZZZZZ.......:::::...
 2 ZZZZZ.......:::::.l.
 1 ZZZZZBBBB...BBBBBBBB
 0 ZZZZZBBBB...BBBBBBBB
```
```props

```

### c7_d01 — the core gate gallery
```
   0123456789012345678901234567890123456789
10 &&&&&.ZZ....ZZZZZZZZZZZZZZZZ......ZZ.BBB
 9 &&&&&.ZZ....ZZZZZZZZZZZZZZZZ......ZZ.BBB
 8 &&&&&.......Z:::::::::::::.......l...BBB
 7 ............Z:::::::::::::...........BBB
 6 ............Z:::::::::::::..............
 5 ............Z:::::::::::::.BB.........T.
 4 ...........................BB.......BBBB
 3 .........................ZZBB.......BBBB
 2 ..@....!.&l....G.........ZZBB.l.....BBBB
 1 &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&.....BBBB
 0 &&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&.....BBBB
```
```props
room checkpoint = true
! speaker_name = "Hlas Korporace"
! dialogue_pages = Array[String](["Narušitel v jádru komplexu. Strážce reaktoru aktivován. Všechny jednotky k šachtě reaktoru."])
```

### c7_d02 — the field cascade
```
   01234567890123456789
21 ZZZZZZZZZZZ.....UUUU
20 ZZZZZZZZZZZ.....UUUU
19 UU::v::v::......UUUU
18 ..::::::::..........
17 ..::::::::...@....l.
16 ..........ZZZZZZZZZZ
15 ..........ZZZZZZZZZZ
14 .........ZZZZZZ.....
13 ZZZZ...e.ZZZZZZ.....
12 ZZZZ..ZZZ:::::.BBBBB
11 UU....ZZZ:::::.BBBBB
10 UU.......:::::.BBBBB
 9 UU.......:::::.BBBBB
 8 ZZZZZZZZZ......BBBBB
 7 ZZZZZZZZZ.......i...
 6 UUUUUUUUU.......i...
 5 UUUUUUUUU.......i...
 4 UUUUUUUUU.......i...
 3 UUUUUUUUU.......i...
 2 UUUUUUUUU^^^^^..i.l.
 1 UUUUUUUUUBBBBBBBBBBB
 0 UUUUUUUUUBBBBBBBBBBB
```
```props

```

### c7_d03 — the coolant hall
```
   0123456789012345678901234567890123456789
10 UUUU...ZZZZZZZZZZZZZ........e.....BBBBBB
 9 UUUU...ZZZZZZZZZZZZZ.......ZZZ....BBBBBB
 8 UUUU....::::::::::.........ZZZ..........
 7 ........::::::::::........-------..C....
 6 ........::::::::::....nnn.-------.ZZZZ..
 5 ........::::::::::....nnn.-------.......
 4 ......................nnn.-------.......
 3 .....ZZZ..........ZZZZnnn.--[[-]].....BB
 2 ..@.lZZZ^^^^^^^^^^ZZZZ^^^^^^^^^..l....BB
 1 BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB....BB
 0 BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB....BB
```
```props
C variant = 1
```

### c7_d04 — the reactor control booth
```
   01234567890123456789
10 UUUUUUU.............
 9 UUUUUUU.............
 8 ....................
 7 ...a................
 6 .ZZZZZZZZZ..........
 5 .Zzzzzlzz.....@.....
 4 .Zzzzzzzz..ZZZZZZZ..
 3 .Zzzzzzzz...........
 2 .ZzzHzz!z...l.......
 1 BBBBBBBBBBBBBBBBBBBB
 0 BBBBBBBBBBBBBBBBBBBB
```
```props
! speaker_name = "Protokol reaktoru"
! dialogue_pages = Array[String](["Stabilita jádra 12 %. Doporučení inženýrů: okamžitě zastavit těžbu.", "Rozhodnutí vedení: těžbu zdvojnásobit."])
```

### c7_d05 — the rim of the reactor shaft
```
   01234567890123456789
10 UUU..ZZZZZZZZ...UUUU
 9 UUU..ZZZZZZZZ...UUUU
 8 UUU.....Z.......UUUU
 7 ........Z...........
 6 ....................
 5 ..l.................
 4 ...............BBBBB
 3 ...............BBBBB
 2 .@.!..........lBBBBB
 1 BBBB.........BBBBBBB
 0 BBBB.........BBBBBBB
```
```props
! speaker_name = "Šachta reaktoru"
! dialogue_pages = Array[String](["Pod tebou hučí reaktor. Gravitace se tu láme každým metrem. Dolů!"])
```

### c7_d06 — the reactor shaft
```
   01234567890123456789
32 UUUU.........UUUUUUU
31 UUUU.........UUUUUUU
30 UUUU.........UUUUUUU
29 .............UUUUUUU
28 .....l..@....UUUUUUU
27 ....ZZZZZZZZZUUUUUUU
26 ....ZZZZZZZZZ.......
25 ....:::::::::.......
24 ....:::::::::.......
23 ....:::::::::.......
22 ....:::^^^:::.......
21 ZZZZZZZZZZZ.........
20 ZZZZZZZZZZZ.........
19 UUU....ZZZ.....l....
18 UUU.....i....BBBBBBB
17 UUU.....i....BBBBBBB
16 UUU.....i....BBBBBBB
15 UUU.....i....BBBBBBB
14 UUU.....i....BBBBBBB
13 iiiiiiZZZZZZZBBBBBBB
12 ......ZZZZZZZBBBBBBB
11 .............BBBBBBB
10 .............BBBBBBB
 9 .............BBBBBBB
 8 .............BBBBBBB
 7 nnnnnnnnnnnnnBBBBBBB
 6 nnnnnnnnnnnnnBBBBBBB
 5 ....................
 4 ..................BB
 3 ........[[.]].....BB
 2 .......^^^^^^....lBB
 1 ZZZZZZZBBBBBB.....BB
 0 ZZZZZZZBBBBBB.....BB
```
```props

```

### c7_d07 — the reactor antechamber
```
   0123456789012345678901234567890123456789
10 UUUUU...........................&&&&&&&&
 9 UUUUU...........................&&&&&&&&
 8 UUUUU...........................&&&&&&&&
 7 ................................&&&&&&&&
 6 UUU..........l.@.................l.dddd&
 5 UUU........ZZZZZZZZZ...............dddd&
 4 UUU........ZZZZZZZZZ....BBBBBBBB...dddd&
 3 UUU.....................FFFBBBBB...dddd&
 2 UUU..................ZZ.FcFBBBBB..lddEd&
 1 BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB
 0 BBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBBB
```
```props
E next_level = "res://boss_room.tscn"
E stage_title = "KAPITOLA 7: TĚŽEBNÍ KOMPLEX"
E stage_index = 7
E max_stage_crystals = 12
```

