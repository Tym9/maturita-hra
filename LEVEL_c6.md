# LEVEL c6 — The Crystal Mines (Krystalové doly)

Under the foundry's sump (end of c5) the great shaft breaks into the **crystal mines**: old timbered galleries of the first miners, then raw veins of living gravity crystal, then the deep shafts the corp drilled toward the planet's core. Rusty's resistance camp hides in the mouth of the mines; he hands the hero a miner's **grappling hook**. Deeper, in an abandoned drill station, the hero finds a **drill** head for the Gravity Coil. The corp starts blasting to bury the intruder: the last section is a descent through a collapsing shaft to the gate of the mining complex (→ chapter 7, `LEVEL_c7.md`).

- **Kit:** run, jump, double jump (DJ), wall climb/jump (8 s stamina), wrench, dash; **hook from a01** (Rusty's chest); **drill from c01** (chest in the drill station). The player has **two tool slots** (wrench / hook / coil / drill, any tool in either slot, swapped in the backpack with Tab): from a01 on they carry hook + coil, from c01 on hook + drill when a room has rock. The drill is a slot tool, so a room may need at most two of hook / coil / drill (never the wrench).
- **New here:** **grapple anchors** `+` (a01–a04), **crystal spikes** `I` (a05), **pressure mines** `M` and **cave crawlers** `e` (b02), **moving / breakable anchors** (b03, b05b), **drillable rock** `r` (c01). Develops: spikes, falling rocks, grates, guards, turrets, drones, dash shards.
- **Signature:** **hook lines through the mines.** Travel is ↓ and →. Chains of anchors over pits and spike beds, hook → jump-off → dash combos, later dash-drilling through cracked rock mid-line.
- **Look:** `#` stone (the default mine rock), `U` basalt (deep shafts, section c–d), `%` blight soil (crystal-infested rock around veins), `W` planks (timbering, old scaffolds, bridges), `Z` iron (corp catwalks, braces), `B` brass (corp machinery, the drill station), `&` brick (rare: the camp's stove wall, the gate); back walls `w` planks, `k` dark rock (sparingly), `z` iron, `t` resistance tarp (camp), `d` doors, `o` lit windows. Decor `l` lanterns, `x` blight crystals (lots, growing from floors), `y` dead roots/trees (upper galleries only), `f` resistance banner (camp), `g` corp banner, `p` corp pylon, `a` antenna. Mostly air `.`: the backdrop (the seam wall with crystal veins and old gallery mouths) must show in every room.
- **Rules:** LEVEL_DESIGN §1–2, §5, ASCII format §6. Crystals: 12, route types never repeat back to back.

## Open rooms — not boxes (read first)

Same as c5 (`LEVEL_c5.md`, "Open rooms in the shaft"). A room edge with **no neighbouring room** is an invisible wall (left, right, top). Only falling out the **bottom** where no room continues kills.

- **Rooms are ledges, galleries, timber scaffolds and rock shelves in big caverns, with open air around them.** No solid frame around a room: never a solid top row or a full-height side wall just to close it. Draw terrain as masses: outcrops, overhangs, pillars, stalactite-like hanging rock, a lone ledge. At least a third of every room is open air.
- **Down-exits (the main way between rooms):** a gap ≥3 tiles wide in the bottom row (air above it) over the room below. The room below has the **same columns open in its top row** and, right under the gap, a safe landing ledge with `@` at most ~6 tiles below its top (no hazard, no enemy in the landing zone). Everywhere else the two rooms' shared edge is closed with terrain **in the upper room's bottom row** (otherwise it is a second exit, or the player lands on the lower room's roof).
- **Side exits:** where two rooms share a side edge, the terrain on both sides matches exactly (same floor height, same solid rows), ≥3 tiles open, floors flush (no lip or crate at the edge).
- **Pits:** a bottom-row gap with **no room below** = bottomless pit (death). Allowed as stakes, never under a respawn. A 2-wide room above a 1-wide room: only the half above the lower room can be an exit; gaps over the other half are pits.
- **Respawns:** every entrance gets a ≥3-tile safe ledge with `@`, right at the entrance (side) or under the drop (top).
- **No backtracking up:** never require climbing back up through a down-exit; every room must be finishable from each of its `@`.
- **Secrets must be invisible:** fill the whole pocket with `F` and put its crystal as `c`; keep a solid tile between the pocket and the room edge. Hint only by geometry.
- Other crystals are visible from the main path. Key cages: one key opens one `L` block.

## Element rules

- **Grapple anchor `+`** (new): a brass ring bolted into rock or hanging from a timber. The hook (right mouse button, aimed) latches only onto anchors, **range 5.5 tiles (88 px), needs a clear line of sight** (no solid tile on the straight line from the player to the anchor). It pulls the player straight to the anchor at 380 px/s; at the anchor the player keeps the pull's momentum, or jumps off early (catapult). Latching **refills the dash and the double jump**.
  - Leave the anchor's own cell and the 8 cells around it as air; anchors float in the open (nothing needs to hold them).
  - **Chains:** anchors 6–8 tiles apart along the line, 3–5 tiles above the floor level you leave from. The first anchor must be within ~5 tiles (diagonal) of the take-off ledge's edge, the last within ~5 tiles of the landing. A pull must not pass through spikes or drag the player into a wall corner (the checker treats a snag as a failure).
  - **Teach (a01):** the first anchor hangs over a **safe pit** (floor ~4 tiles below, steps back up on the near side). The gap must be too wide for jump + DJ + dash (≥ 20 tiles) so the hook is needed, or check that `--nohook` cannot reach the exit. a02 adds stakes (spikes).
  - **Hook gaps:** make them 18+ tiles (a dash alone clears up to 17), or put the landing 6+ tiles higher than the take-off.
  - **Moving anchor** (b03+): props `+2 rail_end = Vector2(48, 0)` (px, relative), `+2 period = 3.0`. The checker treats it as standing at its drawn cell, so the route must work from there; keep rails ≤3 tiles. **Breakable anchor** (b05b+): props `+3 breakable = true` snaps 0.6 s after latching: never the only rest in a chain longer than one pull.
- **Crystal spikes `I`** (a05+): a floor cluster that shoots out when the player comes near (0.4 s glowing crack, out 2 s, retracts). Place on a floor (solid under each `I`), runs of 2–4. The checker ignores them: there must always be a way to wait them out or jump over (never on a 1-tile landing, never right under a down-exit).
- **Pressure mine `M`** (b02+): floats in the air, inflates when near (0.5 s), bursts and launches the player (dash refill), respawns. Checker ignores it: never required, never in a landing zone; use as a risk next to a line or as an optional bounce.
- **Cave crawler `e`** (b02+): crawls around the block it starts on (floors, walls, ceilings), kills on touch, stompable from its outer side. Start it on a floor cell (air cell with solid below) of a **free-standing pillar or block** it can circle. Checker ignores it: leave room to time a pass (the block ≥3 tiles around, a rest ledge before it).
- **Drillable rock `r`** (c01+): cracked rock, solid. Using the **drill** (LMB, aimed with the mouse, reach ~1 tile) stops the player in place, even mid-air, shakes the screen for 2 s and then that vertical run of `r` breaks (each column is drilled separately). The player keeps no momentum: after drilling in the air they fall straight down, so put a safe landing under any mid-air drilling spot. Draw a vertical run of `r` (1 tile thick, 2–4 tall) as a plug in a passage. First one (c01) on a safe floor. Don't put a drilling spot under falling rocks or in a turret's line: 2 s standing still.
- **Dash:** 8 directions, ~5 tiles, recharges on the ground, on a spring, a dash shard `*`, or **when the hook latches**. Winged crystals (`C variant = 1`) fly away if the player dashes anywhere in the room: their route must work with `--nodash` (hook allowed).
- **Spikes `^ v < >`**, **falling rock `O`** (hangs under a ceiling/overhang, drops once when you pass under), **grate `=`** (2-tile pieces, collapses 0.5 s after landing; never chain more than two), **spring `S`**, **turret `T`** (stand it on a floor, give cover on the approach), **drone `D`** (hovers, charges straight, stuns on walls: give it rock to crash into), **guard `G`** (patrols a floor, turns at walls and ledges), **vent `V`** as in c5.

## Dialogue (place via props, text verbatim)

- **a01** `6` (Rusty) `dialogue_pages = Array[String](["Tak ty jsi ten, co prošel slévárnou. Vesper hlásila, že přijdeš. Vítej v dolech, Matěji.", "Tyhle štoly kopali naši dědové, než přišla Korporace. Teď tu roste krystal přímo ze skály. A skála kvůli němu praská.", "Tady máš hornický hák. Miř myší a pravým tlačítkem ho vystřel na mosazný kruh. Přitáhne tě a vrátí ti cívku i druhý skok.", "Vezmi si ho z truhly a dej ho do slotu místo hasáku. V rukou uneseš naráz jen dva nástroje, vyměníš je kdykoli v batohu klávesou Tab. Cívku si nech.", "Kruhy jsme natloukli všude, kam se dalo."])`, `repeat_dialogue_pages = Array[String](["Hák: pravé tlačítko myši na mosazný kruh. Skokem se z něj odrazíš dřív."])`
- **a01** `X` `initial_items = Array[String](["grapple_hook", "health_pack"])`
- **a07** `!` speaker_name `"Stará výtahová klec"`, dialogue_pages `Array[String](["Na dveřích klece je vyryto: SMĚNA 3, VŠICHNI DOLE. Pod tím jiným písmem: Krystal zpívá. Neposlouchejte ho."])`
- **b01** `!` speaker_name `"Hlas Korporace"`, dialogue_pages `Array[String](["Těžební úsek B. Výskyt nestabilních žil. Pracovníci se žádají, aby se nedotýkali rostoucích krystalů.", "Ztráty na životech budou odečteny z výplaty směny."])`
- **b04** `!` speaker_name `"Deník horníka"`, dialogue_pages `Array[String](["Krystaly vyrážejí ze země, když kolem někdo projde. Jako by nás cítily.", "Tlakové miny tu nechala Korporace proti nám. Kdo je šikovný, nechá se jimi vystřelit dál."])`
- **c01** `!` speaker_name `"Vrtná stanice 7"`, dialogue_pages `Array[String](["Opuštěná stanice. Ve skříni zůstala vrtná hlavice na gravitační cívku.", "Hlavice se nasadí na cívku sama, stačí ji mít v batohu. S ní prorazíš dashem popraskanou skálu a letíš dál."])`
- **c01** `X` `initial_items = Array[String](["drill", "health_pack"])`
- **c04** `!` speaker_name `"Vesper (vysílačka)"`, portrait_texture `"res://assets/npc/vesper_portrait.png"`, dialogue_pages `Array[String](["Matěji, slyšíš mě? Jsi hluboko, signál se láme o krystal.", "Pod doly je těžební komplex a pod ním reaktor. Korporace o tobě ví. Chystají odstřel hlubokých šachet, pospěš si."])`
- **d01** `!` speaker_name `"Hlas Korporace"`, dialogue_pages `Array[String](["Narušitel v hlubokých šachtách. Odstřel úseku D za tři minuty. Bezpečnostní jednotky na místa."])`
- **d04** `!` speaker_name `"Protokol odstřelu"`, dialogue_pages `Array[String](["Nálože rozmístěny v šachtě D-6. Po odpalu bude spojení s horními doly přerušeno.", "Poznámka: žíly reagují na otřesy. Doporučeno neprodlévat."])`
- **d05** `!` speaker_name `"Odstřel"`, dialogue_pages `Array[String](["ODPAL. Šachta se hroutí. Dolů, dolů, dolů!"])`
- **d07** `E` next_level `"res://levels/c7/chapter7.tscn"`, stage_title `"KAPITOLA 6: KRYSTALOVÉ DOLY"`, stage_index `6`, max_stage_crystals `12`
- **a01, b01, c01, d01**: `room checkpoint = true`

## Layout

Fixed positions (screens, top-left; y grows downward). Don't move or resize rooms. Rooms touch only their neighbours in the chain (plus the b05b branch).

```layout
chapter res://levels/c6/chapter6.tscn
start_items wrench gravity_coil
kit dash hook drill
c6_a01 0 0
c6_a02 2 0
c6_a03 2 1
c6_a04 3 2
c6_a05 4 3
c6_a06 5 4
c6_a07 5 5
c6_b01 6 5
c6_b02 7 6
c6_b03 8 7
c6_b04 9 8
c6_b05 10 8
c6_b05b 11 8
c6_b06 10 10
c6_c01 12 10
c6_c02 13 11
c6_c03 14 12
c6_c04 15 13
c6_c05 16 13
c6_c06 17 14
c6_c07 18 15
c6_d01 19 15
c6_d02 20 16
c6_d03 21 17
c6_d04 22 18
c6_d05 23 18
c6_d06 23 19
c6_d07 23 22
```

## Rooms

Fixed section boundaries: **a07 → b01**, **b06 → c01** and **c07 → d01** are right-edge crossings with the floor at **h2** (rows 0–1 solid on both sides of the edge), rows 2–6 open on both sides; rows 7+ free. All other connections are agreed inside a section. "top" = you arrive by falling in through the top edge; "bottom" = you leave by dropping through the bottom edge. A 2×1 room's "right screen" = columns 20–39; a 1×2 room's "bottom screen" = rows labelled 10…0. The kit line gives the checker hook + drill everywhere, so **a and b must not contain `r`**, and the hook must not be needed before a01's chest.

| id | size | from → to | challenge | elements | diff | crystal | CP |
|---|---|---|---|---|---|---|---|
| c6_a01 | 2×1 | start (L) → a02 (R, floor h4) | The mouth of the mines: Rusty's camp on a rock shelf (tarps `t`, banner `f`, lanterns, Rusty `6`, chest `X` with the hook) — no hook needed up to the chest. Past the camp the gallery floor has caved in: the first anchor(s) over a **safe pit** (floor ~4 tiles below, steps back up on the near side), gap ≥ 20 tiles. | Rusty, chest, **hook** | 1 | — | ✔ |
| c6_a02 | 1×1 | a01 (L, floor h4) → a03 (bottom, columns 17–19) | The broken gallery: two anchors over a spike bed, land on a timber stub, drop off its end into the old lift shaft. | hook, spikes | 2 | **Skill detour**: crystal on a perch high above, reached by latching the second anchor from below and jumping off upward. | — |
| c6_a03 | 1×2 | a02 (top, columns 17–19) → a04 (R, bottom screen, floor h5) | The old lift shaft, open air: timber landings zig-zag down; one hook swing across the shaft under a hanging rock, a falling rock under a landing. | hook, falling rocks | 2 | — | — |
| c6_a04 | 2×1 | a03 (L, floor h5) → a05 (bottom, right screen, columns 31–33) | The timber bridge over the big cavern (bottomless under the left screen): two crumbling grates, a guard on the sound span, then the fallen middle: a chain of three anchors to the far pier. Drop down the pier's chute. | hook chain, grates, guard, pits | 3 | **Secret passage**: hidden pocket in the far pier (`F` + `c`), hinted by a dead-end shelf. | — |
| c6_a05 | 1×2 | a04 (top, columns 11–13) → a06 (R, bottom screen, floor h3) | The first vein: a crevice where crystal grows from every shelf. **Crystal spikes** intro: the first cluster on a wide safe shelf (walk up, watch it shoot, wait, pass), then clusters on the shelves you drop between. | **crystal spikes**, spikes | 2 | — | — |
| c6_a06 | 1×1 | a05 (L, floor h3) → a07 (bottom, columns 15–17) | A hanging rock tooth with an anchor under it: hook up and over a spike pit to the lift mouth. A **winged** crystal on the timbers above the entrance: reach it by hook or jumps, without dashing. | hook, spikes, winged crystal | 2 | **Winged**: reachable from the entrance with `--nodash`. | — |
| c6_a07 | 1×1 | a06 (top, columns 15–17) → b01 (R, h2 fixed) | Breather: the old lift cage station on a ledge (a timber structure with air around it), health pack, `!` Stará výtahová klec. | `!`, `H` | 1 | — | — |
| c6_b01 | 2×1 | a07 (L, h2 fixed) → b02 (bottom, right screen) | Mining sector B: corp catwalks over a floor of crystal spikes, loudspeaker `!`, a guard on the catwalk, a turret on a gantry (cover), an anchor pair over the gap between the catwalk's two halves. | crystal spikes, guard, turret, hook, `!` | 2 | — | ✔ |
| c6_b02 | 1×2 | b01 (top) → b03 (R, bottom screen) | **Mines and crawlers** intro: a pressure mine floating beside the first drop (safe to ignore, fun to ride), then a free-standing pillar with a **crawler** circling it that you must pass (rest ledge before it), spike floor below. | **pressure mines**, **crawler**, spikes | 2 | **Key/backtrack**: key on a ledge off the path, caged crystal (`L`) near the exit. | — |
| c6_b03 | 2×1 | b02 (L) → b04 (bottom, right screen) | **Moving anchors**: first one sliding over a safe floor, then a chain of anchors (one moving) over a long bed of crystal-infested spikes. | **moving anchors**, spikes | 3 | **Mechanic trick**: hook → jump off upward → dash to a crystal high over the spikes. | — |
| c6_b04 | 1×1 | b03 (top) → b05 (R) | Breather: a miner's niche with a bunk and a lamp (timber lean-to with air around it), health pack, `!` Deník horníka. | `!`, `H` | 1 | — | — |
| c6_b05 | 1×2 | b04 (L, top screen) → b06 (bottom); branch R (top screen) ↔ b05b | The great geode: a cavern of giant crystals; anchors between crystal-crusted pillars, two crawlers on the pillars, a drone patrolling the drop. | hook, crawlers, drone, spikes | 3 | **Secret passage**: hidden niche in a pillar's base (`F` + `c`). | — |
| c6_b05b | 1×1 | b05 (its R edge, top screen) ↔ b05 | Side gauntlet: a long anchor chain over a spike bed with **breakable** anchors (every second one), crystal at the far right; return the same way. Right and top edges have no room, bottom edge = pit or spikes. | breakable anchors, spikes | 4 | **Side gauntlet** | — |
| c6_b06 | 2×1 | b05 (top, left screen) → c01 (R, h2 fixed) | The vein gallery: pressure mines drifting along an anchor line over crystal spikes, a guard-free floor section with a turret behind cover at the far end. | hook, mines, crystal spikes, turret | 3 | — | — |
| c6_c01 | 2×1 | b06 (L, h2 fixed) → c02 (bottom, right screen) | Drill station 7: a brass-and-iron corp station on a basalt shelf, `!` and the chest `X` with the **drill**. Then the first **drillable rock**: a cracked plug in a gallery over a safe floor (dash through), then a second with a pit in front of it. | **drill**, drillable rock, `!` | 2 | — | ✔ |
| c6_c02 | 1×2 | c01 (top) → c03 (R, bottom screen) | The bore shaft: rock plugs across the ledges you descend between; dash through one sideways, one diagonally down. | drill, spikes | 3 | **Skill detour**: crystal in a pocket sealed by a rock plug off the path (visible through a gap). | — |
| c6_c03 | 2×1 | c02 (L) → c04 (bottom, right screen) | Hook-and-drill line: latch an anchor, jump off, dash through a hanging rock plug to the next ledge; a drone in the hall. | hook, drill, drone, spikes | 3 | — | — |
| c6_c04 | 1×1 | c03 (top) → c05 (R) | Breather: a survey niche with instruments, Vesper on the radio (`!`), health pack. | `!`, `H` | 1 | — | — |
| c6_c05 | 2×1 | c04 (L) → c06 (bottom, right screen) | The crawler pillars: three basalt pillars with crawlers over a spike floor, anchors between them, a rock plug guarding the far side. | crawlers, hook, drill, spikes | 4 | **Key/backtrack**: key behind the middle pillar, caged crystal near the exit. | — |
| c6_c06 | 1×2 | c05 (top) → c07 (R, bottom screen) | The blast shaft: drop between ledges past pressure mines, anchors and a dash shard, a crawler on the last block. | mines, hook, shard, crawler | 3 | — | — |
| c6_c07 | 1×1 | c06 (L) → d01 (R, h2 fixed) | Gantry over the abyss: a drone over the gantry, an anchor under its roof, a rock plug in the roof. | drone, hook, drill | 3 | **Mechanic trick**: hook up under the gantry roof and dash-drill upward through the plug to the crystal on top. | — |
| c6_d01 | 2×1 | c07 (L, h2 fixed) → d02 (bottom, right screen) | Sector D gate gallery: alarm `!`, two guards on the gallery, a turret on a buttress (cover), blasting charges (decor) everywhere. | guards ×2, turret, `!` | 3 | — | ✔ |
| c6_d02 | 1×2 | d01 (top) → d03 (R, bottom screen) | The crystal cascade: stepped shelves of crystal spikes, hook down between them; falling rocks under the overhangs. | crystal spikes, hook, falling rocks | 3 | — | — |
| c6_d03 | 2×1 | d02 (L) → d04 (bottom, right screen) | The charge hall: anchors, rock plugs and mines combined over a spike channel; a drone. | hook, drill, mines, spikes, drone | 4 | **Winged**: reachable with `--nodash` from the entrance. | — |
| c6_d04 | 1×1 | d03 (top) → d05 (R) | Breather: the blasting crew's booth, health pack, `!` Protokol odstřelu. | `!`, `H` | 1 | — | — |
| c6_d05 | 1×1 | d04 (L) → d06 (bottom) | The detonator platform: `!` Odstřel as you enter; a short drop to a wide hole over the shaft. | `!` | 1 | — | — |
| c6_d06 | 1×3 | d05 (top) → d07 (bottom) | **Finale: the collapsing shaft**: a 3-screen descent — falling rocks under every overhang, rock plugs in the floors you dash-drill down through, anchors across the gaps, a few spikes. Keep it flowing: every stop is under something that falls. | falling rocks, drill, hook, spikes | 4 | — | — |
| c6_d07 | 2×1 | d06 (top, left screen) → `E` (right end) | The bottom of the mines: rubble settles; the brass blast door of the mining complex in a brick-and-iron wall, `E` at the door on the right. | — | 1 | **Secret passage**: pocket in the rubble wall (`F` + `c`). | — |

Crystal route order: skill (a02) → secret (a04) → winged (a06) → key (b02) → trick (b03) → secret (b05) → gauntlet (b05b) → skill (c02) → key (c05) → trick (c07) → winged (d03) → secret (d07).
Enemies: guards a04, b01, d01 ×2 = 4; turrets b01, b06, d01 = 3; drones b05, c03, c07, d03 = 4; crawlers b02, b05 ×2, c05 ×3, c06 = 7 → 18 (+ pressure mines b02, b06, c06, d03).
Travel: ↓ and →; the chapter descends 23 screens to the gate of the mining complex.

## Rooms (ASCII)


### c6_a01 — the mouth of the mines
```
   0123456789012345678901234567890123456789
10 #####...................####.......#####
 9 ###..................+...##.......######
 8 ##............+..............+..........
 7 ...wtttfttw.............................
 6 ...wttltttw.............................
 5 .l@wt6ttXtw..........................l..
 4 ###########......................#######
 3 ###########......................#######
 2 #############.......................####
 1 #############.....x.......x......x..####
 0 ########################################
```
```props
room checkpoint = true
6 dialogue_pages = Array[String](["Tak ty jsi ten, co prošel slévárnou. Vesper hlásila, že přijdeš. Vítej v dolech, Matěji.", "Tyhle štoly kopali naši dědové, než přišla Korporace. Teď tu roste krystal přímo ze skály. A skála kvůli němu praská.", "Tady máš hornický hák. Miř myší a pravým tlačítkem ho vystřel na mosazný kruh. Přitáhne tě a vrátí ti cívku i druhý skok.", "Vezmi si ho z truhly a dej ho do slotu místo hasáku. V rukou uneseš naráz jen dva nástroje, vyměníš je kdykoli v batohu klávesou Tab. Cívku si nech.", "Kruhy jsme natloukli všude, kam se dalo."])
6 repeat_dialogue_pages = Array[String](["Hák: pravé tlačítko myši na mosazný kruh. Skokem se z něj odrazíš dřív."])
X initial_items = Array[String](["grapple_hook", "health_pack"])
```

### c6_a02 — the broken gallery
```
   01234567890123456789
10 ##..######..C.......
 9 ##..######WWWW......
 8 ....######..........
 7 .............+......
 6 ......+.........l...
 5 .@l...........WWW...
 4 ####..........W.....
 3 ####^^^^^^^^^^W^^...
 2 ####^^^^^^^^^^W^^...
 1 ####^^^^^^^^^^^^^...
 0 #################...
```
```props

```

### c6_a03 — the old lift shaft
```
   01234567890123456789
21 ########............
20 ########............
19 ######..............
18 ####................
17 ##............l...@.
16 .............WWWWWWW
15 ...............#####
14 ...............#####
13 .........l......###.
12 ....WWWWWWWWW.......
11 ......O.............
10 ....................
 9 ............+.......
 8 ...l................
 7 ########............
 6 ######...........xx.
 5 ######..........####
 4 ######..........####
 3 ###.............####
 2 ###.............####
 1 ###.............####
 0 ###.............####
```
```props

```

### c6_a04 — the timber bridge
```
   0123456789012345678901234567890123456789
10 ###...#####...###################....###
 9 .......##.....###################....###
 8 .....................................FF#
 7 ...............+......+......+.....l.Fc#
 6 ..@.....lG........................######
 5 ####====WWWW......................######
 4 ####..............................######
 3 ####................^^^^^^^^^^^...######
 2 ####................^^^^^^^^^^^...######
 1 ####................^^^^^^^^^^^...######
 0 ####................###########...######
```
```props

```

### c6_a05 — the first vein
```
   01234567890123456789
21 ###########...######
20 #########.......####
19 ######............##
18 ....................
17 .......xl...@.......
16 ......#########.....
15 ......#########.....
14 ....................
13 ....................
12 ....................
11 ...........III...x..
10 ........############
 9 ........############
 8 ....................
 7 ...III......l.......
 6 ..########..........
 5 ..########..........
 4 ....^^...III....x...
 3 ####################
 2 ####################
 1 ####################
 0 ####################
```
```props

```

### c6_a06 — the tooth over the pit
```
   01234567890123456789
10 ....##########......
 9 ......######........
 8 .C..................
 7 WWWW....+....l......
 6 ............###.....
 5 ............###.....
 4 x..@........###.....
 3 #####.......###...WW
 2 #####.......###...WW
 1 #####^^^^^^^###...WW
 0 ###############...##
```
```props
C variant = 1
```

### c6_a07 — the old lift cage
```
   01234567890123456789
10 ####................
 9 ##..................
 8 ....................
 7 ..............l.@...
 6 ......WWWWWWWWWWWW..
 5 .......zzzz.........
 4 .......zzzz.........
 3 .......zzzz.........
 2 ...x...z!zH.........
 1 ####################
 0 ####################
```
```props
! speaker_name = "Stará výtahová klec"
! dialogue_pages = Array[String](["Na dveřích klece je vyryto: SMĚNA 3, VŠICHNI DOLE. Pod tím jiným písmem: Krystal zpívá. Neposlouchejte ho."])
```


### c6_b01 — sector B catwalks
```
   0123456789012345678901234567890123456789
10 ######..................######..........
 9 ######..................######..........
 8 ##..........WWWWW.......................
 7 ........................................
 6 ...........+.....+..................T...
 5 ..........................G.........ZZZZ
 4 ......................ZZZZZZZZ.........Z
 3 ......................Z......Z.........Z
 2 ..@..!.x............l.Z.III..Z....x....Z
 1 #########..........ZZZZZZZZZZZ....ZZZZZZ
 0 #########..........ZZZZZZZZZZZ....ZZZZZZ
```
```props
room checkpoint = true
! speaker_name = "Hlas Korporace"
! dialogue_pages = Array[String](["Těžební úsek B. Výskyt nestabilních žil. Pracovníci se žádají, aby se nedotýkali rostoucích krystalů.", "Ztráty na životech budou odečteny z výplaty směny."])
```

### c6_b02 — mines and crawlers
```
   01234567890123456789
21 ...............#####
20 ...............#####
19 ...............#####
18 .K..............####
17 WWWW.....l.@........
16 .......WWWWWWWW.....
15 .....M..........####
14 ................####
13 ...@.x..........####
12 ########........####
11 ................####
10 ................####
 9 ................####
 8 ..........e.....####
 7 ........ZZZZZ...##C#
 6 ........ZZZZZ...##L#
 5 ........ZZZZZ.......
 4 ....................
 3 ..............xx....
 2 .^^^^^^^^^^^^#######
 1 ####################
 0 ####################
```
```props

```

### c6_b03 — sliding rings
```
   0123456789012345678901234567890123456789
10 ######........####...........###.....###
 9 ######........####.....C.....###.....###
 8 ####.................................###
 7 ####..+......+......+......+.....+......
 6 ####....................................
 5 ........................................
 4 ........................................
 3 ..@....x..............................l.
 2 #########^^^^^^^^^^^^^^^^^^^^^^^....####
 1 #########%%%%%%%%%%%%%%%%%%%%%%%....####
 0 #########%%%%%%%%%%%%%%%%%%%%%%%....####
```
```props
+1 rail_end = Vector2(48, 0)
+1 period = 3.0
+3 rail_end = Vector2(0, 32)
+3 period = 2.5
```

### c6_b04 — the miner's niche
```
   01234567890123456789
10 #######..........###
 9 #######..........###
 8 #######.............
 7 WWWWWWWW............
 6 .wwwwwl......@......
 5 .wwwwww...WWWWWWW...
 4 .wwwwww...w.....w...
 3 WWww!wH...w...x.w.x.
 2 ####################
 1 ####################
 0 ####################
```
```props
! speaker_name = "Deník horníka"
! dialogue_pages = Array[String](["Krystaly vyrážejí ze země, když kolem někdo projde. Jako by nás cítily.", "Tlakové miny tu nechala Korporace proti nám. Kdo je šikovný, nechá se jimi vystřelit dál."])
```

### c6_b05 — the great geode
```
   01234567890123456789
21 ###.....%%%%...####.
20 ###.....%%%%...####.
19 ###.....%%%%...####.
18 ###.................
17 ....................
16 ................+...
15 ..........+.........
14 .@.l.........e...x@.
13 #####......%%%%..%%%
12 #####..e...%%%%..%%%
11 #####.%%%........%%%
10 #####.%%%........%%%
 9 #####.%%%........%%%
 8 #####.%%%...D....%%%
 7 #####.%%%........%%%
 6 #####.%%%........%%%
 5 #####.%%%........%%%
 4 #####.%%%........%%%
 3 #####.%%%........FF%
 2 #####^%%%^.....x.Fc%
 1 ##########.....#####
 0 ##########.....#####
```
```props
D patrol_distance = 40.0
```

### c6_b05b — breaking rings
```
   01234567890123456789
10 ...##########.......
 9 .....##...........C.
 8 ........+.....+.####
 7 ..+.............####
 6 ....................
 5 ....................
 4 ....................
 3 .@l.................
 2 ###^^^^^^^^^^^^^^^^^
 1 ####################
 0 ####################
```
```props
+1 breakable = true
```

### c6_b06 — the vein gallery
```
   0123456789012345678901234567890123456789
10 #######........####.....................
 9 #######........####.......+.............
 8 #######.............+...................
 7 #######.........................+.......
 6 .......................M.....M..........
 5 ..........l.@...........................
 4 ........WWWWWWWWW.................ZZ.T..
 3 ........W.......W.................ZZ.ZZ.
 2 .x.x....W.....x.W.III..III..III...ZZ.ZZ.
 1 ########################################
 0 ########################################
```
```props

```



### c6_c01 — the drill station
```
   0123456789012345678901234567890123456789
10 .............UUUUUUUU...................
 9 ...........UUUUUUUUUUUU.................
 8 ..........UUUUUUUUUUUUUU................
 7 .........UUUUUUUUUUUUUUUU...............
 6 ...BBBB.UUUUUUUUUUUUUUUUUU..............
 5 ...Zlzz..rr...........rr..........l...UU
 4 ...zzzz..rr...........rr............UUUU
 3 ...zzzz..rr...........rr............UUUU
 2 .@.z!Xz..rr.x......x..rr...x......xxUUUU
 1 UUUUUUUUUUUUUU...UUUUUUUUUUUU....UUUUUUU
 0 UUUUUUUUUUUUUU...UUUUUUUUUUUU....UUUUUUU
```
```props
room checkpoint = true
! speaker_name = "Vrtná stanice 7"
! dialogue_pages = Array[String](["Opuštěná stanice. Ve skříni zůstala vrtná hlavice na gravitační cívku.", "Hlavice se nasadí na cívku sama, stačí ji mít v batohu. S ní prorazíš dashem popraskanou skálu a letíš dál."])
X initial_items = Array[String](["drill", "health_pack"])
```

### c6_c02 — the bore shaft
```
   01234567890123456789
21 UUUUUUUU........UUUU
20 UUUUUUU..........UUU
19 ....rr........UUUUUU
18 ....rr........UUUUUU
17 ....rr..x.@.l.UUUUUU
16 ....UUUUUUUUUUUUUUUU
15 ....UUUUUUUUUUUUUUUU
14 ........l.....UUUUUU
13 ..............UUUUUU
12 ............x.UUUUUU
11 UUUUUUUrrrUUUUUUUUUU
10 UUUUUUUrrrUUUUUUUUUU
 9 UUUU................
 8 U...rr..............
 7 U...rr..............
 6 U.C.rr...@.xx.......
 5 UUUUUUUUUUUUU.......
 4 UUUUUUUUUUUUU.......
 3 UUUUUUUUUUUUU.^^..x.
 2 UUUUUUUUUUUUUUUUUUUU
 1 UUUUUUUUUUUUUUUUUUUU
 0 UUUUUUUUUUUUUUUUUUUU
```
```props
```

### c6_c03 — hook and drill line
```
   0123456789012345678901234567890123456789
10 ...............UUUUUUUU..UUUUUUU...UUUUU
 9 ...............UUUUUUUU..UUUUUUU...UUUUU
 8 ...............UUUUUUUU............UUUUU
 7 ...................rr......D............
 6 .........+....+....rr................UUU
 5 ...................rr................UUU
 4 ...................rr................UUU
 3 ..@.xx.............UU.x.^^^..x.....l.UUU
 2 UUUUUU.............UUUUUUUUUUU....UUUUUU
 1 UUUUUU.............UUUUUUUUUUU....UUUUUU
 0 UUUUUU.............UUUUUUUUUUU....UUUUUU
```
```props
D patrol_distance = 24.0
```

### c6_c04 — survey niche
```
   01234567890123456789
10 ...............UUU..
 9 ...a...........UUU..
 8 .ZZZZZZZZ.......U...
 7 .Zzzlzzz............
 6 .Zzzozzz............
 5 .Zzzzzzz............
 4 .Z.!..H.....@..x.l..
 3 UUUUUUUUUUUUUUUUUUUU
 2 UUUUUUUUUUUUUUUUUUUU
 1 UUUUUUUUUUUUUUUUUUUU
 0 UUUUUUUUUUUUUUUUUUUU
```
```props
! speaker_name = "Vesper (vysílačka)"
! portrait_texture = "res://assets/npc/vesper_portrait.png"
! dialogue_pages = Array[String](["Matěji, slyšíš mě? Jsi hluboko, signál se láme o krystal.", "Pod doly je těžební komplex a pod ním reaktor. Korporace o tobě ví. Chystají odstřel hlubokých šachet, pospěš si."])
```

### c6_c05 — the crawler pillars
```
   0123456789012345678901234567890123456789
10 ...........................UUUUUUU....UU
 9 .............+.......+.....UUUUUUU....UU
 8 ...........................UUUUUUU....UU
 7 ..............................rr......UU
 6 .........e.......e.......e....rr......UU
 5 ........UUU.....UUU.....UUU...rr......L.
 4 .@.x.l..UUU.....UUU..K..UUU.x.rr.x...xLC
 3 UUUUUU..UUU.....UUU.UUU.UUUUUUUUUU...UUU
 2 UUUUUU^^UUU^^^^^UUU^UUU^UUUUUUUUUU...UUU
 1 UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU...UUU
 0 UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU...UUU
```
```props
```

### c6_c06 — the blast shaft
```
   01234567890123456789
21 UUUUUUUUU........UUU
20 UUUUUU...........UUU
19 UUUUUU...........UUU
18 UUUUUU..............
17 ....................
16 ...............@..l.
15 ........M...UUUUUUU.
14 ............UUUUUUU.
13 ....................
12 ..x.l...............
11 UUUUU...............
10 UUUUU....*....+.....
 9 ......M.............
 8 .........x..........
 7 .......UUUUU....e...
 6 .......UUUUU...UUU..
 5 ...............UUU..
 4 ..x..........x.UUU..
 3 UUUUUUUUUUUUUUUUUUUU
 2 UUUUUUUUUUUUUUUUUUUU
 1 UUUUUUUUUUUUUUUUUUUU
 0 UUUUUUUUUUUUUUUUUUUU
```
```props
```

### c6_c07 — gantry over the abyss
```
   01234567890123456789
10 .....ZZZ...ZZZZZ....
 9 .....ZZZ.C.ZZZZZ....
 8 .....ZZZ...ZZZZZ.D..
 7 .....ZZZZrrZZZZZ....
 6 .....ZZZZrrZZZZZ....
 5 .....zzzz+zzzzz.....
 4 .@xl.zzzzzzzzzz.....
 3 UUUU.zzzzzzzzzz...l.
 2 UUUU.zzzzzzzzzz..x..
 1 UUUUBBBBBBBBBBBUUUUU
 0 UUUU...........UUUUU
```
```props
D patrol_distance = 24.0
```


### c6_d01 — sector D gate gallery
```
   0123456789012345678901234567890123456789
10 ......UUUUUU....................UUUUUUUU
 9 .......UUUU......................UUUUUUU
 8 ........................................
 7 ........................................
 6 ....l...................................
 5 ...............G....................T...
 4 ............ZZZZZZZZ.............BBBBBBB
 3 ........................ZZ.......BBBBBBB
 2 ..@..!.....G............ZZ.......BBBBBBB
 1 UUUUUUUUUUUUUUUUUUUUUUUUUU.....UUUUUUUUU
 0 UUUUUUUUUUUUUUUUUUUUUUUUUU.....UUUUUUUUU
```
```props
room checkpoint = true
! speaker_name = "Hlas Korporace"
! dialogue_pages = Array[String](["Narušitel v hlubokých šachtách. Odstřel úseku D za tři minuty. Bezpečnostní jednotky na místa."])
```

### c6_d02 — the crystal cascade
```
   01234567890123456789
21 UUU...............UU
20 UUU...............UU
19 UU................UU
18 U.................UU
17 .....l..@...........
16 UUUUUUUUUUUUU.......
15 .......O.O..........
14 ....................
13 ....................
12 ..........II........
11 .....UUUUUUUUUUUUUUU
10 .....O...O..........
 9 ....................
 8 ....................
 7 ............+.......
 6 .......II...........
 5 UUUUUUUUUUU.........
 4 UUUUUUUUUU..........
 3 UUUUUUUU............
 2 UUUUUU..............
 1 UUUUU..........UUUUU
 0 UUUUU..........UUUUU
```
```props
```

### c6_d03 — the charge hall
```
   0123456789012345678901234567890123456789
10 ...UUUUU..................UUUUUU........
 9 ....UUU...................UUUUUU........
 8 ..........................UUUUUU........
 7 ..............C.......D...UUUUUU........
 6 ..........................UUUUUU........
 5 ...........+......+.......UUrr..........
 4 ...............M.....M......rr..........
 3 ............................rr..........
 2 ..@.......^^^^^^^^^^^^^.....rr..........
 1 UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU......UU
 0 UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU......UU
```
```props
C variant = 1
```

### c6_d04 — the blasting crew's booth
```
   01234567890123456789
10 ....................
 9 .WWWWWWWWWW.........
 8 .WwwwwwwwW..........
 7 .WwwwowwwW..........
 6 .Wwwlwwwww..........
 5 .W..!...H.....@..l..
 4 UUUUUUUUUUUUUUUUUUUU
 3 UUUUUUUUUUUUUUUUUUUU
 2 UUUUUUUUUUUUUUUUUUUU
 1 UUUUUUUUUUUUUUUUUUUU
 0 UUUUUUUUUUUUUUUUUUUU
```
```props
! speaker_name = "Protokol odstřelu"
! dialogue_pages = Array[String](["Nálože rozmístěny v šachtě D-6. Po odpalu bude spojení s horními doly přerušeno.", "Poznámka: žíly reagují na otřesy. Doporučeno neprodlévat."])
```

### c6_d05 — the detonator platform
```
   01234567890123456789
10 ....................
 9 ....................
 8 ....................
 7 ................BB.l
 6 ...............ZZZZZ
 5 .@..!..........ZZZZZ
 4 UUUUUUU........ZZZZZ
 3 UUUUUUU........ZZZZZ
 2 UUUUUUUUU......ZZZZZ
 1 UUUUUUUUU......ZZZZZ
 0 UUUUUUUUU......ZZZZZ
```
```props
! speaker_name = "Odstřel"
! dialogue_pages = Array[String](["ODPAL. Šachta se hroutí. Dolů, dolů, dolů!"])
```

### c6_d06 — the collapsing shaft
```
   01234567890123456789
32 UUU..............UUU
31 UUU..............UUU
30 UU................UU
29 U..................U
28 ....................
27 ........@...l.......
26 ...UUUUUUUUUUU......
25 ........O..O........
24 ....................
23 ....................
22 ....................
21 UUUUrrrUUUUUUUUUUUUU
20 UUUUrrrUUUUUUUUUUUUU
19 .......OO.........UU
18 ..................UU
17 ..........+.......UU
16 .................UUU
15 UUUUUUU......UUUUUUU
14 UU............O.O...
13 UU..................
12 UU..................
11 UUUUUUUUU...........
10 UUUUUUUUU...UUUUU...
 9 ......OO.....O.O....
 8 ....................
 7 ....................
 6 ....................
 5 .........^^^........
 4 UUrrrrUUUUUUUUUUUUUU
 3 UUrrrrUUUUUUUUUUUUUU
 2 UU....UUUUUUUUUUUUUU
 1 UU....UUUUUUUUUUUUUU
 0 UU....UUUUUUUUUUUUUU
```
```props
```

### c6_d07 — the bottom of the mines
```
   0123456789012345678901234567890123456789
10 UU....UUUUUU..................UUUUUUUUUU
 9 U.....UUUUU...................UUUUUUUUUU
 8 ................................UUUUUUUU
 7 .................................&&&&&&&
 6 ...@.......l.....................ZZZZZZZ
 5 UUUUUUUUU........................qoqqqoq
 4 UUUUUUUUU...........UUUUUUUU.....qqdddqq
 3 UUUUUUUUUUU.........FFFFFUUU.....qqdddqq
 2 UUUUUUUUUUUUUU......FFFcFUUU.....qqdEdqq
 1 UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU
 0 UUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUUU
```
```props
E next_level = "res://levels/c7/chapter7.tscn"
E stage_title = "KAPITOLA 6: KRYSTALOVÉ DOLY"
E stage_index = 6
E max_stage_crystals = 12
```

