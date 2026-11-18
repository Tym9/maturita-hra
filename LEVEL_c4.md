# LEVEL c4 — The North Face (Severní stěna)

Steam City ends at its citadel; above it the mountain is bare rock, snow and wind. The corporation's true seat — the **Headquarters (Hlavní sídlo)** — is carved into the cliff under the summit, and behind its gate the great shaft drops to the planet's core. A corp cable car hauls the crystals from the city up to it. The hero leaves the citadel through its back gate and **climbs the north face** to the HQ gate: scree and cliffs above the city, the cable-car pylons and stations, the storm on the knife-edge ridge, and the fortified gate in the rock. At the gate the descent begins (→ `LEVEL_c5.md`, Otis waits in the old workshops behind it).

- **Kit:** run, jump, double jump (DJ), wall climb/jump (8 s stamina), wrench. No dash, no hook.
- **New here:** **mountain wind** (`}`, gusts across the whole room, a03). Develops: falling rocks (`O`), crumbling grates (`=`, rotten boardwalks and snow cornices), springs (pneumatic maintenance lifts), vents (de-icers on the pylons), belts (stations), crystal spikes (`I`, blight bursting from the rock), guards, turrets, drones, presses (the HQ gate only, d05/d07).
- **Signature:** **open mountain faces in the wind.** Travel is ↑ and →. Gusts push you back or off; wait out a gust in shelter, move in the lull.
- **Look:** `J` mountain rock (the builder puts a snow cap on every top that has air above it — just draw `J`), `#` carved stone (HQ fortifications, cable-car foundations), `B` brass (pylon girders, machinery, the HQ gate), `Z` scrap (braces, sheds), `W` planks (boardwalks, the refuge hut), `&` brick (only at the citadel back gate in a01); back walls `k` dark rock (caves, crevices — sparingly), `w` planks (hut), `q` brick, `o` lit windows (stations, HQ), `d` doors. Decor `y` wind-bent dead pines, `x` blight crystals, `p` corp pylons/searchlights, `l` lamps (stations, hut, HQ), `g` corp banners (stations, HQ), `h` stove fire (hut), `a` antennas. Mostly air `.`: the backdrop (peaks, sea of clouds over the city, the cable-car line, the HQ lights) must show in every outdoor room.
- **Rules:** LEVEL_DESIGN §1–2, §5, ASCII format §6. Crystals: 12, route types never repeat back to back.

## Open rooms — not boxes (read first)

Since 2026-10-19 a room edge with **no neighbouring room** is an invisible wall (left, right and top; you may jump 24 px over the top and fall back). Only falling out the **bottom** where no room continues kills. So, like Celeste:

- **Outdoor rooms have no ceiling and no framing walls.** Leave the top rows as air (sky). Draw the terrain as natural masses: cliffs, ledges, overhangs, pinnacles, boulders, a lone outcrop; the outer columns may be air wherever no neighbour is (the invisible wall holds the player). Never draw a solid top row or a full-height wall just to close the room.
- **Buildings stand in the open:** the refuge hut, the stations, the guardroom are structures inside the room with sky around them — not the room's walls. Even caves and shafts open to the sky somewhere (a mouth, a window, a gap).
- **Connections:** where two rooms share an edge, the terrain on both sides matches exactly (same floor height, same solid rows at the edge), so the mountain continues. A shared edge is open only where the path goes; close the rest with terrain on both sides (otherwise it is a second exit).
- **Up-exits:** open air in the top row above the lower room's last ledge; the room above has a ledge with `@` right over that spot (the game boosts an upward room crossing by a jump). Falling back down into the lower room is fine (no death).
- **Pits:** a bottom-row gap with no room below = bottomless pit (death). Allowed as stakes, never under a respawn. If a room is below, the gap drops you into it instead.
- **Respawns:** every entrance gets a ≥3-tile safe ledge with `@` (and out of the wind's reach: see wind rules).
- **Climbing:** never more than ~4 s of continuous wall climbing without a ledge (stamina 8 s); a 1×2 climb gets a rest ledge each screen.
- **Secrets must be invisible:** fill the whole pocket with `F` (drawn like the rock around it, snow caps included) and put its crystal as `c`; keep a solid tile between the pocket and the room edge. Hint only by geometry (a ledge into the rock, a dead-end shelf, a lone pine).
- Other crystals (skill, key, trick, gauntlet) are visible from the main path. Key cages: one key opens one `L` block; make the block you touch first the one that frees the crystal.

## Element rules

- **Wind `}`** (new): one `}` anywhere in a room (an air cell, conventionally top-left) = gusts across the **whole room**. Defaults: blows **left** (`Vector2(-1, 0)`, against the travel) at 80 px/s (running is 150), cycle 3.2 s: 0.4 s telegraph (first snow streaks) → 1.2 s gust → 1.6 s calm. Props: `} direction = Vector2(1, 0)` (tailwind), `} strength = 100.0`, `} offset = 1.6`, `} period = 3.6`, `} on_time = 1.0`. Horizontal only.
  - **The checker ignores wind:** every move it finds must also work in a calm. Between two places where you can stand out of the gust's harm, at most ~1.5 s of movement.
  - A gust pushes even a standing player (~6 tiles over a gust unless you hold against it). So every place where the player must wait (respawn ledges, before a jump over a pit) is **sheltered**: a rock or wall on the downwind side, or ≥7 tiles of floor downwind before any drop.
  - On a wall: wind blowing **into** the face pins you (safe); wind blowing **away** from a face peels you off. Faces you must climb in a gusty room face the wind (the wind blows into them), or have a ledge every ~3 tiles.
  - Stakes come from what lies downwind: a pit, spikes, the room's bottomless edge.
- **Falling rock `O`:** hangs under a ceiling/overhang, drops once when you pass under (dust + shake telegraph), resets on death.
- **Grate `=`** (2-tile pieces): rotten boardwalk / snow cornice, collapses 0.5 s after landing, returns. The checker treats it as solid: never chain more than two without a solid rest.
- **Spring `S`:** launches ~5.6 tiles up and refills the DJ (`S direction = Vector2(1, -1)` for an angled one).
- **Vent `V`:** blasts 4 tiles up (idle 2.0 s, warn 0.5 s, blast 1.0 s), 1 HP + knockback, not death; `V2 offset = 1.0` staggers them.
- **Belt `~`:** 60 px/s right by default (`~ speed = -60` for left). The checker treats it as floor: never require its speed; keep spikes ≥6 tiles past its end.
- **Crystal spikes `I`** (floor): burst 2 tiles up when you come near, retract after 2 s. The checker ignores them: give 3 safe tiles before and after.
- **Press `P`** (d05, d07 only): as in LEVEL_c3 (housing solid, head strikes down `reach` tiles, period 2.0 s, ~1.55 s safe; `P reach = n`, `P2 offset = 0.6`); never make the player wait under a head; 3 safe tiles before/after.
- **Turret `T`:** falls with gravity, stand it on a floor; give cover on its approach; a perch wider than 1 tile under it blinds it. **Drone `D`:** hovers, patrols ±50 px (`D patrol_distance = 24.0`), sees 120 px, charges straight, stuns on walls: give it rock to crash into. **Guard `G`:** patrols a floor, turns at walls and ledges.

## Dialogue (place via props, text verbatim)

- **a01** `!` speaker_name `"Severní stěna"`, dialogue_pages `Array[String](["Za citadelou končí město i cesta. Dál vede jen zásobovací stezka, nad ní holá skála, sníh a vítr.", "Vysoko ve stěně pod vrcholem blikají rudá světla — Hlavní sídlo korporace, vytesané do hory. Za jeho branou začíná šachta k jádru."])`
- **a07** `!` speaker_name `"Deník horníka"`, dialogue_pages `Array[String](["Den 40. Korporace nás vyhnala z chaty. Prý tu povede lanovka k novému sídlu ve skále.", "Na hřebeni fouká v nárazech. Kdo chce projít, čeká v závětří, až vítr na chvíli ztichne."])`
- **b01** `!` speaker_name `"Hlas Korporace"`, dialogue_pages `Array[String](["Pozor, provoz lanovky. Nepovolaným osobám vstup zakázán.", "Náklad krystalů pro Hlavní sídlo odjíždí každých dvanáct minut. Korporace děkuje za vaši přesnost."])`
- **b04** `!` speaker_name `"Údržbářský deník"`, dialogue_pages `Array[String](["Kladka číslo tři zase zamrzla. Vedení chce provoz i v bouři.", "Nad hřebenem se v noci zvedají kameny do vzduchu. Prý anomálie. Prý to nic není."])`
- **c01** `!` speaker_name `"Hřeben"`, dialogue_pages `Array[String](["Hřeben se ztrácí ve vánici. Sídlo korporace je odsud jen rudá světla ve skále nad sedlem."])`
- **c04** `!` speaker_name `"Vesper (vysílačka)"`, portrait_texture `"res://assets/npc/vesper_portrait.png"`, dialogue_pages `Array[String](["Matěji, slyšíš mě? Bouře to ruší... Jsi na hřebeni? Tak vysoko se nikdo z nás nedostal.", "Brána sídla je ve skále nad sedlem. Otis tě čeká ve starých dílnách za ní — odtud už vede cesta jen dolů, k jádru."])`
- **c07** `!` speaker_name `"Hlavní sídlo"`, dialogue_pages `Array[String](["Za sedlem se zvedá skalní stěna a v ní, vytesané do hory, sídlo korporace: mosazné brány, reflektory, lanovka mizící ve skále.", "Někde pod tím vším bije reaktor."])`
- **d01** `!` speaker_name `"Hlas Korporace"`, dialogue_pages `Array[String](["Narušení perimetru Hlavního sídla. Uzavřít brány. Vypustit drony."])`
- **d04** `!` speaker_name `"Rozkaz velení"`, dialogue_pages `Array[String](["Smallville evakuovat do konce měsíce. Těžbu ve Vrtu 7 nezastavovat.", "Anomálie kolem jádra dál rostou. Pokud reaktor selže, hora to nepřežije."])`
- **d07** `E` next_level `"res://levels/c5/chapter5.tscn"`, stage_title `"KAPITOLA 4: SEVERNÍ STĚNA"`, stage_index `4`, max_stage_crystals `12`
- **a01, b01, c01, d01**: `room checkpoint = true`

## Layout

Fixed positions (screens, top-left; y grows downward, so the climb goes to negative y). Don't move or resize rooms. Rooms touch only their neighbours in the chain (plus the b05b branch), so every shared edge below is a real connection.

```layout
chapter res://levels/c4/chapter4.tscn
start_items wrench
hint_up_exits
c4_a01 0 0
c4_a02 2 -1
c4_a03 2 -2
c4_a04 3 -2
c4_a05 5 -3
c4_a06 5 -4
c4_a07 6 -4
c4_b01 7 -4
c4_b02 8 -6
c4_b03 9 -6
c4_b04 11 -6
c4_b05 11 -8
c4_b05b 10 -8
c4_b06 11 -9
c4_c01 13 -9
c4_c02 15 -9
c4_c03 15 -11
c4_c04 16 -11
c4_c05 17 -11
c4_c06 18 -13
c4_c07 19 -13
c4_d01 20 -13
c4_d02 21 -15
c4_d03 22 -15
c4_d04 23 -15
c4_d05 23 -17
c4_d06 24 -17
c4_d07 25 -18
```

## Rooms

Fixed section boundaries: **a07 → b01**, **b06 → c01** and **c07 → d01** are right-edge crossings with the floor at **h2** (rows 0–1 solid on both sides of the edge), rows 2–6 open on both sides; rows 7+ free (open sky is fine). All other connections are agreed inside a section. "floor" = you arrive by jumping up through the bottom edge; "top" = you leave through the top edge.

| id | size | from → to | challenge | elements | diff | crystal | CP |
|---|---|---|---|---|---|---|---|
| c4_a01 | 2×1 | start (L) → a02 (R, h4) | The citadel's back gate (brick alcove) opens onto the bare mountain: the supply road with a guard and a searchlight, rock steps and two short bottomless pits, open sky over the city's smog. | guard, pits, `!` | 1 | — | ✔ |
| c4_a02 | 1×2 | a01 (L, bottom screen, h4) → a03 (top) | Scree field: climb big boulders and ledges up two screens; falling rocks hang under two overhangs. No wind. | falling rocks, climb | 2 | — | — |
| c4_a03 | 1×1 | a02 (floor) → a04 (R) | **Wind** intro: a wide snowy shelf, gust ← pushes you back along it toward a rock at its left end (no pit downwind); then a short climb to the exit in a calm. | **wind** | 1 | — | — |
| c4_a04 | 2×1 | a03 (L) → a05 (R, right screen) | Old miners' trail: rotten boardwalks (`=`) bolted to the cliff over a bottomless drop, gust ←, boulders to shelter behind between the runs. | wind, grates, pits | 3 | **Skill detour**: crystal on a pinnacle out over the drop, a harder wall-jump line. | — |
| c4_a05 | 1×2 | a04 (L, bottom screen) → a06 (top) | Chimney: a narrow crack in the face climbed by wall jumps (sheltered, no wind), falling rocks inside, a rest ledge each screen; the crack opens to the sky at the top. | wall jumps, falling rocks | 3 | **Secret passage**: hidden pocket in the chimney wall (`F` + `c`). | — |
| c4_a06 | 1×1 | a05 (floor) → a07 (R) | Overhang: climb out from under a big overhang onto the open face; gust → pins you to the face while climbing, but throws you when you jump off it. | wind, overhang | 3 | **Key/backtrack**: key on a ledge under the overhang, caged crystal near the exit. | — |
| c4_a07 | 1×1 | a06 (L) → b01 (R, h2 fixed) | Breather: the abandoned miners' refuge hut on a ledge (planks, stove fire `h`), health pack, `!` Deník horníka; sky all around. | `!`, `H` | 1 | — | — |
| c4_b01 | 2×1 | a07 (L, h2 fixed) → b02 (top, right screen) | Lower cable-car station: a platform on the cliff, belts carry crystal crates to the gondola dock, a guard on the platform, a turret on the station roof (cover on the approach), `!` Hlas Korporace loudspeaker. | belts, guard, turret, `!` | 2 | — | ✔ |
| c4_b02 | 1×2 | b01 (floor) → b03 (R, top screen) | First pylon: a steel lattice tower (`B` girders, `Z` braces) climbed by wall jumps and maintenance springs; gusts ← (the climbing faces take the wind). | springs, wall jumps, wind | 3 | **Mechanic trick**: an angled maintenance spring flings you to a cable bracket off the path (checker-reachable via the spring sim). | — |
| c4_b03 | 2×1 | b02 (L) → b04 (R) | Under the cable: maintenance catwalks hung from the cable (planks, grates) over a bottomless drop; a drone patrols between them; gusts ←. | drone, grates, wind, pits | 3 | — | — |
| c4_b04 | 1×1 | b03 (L) → b05 (top) | Breather: maintenance shed on a pylon foundation, health pack, `!` Údržbářský deník. | `!`, `H` | 1 | — | — |
| c4_b05 | 1×2 | b04 (floor) → b06 (top); branch L (top screen) ↔ b05b | Second, taller pylon: steam de-icer vents on the girders, grates, a turret on a platform with cover. | vents, grates, turret | 3 | **Secret passage**: hidden niche in the pylon's foundation block (`F` + `c`). | — |
| c4_b05b | 1×1 | b05 (its R edge) ↔ b05 | Side gauntlet, the frozen pulley: gusts + grates + a spring over bottomless gaps; crystal at the far (left) end; return the same way. Open sky, but its left and top edges have no room (invisible walls). | wind, grates, spring | 4 | **Side gauntlet** | — |
| c4_b06 | 2×1 | b05 (floor, left screen) → c01 (R, h2 fixed) | Upper station: loading belts, a guard on the dock and a drone in the gondola bay; the bay opens to the sky and the ridge beyond. | belts, guard, drone | 3 | — | — |
| c4_c01 | 2×1 | b06 (L, h2 fixed) → c02 (R) | Onto the knife-edge ridge: open sky everywhere, a strong **tailwind** gust → (`} direction = Vector2(1, 0)`, `} strength = 100.0`) throws you along the crest; jump the notches (pits) with or without it. `!` Hřeben. | wind →, pits, `!` | 2 | — | ✔ |
| c4_c02 | 1×1 | c01 (L) → c03 (top) | Avalanche couloirs: rocks hanging under a rock lip, crumbling snow cornices (`=`) over notches, gust ←. | falling rocks, grates, wind | 3 | — | — |
| c4_c03 | 1×2 | c02 (floor) → c04 (R, top screen) | Ice wall: a big face climb with rest ledges, blight spikes (`I`) bursting from two ledges; gust → into the face (pins you; jump away only in a calm). | wall climb, crystal spikes, wind → | 4 | **Skill detour**: crystal on a pillar standing off the face. | — |
| c4_c04 | 1×1 | c03 (L) → c05 (R) | Breather: a cave through the ridge, out of the storm (rock above, mouths open on both sides), Vesper on the radio (`!`), health pack. | `!`, `H` | 1 | — | — |
| c4_c05 | 2×1 | c04 (L) → c06 (top, right screen) | Blighted ridge: blight crystals burst out of the crest (`I`), a drone hunting over it with boulders to bait it into, gusts ←. | crystal spikes, drone, wind | 3 | **Secret passage**: pocket inside a boulder (`F` + `c`, drawn as rock). | — |
| c4_c06 | 1×2 | c05 (floor) → c07 (R, top screen) | Summit buttress: climb the last pillar to the cornice; crumbling cornice grates at the top; gusts ←. | wall climb, grates, wind | 4 | **Mechanic trick**: an angled spring on a side ledge launches you to a crystal on a cornice tip (checker-reachable). | — |
| c4_c07 | 1×1 | c06 (L) → d01 (R, h2 fixed) | The saddle: a short safe walk, the HQ in the cliff across (`!` Hlavní sídlo); descend a little to the h2 exit. | `!` | 1 | — | — |
| c4_d01 | 2×1 | c07 (L, h2 fixed) → d02 (top, right screen) | Outer fortifications on the cliff: carved stone ramparts and brass, searchlight pylons, two guards on the ramparts, a turret on a bastion (cover), `!` alarm. | guards ×2, turret, `!` | 3 | — | ✔ |
| c4_d02 | 1×2 | d01 (floor) → d03 (R, top screen) | Lift shaft cut into the cliff: pneumatic springs and vents up the shaft, windows open to the sky on the outer side, a turret on a landing with cover. | springs, vents, turret | 3 | **Skill detour**: crystal in a window niche off the climb. | — |
| c4_d03 | 1×1 | d02 (L) → d04 (R) | Searchlight walkway: an outer walkway on the cliff, two drones, pillars to bait them into. | drones ×2 | 3 | — | — |
| c4_d04 | 1×1 | d03 (L) → d05 (top) | Breather: an abandoned guardroom on a ledge (a structure with sky around), health pack, `!` Rozkaz velení. | `!`, `H` | 1 | — | — |
| c4_d05 | 1×2 | d04 (floor) → d06 (R, top screen) | Blast doors: a stair carved up the cliff, presses slam over its landings, a belt; no wind. | presses, belt | 3 | — | — |
| c4_d06 | 2×1 | d05 (L) → d07 (top of the right screen; d07's left screen sits above it) | Cliff gallery: a long gallery on the face, gusts ←, a guard, grates over gaps. | wind, guard, grates | 3 | **Key/backtrack** | — |
| c4_d07 | 2×1 | d06 (floor, left screen) → `E` (right end) | The main gate: the great brass gate cut into the mountain, two presses in the gateway, searchlights; `E` at the gate on the right. | presses | 3 | **Secret passage**: pocket in the gate's stonework (`F` + `c`). | — |

Crystal route order: skill (a04) → secret (a05) → key (a06) → trick (b02) → secret (b05) → gauntlet (b05b) → skill (c03) → secret (c05) → trick (c06) → skill (d02) → key (d06) → secret (d07).
Enemies: guards a01, b01, b06, d01 ×2, d06 = 6; turrets b01, b05, d01, d02 = 4; drones b03, b06, c05, d03 ×2 = 5 → 15.
Wind rooms: a03, a04, a06 (→), b02, b03, b05b, c01 (→, 100), c02, c03 (→), c05, c06, d06.
Travel: ↑ and → only; the chapter climbs 19 screens to the HQ gate.

## Rooms (ASCII)

### c4_a01 — back gate of the citadel
```
   0123456789012345678901234567890123456789
10 ........................................
 9 ........................................
 8 &&......................................
 7 &&&.....................................
 6 &&&&&...................................
 5 &&qqq...................................
 4 &&qoq..............y........p.......y...
 3 &&qqq.............JJJJ.....JJJJ...JJJJJJ
 2 &&dqq.............JJJJ....JJJJJ...JJJJJJ
 1 &&@qql!..g..G...JJJJJJ....JJJJJ...JJJJJJ
 0 JJJJJJJJJJJJJJJJJJJJJJ....JJJJJ...JJJJJJ
```
```props
room checkpoint = true
! speaker_name = "Severní stěna"
! dialogue_pages = Array[String](["Za citadelou končí město i cesta. Dál vede jen zásobovací stezka, nad ní holá skála, sníh a vítr.", "Vysoko ve stěně pod vrcholem blikají rudá světla — Hlavní sídlo korporace, vytesané do hory. Za jeho branou začíná šachta k jádru."])
```
- Start in the brick alcove of the citadel's back gate (`@` col 2, h1). Supply road h1 (cols 0-15) with a guard (patrols to the rock step at col 16) and a banner; rock steps h2 (cols 16-17) and h4 (cols 18-21); bottomless pit cols 22-25 to h3/h4 (cols 26-30), pit cols 31-33 to the h4 shelf (cols 34-39). Exit R at h4 (rows 0-3 solid at col 39, rows 4+ open). No ceiling, no outer walls.

### c4_a02 — scree field
```
   01234567890123456789
21 ....................
20 ....................
19 JJ...JJJJJJJJJJJJ...
18 JJ...JJJJJJJJJJJJ...
17 JJ.......O...O......
16 JJJ.................
15 JJJ.................
14 JJJJJJ..............
13 JJJJJJ..............
12 JJJJJJJJJJJJJJJJ....
11 ......JJJJJJJJJJ....
10 ......JJJJJJJJJJ....
 9 ......JJJJJJJJJJ.JJJ
 8 ........O...O....JJJ
 7 .................JJJ
 6 ...............JJJJJ
 5 ...............JJJJJ
 4 ..@........JJJJJJJJJ
 3 JJJJJJ.....JJJJJJJJJ
 2 JJJJJJ.JJJJJJJJJJJJJ
 1 JJJJJJJJJJJJJJJJJJJJ
 0 JJJJJJJJJJJJJJJJJJJJ
```
- Enter L (bottom screen) at h4 (rows 0-3 solid at col 0). `@` col 2. Boulders and ledges climb right: h4, h3, h5, h7, h10, then the overhang mass (top h13, cols 6-15); falling rocks `O` hang under it (cols 8, 12) over the h5 step, each drops once as you pass (4-tile clearance, run on). Climb left up the stair (h15, h17, h20) and cross the big slab (top h20, cols 5-16): two more rocks under it (cols 9, 13) over the h13 mass. No wind.
- Exit T: open air above the slab, leave anywhere on cols 5-16 (a03's hole at cols 13-14 is the way up). Falling back down is safe.

### c4_a03 — the first gust
```
   01234567890123456789
10 .}..................
 9 ....................
 8 ....................
 7 ....................
 6 JJJJ................
 5 JJJJ...@.......JJJJJ
 4 JJJJJJJJJJJJJ..JJJJJ
 3 JJJJJJJJJJJJJ..JJJJJ
 2 JJJJJJJJJJJJJ..JJJJJ
 1 JJJJ...........JJJJJ
 0 JJJJ...........JJJJJ
```
- Arrive from below through the hole (cols 13-14) onto the snowy shelf (h5, cols 4-12) or the right piece (cols 15-19, one higher). `@` col 7 on the shelf, sheltered: boulder rock cols 0-3 (top h7) on the downwind (left) side, 3 tiles of floor between. Gust blows left (default 3.2 s cycle): it pushes you back along the shelf into the rock, no pit downwind; the hole is upwind of the rock and drops you only into a02 (no death).
- Run the shelf in the calm, hop the 2-wide hole onto the right piece (cols 15-19, h5, level with the exit) and walk out R at h6 (rows 0-5 solid at col 19, rows 6+ open).

### c4_a04 — miners' trail
```
   0123456789012345678901234567890123456789
10 .}......................................
 9 ........................................
 8 ................JJ......................
 7 ...............JJJ......................
 6 .....@.........JJJ......................
 5 JJJJJJJJJ====JJJJJJJJJ====JJJ...====JJJJ
 4 JJJJJJJJJ....JJJJJJJJJ....JJJ.......JJJJ
 3 JJJJJJJJJ....JJJJJJJJJ....JJJ.......JJJJ
 2 JJJJJJJJJ....JJJJJJJJJ....JJJ.......JJJJ
 1 JJJJJJJJJ....JJJJJJJJJ....JJJ....C..JJJJ
 0 JJJJJJJJJ....JJJJJJJJJ....JJJ..JJJJJJJJJ
```
- Enter L at h6 (rows 0-5 solid at col 0, rows 6+ open). `@` col 5; 4+ tiles of floor, then a03's h6 floor downwind. Gust blows left (default). Crossing 1: two grate pieces (cols 9-12, bottomless drop), land on the landing (cols 13-14), hop the boulder (top h9, cols 15-17) and rest behind it in the pocket (cols 18-21): the boulder shelters you from the gust. Crossing 2: grates cols 22-25 to the island (cols 26-28), then a 3-wide jump to the grates cols 32-35 (a short chain, solid cliff from col 36). Move in the lull, 1.5 s per leg.
- Skill crystal `C` (col 33, h2) on the pier under the last grates, out over the drop: from the island's right edge jump out (2-wide gap) and land on the pier, take the crystal, then wall-jump back up the island's right face (col 28, 5 tiles) while the gust tries to peel you off. Falling in the gap kills. 3-4/5.
- Exit R at h6 (rows 0-5 solid at col 39, rows 6+ open).

### c4_a05 — the chimney
```
   01234567890123456789
21 ............JJJJJJJJ
20 ............JJJJJJJJ
19 ............JJJJJJJJ
18 ..........JJJJJJJJJJ
17 JJJJJJJJ..JJJJJJJJJJ
16 JJJJJJJJ..OO...JJJJJ
15 JJJJJJJJ.......JJJJJ
14 JJJJJJJJ.......JJJJJ
13 JJJJJJJJ....JJJJJJJJ
12 JJJJJJJJ....JJJJJJJJ
11 ....O.......JJJJJJJJ
10 ............JJJJJJJJ
 9 ............JJJJJJJJ
 8 ............JJJJJJJJ
 7 ..............FFFFJJ
 6 ..@...........FcFFJJ
 5 JJJJJJJJJJJJJJJJJJJJ
 4 JJJJJJJJJJJJJJJJJJJJ
 3 JJJJJJJJJJJJJJJJJJJJ
 2 JJJJJJJJJJJJJJJJJJJJ
 1 JJJJJJJJJJJJJJJJJJJJ
 0 JJJJJJJJJJJJJJJJJJJJ
```
- Enter L (bottom screen) at h6 (rows 0-5 solid at col 0, rows 6+ open); a low tunnel under the left rock mass, `@` col 2. A falling rock `O` hangs under the mass (col 4): it drops as you walk in. The chimney is the 4-wide crack (cols 8-11) between the left mass and the right wall: wall-jump up it (rise ~6 to the alcove). Rest ledge 1: the alcove in the right wall (h14, cols 12-14). Two more rocks `O` hang under the right wall's lip (cols 10-11, h17): they drop as you climb past. Rest ledge 2: the left mass top (h18, cols 0-7). Longest climb ~3 s. No wind.
- Secret: the dead-end shelf in the right wall at the foot of the chimney (cols 12-13, h6-h7) looks like a nook; the pocket behind it (cols 14-17, rows 6-7, crystal col 15) is `F`; solid rock cols 18-19 between it and the room edge.
- Exit T: from the left mass top (h18) jump out of the open air above (cols 0-9 reach a06's hole at cols 4-7).

### c4_a06 — under the overhang
```
   01234567890123456789
10 .}..................
 9 JJJJJJJJJJJ.........
 8 JJJJJJJJJJJ....JLJ..
 7 JJJJJJJJJJJ....JCJ..
 6 ...............JJJ..
 5 ...............JJJ..
 4 .K...........JJJJJJJ
 3 JJJ..........JJJJJJJ
 2 JJJ.......@..JJJJJJJ
 1 JJJJ....JJJJJJJJJJJJ
 0 JJJJ....JJJJJJJJJJJJ
```
```props
} direction = Vector2(1, 0)
```
- Arrive from below through the hole (cols 4-7, a05's shelf) onto the ledge (h2, cols 8-12; `@` col 10) or the left ledge (cols 0-3). Tailwind `} direction = Vector2(1, 0)` blows right: the ledge is sheltered by the face on its right (cols 13+, rock on the downwind side).
- Key `K` on the shelf at the back of the overhang (h4, cols 0-2, under the big overhang slab h7+). Climb out: from the ledge hop to the step (h5, cols 13-14), then wall-jump the face (cols 15-17, up to h9): the gust pins you to it; jumping off in a gust throws you right. Short, 2 s.
- Caged crystal `C` in the pocket at the top (col 16, h8) under the `L` block (the only `L`); touch it with the key, then drop in and out. Exit R at h5 (rows 0-4 solid at col 19, rows 5+ open): drop from the top onto the exit shelf (cols 18-19).

### c4_a07 — miners' refuge
```
   01234567890123456789
10 ....................
 9 ....WWWWW...........
 8 ..WWWWWWWWW.........
 7 ...WwwwwwW..........
 6 ....wwwdw...........
 5 .@..!lhdH.y.........
 4 JJJJJJJJJJJJ........
 3 JJJJJJJJJJJJ........
 2 JJJJJJJJJJJJJJJ.....
 1 JJJJJJJJJJJJJJJJJJJJ
 0 JJJJJJJJJJJJJJJJJJJJ
```
```props
! speaker_name = "Deník horníka"
! dialogue_pages = Array[String](["Den 40. Korporace nás vyhnala z chaty. Prý tu povede lanovka k novému sídlu ve skále.", "Na hřebeni fouká v nárazech. Kdo chce projít, čeká v závětří, až vítr na chvíli ztichne."])
```
- Enter L at h5 (rows 0-4 solid at col 0). `@` col 1. Refuge hut on the ledge (planks `W` roof, `w` back, door `d`, stove fire `h`, lamp `l`): `!` Deník horníka at col 4, health pack `H` col 8, doorways open on both sides. Sky all around. The ledge steps down (h5, h3, h2) to the exit R at h2 fixed (rows 0-1 solid at col 19, rows 2-6 open).

### c4_b01 — lower cable-car station
```
   0123456789012345678901234567890123456789
10 ........................................
 9 ...........................ZZ..T..l.....
 8 ........................RRRRRRRRRRRRR...
 7 ........................qqqqqqqqqqqqq...
 6 ......................WWqqqqoqqqoqqqq.JJ
 5 ..................G.l.WWqqqqqqqqqqqqq.JJ
 4 ................BB~~~~BBBBBB~~~~~~~BBBJJ
 3 ............yJJJ##......##.......###.JJJ
 2 ...@.g.!..JJJJJJ##......##.......###.JJJ
 1 JJJJJJJJJJJJJJJJ##......##.......###.JJJ
 0 JJJJJJJJJJJJJJJJ##......##.......###.JJJ
```
```props
room checkpoint = true
! speaker_name = "Hlas Korporace"
! dialogue_pages = Array[String](["Pozor, provoz lanovky. Nepovolaným osobám vstup zakázán.", "Náklad krystalů pro Hlavní sídlo odjíždí každých dvanáct minut. Korporace děkuje za vaši přesnost."])
```
- Enter L at h2 fixed (rows 0-1 solid at col 0, rows 2-6 open), `@` col 3 on the h2 ground cols 0-9, `!` loudspeaker col 7. Rock steps h3/h4, then the station deck h5 (cols 16-37, belts cols 18-21 and 28-34 along the travel direction) on stone pillars over a visible pit; guard on the yard (cols 16-21), crates (cols 22-23) up to the open-front canopy roof h9 (cols 24-36).
- Turret on the roof (col 31): cover = the crate pair cols 27-28 (crouch behind it), then 3 tiles to hop/stomp/slash it. Exit: jump up through the top over the roof cols 32-34 (b02 hole cols 12-14). Sky open on top; the right outcrop (cols 38-39) is plain rock.

### c4_b02 — first pylon
```
   01234567890123456789
21 }...................
20 ....................
19 .....B.B............
18 .....B.B............
17 .....BZB............
16 .....B.B....BBBBBBBB
15 .....B.B...........Z
14 .....B.B.........C.Z
13 .....BZB...........Z
12 .....B.B........BBBZ
11 .....B.B...........Z
10 .....B.B..S...S.....
 9 .....BZB..BBBBB.....
 8 .....B.B............
 7 .....B.B............
 6 JJJJ.B.B............
 5 JJJJ.BZB............
 4 JJJJ.B.B............
 3 JJJJ.B.B............
 2 JJJJ.B.B..@.........
 1 JJJJJJJJJJJJ...JJJJJ
 0 JJJJJJJJJJJJ...JJJJJ
```
```props
S2 direction = Vector2(1, -1)
```
- Arrive through the hole cols 12-14 (b01 cols 32-34) onto the ledge cols 8-11 h2 (`@` col 10; the lattice leg col 7 shelters it from the wind). Climb the right face of the leg (col 8: the wind pins you into it) ~8 tiles to the arm h10 (cols 10-14, rest). Spring S (col 10) + double jump onto the top slab h17 (cols 12-19) ; exit R at col 19, rows 17-21 open above the solid rows 11-16 (b03 floor h6).
- Trick crystal: the angled spring S2 (col 14, direction (1,-1)) flings you onto the cable bracket h13 (cols 16-18, under the slab), crystal col 17 row 14; step off the bracket's left end to fall back to the arm. Wind `}` left (cycle default): wait in the lee of the leg between wall climbs; the arm is the rest.

### c4_b03 — under the cable
```
   0123456789012345678901234567890123456789
10 }.......................................
 9 .................D......B...............
 8 ........................B...............
 7 ..........B...........WWWWWW............
 6 ...@......B.....====.........JJJ........
 5 JJJJJJ..WWWWWW...............JJJ........
 4 JJJJJJ.......................JJJ..WWW...
 3 JJJJJJ.......................JJJ........
 2 JJJJJJ.......................JJJ.....JJJ
 1 JJJJJJ.......................JJJ.....JJJ
 0 JJJJJJ.......................JJJ.....JJJ
```
```props
D patrol_distance = 24.0
```
- Enter L on the cliff stub h6 (cols 0-5, `@` col 3; 11+ tiles of floor downwind incl. b02's slab). Catwalks over a bottomless drop: planks h6 (cols 8-13, 2-tall post col 10 = lee), grates h7 (cols 16-19, one piece pair: run), planks h8 (cols 22-27, post col 24), rock pinnacle h7 (cols 29-31), plank h5 (cols 34-36), exit R at h3 (cols 37-39, rows 0-2 solid).
- Wind left (against travel): cross each 2-3 tile gap from the lee behind a post in the calm; the gust at worst undershoots into the next gap = death, so jump at the end of the gust. Drone col 17 row 9 (patrol 24 px): bait it into the post cols 24 / the pinnacle, or stomp it.

### c4_b04 — pylon foundation shed
```
   01234567890123456789
10 .................BB.
 9 .................BB.
 8 .................BB.
 7 .......RRRRRRRRR.BB.
 6 ........qqqqqqqZ.BB.
 5 ........qqqqqqqZ.BB.
 4 ......WWql!qHqqZ.BB.
 3 ..@...##########....
 2 JJJJJJ##########....
 1 JJJJJJ##########....
 0 JJJJJJ##########....
```
```props
! speaker_name = "Údržbářský deník"
! dialogue_pages = Array[String](["Kladka číslo tři zase zamrzla. Vedení chce provoz i v bouři.", "Nad hřebenem se v noci zvedají kameny do vzduchu. Prý anomálie. Prý to nic není."])
```
- Enter L on ground h3 (cols 0-5, `@` col 2; solid rows 0-2 at col 0 matches b03). Foundation block h4 (cols 6-15) with the shed (back wall q, lamp, health pack col 12, `!` col 10, roof h8 cols 7-15); pylon stub cols 17-18. A crate (cols 6-7, h5) is the doorstep into the shed; from it a double jump reaches the roof; exit: jump up through the top over the roof cols 10-12 (b05 hole cols 10-12).

### c4_b05 — second pylon
```
   01234567890123456789
21 ....................
20 ..............Z...T.
19 ............BBBBBBB.
18 ....................
17 ....................
16 .....BBBBB==........
15 ....................
14 ....................
13 BBBBB..........BBBB.
12 BBBBB...............
11 BBBBB.......V.......
10 BBBBBBBB==..BB......
 9 ....................
 8 ...........V........
 7 ..........BBB.BBBBB.
 6 ....................
 5 ##########..........
 4 ####FFF..........WWW
 3 ####FcF..........WWW
 2 ##########....@..WWW
 1 ##########...JJJJJJJ
 0 ##########...JJJJJJJ
```
```props
V2 offset = 1.0
```
- Arrive through the hole cols 10-12 onto the ledge cols 13-16 h2 (`@` col 14; crates cols 17-19). Girders (no wind): arm h8 (cols 14-18), pad h8 (cols 10-12) with vent V2 (col 11, offset 1.0), arm h11 with grates (cols 5-9; left part is a block cols 0-4 up to h14 = the b05b branch ledge, rows 11-13 solid at col 0), pad h11 (cols 12-13) with vent V (col 12), arm h14 (cols 15-18), arm h17 with grates (cols 5-11), top arm h20 (cols 12-18). Jump the vents in their idle window (2.0 s idle, 0.5 s warn, 1.0 s blast); a hit is 1 HP.
- Turret col 18 on the top arm, cover = the crate col 14 (crouch); exit: jump up through the top over cols 11-13 (b06 hole cols 11-13). Branch: jump left from the h11 arm to the h14 block and walk out of the left edge at rows 11-13 into b05b (floor h3).
- Secret: the dead-end tunnel in the foundation (cols 7-9, h3, right face) ends in a fake wall; crystal inside (cols 4-6, rows 3-4).

### c4_b05b — frozen pulley
```
   01234567890123456789
10 }...................
 9 .C..................
 8 ....................
 7 .BBBB...............
 6 ....................
 5 .....Z..............
 4 .....ZS........Z....
 3 .....JJJ.......Z.@..
 2 .....JJJ..====.JJJJJ
 1 .....JJJ.......JJJJJ
 0 .....JJJ.......JJJJJ
```
- Entered from the right edge (floor h3, rows 0-2 solid, matching b05's block). `@` col 17 behind the 2-tall post (col 15, the lee of the wind). Gust blows left = tailwind going out: hop the post, jump the 2-gap onto the grates (cols 10-13: run, they collapse after 0.5 s), jump the gap onto the pillar (cols 5-7, h4, post col 5 = lee), spring (col 6) up to the high girder h8 (cols 1-4), crystal at col 1 row 9. Left and top: invisible walls; below the gaps: death.
- Return: drop from the girder to the pillar, then jump the gap against the wind in a calm to the grates and over the post to the ledge; walk out the right edge. Difficulty 4.

### c4_b06 — upper station
```
   0123456789012345678901234567890123456789
10 ........................................
 9 ....................RRRRRRRRRR.BBBBB....
 8 .....................qqqqqqqq......B....
 7 .....................qqqqqqqq......B....
 6 .....................qqqoqoqq....D.B....
 5 .....................Glqqqqqq...........
 4 ....................##~~~~~~##..........
 3 ...JJJJJJJJ.......WW##########..ZZZ.....
 2 ...JJJJJJJJ.....@.WW##########..........
 1 JJJJJJJJJJJ...JJJJJJ##########.......JJJ
 0 JJJJJJJJJJJ...JJJJJJ##########.......JJJ
```
```props
D patrol_distance = 24.0
```
- Arrive through the hole cols 11-13 (b05 top) onto the ledge cols 14-19 h2 (`@` col 16) or the rocks left of it; crates cols 18-19 up to the loading dock h5 (cols 20-29, belts cols 22-27 along the travel) under an open-front canopy (roof h9, back wall q, lamp). Guard on the dock (col 21): hop or stomp it.
- Gondola bay: dock end col 29, gap, gondola platform h4 (cols 32-34), gap, rock h2 (cols 37-39). The drone hovers over the gondola (col 33 row 6): bait it into the hoist post (col 35) or stomp. Sky and the ridge beyond; right screen bottom is bottomless. Exit R at h2 fixed (rows 0-1 solid at col 39, rows 2-6 open).

### c4_c01 — The ridge
```
   0123456789012345678901234567890123456789
10 ........................................
 9 .}......................................
 8 ........................................
 7 ........................................
 6 ..................JJ....................
 5 ..................JJ.y.....JJ...........
 4 .......!.......JJJJJJJ.....JJ...........
 3 .....JJJJJJJ...JJJJJJJ.....JJ.....JJJJJJ
 2 ..@..JJJJJJJ...JJJJJJJ...JJJJJJ...JJJJJJ
 1 JJJJJJJJJJJJ...JJJJJJJ...JJJJJJ...JJJJJJ
 0 JJJJJJJJJJJJ...JJJJJJJ...JJJJJJ...JJJJJJ
```
```props
room checkpoint = true
! speaker_name = "Hřeben"
! dialogue_pages = Array[String](["Hřeben se ztrácí ve vánici. Sídlo korporace je odsud jen rudá světla ve skále nad sedlem."])
} direction = Vector2(1, 0)
} strength = 100.0
```
- Enter LEFT at h2 (rows 0-1 solid at col 0, rows 2-6 open); `@` col 2 on the 5-tile ledge (cols 0-4), sheltered: the rock at col 5 is downwind of the tailwind. Exit RIGHT at col 39: floor h4 (rows 0-3 solid, rows 4-8 open) into c02.
- Crest: A cols 5-11 (h4), notch 12-14, B cols 15-21 (h5, spire at 18-19), notch 22-24, C cols 25-30 (h3, spire 27-28), notch 31-33, D cols 34-39 (h4). Notches are 3 wide: jumpable in a calm, the tailwind only helps. Every crest piece is 6-7 tiles, so a gust never carries a standing player into a notch within ~1.5 s of exposure; no waiting needed (run in the gust, or wait on the ledge).
- `!` Hřeben on crest A (col 7). No ceiling, no outer wall: sky everywhere, bottom edge over nothing kills.

### c4_c02 — Avalanche couloirs
```
   01234567890123456789
10 JJJJJJ}.......JJJJJJ
 9 JJJJJJ........JJJJJJ
 8 .O.O.........JJJJJJJ
 7 .............JJJJJJJ
 6 ...........JJJJJJJJJ
 5 .JJ........JJJJJJJJJ
 4 .JJ..@...JJJJJJJJJJJ
 3 JJJJJJ.==JJJJJJJJJJJ
 2 JJJJJJ...JJJJJJJJJJJ
 1 JJJJJJ...JJJJJJJJJJJ
 0 JJJJJJ...JJJJJJJJJJJ
```
```props
} direction = Vector2(-1, 0)
```
- Enter LEFT at h4 (rows 0-3 solid at col 0, rows 4-8 open). Boulder cols 1-2 (hop over); `@` col 5 on the cols 3-5 ledge, sheltered from the leftward gust by the boulder. Falling rocks `O` hang under the corner overhang (cols 1 and 3): they drop when you land past the boulder, keep running.
- Notch cols 6-8 with a snow cornice `==` (cols 7-8) flush with the floor; then the cliff's shoulder: steps E (cols 9-10, h5), F (11-12, h7), G (col 13, h9). The gust (←) pushes you back toward the notch: move in the lull.
- Exit TOP over cols 7-13 (row 10 open) onto c03's ledge at cols 14-19 (c03 row 0 = this room's cliff top). Reach: from G jump up and right.

### c4_c03 — Ice wall
```
   01234567890123456789
21 ....................
20 .}..................
19 ....................
18 ....................
17 ....................
16 ....................
15 ....................
14 ...C................
13 ..................y.
12 ..JJJ............JJJ
11 ..JJJ.......I....JJJ
10 ..JJJ....JJJJJJJ.JJJ
 9 ..JJJ....JJJJJJJ.JJJ
 8 ..JJJ............JJJ
 7 JJJJJJ...........JJJ
 6 JJJJJJ......I....JJJ
 5 JJJJJJ...JJJJJJJ.JJJ
 4 JJJJJJ...JJJJJJJ.JJJ
 3 JJJJJJ...........JJJ
 2 JJJJJJ...........JJJ
 1 JJJJJJ.........@.JJJ
 0 JJJJJJ........JJJJJJ
```
```props
} direction = Vector2(1, 0)
```
- Arrive from below through the open top of c02 (cols 6-13) onto the ledge cols 14-19; `@` col 15 (cols 14-16 free of the face, the face at col 17 shelters the tailwind). Face M = cols 17-19 up to row 12 (top, h13); slot col 16 along its left face: the tailwind pins you into the face.
- Rest ledges R1 (cols 9-15, h6) and R2 (cols 9-15, h11) hang off the slot; a crystal spike `I` sits on each (col 12): 3 safe tiles on both sides (cols 9-11 and 13-15). Wall climbs: S1 to R1 ~5 rows, R1 to R2 ~5, R2 to the top 2 (each well under 4 s).
- Skill crystal `C` on the spire (cols 2-4, top row 12) standing off the face: leap left from R2's left end (col 9) across 4 tiles, against the tailwind, double jump; 4/5.
- Exit RIGHT: col 19 solid up to row 12 (= c04 rows 0-1 solid), open from row 13 (= c04 row 2+) into c04.

### c4_c04 — Cave through the ridge
```
   01234567890123456789
10 .......JJ.JJJ.......
 9 .....JJJJ.JJJJJ.....
 8 ...JJJJJJ.JJJJJJJ...
 7 .JJJJJJJJ.JJJJJJJJJ.
 6 ...kkkkkkkkkkkkkk...
 5 ...kkkkkkkkkkkkkk...
 4 ...kkkkkkkkkkkkkk...
 3 ...kkkkkkkkkkkkkk...
 2 .@.lkk!kkkkkkHkkl...
 1 JJJJJJJJJJJJJJJJJJJJ
 0 JJJJJJJJJJJJJJJJJJJJ
```
```props
! speaker_name = "Vesper (vysílačka)"
! portrait_texture = "res://assets/npc/vesper_portrait.png"
! dialogue_pages = Array[String](["Matěji, slyšíš mě? Bouře to ruší... Jsi na hřebeni? Tak vysoko se nikdo z nás nedostal.", "Brána sídla je ve skále nad sedlem. Otis tě čeká ve starých dílnách za ní — odtud už vede cesta jen dolů, k jádru."])
```
- Enter LEFT at h2 (rows 0-1 solid, rows 2-6 open), exit RIGHT the same into c05. Flat floor all along; no hazards, no wind. `@` col 1, `!` Vesper radio col 6, `H` col 13, lamps `l`.
- A cave through the ridge: rock roof over cols 1-18 (rows 7-10), `k` back wall only inside (cols 3-16), mouths open at both ends with sky and peaks showing, and a one-tile crack in the roof (col 9) letting daylight in.

### c4_c05 — Blighted ridge
```
   0123456789012345678901234567890123456789
10 ....................................JJJJ
 9 .}..................................JJJJ
 8 .........................JJJJJJJ....JJJJ
 7 ..............D..........JJJJJFF....JJJJ
 6 ......................JJJJJJJJcF....JJJJ
 5 ......................JJJJJJJJJJJJJJJJJJ
 4 ........JJ...II...JJJJJJJJJJJJJJJJJJJJJJ
 3 ........JJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ
 2 ...@..JJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ
 1 JJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ
 0 JJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJJ
```
```props
D patrol_distance = 24.0
```
- Enter LEFT at h2 (rows 0-1 solid at col 0, rows 2-6 open); `@` col 3 on the cols 0-5 floor: the gust (←) only pushes you back along 20 tiles of floor, no drop. Wind default ←.
- Boulder B1 (cols 8-9, h5) shelters the way and baits the drone; crest cols 10-17 (h4) with two crystal spikes `I` (cols 13-14): safe tiles 10-12 and 15-17. Drone `D` (col 14, row 7) hunts over the crest: lure it into B1 or the plateau wall and stomp it.
- Secret: drop off the plateau's right end into the trough (cols 32-35, h6); its left wall (the plateau face) holds the pocket (cols 30-31, rows 6-7, `F` + `c`), invisible, flush with the trough floor. Hint: the trough is a dead-end shelf under the plateau; wind (←) pins you into that wall. Climb back by wall jumps (4 tiles).
- Exit TOP over cols 20-35: plateau G (cols 28-31, h9), jump up and left onto c06's ledge (c06 cols 5-9). The cliff (cols 36-39) is the base of c06's right wall.

### c4_c06 — Summit buttress
```
   01234567890123456789
21 ....................
20 ....................
19 ....................
18 .}..................
17 ....................
16 ....................
15 JJJJJ...............
14 JJJJJ.......C.....JJ
13 JJJJJ.............JJ
12 JJJJJ...........JJJJ
11 JJJJJ...........JJJJ
10 JJJJJ.......====JJJJ
 9 JJJJJ...........JJJJ
 8 JJJJJS..........JJJJ
 7 JJJJJJJJJ.......JJJJ
 6 JJJJJJJJJ.......JJJJ
 5 JJJJJ...........JJJJ
 4 JJJJJ.......JJJJJJJJ
 3 JJJJJ.......JJJJJJJJ
 2 JJJJJ..@........JJJJ
 1 JJJJJJJJJJ......JJJJ
 0 JJJJJ...........JJJJ
```
```props
S direction = Vector2(1, -1)
```
- Arrive from below onto the shelf cols 5-9 (h13 above c05's plateau; c05 cols 25-29); `@` col 7, wall of the left cliff on the downwind (←) side. The gust blows INTO the left cliff and the right cliff: zigzag up: shelf L1 (h13) to R1 (cols 12-15) to L2 (cols 5-8) to cornice grates R2 (cols 12-15, two `==` pieces) to the step cols 16-17 (h13) to the top cols 18-19 (h15).
- Falling from any shelf drops into c05 (no death). Exit RIGHT: col 19 solid up to row 14 (= c07 rows 0-3), open from row 15 (= c07 row 4+).
- Trick crystal `C`: the angled spring `S` (↗) on L2's far-left end (col 5) flings you up and right to the cornice tip crystal.

### c4_c07 — The saddle
```
   01234567890123456789
10 ....................
 9 ....................
 8 ....................
 7 ....................
 6 ....................
 5 ....................
 4 .@.............JJ...
 3 JJJJJJJ..!.....JJ...
 2 JJJJJJJJJJJJJ..JJ...
 1 JJJJJJJJJJJJJJJJJJJJ
 0 JJJJJJJJJJJJJJJJJJJJ
```
```props
! speaker_name = "Hlavní sídlo"
! dialogue_pages = Array[String](["Za sedlem se zvedá skalní stěna a v ní, vytesané do hory, sídlo korporace: mosazné brány, reflektory, lanovka mizící ve skále.", "Někde pod tím vším bije reaktor."])
```
- Enter LEFT at h4 (rows 0-3 solid at col 0, rows 4-8 open), `@` col 1; walk down: cols 0-6 h4, cols 7-12 h3, cols 13-19 h2. Exit RIGHT at h2 fixed (rows 0-1 solid at col 19, rows 2-6 open) into d01. A little outcrop (cols 15-16) for the silhouette. No wind, no hazards. `!` Hlavní sídlo at col 9.

### c4_d01 — outer fortifications
```
   0123456789012345678901234567890123456789
10 JJJJ....................................
 9 JJJJ....................................
 8 JJJJ........................BB..p..g..T.
 7 JJ..........................BB##########
 6 ......................g.G...BB##########
 5 ............g.G..p...#######JJJJJJJJJJJJ
 4 ...........########..#######JJJJJJJJJJJJ
 3 ........g..########..JJJJJJJJJJJJJJJJJJJ
 2 ..@.!.pJJ..JJJJJJJJ..JJJJJJJJJJJJJJJJJJJ
 1 JJJJJJJJJ..JJJJJJJJ..JJJJJJJJJJJJJJJJJJJ
 0 JJJJJJJJJ..JJJJJJJJ..JJJJJJJJJJJJJJJJJJJ
```
```props
room checkpoint = true
! speaker_name = "Hlas Korporace"
! dialogue_pages = Array[String](["Narušení perimetru Hlavního sídla. Uzavřít brány. Vypustit drony."])
```
- Section start. Enter LEFT at h2 (rows 0-1 solid at col 0, rows 2-6 open, `@` col 2 on the 7-tile ledge cols 0-6, alarm `!` col 4). Step cols 7-8 (h3), 2-wide pit cols 9-10, then the rampart (cols 11-18, h5) with guard G1 (col 14, turns at the pit edges cols 9-10 and 19-20).
- Second rampart cols 21-27 (h6) with guard G2 (col 24); the brass pillar cols 28-29 (h9) is the turret's cover: the bastion (cols 30-39, h8) turret at col 38 cannot see you below the pillar. Climb the pillar, drop onto the bastion and leave through the open top above cols 32-35 (d02 cols 12-15); the turret is 3+ tiles away, its bolt is slow.

### c4_d02 — lift shaft
```
   01234567890123456789
21 ....................
20 ....................
19 .......J............
18 ......JJkkkkkkkkk...
17 ......JJkkkkkkkkk...
16 .....JJJkkkkkkkkk...
15 JJ...JJJkkkkkkkkk...
14 JJJ..JJJkkkkkkkkBBBB
13 JJJJJJJJkk##kkkkBBBB
12 JJJJJJJJTk##lkSkk.BB
11 JJJJJJJJBBBBBBBkk.BB
10 JJJJJkkkBBBBBBBkk.BB
 9 JJJJJCkkkkkkkkkkk...
 8 JJJJJkVkkkkkkVkSk...
 7 JJJJJJJJkkkBBBBBk...
 6 JJJJJJJJkkkBBBBBk...
 5 JJJJJJJJkkkkkkkkk...
 4 JJJJJJJJkkkkkkkkk.BB
 3 JJJJJJJJkSkkkkgk@pBB
 2 JJJJJJJJBBB...BBBBBB
 1 JJJJJJJJBBB...BBBBBB
 0 ....................
```
```props
V2 offset = 1.0
```
- Arrive from below through the gap cols 11-13 (d01 exit cols 32-35 is d02 cols 12-15); the deck cols 14-17 (h3) with `@` col 16 is sheltered by the outer wall. Springs S: col 9 (floor cols 8-10) -> landing L1 cols 11-15 (h8, vent V col 13: cross in its 2 s idle) -> S col 15 -> landing L2 cols 8-14 (h12) -> S col 14 -> outer deck cols 15-19 (h15). Exit RIGHT at h15 (col 19 rows 15-17 open, rows 11-14 solid = d03 h4).
- Turret T col 8 on L2 is covered by the block cols 10-11 (rows 12-13): stay right of it, the only exposure is the moment you spring up. Windows (cols 18-19, rows 5-9) open the shaft to the sky.
- Crystal (skill detour): niche cut in the cliff cols 5-7, rows 8-10, floor h8. Spring col 9 and steer left onto col 7; the vent col 6 guards the way to the crystal col 5 (jump it in the idle).

### c4_d03 — searchlight walkway
```
   01234567890123456789
10 ....................
 9 ....................
 8 ...........p...D....
 7 .........D.JJ.......
 6 ...........JJ....JJ.
 5 ...........JJ..p.JJ.
 4 .g@.....WWWJJ..JJJJJ
 3 JJJJJ......JJ..JJJJJ
 2 JJJJJ......JJ..JJJJJ
 1 JJJJJ......JJ..JJJJJ
 0 JJJJJ......JJ..JJJJJ
```
- Enter LEFT at h4 (`@` col 2, ledge cols 0-4). Bottomless pits: cols 5-7 and 13-14 (no room below). Catwalk planks cols 8-10 (h5), rock spire cols 11-12 (h8, bait: stand behind it and the drone D1 (col 9) crashes into it), then the walkway cols 15-19 (h5) with the low rock cols 17-18 (h7) as bait for D2 (col 15).
- Exit RIGHT at h5 (col 19 rows 0-4 solid, rows 5-7 open).

### c4_d04 — abandoned guardroom
```
   01234567890123456789
10 ....................
 9 .....RRRRRRRR.......
 8 .....RRRRRRRR.......
 7 .....qqqqoqq...JJJ..
 6 .....qqoqqqq...JJJ..
 5 .@.y.l!qHqdq...JJJ..
 4 JJJJJJJJJJJJJJJJJJJJ
 3 JJJJJJJJJJJJJJJJJJJJ
 2 JJJJJJJJJJJJJJJJJJJJ
 1 JJJJJJJJJJJJJJJJJJJJ
 0 JJJJJJJJJJJJJJJJJJJJ
```
```props
! speaker_name = "Rozkaz velení"
! dialogue_pages = Array[String](["Smallville evakuovat do konce měsíce. Těžbu ve Vrtu 7 nezastavovat.", "Anomálie kolem jádra dál rostou. Pokud reaktor selže, hora to nepřežije."])
```
- Breather, no hazards. Enter LEFT at h5 (`@` col 1). Walk through the guardroom (open front and back, roof cols 5-12, health pack col 8, `!` col 6), then up the boulder cols 15-17 (h8) and across the 2-tile gap to the roof (h10).
- Exit TOP from the roof, cols 5-9 (d05 entry hole cols 5-9).

### c4_d05 — blast doors
```
   01234567890123456789
21 .......BBBBBBBBB....
20 ........PP...PP.....
19 ....................
18 ....................
17 ....................
16 ....JJJJJJJJJJJJ~~~J
15 ....JJJJJJJJJJJJJJJJ
14 ##....BBBBBBBB....JJ
13 ##.....PP...PP....JJ
12 ####..............JJ
11 ####..............JJ
10 ######..............
 9 ######....l....l....
 8 JJJJJJJJJJJJJJJJ....
 7 JJJJJJJJJJJJJJJJ....
 6 ..................##
 5 ..................##
 4 ................####
 3 ...........g@...###p
 2 JJJJJ.....JJJJJJJJJJ
 1 JJJJJ.....JJJJJJJJJJ
 0 ....................
```
```props
P reach = 4
P2 offset = 0.6
P3 reach = 3
P4 reach = 3
P4 offset = 0.6
```
- Arrive from below through the hole cols 5-9 (d04 roof exit); land on the floor cols 10-19 (h3, `@` col 12). No wind. Stair carved in the cliff: # steps cols 16-19 (h5), 18-19 (h7), then the lower corridor (floor h9, cols 0-15) running LEFT.
- Lower corridor, 4 tall (reach 4), period 2.0: P1 housing cols 12-13, P2 cols 7-8 (offset 0.6, wave). Safe tiles: cols 14-15 + the gap before P1, cols 9-11 between, cols 4-6 after. Wait on the safe tiles, never under a head; run on the retract. Stair up the left: # steps cols 4-5 (h11), 2-3 (h13), 0-1 (h15).
- Upper corridor, floor h17 running RIGHT, 3 tall (reach 3): P3 cols 8-9, P4 cols 13-14 (offset 0.6). Safe: cols 4-7 before, cols 10-12 between, cols 15-19 after; belt cols 16-18 carries you on to the exit. Exit RIGHT at h17 (col 19 rows 11-16 solid, rows 17-19 open).

### c4_d06 — cliff gallery
```
   0123456789012345678901234567890123456789
10 .}............K.....................JJJJ
 9 .............RRR......................JJ
 8 ............wwwwww.............y.p..LCJJ
 7 ...........BwwwwwwB.....B.....JJJJJJJJJJ
 6 ...@.......BwwGwlwB.....B.....JJJJJJJJJJ
 5 JJJJJJJ====WWWWWWWWW====WWWWWWJJJJJJJJJJ
 4 JJJJJJJ....JJJJJJJJJ....JJJJJJJJJJJJJJJJ
 3 JJJJJJJ....JJJJJJJJJ....JJJJJJJJJJJJJJJJ
 2 JJJJJJJ....JJJJJJJJJ....JJJJJJJJJJJJJJJJ
 1 JJJJJJJ....JJJJJJJJJ....JJJJJJJJJJJJJJJJ
 0 JJJJJJJ....JJJJJJJJJ....JJJJJJJJJJJJJJJJ
```
- Enter LEFT at h6 (rows 0-5 solid at col 0, rows 6-8 open, `@` col 3). Wind `}` blows left (default 80 px/s, cycle 3.2 s): the entry floor cols 0-6 has d05 behind it, so a gust only pushes you back. Cross the grates cols 7-10 in a calm (about 0.6 s), land on the pillar col 11 (h8): it shelters the gallery floor cols 12-17 (h6) where guard G (col 14) patrols between pillars cols 11 and 18.
- Grates cols 20-23 (two pieces) over the bottomless gap, land on the pillar col 24 (h8) and drop behind it onto cols 25-29 (sheltered: the gust pins you to the pillar). Step up to the ledge cols 30-35 (h8) and leave through the TOP above cols 30-35 (d07 cols 10-15).
- Key/backtrack: key K floats on the gallery roof fragment (cols 13-15, h10) reached from the pillar col 11 or col 18. The only key block L (col 36) cages the crystal C (col 37) in a 2-tall chamber of the rock at the exit ledge (the open cell above L is only 1 tile tall, so you cannot squeeze past): fetch the key, come back and touch L.

### c4_d07 — the main gate
```
   0123456789012345678901234567890123456789
10 ...........................p............
 9 ..........................JJJJ...p..g.g.
 8 ..........................FFFJJJJJJJJJJJ
 7 ........................p.FcFJJJJJJJJJJJ
 6 ......................JJJJBBBBPPBBBPPBBB
 5 ......................JJJJ..............
 4 ................@.y.....................
 3 JJJJ..........JJJJJJ....................
 2 JJJJ..........JJJJJJ....g............lEl
 1 JJJJ..........JJJJJJ..JJJJJJJJJJJJJJJJJJ
 0 JJJJ..................JJJJJJJJJJJJJJJJJJ
```
```props
P reach = 4
P2 offset = 0.6
E next_level = "res://levels/c5/chapter5.tscn"
E stage_title = "KAPITOLA 4: SEVERNÍ STĚNA"
E stage_index = 4
E max_stage_crystals = 12
```
- Arrive from below into the left screen through the gap cols 10-13 (d06 exit cols 30-35 is d07 cols 10-15); `@` col 16 on the ledge cols 14-19 (h4). 2-wide bottomless pit cols 20-21 to the forecourt cols 22-25 (h2), then the gateway tunnel (floor h2, 4 tall) in the mountain: presses P1 cols 30-31 and P2 cols 35-36 (reach 4, period 2.0, P2 offset 0.6). Safe tiles: cols 26-29 before, 32-34 between, 37-39 after. `E` at col 38 with lamps beside it. Searchlights on the crest.
- Secret: from the ledge jump (3 up, 2-tile gap) to the dead-end shelf cols 22-25 (h7, lone searchlight and pine hint); walk right into the gate stonework: invisible pocket F cols 26-28, rows 7-8, crystal at col 27.
