# LEVEL c2 — Smallville (the climb)

The mountain begins above the resistance ravine. Smallville clings to its lower slopes: terraced fields held up by dry-stone walls, half-timbered cottages stacked up the hillside (some cracked, roofs caved in, windows boarded), a church with a tall bell tower, cliffs above it. Violet blight crystals burst through terraces and streets, corp pylons and eviction notices everywhere. The corp drill bores under the village. The hero **climbs** — up the terraces, over and through the stacked houses, up the bell tower and the cliffs — and when the drill breaks through and the slope starts to slide, up the collapsing mountain trail toward Steam City, which glows in the smog far above.

- **Kit:** run, jump, double jump (DJ), wall climb/jump (8 s stamina), wrench. No dash, no hook.
- **New here:** crystal spikes (a03), drone (d02). Develops: grates (hay bales, crumbling roofs, beams), falling rocks (cliffs, chimneys), steam vents (chimneys), guards, turrets, springs (rare: a DIY hay-cart catapult at most).
- **Signature:** **the climb.** Travel is ↑ and →: rooms are entered from the bottom or the left and left through the top or the right. Wall climbing and wall jumps are the core verb, then roof-to-roof jumps and beams.
- **Look:** terraces and cliffs `#` stone, `_` ground, `%` blight soil; houses `W` planks, `R` roofs, `&` brick (chimneys, church), back facades `w q o b d` (`b` boarded often), `k` dark rock behind cliffs. Decor `y` dead trees, `x` blight crystals, `p` corp pylons, `l` lanterns (few, dim). Leave air `.` where the sky should show — the backdrop sinks as you climb (altitude), so high rooms are mostly sky. Every room shows the damage.
- **Rules:** LEVEL_DESIGN §1–2, §5, ASCII format §6. Crystals: 12, route types never repeat back to back.

## Celeste rules for this chapter (read before drawing)

- **One idea per room**, small rooms: mostly 1×1, climbs 1×2, one 1×3 (the bell tower). Death is cheap (respawn at the room entry in <1 s), so rooms may be tight and spiky — but the main path stays 2–3/5 and always readable.
- **Teach → test:** a new element first appears where failing is safe (a fall to the terrace below, not spikes); the next room adds stakes.
- **Climbing:** never require more than ~4 s of continuous wall climbing without a ledge to stand on (stamina 8 s); a 1×2 climb gets at least one rest ledge per screen. Falling in a climb room should usually drop you to an earlier ledge, not kill you — spikes and pits are the stakes in the 1×1 rooms.
- **Up-exits:** a top exit is an opening ≥3 tiles wide in the top row; the room above has a matching hole in its bottom row and a ledge with `@` right beside it (the game gives a small upward boost when you jump up through a room edge). Down-falls between rooms only where the room below exists.
- **Pits:** a floor opening with no room below kills (Celeste pits) — use them as stakes only in 1×1 rooms, never under a respawn.
- **Secrets must be invisible.** `F` fake wall cells are drawn with the same tile as the wall around them (the builder copies it), so: fill the whole secret pocket with `F` and put its crystal as `c` (hidden crystal = fake wall + crystal) — nothing of the pocket may show. Hint only with geometry (a ledge that leads into a wall, a dead-end shelf, a gap in a spike row, a lantern standing oddly), never with a different tile or a dark back tile.
- Other crystal types (skill detour, key, gauntlet, trick) stay visible from the main path, like Celeste strawberries.

## Dialogue (place via props, text verbatim)

- **a01** `!` speaker_name `"Úpatí hory"`, dialogue_pages `Array[String](["Stezka z rokle se zvedá do svahů hory. Na terasách nad námi leží Smallville — a ještě výš, schované ve smogu, Parní město korporace.", "Pole jsou šedá a mrtvá. Z prasklin v kamenných zídkách prorůstají fialové krystaly."])`
- **a07** `5` Tobi dialogue_pages `Array[String](["Ty nejsi od korporace? Uf... Táta říkal, ať nikomu neotvírám.", "Ulice jsou zavalené krystaly a hlídají je stráže. Nahoru se dostaneš jen po střechách!", "Babička Elda je úplně nahoře ve zvonici. Ta ví, kudy dál na horu."])`, repeat_dialogue_pages `Array[String](["Po střechách nahoru! A pozor na komíny, ty syčí."])`
- **b04** `!` speaker_name `"Vyhláška Korporace"`, dialogue_pages `Array[String](["Z rozhodnutí Korporace je oblast Smallville určena k těžbě.", "Obyvatelé mají tři dny na vystěhování. Neuposlechnutí bude potrestáno."])`
- **c03** `4` Elda dialogue_pages `Array[String](["Odboj tě posílá? Pak neseš špatné zprávy pozdě. Korporace dnes ráno spustila vrt přímo pod vesnicí.", "Do Parního města vede jen stará horská stezka nad zvonicí. Jestli se svah utrhne, zůstanou jen útesy.", "Lez, chlapče. My ostatní... my to tu nějak vydržíme."])`, repeat_dialogue_pages `Array[String](["Stezka nad zvonicí. Lez!"])`
- **c06** `!` speaker_name `"Otřesy"`, dialogue_pages `Array[String](["Hora se otřese. Hluboko pod vesnicí řve korporátní vrták a celý svah se dává do pohybu."])`
- **d04** `5` Tobi dialogue_pages `Array[String](["Ty jsi taky vylezl až sem? Znám zkratku, kudy chodí kozy... Jenže babička zůstala ve zvonici!", "Vrátím se pro ni. Ty lez dál a řekni odboji, že Smallville se nevzdá!"])`, repeat_dialogue_pages `Array[String](["Lez! Já se vrátím pro babičku."])`
- **d07** `E` next_level `"res://levels/c3/chapter3.tscn"`, stage_title `"KAPITOLA 2: SMALLVILLE"`, stage_index `2`, max_stage_crystals `12`
- **a01, b01, c01, d01**: `room checkpoint = true`

## Layout

Fixed positions (screens, top-left; y grows downward, so the climb goes to negative y). Don't move or resize rooms.

```layout
chapter res://levels/c2/chapter2.tscn
start_items wrench
c2_a01 0 0
c2_a02 2 -1
c2_a03 2 -2
c2_a04 3 -3
c2_a05 3 -4
c2_a06 5 -5
c2_a07 5 -6
c2_b01 6 -6
c2_b02 7 -8
c2_b03 8 -8
c2_b04 9 -8
c2_b05 9 -9
c2_b05b 10 -10
c2_b06 11 -10
c2_b07 11 -11
c2_c01 12 -11
c2_c02 13 -13
c2_c03 13 -14
c2_c04 14 -14
c2_c05 15 -15
c2_c06 15 -16
c2_d01 16 -16
c2_d02 18 -16
c2_d03 18 -18
c2_d04 19 -18
c2_d05 20 -19
c2_d06 20 -20
c2_d07 22 -20
```

## Rooms

Fixed section boundaries: **a07 → b01**, **b07 → c01** and **c06 → d01** all open at h1: row 0 solid across the edge, rows 1–4 open on both sides of the edge (rows 5+ may be wall). All other entries/exits are agreed inside a section. "floor hole" = you arrive by jumping up through the bottom row; "top" = you leave through the top row.

| id | size | from → to | challenge | elements | diff | crystal | CP |
|---|---|---|---|---|---|---|---|
| c2_a01 | 2×1 | start (L, h1) → a02 (R) | Mountain foot: the ravine trail meets the first terraces; dry-stone terrace walls 2–3 high, a dead orchard, hops. | terraces, `!` | 1 | — | ✔ |
| c2_a02 | 1×2 | a01 (L bottom) → a03 (top) | Terrace climb: tall terrace walls (4–6) to wall-climb, a rest ledge on each; a fall only drops you a terrace (safe). | wall climb, grates (hay) | 1 | **Skill detour**: crystal on an overhanging terrace lip, wall-jump line off the main climb. | — |
| c2_a03 | 1×1 | a02 (floor hole) → a04 (R) | **Crystal spikes** intro: a blight patch in a furrow, seen from a safe ledge first; bait, step back, pass in the cooldown. | crystal spikes | 2 | — | — |
| c2_a04 | 1×2 | a03 (L bottom) → a05 (top) | Cliff orchard: wall jumps between a terrace wall and a boulder column, falling rocks shaken loose above, a blight patch on a ledge. | wall jumps, falling rocks, crystal spikes | 2 | **Secret passage**: hidden pocket in the terrace wall (`F` + `c`). | — |
| c2_a05 | 2×1 | a04 (floor hole, left screen) → a06 (R) | Windmill terraces: hayloft grates, a corp surveyor guard on a terrace, crystal spikes; the broken windmill sheds debris. | grates, guard, falling rocks, crystal spikes | 3 | — | — |
| c2_a06 | 1×2 | a05 (L bottom) → a07 (top) | Dry well and the village fence: climb the fence posts and the well wall, grates. | grates, climb, spikes | 2 | **Key/backtrack**: key down in a side pit of the well, caged crystal (`L`) on the fence top. | — |
| c2_a07 | 1×1 | a06 (floor hole) → b01 (R, h1 fixed) | Breather at the village edge: Tobi, health pack, first cottages. | Tobi `5`, `H` | 1 | — | — |
| c2_b01 | 2×1 | a07 (L, h1 fixed) → b02 (top, right screen) | Lowest street, blocked by a wall of blight (`%`) and a corp barricade with a guard: climb the first houses to the roofs. | houses, guard | 2 | — | ✔ |
| c2_b02 | 1×2 | b01 (floor hole) → b03 (R, top screen) | The gap between two tall houses: wall-jump up the narrow "chimney" between them; spikes on part of one face. Left wall of the top screen closed. | wall jumps, spikes | 3 | — | — |
| c2_b03 | 1×1 | b02 (L) → b04 (R) | Crumbling roofs over a street of crystal spikes; keep moving. | grates, crystal spikes | 3 | **Mechanic trick**: let a crumbling roof drop you into an attic with the crystal, climb back out. | — |
| c2_b04 | 1×1 | b03 (L) → b05 (top) | Breather attic: the eviction notice (`!`), health pack, beams up to the roof hatch. | `!`, `H` | 1 | — | — |
| c2_b05 | 2×1 | b04 (floor hole, left screen) → b06 (R); branch up to b05b | Market roofs on the slope: two guards on flat roofs, debris from a tall chimney, grates; a hole in the ceiling of the right screen leads up to b05b. | guards ×2, falling rocks, grates | 3 | — | — |
| c2_b05b | 1×1 | b05 (floor hole) ↔ b05 | Side gauntlet: the leaning clock attic — wall jumps, spikes, crystal spikes; crystal at the end; drop back down the hole. Left, right and top walls closed. | wall jumps, spikes, crystal spikes | 4 | **Side gauntlet** | — |
| c2_b06 | 1×2 | b05 (L bottom) → b07 (top) | Chimney stack climb: chimneys vent steam upward (time the climb), wall jumps between stacks. Left wall of the top screen closed (b05b is there). | vents, wall jumps | 3 | **Secret passage**: hidden attic in a chimney (`F` + `c`). | — |
| c2_b07 | 1×1 | b06 (floor hole) → c01 (R, h1 fixed) | Churchyard: a turret on the church roof covers the yard; gravestones and a wall as cover. | turret | 2 | — | — |
| c2_c01 | 1×1 | b07 (L, h1 fixed) → c02 (R) | Church nave: quiet, pews, a few grates up to the tower door. | grates | 1 | — | ✔ |
| c2_c02 | 1×3 | c01 (L bottom) → c03 (top) | Bell tower: climb the inside on beams (grates) and wall-jump ladders; a rest floor every screen; a fall lands on the floor below. Left walls of the two upper screens closed. | grates, wall jumps | 3 | **Skill detour**: crystal off the beams near the top, guarded by spikes. | — |
| c2_c03 | 1×1 | c02 (floor hole) → c04 (R) | Bell platform: Elda (dialogue), health pack; open arches show the mountain and the city lights above. | Elda `4`, `H` | 1 | — | — |
| c2_c04 | 2×1 | c03 (L) → c05 (top, right screen) | Out of the belfry onto the roof ridge, crumbling slates, then a leap to the cliff; the void below kills (no room under it). | grates, pits | 3 | **Key/backtrack**: key on the spire, caged crystal on the cliff ledge. | — |
| c2_c05 | 1×1 | c04 (floor hole) → c06 (top) | Cliff face above the village: wall climb with rest ledges, crystal spikes in the rock, falling rocks. | climb, crystal spikes, falling rocks | 3 | **Secret passage**: hidden cave behind fake rock (`F` + `c`). | — |
| c2_c06 | 1×1 | c05 (floor hole) → d01 (R, h1 fixed) | Lookout ledge: `!` Otřesy — the drill breaks through far below; short and safe. | `!` | 1 | — | — |
| c2_d01 | 2×1 | c06 (L, h1 fixed) → d02 (R) | The mountain trail as the slope starts to slide: debris falling, crystal spikes erupting, crumbling ground. | falling rocks, crystal spikes, grates | 2 | — | ✔ |
| c2_d02 | 1×1 | d01 (L) → d03 (top) | **Drone** intro: a corp survey drone over a ledge; cover nearby; bait it into the rock face, stomp it. | drone | 2 | — | — |
| c2_d03 | 1×2 | d02 (floor hole) → d04 (R, top screen) | Collapsing switchbacks: grates, debris, a guard on a switchback. | grates, falling rocks, guard | 3 | **Skill detour** | — |
| c2_d04 | 1×1 | d03 (L) → d05 (R) | Breather in a shepherd's hut: Tobi (dialogue), health pack. | Tobi `5`, `H` | 1 | — | — |
| c2_d05 | 1×2 | d04 (L bottom) → d06 (top) | The scree chute: climb while rocks fall, crystal spikes, a drone. Left wall of the top screen closed. | falling rocks, crystal spikes, drone | 3 | **Mechanic trick**: stomp-bounce off the drone (bounce + refill) to reach a high crystal. | — |
| c2_d06 | 2×1 | d05 (floor hole, left screen) → d07 (R) | Corp checkpoint on the mountain road: turret, guard, barricade, a steam pump venting. | turret, guard, vents | 3 | **Key/backtrack** | — |
| c2_d07 | 1×1 | d06 (L) → E (R) | The old mountain road: Steam City's walls glow above; `E` at the right. | `E` | 1 | — | — |

Crystal route order: skill (a02) → secret (a04) → key (a06) → trick (b03) → gauntlet (b05b) → secret (b06) → skill (c02) → key (c04) → secret (c05) → skill (d03) → trick (d05) → key (d06).
Enemies: guards a05, b01, b05 ×2, d03, d06 = 6; turrets b07, d06; drones d02, d05 = 10.
Travel: ↑ and → only; the chapter climbs 20 screens.

## Sketches

### c2_a01 — foot of the mountain
```
   0123456789012345678901234567890123456789
10 ########################################
 9 #.......................................
 8 #.......................................
 7 #.......................................
 6 #.......................................
 5 #.......................................
 4 #.....................y.................
 3 #.........y.........______..............
 2 #......._____.......######..............
 1 #l@.y.!.#####..x..__######_____.x.xl.p..
 0 ________#####_____#############%%%%_____
```
```props
room checkpoint = true
! speaker_name = "Úpatí hory"
! dialogue_pages = Array[String](["Stezka z rokle se zvedá do svahů hory. Na terasách nad námi leží Smallville — a ještě výš, schované ve smogu, Parní město korporace.", "Pole jsou šedá a mrtvá. Z prasklin v kamenných zídkách prorůstají fialové krystaly."])
```
- Start ledge cols 0-7 h1 (`@` col 2); terraces h3 (cols 8-12), h4 (cols 20-25), h2 (cols 26-30): every rise is 1-2, one drop of 2-3. Exit R at h1 (rows 1-4 open) onto the far ledge cols 31-39 (blight patch, pylon).
- Open sky above; dead orchard (`y`), blight (`%`, `x`) and a corp pylon show the damage.

### c2_a02 — terrace climb
```
   01234567890123456789
21 ###...##############
20 #..................#
19 #..................#
18 #...............C..#
17 #....l.......#######
16 #_______.....#######
15 ########...........#
14 ########...........#
13 ########...........#
12 ########....p....x.#
11 ########...____%%%%#
10 ########...#########
 9 ########...#########
 8 ########...#########
 7 .kkkkkkk...#########
 6 .kkkkkkk.xx#########
 5 .kkkkkkk___#########
 4 .kkkkkkk############
 3 .kkkkkkk############
 2 .kkkkk==############
 1 .l@kykkk############
 0 ####################
```
- Entry L at h1 (alcove cols 0-7, hay grate step at h3), exit through the top row cols 3-5 (a03 floor hole cols 3-5). Climb: face col 8 up to T1 h6 (cols 8-10, wall-jump shaft cols 8-10), C face up to T2 h12 (cols 11-14 rest), leap left onto B face col 7, T3 h17 (cols 0-7) under the hole. A fall always lands on T1/T2/floor, never on spikes.
- Skill crystal: the shelf (cols 13-19, h18) overhangs T2; from T2 col 12 double-jump up the shelf end and climb its 2-row face. Visible from T2.

### c2_a03 — the furrow
```
   01234567890123456789
10 ####################
 9 ##.................#
 8 ##.................#
 7 ##.................#
 6 ##.................#
 5 ##.................#
 4 ##..................
 3 ##.........___......
 2 ##........l###......
 1 ##y....@.__###.IIIx.
 0 ###...########%%%%%%
```
- Arrival: floor hole cols 3-5, ledge cols 6-8 h1 (`@` col 7), step h2, wall h4 (cols 11-13) as the safe vantage over the furrow; the blight patch `III` (cols 15-17, zone cols 14-18) is 3 below it.
- Teach: drop to col 14 (safe tile), spikes burst after 0.4 s, wait out 2 s out + 0.25 retract, cross the 5-tile zone in the 1 s cooldown (~0.55 s). Jumping straight over fails (warn 0.4 s). Exit R at h1, cols 14-19 floor.

### c2_a04 — cliff orchard
```
   01234567890123456789
21 ################...#
20 ####......O.O......#
19 ####...............#
18 ####...............#
17 ####.........x.II.p#
16 ####.........__%%___
15 ####.........#######
14 ####.........#######
13 ####.........#######
12 ####.........#######
11 ####.........#######
10 ####....x....#######
 9 ####...___...#######
 8 ####...###...#######
 7 ####...###...#######
 6 ####...###...#######
 5 ####...###...#######
 4 .......###...#######
 3 .......###...FFFF###
 2 .......###...FFcF###
 1 .@y....###..lFFFF###
 0 ####################
```
- Entry L at h1 (corridor cols 0-3, `@` col 1), 3-wide wall-jump chimney cols 4-6 (wall face col 3 vs boulder column cols 7-9) up to R1 h10; leap the 3-wide cleft (cols 10-12, falling rocks at cols 10 and 12 row 20) and climb the terrace face (col 13) to T2 h17; blight patch `II` cols 15-16 on T2, exit through the top row cols 16-18 (a05 floor hole cols 16-18).
- Secret: the cleft floor (cols 10-12, row 0) is a dead-end shelf that runs straight into the terrace wall; the pocket cols 13-16, h1-h3 is all `F`, crystal `c` at col 15 h3. A lantern on the shelf (col 12) is the only hint; return by wall jumps up the 3-wide cleft.

### c2_a05 — windmill terraces
```
   0123456789012345678901234567890123456789
10 ############################WWWW########
 9 #...........................WWWW.......#
 8 #.............................O........#
 7 #.................................RRRR.#
 6 #.................................WWWW.#
 5 #.................................WWWW.#
 4 #.p.y..x......................G...WWWW..
 3 #_________..................______WWWW..
 2 ##########................==######WWWW..
 1 ##########l.@........x.II.x.######WWWW..
 0 ################...####%%#########WWWW##
```
- Arrival: floor hole cols 16-18, ledge cols 10-15 h1 (`@` col 12). Crystal-spike patch `II` cols 23-24 (zone 22-25; safe cols 19-21), hay grate step h3 (cols 26-27), guard terrace h4 (cols 28-33) under the broken sail (planks cols 28-31) that sheds a rock (col 30), tower h8 (cols 34-37; climb its face col 34, 4 rows), drop to the exit R at h1 (rows 1-4 open, cols 38-39).
- Windmill tower is planks `W` with a broken-sail roof `R`; sky stays open above it. Wall-jump/climb is not timed; the guard turns at the terrace ends.

### c2_a06 — dry well and fence
```
   01234567890123456789
21 ###...##############
20 #..................#
19 #..................#
18 #....l..x..........#
17 __________.........#
16 ##########.........#
15 ##########.......WWW
14 ##########==.....WWW
13 ##########.......L.#
12 ##########....px.LC#
11 ##########....WWWWWW
10 ##########....WWWWWW
 9 ##########....WWWWWW
 8 ##............WWWWWW
 7 ##............WWWWWW
 6 ##....x.......WWWWWW
 5 ##...___....__######
 4 .....###....########
 3 .....###....########
 2 .....###....########
 1 .y@l.###^^.K########
 0 ####################
```
- Entry L at h1 (cols 0-4, `@` col 2), climb the well drum face col 5 (h6), cross the 4-wide hollow (key `K` col 11, spikes cols 8-9 on its floor; leave by climbing the right rim face) to the plank fence face col 14 -> T2 h12 (cols 14-16), leap left to the cliff face col 9 (rest on the hay grate h15, cols 10-11) -> T3 h18 under the top hole cols 3-5 (a07 floor hole cols 3-5).
- Key/backtrack: caged crystal `C` col 18 h12 behind key block `L` (col 17, h12-13) under a plank slab; bring the key from the well. Falling from the fence drops into the shaft/hollow right half (safe), spikes only on the left half.

### c2_a07 — village edge
```
   01234567890123456789
10 ####################
 9 ####################
 8 #...............&..#
 7 #...........RRR.&..#
 6 #..........RRRRR&..#
 5 #........RRRRRRRRR.#
 4 #.........wwwwwww...
 3 #.........wwbwwow...
 2 #.........wbwwwww...
 1 #xy....@5xwwwHdww.l.
 0 ###...##########%%%#
```
```props
5 dialogue_pages = Array[String](["Ty nejsi od korporace? Uf... Táta říkal, ať nikomu neotvírám.", "Ulice jsou zavalené krystaly a hlídají je stráže. Nahoru se dostaneš jen po střechách!", "Babička Elda je úplně nahoře ve zvonici. Ta ví, kudy dál na horu."])
5 repeat_dialogue_pages = Array[String](["Po střechách nahoru! A pozor na komíny, ty syčí."])
```
- Arrival: floor hole cols 3-5, ledge cols 6-9 h1 (`@` col 7, Tobi col 8), health pack in the cottage porch (col 13). Boarded cottage (roof row 5) and a crumbling chimney; blight under the roof edge.
- Exit R at h1 (row 0 solid, rows 1-4 open at col 19) into b01, framed by a lantern.

### c2_b01 - lowest street
```
   0123456789012345678901234567890123456789
10 ############################...#########
 9 #...............wwwwwww..........&######
 8 #........wwwww..wbwwwww..........&######
 7 #........wwwow..wwwwwbw....l...l.&######
 6 #........wbwww..wwwGwxw.RRRRRRRRRR######
 5 #........wwwpw..RRRRRRR.WWWWWWWWWW######
 4 ........xRRRRR..WWWWWWW.WWWWWWWWWW######
 3 ........%WWWWW..WWWWWWW.WWWWWWWWWW######
 2 .......%%WWWWW..WWWWWWW.WWWWWWWWWW######
 1 ..@x.y%%%WWWWW^^WWWWWWW.WWWWWWWWWW######
 0 ______%%%____%%%_______%________________
```
```props
room checkpoint = true
```
- Entry left h1 (rows 1-4), checkpoint @ on the 6-tile street. Blight stair h2-h4 (cols 6-8) -> house L roof h5 -> spiked gap (cols 14-15) -> house M roof h6 (guard) -> house N terrace h7 (cols 24-33), lamps frame the up-exit hole cols 28-30.
- Gaps 2, 2 and 1 tiles, rises 1-2; the street itself is walled off by the houses.

### c2_b02 - between the houses
```
   01234567890123456789
21 ####################
20 #.......www..#######
19 #..&....www..#######
18 #..&.p..wow........#
17 #RRRRRRRwww........#
16 #WWWWWWWwww........#
15 #WWWWWWWwww.........
14 #WWWWWWWwbw.........
13 #WWWWWWWwww.........
12 #WWWWWWWwww...xy.l..
11 #WWWWWWWwwwRRRRRRRRR
10 #WWWWWWWwww<WWWWWWW#
 9 #WWWWWWWwbw<WWWWWWW#
 8 #WWWWWW>www<WWWWWWW#
 7 #WWWWWW>wwwWWWWWWWW#
 6 #WWWWWW>wwwWWWWWWWW#
 5 #WWWWWWWwwwWWWWWWWW#
 4 #WWWWWWW...........#
 3 #WWWWWWW...........#
 2 #WWWWWWW...........#
 1 #WWWWWWW....l.@.x..#
 0 ########...#########
```
- Arrive through the floor hole (cols 8-10), ledge @ cols 11-18 under the arch. Chimney gap cols 8-10: left face spiked at h7-h9 (rows 6-8), right face spiked h9-h11 (rows 8-10) - zig-zag with one wall jump; a fall drops back to b01.
- Roof of the right house (row 11, h12) is the rest ledge; exit right at rows 12-15 (b03 h1-h4).

### c2_b03 - crumbling roofs
```
   01234567890123456789
10 ####################
 9 #..................#
 8 #..................#
 7 #..................#
 6 #...................
 5 #.........R====R....
 4 ..........Wwbwo.....
 3 .....====.WwCww...p.
 2 ..........WWWWWW..WW
 1 .@.W.IIII^WWWWWWIIWW
 0 ____%____%______%%__
```
- Entry h1 -> crate h2 -> grate h4 over crystal spikes (cols 5-8) -> attic roof grates h6 (cols 11-14) -> over the spiked pit to exit ledge h3 (cols 18-19). Keep moving: grates fall 0.5 s after landing.
- Crystal in the attic (col 12, h3): intended = stop on the roof grates and drop in; the broken gable (col 15, rows 3-4) is the side gap for the checker and the way out.

### c2_b04 - eviction attic
```
   01234567890123456789
10 ############....####
 9 #wwwwwwwwwwwwwwwwww#
 8 #wwowwwwbwwwwwwwwww#
 7 #wwwwwwwwwwwwwwwwbw#
 6 .wwwwwwww==wwwwwwww#
 5 .wwwwwwwwwwwwwbwwww#
 4 .wwwww==wwwowwwwwww#
 3 .@w!wwwwwwwwwwwwwww#
 2 WWWWWwwlwwxwwwwwHwx#
 1 WWWWWWWWWWWWWWWWWWW#
 0 WWWWWWWWWWWWWWWWWWW#
```
```props
! speaker_name = "Vyhláška Korporace"
! dialogue_pages = Array[String](["Z rozhodnutí Korporace je oblast Smallville určena k těžbě.", "Obyvatelé mají tři dny na vystěhování. Neuposlechnutí bude potrestáno."])
```
- Entry ledge h3 (cols 0-4, @, notice), attic floor h2 with the health pack; two crumbling beams (h5, h7) to the roof hatch cols 12-15. Falling is harmless.

### c2_b05 - market roofs
```
   0123456789012345678901234567890123456789
10 ###########################....#########
 9 #................................O.....#
 8 #wwwwwwwww..............................
 7 #wwwwwwwww........................&&....
 6 #wwwwwwwww................l....lG.&&....
 5 #wwwwwowww...............RRRRRRRRRRR..p.
 4 #wwwwwwwww........x.G....WWWWWWWWWWWRRRR
 3 #wwbwwwwbw......RRRRRRRR.WWWWWWWWWWWWWWW
 2 #wwwwwwwww......WWWWWWWW.WWWWWWWWWWWWWWW
 1 #wpwwxw@wwWW....WWWWWWWWxWWWWWWWWWWWWWWW
 0 #___________....________%_______________
```
- Arrive through hole cols 12-15, ledge cols 1-11 (@). Roof 1 h4 (guard), roof 2 h6 (guard, lamps frame the ceiling hole cols 27-30 up to b05b), chimney h8 (rock above), roof 4 h5 -> exit right rows 5-8 (b06 h5).

### c2_b05b - clock attic
```
   01234567890123456789
10 ####################
 9 #wwwwwwwwwwwwwwwwww#
 8 #wwwwwwbwwwwwwwwwbw#
 7 #wooowwwwwwCIIwwwww#
 6 #wooowwwwbwWWWWwww<#
 5 #wooowwwwwwWWWWwww<#
 4 #wwwwwwwwwwWWWW>www#
 3 #wwwwwwwwwwWWWW>www#
 2 #wwwwwwwwwwwwwwwwww#
 1 #ww@wlwwwwwwIIwwxww#
 0 #######....#########
```
- Side gauntlet 4/5: hole cols 7-10 up from b05, ledge cols 1-6 (@). Low passage under the leaning block (crystal spikes), shaft cols 15-18 with spiked faces (left rows 3-4, right rows 5-6) - wall-jump up, then crystal spikes before the crystal (col 11, h8). Return: step left into the hole. Outer walls closed.

### c2_b06 - chimney stack
```
   01234567890123456789
21 ##....##############
20 #..................#
19 #..................#
18 #..p....V..x.......#
17 RRRRRRRRRRRRRR...&&&
16 WWWWWWWWWWWWWW...&&&
15 WWWWWWWWWWWWWW...&&&
14 WWWWWWWWWWWWWW...FF&
13 WWWWWWWWWWWWWW..lFc&
12 WWWWWWWWWWWWWW.WW&&&
11 #................&&&
10 #................&&&
 9 #...........V....&&&
 8 ...........&&&...&&&
 7 .......V...&&&...&&&
 6 ......&&&..&&&...&&&
 5 ..@...&&&..&&&...&&&
 4 RRRR..&&&..&&&...&&&
 3 WWWW..&&&..&&&...&&&
 2 WWWW..&&&x.&&&...&&&
 1 WWWW..&&&..&&&...&&&
 0 ####################
```
- Enter left h5 (@ cols 0-3), vent-topped stacks (h7, h9: pass in the idle window), 3-wide shaft cols 14-16 up the house face to the roof (h18) with one more vent, hole cols 2-5 at the top. Top-screen left wall closed.
- Secret (c2_b06 crystal): 2x2 `F` pocket in the right stack at rows 13-14, reached from the dead-end shelf (cols 15-16, h13) with a lone lantern facing a blank wall; nothing else marks it.

### c2_b07 - churchyard
```
   01234567890123456789
10 ####################
 9 #................&&#
 8 #.............T..&&#
 7 #.............RRRRRR
 6 #.............&&&&&&
 5 #.............&&&&&&
 4 #........##....qqbq.
 3 #........##....oqqo.
 2 #........##.#..qdqq.
 1 #p.....@.##x#.lqdqq.
 0 ##....##############
```
- Arrive through the hole cols 2-5, ledge cols 6-8 (@) is hidden from the turret by the wall (cols 9-10, h5). Turret on the church cantilever (col 14, h8) covers the yard; gravestone col 12 as cover, portico under the overhang is safe. Exit right h1 (rows 1-4).

### c2_c01 — church nave
```
   01234567890123456789
10 &&&&&&&&&&&&&&&&&&&&
 9 &qqqqqqqqqqqqqqqqqq&
 8 &qqoqqqqqoqqqqqoqqq.
 7 &qqoqqqqqoqqqqqoqqq.
 6 &qqqqqqqqqqqqqqqqqq.
 5 &qqqqqqqqqqqqqqqqqq.
 4 .qqqqqqqqqqqqqq&&&&&
 3 .qqqqqqq====qqq&&&&&
 2 .qqqqqqqqqqqqqq&&d&&
 1 .l@qqWWWqqlqqxq&&&&&
 0 &&&&&&&&&&&%%%&&&&&&
```
```props
room checkpoint = true
```
- Enter L at h1 (cols 0-4 flat, `@` col 2, lamp), pew h2 (cols 5-7), grate h4 (cols 8-11), gap 3 to the gallery h5 (cols 15-19) = the tower door; exit R at h5 (rows 5-8 open). Blight bursts through the nave floor (cols 11-13); a fall just lands on the floor.

### c2_c02 — bell tower
```
   01234567890123456789
32 &&&&&&&&&....&&&&&&&
31 &&.BB.............&&
30 &&BBBB............&&
29 &&BBBB............&&
28 &&.......====..^^C&&
27 &&............&&&&&&
26 &&................&&
25 &&...WWWW.........&&
24 &&................&&
23 &&..l.....x.x.....&&
22 &&&&&&&&&&&&&&....&&
21 &&qqqqqqqqqqqqqqqq&&
20 &&qqqqqqqlqqqqoqqq&&
19 &&qbqWWWWWWWWWqqqq&&
18 &&qqq&&&qqqqqqqqqq&&
17 &&qqq&&&qqqqqqqbqq&&
16 &&qqq&&&qqqqqqqqqq&&
15 &&qqq&&&qoqqqqqqqq&&
14 &&qqq&&&qqqqqqqqoq&&
13 &&qqq&&&qqqqqqqqqq&&
12 &&lqq&&&qxqqqqqqqq&&
11 &&&&&&&&&&&&....&&&&
10 &&qqqqqqqqqqqqqqqq&&
 9 &&qqqqqqqqqqqqqqqq&&
 8 qqqqqqqqqqqqWWWWqq&&
 7 qqqqqqqqqqbqqqqqqq&&
 6 qqqqqq====qqqqqqqq&&
 5 qq@qqqqqqqqqqqqqqq&&
 4 &&&&&qqoqqqqqqqqqq&&
 3 &&&&&qqqqqqqqqqqbq&&
 2 &&&&&qqqqqqqqqqqqq&&
 1 &&&&&qlqqqxqxqqqqq&&
 0 &&&&&&&&&&&&&&&&&&&&
```
- Enter L at h5 (rows 5-8 open, gallery ledge cols 0-4 with `@`). Screen 1: grate h7 (cols 6-9, one-tile gap), plank h9 (cols 12-15), then straight up through the floor hole (cols 12-15) to the rest floor h12 (cols 2-11 / 16-17). Screen 2: wall-jump ladder in the 3-wide shaft (cols 2-4, left wall vs the pillar) up to the beam h20, ~2 s of climbing and a fall lands on the rest floor; hole in the next floor at cols 14-17 right beside the beam end. Screen 3 = open bell chamber (sky shows): rest floor h23 (cols 2-13), plank h26, grate h29, exit through the top at cols 9-12. Left walls of the two upper screens are closed.
- Skill crystal: ledge h28 (cols 14-17) with two spikes (cols 15-16) in front of the crystal (col 17): land on col 14, hop the spikes, hop back; reached from the grate/plank line with a double jump.

### c2_c03 — bell platform
```
   01234567890123456789
10 RRRRRRRRRRRRRRRRRRRR
 9 &&..RR..RR..RR..RR&&
 8 &&.............BB.&&
 7 &&............BBBB&&
 6 &&............BBBB&&
 5 &&................&&
 4 &&..................
 3 &&qqqqqqq....qqqqq..
 2 &&qqqbqqq....qbqqq..
 1 &&lq@qqHq....qq4qx..
 0 &&&&&&&&&....&&&&%%&
```
```props
4 dialogue_pages = Array[String](["Odboj tě posílá? Pak neseš špatné zprávy pozdě. Korporace dnes ráno spustila vrt přímo pod vesnicí.", "Do Parního města vede jen stará horská stezka nad zvonicí. Jestli se svah utrhne, zůstanou jen útesy.", "Lez, chlapče. My ostatní... my to tu nějak vydržíme."])
4 repeat_dialogue_pages = Array[String](["Stezka nad zvonicí. Lez!"])
```
- Arrive from below through the floor hole (cols 9-12); ledges on both sides (left h1 cols 2-8 with `@` and health pack, right cols 13-19 with Elda). Open arches (back wall only up to h3) show the sky; bell hangs from the roof. Exit R at h1 (rows 1-4 open), blight crystals in the floor corner.

### c2_c04 — roof ridge and spire
```
   0123456789012345678901234567890123456789
10 ##############################....######
 9 ........................kkkkkkkkkkkkLkk#
 8 ........................kkkkkkkkxkkkLCk#
 7 ................K............###########
 6 ...............WWW...........###########
 5 .............................###########
 4 ......................&&...#############
 3 ....................x.&&...#############
 2 .................x.RRR&&..x#############
 1 ..@..l..........RRRRRR&&################
 0 RRRRRRR...====RRRRRRRR&&################
```
- Enter L at h1 (belfry roof cols 0-6, `@`). Pit 3 (cols 7-9, deadly), crumbling slates (cols 10-13), ridge stepping up h1-h3 (cols 14-21), spire (cols 22-23, top h5), leap 2 to the cliff foot h2 -> step h5 -> wall climb/jump up the ledge face to h8 (cols 29-39), exit through the top at cols 30-33 (c05 floor hole cols 10-13). Floor gaps are deadly (no room below).
- Key detour: `K` on the weathervane plank h7 (cols 15-17), reached from the spire top with a double jump; a fall lands safely on the ridge. Cage: one key block `L` (col 36, h8-h9) closes the nook (cols 37-39) with the crystal; the ledge before it (cols 33-35) is safe.

### c2_c05 — cliff face
```
   01234567890123456789
10 ##....##############
 9 ##kkkkkkOkkkkkkkk###
 8 ##kkkkkkkkkkkkkkk###
 7 #####kkkkkkkkkkkk###
 6 #####kIIkkkkkkkkk###
 5 #####k####kkkkkkk###
 4 #####k####kkkkkkk###
 3 #####k####kkkkkkk###
 2 #####k####kkkkkkkFF#
 1 #####k####kkxkk@lFc#
 0 ##########....######
```
- Arrive through the floor hole (cols 10-13), `@` ledge cols 14-16. Grab the pillar face (col 9) right beside the hole, climb to the rest ledge h6 (cols 6-9; crystal spikes on cols 6-7: bait, step back, cross in the cooldown; a falling rock hangs over col 8), hop 2 left-up to the h8 shelf (cols 0-4) and out through the top at cols 2-5. Falling returns to the floor or into c04.
- Secret: the ledge by the hole runs straight into a tall rock mass at the right edge (cols 17-19) with a lone lantern; the whole pocket (cols 17-18, h1-h2) is fake rock (`F`), crystal at col 18; col 19 stays solid so nobody walks out of the room. Nothing differs visually.

### c2_c06 — lookout ledge
```
   01234567890123456789
10 ####################
 9 ##kkkkkkkkkkkkkkkk##
 8 ##kkkkkkkkkkkkkkkk##
 7 ##................##
 6 ##................##
 5 ##................##
 4 ##..................
 3 ##..................
 2 ##..................
 1 ##.....@.!.yx.p..l..
 0 ##....##############
```
```props
! speaker_name = "Otřesy"
! dialogue_pages = Array[String](["Hora se otřese. Hluboko pod vesnicí řve korporátní vrták a celý svah se dává do pohybu."])
```
- Arrive through the floor hole (cols 2-5) beside the left wall; long safe ledge h1 (cols 6-19, `@`), `!` Otřesy at col 9, dead tree, blight crystal and a corp pylon on the ledge; rock overhang above. Exit R at h1 (rows 1-4 open) marked by a lantern.

### c2_d01 — rockfall trail
```
   0123456789012345678901234567890123456789
10 ########################################
 9 ########################################
 8 #kkkkk#########kkkkkkkkkkkkkkOkk.......#
 7 #kkkkk#########kkkkkkkkkkkkkkkkk........
 6 #kkkkk#########kkkkkkkkkkkkkkkkk........
 5 #kkkkk..O...O..kkkkkkkkkkkkkkkkk........
 4 ...............kkxkkkkkkkkkkkkxk........
 3 ................###========#####..III.l.
 2 ................###........#############
 1 ..@.py........#####.IIIIII.#############
 0 ________%%%%________________%%%_________
```
```props
room checkpoint = true
```
- Entry h1 (floor cols 0-5, `@` col 2, row 0 solid / rows 1-4 open). Beat 1: low overhang (cols 6-14) with two scree rocks that shake loose when you walk under (keep moving). Beat 2: step to h4, then a 8-tile crumbling bridge (grates h4, cols 19-26) over a trench of erupting crystal spikes (cols 20-25): cross at a run, the grates drop 0.5 s after landing. A fall lands on the trench floor (h1, cols 19 and 26 are free of spikes) and the h4 ledge is a DJ/wall jump away.
- Beat 3: ledge h4 with one more rock (col 29), then a step down to h3 and a 3-wide crystal-spike patch (cols 34-36) on the trail: bait it, wait out the 2 s retract, or double jump over. Exit R at h3 (rows 3-7 open, cols 37-39 safe floor, lamp col 38) into d02.

### c2_d02 — survey drone
```
   01234567890123456789
10 #############.....##
 9 ####............l.##
 8 #kkkkkkkkkkkk..#####
 7 kkkkkkkkkDkkk..#####
 6 kkkk###kkkkkk#######
 5 kkkk###kkkkkk#######
 4 kkkk###kkkk#########
 3 k@ky###kkkx#########
 2 #######..###########
 1 #######.x###########
 0 #######%%#########__
```
```props
D patrol_distance = 24.0
```
- Entry h3 (plate cols 0-3, `@` col 1, rows 3-8 open at col 0) from d01. The boulder (cols 4-6, h7) hides the plate from the drone (col 9, h7, patrol +-24 px): climb it and the eye locks (0.5 s red sight); drop back left behind the boulder and the charge flies into its right face (stun 1 s) - then step off the boulder onto it to stomp (bounce + refill), or just run past while it is stunned. Falling only reaches the gully floor (h1).
- Scree stairs h3 -> h5 -> h7 -> h9 (cols 9-17, rises 2); the top ledge (cols 15-17, h9) sits under the 5-wide hole (cols 13-17, row 10) with the lamp: jump + double jump out of it into d03 (its floor is ~h12.7 in d02 units, apex from h9 is ~h14.5). Right wall closed.

### c2_d03 — collapsing switchbacks
```
   01234567890123456789
21 ####################
20 ########Okk####O...#
19 #####...kkk####....#
18 #####C..kkk####.....
17 ########kkk####.....
16 ########kkkkOkk.....
15 ########kkkkkkk..l..
14 ########kkkkkkk.####
13 ########kkkkkkkp####
12 #kkkkkkkkkkkkkk#####
11 #kkkkkkkkkykGkk#####
10 #kkkkkkkk###########
 9 #kkkkkkkk###########
 8 #kkkk====###########
 7 #kxkkkkkkkkkkkk....#
 6 ####kkkkkkkkkkk....#
 5 ####kkkkkkkkkkk....#
 4 #######kkkkkkkk....#
 3 #######kkkkkkkk....#
 2 ##########kkkkk....#
 1 ##########k@kkk...##
 0 _%%%%#####___.....##
```
- Arrive through the floor hole (cols 13-17, from d02); floor ledge cols 10-12 with `@` (col 11). Switchback 1 climbs left: A h3 -> B h5 -> C h7 (cols 7-9 / 4-6 / 1-3), switchback 2 returns right over crumbling grates (h9, cols 5-8) onto the guard shelf (h11, cols 9-14, guard patrols it, a rock hangs over it at col 12). Falling off the grates drops onto B (safe).
- Main path: shelf -> F (h13, cols 15-19) -> exit plate G (h15, cols 16-19), a rock over F (col 15). Exit R at h15 (rows 15-18 open) into d04's plate at h4 (same row).
- Skill detour (crystal visible in the notch, h18 cols 5-7): from the shelf's left end climb the face (col 7, h13-h17) in the shaft cols 8-10 and mantle onto the notch; a rock at the ceiling (col 8) shakes loose while you climb - step off or time it. Dead end, drop back down.

### c2_d04 — shepherd's hut
```
   01234567890123456789
10 ####################
 9 #.RRRRRR..RRRRR....#
 8 #..wwwwwwwwwww......
 7 ...wwwwwwwwwww......
 6 ...wwbwwwwwoww......
 5 ...wwwwdwwwwww......
 4 .@.wwwwdw5wwHwlxxp..
 3 _______________%%%__
 2 ####################
 1 ####################
 0 ####################
```
```props
5 dialogue_pages = Array[String](["Ty jsi taky vylezl až sem? Znám zkratku, kudy chodí kozy... Jenže babička zůstala ve zvonici!", "Vrátím se pro ni. Ty lez dál a řekni odboji, že Smallville se nevzdá!"])
5 repeat_dialogue_pages = Array[String](["Lez! Já se vrátím pro babičku."])
```
- Breather: no hazards. Flat floor h4 (entry from d03's plate, rows 4-8 open at col 0, `@` col 1), a caved-in shepherd's hut (roof gap cols 8-9, boarded window) with Tobi (col 9) and a health pack (col 12); blight crystals and a pylon crowd the exit.
- Exit R at h4 (rows 4-8 open at col 19). d05's entry plate is one tile higher (h5): a plain hop up.

### c2_d05 — scree chute
```
   01234567890123456789
21 ########...#########
20 ####.............###
19 ####.......l.....###
18 ####...######....###
17 ####......O......###
16 #######..........###
15 ####.............###
14 ####.....###....<###
13 ####............<###
12 #######........C<###
11 ####.........D..<###
10 ####.....###....<###
 9 ####............<###
 8 ....###..........###
 7 .....O...x.II.l..###
 6 ........############
 5 ..@.....############
 4 #####...############
 3 #####...############
 2 #####...############
 1 #####.II############
 0 #####%__#########___
```
```props
D patrol_distance = 12.0
```
- Entry from d04 at h5 (plate cols 0-4, `@` col 2; rows 5-8 open at col 0, left wall of the top screen closed). Zigzag of scree stones, rises 2: heap R1 (h7, cols 8-16, crystal spikes cols 11-12, wall spikes cols 16 h10-15), L2 h9, A h11, B h13, C h15, D h17 (stones cols 4-6 / 9-11), then the top slab S (h19, cols 7-12) under the 3-wide hole (cols 8-10). Falls end on the trench (h1, spikes cols 6-7) or an earlier stone; rocks hang under L2 (col 5) and S (col 10) and shake when you stand below.
- Trick crystal (col 15, h12, visible): the drone hovers over the heap (col 13, h11, +-12 px). Easy way: let it charge, stomp it for a bounce + refill and reach the crystal. Hard line without it: run along the heap past the spikes and double jump from its right end or a long jump from stone A. Wall climbing to it is blocked by the spike strip on the right wall.

### c2_d06 — corp checkpoint
```
   0123456789012345678901234567890123456789
10 ########################################
 9 ########################################
 8 Z..........kkkkkkkkkkkkkkkkkkkkkk......B
 7 Z..........kkkkkkkkkkkkkkkkkkkkkk......B
 6 Z..........kkkkkkkkkkkkkkkkkkkkkkT.....B
 5 Z..........kkkkkkkkkkkkkkkkkkkkkkBBBBBBB
 4 ZZZ........kkkkkkkkkkkkkkkWWkkkkk.......
 3 Z.L........kkkkkkkkkkkkkkkWWkkkkk....K..
 2 ZCL........kkkkZZkkkkkkkkWWWWkkkk....WW.
 1 Z.L.l@.....kgpkZZkkkGkxkWWWWWWkVk..V.WW.
 0 ZZZ_____..._____________________________
```
```props
V2 offset = 1.0
```
- Arrive up through the floor hole (cols 8-10 from d05), ledge cols 3-7 with `@` (col 5). Corp container (cols 0-2) with the crystal behind a single key block `L` (col 2, h2-h4): visible at once, locked. Road east: scrap barricade (h3, cols 15-16), guard on cols 17-23, crate hump (peak h5, cols 26-27) = cover.
- Turret on the brass catwalk (col 33, h6, standing on the slab, sees 13 tiles): from the hump shadow run cols 28-32 (vent at col 31, `V2 offset = 1.0`), then you are under the catwalk out of its sight. Key `K` on the crate stack (h3, cols 37-38) under the catwalk, vent at col 35; take it, backtrack west to the container (the block touched first frees the crystal), come back for the exit. Exit R at h1 (rows 1-4 open).

### c2_d07 — old mountain road
```
   01234567890123456789
10 ####################
 9 #.........qqqqqqqqq#
 8 #.........qqqqqqqoq#
 7 #.........qqqqqqqqq#
 6 #.........qqoqqoqqq#
 5 #.........qqqqqqqqq#
 4 ..........qqqbqqqqq#
 3 ..........x........#
 2 .........###.......#
 1 ..@.p.######..gl.El#
 0 ____________________
```
```props
E next_level = "res://levels/c3/chapter3.tscn"
E stage_title = "KAPITOLA 2: SMALLVILLE"
E stage_index = 2
E max_stage_crystals = 12
```
- Entry h1 (floor cols 0-5, `@` col 2, rows 1-4 open at col 0); rubble steps h2 (cols 6-8) and h3 (cols 9-11, blight crystal), then the road h1 again (cols 12-19). Steam City's lit walls fill the back; lamps frame `E` (col 17). Right wall and top closed.
