# LEVEL c1 — Outpost (Základna odboje)

After the surface prologue the hero (Matěj) reaches the resistance outpost: a camp of DIY houses from scrap metal and planks, tarps, antennas, string lights and teal banners, hidden in a blighted ravine. Section a crosses its scrap wall, b is the camp itself, c is the corp raid that burns it and sends the hero on to Smallville.

- **Kit:** run, jump, double jump (DJ), wall climb/jump. Wrench from the chest in a03 (melee only). No dash, no hook.
- **New here:** springs (a02), guards (a04), steam vents (b03), conveyor (b04), falling debris (c01), steam turret (c02).
- **Look:** walls/floors `Z` scrap, `W` planks, `_` dead-grass ground, `%` blight soil; houses = back facades `w z o b d t` with solid `R` roofs and `W` floors; decor `l f a` in the camp, damage `y x p` everywhere. Every room shows the damage (blight, dead trees, pylons, boarded windows).
- **Rules:** LEVEL_DESIGN §1–2, §5, ASCII format §6. Crystals: 7, route types never repeat back to back.

## Dialogue (place via props, text verbatim)

- **a01** `!` speaker_name `"Základna odboje"`, dialogue_pages `Array[String](["Stezka z hor končí na dně rokle. Za skalní hradbou z rezavého plechu bliká pár lamp — tady někde se skrývá odboj.", "Půda pod nohama je popraskaná a v puklinách fialově žhne krystalová nákaza."])`
- **a03** `X` initial_items `Array[String](["wrench", "health_pack"])`
- **a08** `1` Otis dialogue_pages `Array[String](["Matěji! Takže jsi prošel povrchem. Vítej na Základně — poslední místo, kam korporace ještě nedosáhla.", "Ten hasák z kůlny sis vzal dobře. Seknutím [LMB / F] rozbiješ hodinový strojek každé stráže.", "Velitelka Mira tě čeká na náměstí za branou."])`, repeat_dialogue_pages `Array[String](["Mira je na náměstí. Jdi dál do tábora."])`
- **b02** `2` Mira dialogue_pages `Array[String](["Tak ty jsi ten z povrchu. Rozhlédni se — vrty korporace vysávají gravitační krystaly z jádra planety a země praská.", "Smallville, vesnice na svahu nad námi, umírá jako první. Studny jsou otrávené a korporátní stráže vyhánějí poslední rodiny.", "Nad vesnicí, výš na hoře, leží Parní město, sídlo korporace. Odtud vrtají do nitra hory až k jádru planety. Tam musíme udeřit.", "Brann ti v ošetřovně doplní síly. Pak se hlas na hlídkové věži."])`, repeat_dialogue_pages `Array[String](["Hlídková věž je na konci tábora. Dej vědět, co vidíš."])`
- **b05** `3` Brann dialogue_pages `Array[String](["Hasák od Otise? Ten starý blázen ti dal svůj nejlepší kus. Opatruj ho.", "Vezmi si lékárničku. A drž se dál od fialových prasklin — co vyroste z nákazy, řeže jako sklo."])`, repeat_dialogue_pages `Array[String](["Drž se, kluku."])`
- **b06** `!` at the tower top, speaker_name `"Hlídková věž"`, dialogue_pages `Array[String](["Na obzoru se zvedá prach. Kolona korporátních strojů míří přímo k táboru!", "Stráže už jsou u brány. Někdo nás prozradil..."])`
- **c01** `!` speaker_name `"Mira (vysílačka)"`, dialogue_pages `Array[String](["Matěji! Prorazili bránu. Nečekej na nás — utíkej po střechách k cestě do Smallville!"])`
- **c04** `3` Brann dialogue_pages `Array[String](["Tábor je ztracený... ale lidi stihli utéct do skal.", "Jdi do Smallville. Starostka Elda ví, kudy do Parního města. Řekni jí, že tě posílá odboj."])`, repeat_dialogue_pages `Array[String](["Běž! Dokud hoří, stráže tě v kouři nevidí."])`
- **c05** `E` next_level `"res://levels/c2/chapter2.tscn"`, stage_title `"KAPITOLA 1: ZÁKLADNA ODBOJE"`, stage_index `1`, max_stage_crystals `7`
- **a01, b01, c01**: `room checkpoint = true`

## Layout

```layout
chapter res://levels/c1/chapter1.tscn
c1_a01 0 0
c1_a02 1 0
c1_a03 1 -1
c1_a04 2 -1
c1_a05 3 -1
c1_a06 4 -2
c1_a07 4 -3
c1_a08 6 -3
c1_b01 7 -3
c1_b02 9 -3
c1_b03 11 -3
c1_b04 12 -3
c1_b05 14 -3
c1_b06 15 -4
c1_c01 16 -4
c1_c02 18 -4
c1_c02b 18 -5
c1_c03 19 -4
c1_c04 21 -4
c1_c05 22 -4
```

## Rooms

| id | size | from → to | challenge | elements | diff | crystal | CP |
|---|---|---|---|---|---|---|---|
| c1_a01 | 1×1 | start (L, h2) → a02 (R, h0) | Arrival at the scrap wall: hop a 4-wide, 2-deep ditch on a grate, climb or DJ a 5-tall block, drop to the exit. | grate, climb, `!` | 1 | — | ✔ |
| c1_a02 | 1×1 | a01 (L, h0) → a03 (ceiling hole) | Spring on the walking line: 5.6 up, DJ onto a floating h7 catwalk, jump + DJ through the hole. | **spring** | 1 | — | — |
| c1_a03 | 1×1 | a02 (floor hole) → a04 (R, h6) | Wrench chest in the armorer's shed, then spring at the lip of a 4-wide spike pit and DJ to the exit block. | chest, spring, spikes | 2 | **Skill detour**: crystal 1 tile above the spikes; drop to it after the spring, DJ late, grab the wall, climb. | — |
| c1_a04 | 1×1 | a03 (L, h6) → a05 (R, h2) | A corp guard that slipped in patrols a hazard-free yard; hop, stomp or wrench it. | **guard** | 1 | — | — |
| c1_a05 | 1×1 | a04 (L, h2) → a06 (R, h2) | Over spikes: grate → h3 platform with a guard → grate → exit; read the guard from the entry ledge. | grates, guard, spikes | 3 | **Secret passage**: cracked off-tone plate above the exit arch → FakeWall pocket. | — |
| c1_a06 | 1×2 | a05 (L bottom, h2) → a07 (ceiling hole) | Spiked shaft of the wall tower: spring → grate → guard ledge → spring → grate → hole. | springs, grates, guard, spikes | 3 | — | — |
| c1_a07 | 2×1 | a06 (floor hole) → a08 (R, h6) | Top of the wall: guard between curbs, grate + pillar over spikes, spring to a guarded ledge. | guards ×2, grate, spring, spikes | 3 | **Key/backtrack**: caged crystal on a shelf; key over the last gap. | — |
| c1_a08 | 1×1 | a07 (L, h6) → b01 (R, h2) | Breather at the camp gate: Otis (dialogue 2), health pack, view of the camp. | Otis `1`, `H` | 1 | — | — |
| c1_b01 | 2×1 | a08 (L, h2) → b02 (R) | Into the camp: up onto a row of DIY houses, roof-to-roof running jumps (gaps 2–5), a roof spring up to a plank walkway, down to the square. | houses, spring, grates | 2 | — | ✔ |
| c1_b02 | 2×1 | b01 (L) → b03 (R) | Camp square breather: Mira's briefing (dialogue 3) by the meeting-hall tent; easy hops over market stalls. | Mira `2`, tents, banners | 1 | — | — |
| c1_b03 | 1×1 | b02 (L) → b04 (R) | **Steam vent** intro in a boiler alley: vents blast up between houses (1 HP + knockback, not deadly); cross in the idle window. | vents, houses | 2 | **Mechanic trick**: a sideways spring (`S direction = Vector2(1, 0)`) on a chimney flings you across to a hidden roof nook. | — |
| c1_b04 | 2×1 | b03 (L) → b05 (R) | Freight yard: scrap conveyors carry you toward gaps; jump with/against them, springs between belts, a vent under a grate. | conveyors, springs, grates, vents, spikes | 3 | — | — |
| c1_b05 | 1×1 | b04 (L) → b06 (R, bottom) | Infirmary breather: Brann (dialogue 4), health pack. | Brann `3`, `H` | 1 | **Secret passage**: fake wall at the loft's end (looks like the wall) → FakeWall room with the crystal. | — |
| c1_b06 | 1×2 | b05 (L bottom) → c01 (R top) | Watchtower climb: springs and grate landings up a spiked shaft (no free climbing), vents on the side; lookout event at the top (`!`). | springs, grates, vents, spikes, `!` | 3 | — | — |
| c1_c01 | 2×1 | b06 (L) → c02 (R) | The raid starts: down from the tower over burning roofs; **falling debris** first appears over open roof (safe: watch it fall, then pass); fire gaps = spikes. | falling debris, spikes, grates, `!` | 2 | — | ✔ |
| c1_c02 | 1×1 | c01 (L) → c03 (R); branch up to c02b | **Steam turret** intro: a corp turret on a pole covers the square; move between cover (house walls, crates). A guard below. | turret, guard | 2 | — | — |
| c1_c02b | 1×1 | c02 (floor hole) ↔ c02 | Side gauntlet: burning attic above the square — debris, fire spikes, grates; crystal at the end, drop back to c02. | debris, spikes, grates | 4 | **Side gauntlet** | — |
| c1_c03 | 2×1 | c02 (L) → c04 (R) | Collapsing scaffolds: grates fall under you, debris from above, two guards on the planks, springs to the high scaffold. | grates, debris, guards ×2, springs | 3 | — | — |
| c1_c04 | 1×1 | c03 (L) → c05 (R) | Breather in the ashes: Brann again (dialogue), health pack. | Brann `3`, `H` | 1 | — | — |
| c1_c05 | 3×1 | c04 (L) → E (R) | Escape run over the outer roofs: springs, grates, debris, a turret, two guards, vents; the cliff road and `E` at the end. | everything | 3 | **Skill detour**: high roof line with the crystal (harder jumps). | — |

Enemies: guards a04, a05, a06, a07 ×2, c02, c03 ×2, c05 ×2 = 10; turrets c02, c05.

## Sketches

### c1_a01 — arrival at the scrap wall
```
   01234567890123456789
10 ZZZZZZZZZZZZZZZZZZZZ
 9 Z..................Z
 8 Z...........a......Z
 7 Z..........WWW.....Z
 6 Z.zz.......ZZZ.....Z
 5 Z.oz.......ZZZ.....Z
 4 Z..........ZZZ.....Z
 3 Z.@.!y....xZZZ......
 2 Z_____.==._ZZZ......
 1 ZZZZZZ....ZZZZx.pl..
 0 ZZZZZZ%%%%ZZZZ______
```
```props
room checkpoint = true
! speaker_name = "Základna odboje"
! dialogue_pages = Array[String](["Stezka z hor končí na dně rokle. Za skalní hradbou z rezavého plechu bliká pár lamp — tady někde se skrývá odboj.", "Půda pod nohama je popraskaná a v puklinách fialově žhne krystalová nákaza."])
```
- Ditch 4 wide / 2 deep: grate at h2 in the middle, falling in is safe (climb out). Block h7: 5 up = jump + DJ 5.5, or climb. Drop to h0.

### c1_a02 — spring intro
```
   01234567890123456789
10 ZZZZZZZZ...ZZZZZZZZZ
 9 Z..................Z
 8 Z........a.l.......Z
 7 Z......WWWWW.......Z
 6 Z......z...z.......Z
 5 Z......z...z.......Z
 4 Z......z...z.......Z
 3 .......z...z.....z.Z
 2 .......z...z.....b.Z
 1 ..@x.S.z..xz..y.p..Z
 0 Z__________________Z
```
- Spring -> 5.6, DJ (capped 7.9) and drift 2 right onto the h7 catwalk.
- Catwalk is 6/7 tiles from the walls.
- Catwalk -> hole: need 4, jump + DJ 5.5.

### c1_a03 — armorer's shed
```
   01234567890123456789
10 ZZZZZZZZZZZZZZZZZZZZ
 9 Z...................
 8 Z...................
 7 Z................pl.
 6 Z..a.............WWW
 5 Z.RRR............ZZZ
 4 ZRRRRR...........ZZZ
 3 Zwwww............ZZZ
 2 Zwowb..........C.ZZZ
 1 ZwXdw.@x....S^^^^ZZZ
 0 Z_______...__%%%%ZZZ
```
```props
X initial_items = Array[String](["wrench", "health_pack"])
```
- Hole cols 8-10 = a02's ceiling hole. Landing cols 5-7 (@ col 6). Spring (S, col 12) on the lip of the 4-wide spike pit cols 13-16.
- Main: spring (5.6) + DJ -> capped 7.9 over the h6 exit block, margin 1.9. Crystal at col 15 h2 (1 tile above spikes): spring, drop toward it, DJ late, grab the block wall, climb.

### c1_a04 — scrap yard
```
   01234567890123456789
10 ZZZZZZZZZZZZZZZZZZZZ
 9 ...................Z
 8 ...................Z
 7 .@.a...............Z
 6 WWWW...............Z
 5 ZZZZ................
 4 ZZZZ................
 3 ZZZZ...zzzz.....f.l.
 2 ZZZZ...zozb.....WWWW
 1 ZZZZ.p.zzGd..xy.ZZZZ
 0 ZZZZ____________ZZZZ
```
- Drop 6 from the ledge into a hazard-free yard (3 HP, no spikes). Guard patrols cols 4-15 between the ledge wall and the exit step: hop it, stomp it, or wrench it.

### c1_a05 — spike run
```
   01234567890123456789
10 ZZZZZZZZZZZZZZZZZZZZ
 9 Z................ZZZ
 8 Z.....kkkkkkkk...FFZ
 7 Z.bz..kkkkkkkk...FcZ
 6 Z................ZZZ
 5 ....................
 4 .........G..........
 3 .@y.....BBBB......l.
 2 WWW.==........==.WWW
 1 ZZZ^^^^^^^^^^^^^^ZZZ
 0 ZZZ%%%%%%%%%%%%%%ZZZ
```
- Ledge -> grate: gap 1, level. Grate -> platform (h3, guard): gap 2, +1. Platform -> grate 2: gap 2, -1. Grate -> exit ledge: gap 1, level.
- Secret: the F pocket cols 17-18 rows 7-8 looks like the scrap wall (crystal `c` inside); from grate 2 jump + DJ up-right (need 6, have 5.5 from h2 -> feet 7.5).

### c1_a06 — wall tower shaft
```
   01234567890123456789
21 ZZZZZZZZZ...ZZZZZZZZ
20 Z>................<Z
19 Z>................<Z
18 Z>........==......<Z
17 Z>.kz.............<Z
16 Z>.kz.............<Z
15 Z>.kz.....ob......<Z
14 Z>.kz.............<Z
13 Z>..............S.<Z
12 Z>..........p.GxW.<Z
11 Z>..........WWWWZ.<Z
10 Z>................<Z
 9 Z>......==........<Z
 8 Z>............kz..<Z
 7 Z.............kz..<Z
 6 Z.............kz..<Z
 5 ..............kz..<Z
 4 ..................<Z
 3 ..@x..yS..........<Z
 2 Z___..__..........<Z
 1 ZZZZ^^ZZ^^^^^^^^^^^Z
 0 ZZZZ__ZZ___________Z
```
- Ledge -> pillar: gap 2. Wait at col 6 for the guard (4-tile patrol, 0.4 s wind-up at each turn).
- S1 (h2): 7.6 + DJ = 10.1 -> h9 grate, 1 right. Grate -> ledge: gap 2, +2, inside 0.5 s.
- S2 (h12; pedestal turns the guard): DJ, capped 18.9 -> h18 grate, 5 left. Grate -> hole: need 4, have 5.5.
- Left spikes start at h8, so a plain jump from the entry is safe.

### c1_a07 — top of the wall
```
   0123456789012345678901234567890123456789
10 ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ
 9 ZZZZZZ................B.L...............
 8 ZZZZZZ............a...BCL.f..........K..
 7 ZZZZZZ................ZWWWWW.....G..l...
 6 ZZZZZZ.........................WWWWW..WZ
 5 ZZZZZZ................................ZZ
 4 ZZZZZZ..kkkkkkk..............S........ZZ
 3 ZZZZZZ......................WW........ZZ
 2 ZZZZZZ..................==..ZZ........ZZ
 1 ZZZZZZ.yx....@._..G.._^^^^^^ZZ^^^^^^^^ZZ
 0 ZZZZZZ___...___Z_____Z______ZZ________ZZ
```
- Guard A patrols cols 16-20 between bump and curb, away from the landing.
- Curb -> grate: gap 2, +1. Grate -> pillar: gap 2, +1; a low hop avoids the shelf above.
- Spring (h3): capped 7.9 -> guard B's h6 ledge, 2 right, no DJ. Time guard B from col 28.
- Ledge -> exit: gap 2, through the key.
- Key route: ledge -> shelf, gap 3, +1 (capped 7.9, need 7). Unlock L (brass cage), take C, drop to the pillar, spring again.

### c1_a08 — camp gate
```
   01234567890123456789
10 ZZZZZZZZZZZZZZZZZZZZ
 9 ............a......Z
 8 ...........RRR.....Z
 7 .@.a.....RRRRRRR...Z
 6 WWWW.....zzzzzzzBBBB
 5 ZZZZ.x...wowwwow....
 4 ZZZZWWW..zzzzzzz....
 3 ZZZZZZZ.Hwww1dww.lf.
 2 ZZZZZZZ_____________
 1 ZZZZZZZZZZZZZZZZZZZZ
 0 ZZZZZZZZZZZZZZZZZZZZ
```
```props
1 dialogue_pages = Array[String](["Matěji! Takže jsi prošel povrchem. Vítej na Základně — poslední místo, kam korporace ještě nedosáhla.", "Ten hasák z kůlny sis vzal dobře. Seknutím [LMB / F] rozbiješ hodinový strojek každé stráže.", "Velitelka Mira tě čeká na náměstí za branou."])
1 repeat_dialogue_pages = Array[String](["Mira je na náměstí. Jdi dál do tábora."])
```
- Breather: no hazards. Steps h6 -> h4 -> h2, Otis in front of his hut, health pack, brass lintel gate.

### c1_b01 — rooftop crossing
```
   0123456789012345678901234567890123456789
10 ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ
 9 Z.......................................
 8 Z.......................................
 7 Z........................la..........pl.
 6 Z................f.l....RRRRR.......WWWW
 5 ..........a....RRRRRR...ZZZZZ...S...ZZZZ
 4 ........RRRRR..ZZZZZZ...ZZbZZ..RRR..ZZZZ
 3 ..@y....ZZZZZ..ZbZoZZ...ZZoZZ..ZZZ..ZZZZ
 2 ______..ZZoZZ..ZZZZZZ...ZZZZZ..ZZZ..ZZZZ
 1 ZZZZZZ.xZZdZZx.ZZZZZZ^^^ZZZZZ^^ZZZ^^ZZZZ
 0 ZZZZZZ%%ZZZZZ%%ZZZZZZ%%%ZZZZZ%%ZZZ%%ZZZZ
```
```props
room checkpoint = true
```
- Ledge -> H1: gap 2, +2. H1 -> H2: gap 2, +1. H2 -> H3: gap 3, +1 (spikes below). H3 -> H4: gap 2 +, -2. H4 spring (col 32) or jump -> walkway h6 (gap 2, +2).
- Pits between safe houses are 4-5 deep (climb out); spikes only under the longer gaps.

### c1_b02 — camp square
```
   0123456789012345678901234567890123456789
10 ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ
 9 ....................RRRR...............Z
 8 ..................RRRRRRRR.............Z
 7 .@.p............RRRRRRRRRRRR...........Z
 6 WWWW.............tttttttttt............Z
 5 ZZZZ......tttt...tottttttot.tttt........
 4 ZZZZWW....tttt...zbzzzzzzzz.tttt........
 3 ZZZZZZ.xl..WW..f.tttdt2tttt..WW..f.l.y..
 2 ZZZZZZ__________________________________
 1 ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ
 0 ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ
```
```props
2 dialogue_pages = Array[String](["Tak ty jsi ten z povrchu. Rozhlédni se — vrty korporace vysávají gravitační krystaly z jádra planety a země praská.", "Smallville, vesnice na svahu nad námi, umírá jako první. Studny jsou otrávené a korporátní stráže vyhánějí poslední rodiny.", "Nad vesnicí, výš na hoře, leží Parní město, sídlo korporace. Odtud vrtají do nitra hory až k jádru planety. Tam musíme udeřit.", "Brann ti v ošetřovně doplní síly. Pak se hlas na hlídkové věži."])
2 repeat_dialogue_pages = Array[String](["Hlídková věž je na konci tábora. Dej vědět, co vidíš."])
```
- Breather. Walk-in from the walkway (h6), two steps down to the square (h2), stalls 1 high, meeting-hall tent with Mira.

### c1_b03 — boiler alley
```
   01234567890123456789
10 ZZZZZZZZZZZZZZZZZZZZ
 9 Z...............RRRR
 8 Z................kkZ
 7 Z....qS.........l.CZ
 6 Z...RRR..........WWW
 5 ....www.............
 4 ..W.wob.............
 3 .@Z.www.V.WW..Vx.yp.
 2 ____________________
 1 ZZZZZZZZZZZZZZZZZZZZ
 0 ZZZZZZZZZZZZZZZZZZZZ
```
```props
S direction = Vector2(1, 0)
V idle_time = 1.4
V2 offset = 0.7
```
- Vents cols 8, 14: 1 s blast / 1 s idle, 0.5 s hiss; 1 HP, not deadly. Crate refuge cols 10-11 between them.
- Crystal: crate (col 2) -> roof cols 4-6 (h6) -> sideways spring at col 6 flings right across 10 tiles to the nook cols 17-19 (h6).

### c1_b04 — freight yard
```
   0123456789012345678901234567890123456789
10 ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ
 9 Z......................................Z
 8 Z......................................Z
 7 Z......................a.l.............Z
 6 Z.....................WWWW.............Z
 5 ........................................
 4 ...........................==...V.......
 3 .@y..............f.Sx.........~~~~....l.
 2 ____~~~~~...~~~~~____................___
 1 ZZZZZZZZZ.x.ZZZZZZZZZ......^^^^^^^^^^ZZZ
 0 ZZZZZZZZZ%%%ZZZZZZZZZ%%%%%%%%%%%%%%%%ZZZ
```
```props
~1 speed = 60.0
~2 speed = 90.0
~3 speed = -90.0
```
- Belts (row-major): ~1 = high belt cols 30-33 (+60, carries toward the spike gap), ~2 = cols 4-8 (+90), ~3 = cols 12-16 (-90, pushes back toward the safe pit).
- Spring (col 19) -> plank platform h6 cols 22-25. Platform -> grate (cols 27-28, h4): gap 1, -2. Grate -> belt h3: gap 1. Vent on the belt (col 32). Belt -> ledge: gap 3 over spikes, -1.

### c1_b05 — infirmary
```
   01234567890123456789
10 ZZZZZZZZZZZZZZZZZZZZ
 9 ZRRRRRRRRRRRRRRRR..Z
 8 ZFFF...o.b.........Z
 7 ZcFF...............Z
 6 ZWWWWWWWWW.........Z
 5 ..wwwwwwwwwwwwwww...
 4 ..wwwwwowwwwwwwww...
 3 .@www3wwHwwWWwwfdyx.
 2 ____________________
 1 ZZZZZZZZZZZZZZZZZZZZ
 0 ZZZZZZZZZZZZZZZZZZZZ
```
```props
3 dialogue_pages = Array[String](["Hasák od Otise? Ten starý blázen ti dal svůj nejlepší kus. Opatruj ho.", "Vezmi si lékárničku. A drž se dál od fialových prasklin — co vyroste z nákazy, řeže jako sklo."])
3 repeat_dialogue_pages = Array[String](["Drž se, kluku."])
```
- Breather: Brann + health pack on the ground floor. Attic: hop the crate (cols 11-12, h3), then jump + DJ (need 3 more, have 5.5) onto the loft h6; the loft's left end (cols 1-3, h7-h8) is fake wall that looks like the rest; the crystal `c` hides inside.

### c1_b06 — watchtower climb
```
   01234567890123456789
21 ZZZZZZZZZZZZZZZZZZZZ
20 Z>..z...............
19 Z>..z...............
18 Z>..z.......a.!.fl..
17 Z>..z....WWWWWWWWWWW
16 Z>..z....ZZZZZZZZZZZ
15 Z>..z....ZZZZZZZZZZZ
14 Z>..z..wwww.......<Z
13 Z>.....wwww.......<Z
12 Z>.S.V.wwww.......<Z
11 Z>WWWWWwwww.......<Z
10 Z>.....wwww.......<Z
 9 Z>.....wwww==.....<Z
 8 Z>.....wobw.......<Z
 7 Z>.....wwww.......<Z
 6 Z>.....wwww.......<Z
 5 ...................Z
 4 ...................Z
 3 ..@.....S..........Z
 2 ____...___.........Z
 1 ZZZZ^^^ZZZ^^^^^^^^.Z
 0 ZZZZ%%%ZZZ%%%%%%%%ZZ
```
```props
! speaker_name = "Hlídková věž"
! dialogue_pages = Array[String](["Na obzoru se zvedá prach. Kolona korporátních strojů míří přímo k táboru!", "Stráže už jsou u brány. Někdo nás prozradil..."])
```
- Ledge -> pillar: gap 3. S1 (h2, col 8): 7.6 + DJ = 10.1 -> grate h9 cols 11-12, 3 right. Grate -> ledge L2 (h11, cols 2-6): gap 4, +2, within 0.5 s.
- L2: vent col 5 between the landing (col 6) and S2 (col 3): cross in the idle window. S2: 16.6 + DJ, capped 18.9 -> tower top h17 (cols 9-19), 5.5 right. Walls spiked: no free climbing.
- Exit labels 18-20 at col 19 = c1_c01's left opening rows 7-9.

### c1_c01 — the raid begins
```
   0123456789012345678901234567890123456789
10 ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ
 9 .......................................Z
 8 .............WWW............WWW........Z
 7 .@!a..........O..............O.........Z
 6 WWWW...x...............................Z
 5 ZZZZ..RRRR..h...yh.........h............
 4 ZZZZ..ZZZZ..RRRRRR.==.hx...RRRR.........
 3 ZZZZ..ZZoZ..ZZZZZZ....RRR..ZZZZ...l.ph..
 2 ZZZZ..ZZZZ..ZZbZZZ....ZZZ..ZbZZ.._______
 1 ZZZZ..ZZZZ..ZZZZZZ^^^^ZZZ^^ZZZZ^^ZZZZZZZ
 0 Z%%%%%ZZZZ%%ZZZZZZ%%%%ZZZ%%ZZZZ%%ZZZZZZZ
```
```props
decor burning = true
! portrait_texture = "res://assets/npc/mira_portrait.png"
room checkpoint = true
! speaker_name = "Mira (vysílačka)"
! dialogue_pages = Array[String](["Matěji! Prorazili bránu. Nečekej na nás — utíkej po střechách k cestě do Smallville!"])
```
- Debris O (cols 14, 29): hangs under a burnt beam above open roof; walk on, it falls behind you. Fire gaps = spikes (2-4 wide, grate cols 19-20 over the widest).
- Ledge -> roof A: gap 2, -1. A -> B: gap 2, -1. B -> grate: gap 1; grate -> C: gap 1, -1. C -> D: gap 2, +1. D -> ground: gap 2, -2.

### c1_c02 — the turret square
```
   01234567890123456789
10 ZZZZZZZZ...ZZZZZZZZZ
 9 Z..................Z
 8 Z................T.Z
 7 Z...............BBBZ
 6 Z........S.........Z
 5 ........WW......zzz.
 4 ....WW..ZZ....WWbbb.
 3 .@.yZZxhZZ.GhxZZzzz.
 2 ____________________
 1 ZZZZZZZZZZZZZZZZZZZZ
 0 ZZZZZZZZZZZZZZZZZZZZ
```
```props
decor burning = true
```
- Turret on the gantry arm (cols 16-18, h7): bolts need line of sight; cover = crate A (h4), pillar B (h5), crate E (h4). Guard patrols cols 10-13 between B and E.
- Branch up: spring on pillar B (col 9, h5) -> 5.6 + DJ through the ceiling hole cols 8-10 into c1_c02b (its floor top = h11 here).

### c1_c02b — burning attic (side gauntlet)
```
   01234567890123456789
10 ZZZZZZZZZZZZZZZZZZZZ
 9 Z..................Z
 8 Z..............WWW.Z
 7 Z...............O..Z
 6 Z..................Z
 5 Z.................CZ
 4 Z.................WW
 3 Z.................ZZ
 2 Z..............==.ZZ
 1 Z.xy..@.....x.^^^^ZZ
 0 Z_______...___%%%%%Z
```
```props
decor burning = true
```
- Floor hole cols 8-10 = c1_c02's ceiling hole; falling back through it is the way home. Landing cols 5-7 (@ col 6).
- Hole (3) -> floor -> grate cols 15-16 (h2, gap 1, +2) over fire spikes; the debris O drops after ~0.85 s, keep moving. Grate -> crystal plank (h4, cols 18-19): gap 1, +2, inside 0.5 s.

### c1_c03 — collapsing scaffolds
```
   0123456789012345678901234567890123456789
10 ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ
 9 Z..................WWW.................Z
 8 Z...................O......h.G..h......Z
 7 Z.........................WWWWWWW......Z
 6 Z..........................w...w.......Z
 5 ......................hS...w...w........
 4 .......h.G..h......WWWWW...w...w........
 3 .@yl...WWWWWW..==...w.w..............xp.
 2 _____...w..w........w.w.............____
 1 ZZZZZ^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^^ZZZZ
 0 ZZZZZ%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%ZZZZ
```
```props
decor burning = true
```
- Ledge -> scaffold 1 (h3, guard): gap 2, +1. Scaffold -> grate cols 15-16: gap 2. Grate -> scaffold 2 (h4): gap 2, +1; debris O over cols 19-21.
- Spring (col 23): 4+5.6, capped 7.9 -> high scaffold h7 (guard), 3 right. High scaffold -> ground ledge: gap 3, -5.

### c1_c04 — ashes
```
   01234567890123456789
10 ZZZZZZZZZZZZZZZZZZZZ
 9 Z..................Z
 8 Z....RRR...........Z
 7 Z...RRRRR..........Z
 6 Z......qqqqqqq.....Z
 5 ......qqqqqqqqq.....
 4 .....qqbqqkqqqbq....
 3 .@xy.qqqq3qqHqqyaxp.
 2 ____________________
 1 ZZZZZZZZZZZZZZZZZZZZ
 0 ZZZZZZZZZZZZZZZZZZZZ
```
```props
decor burning = true
3 dialogue_pages = Array[String](["Tábor je ztracený... ale lidi stihli utéct do skal.", "Jdi do Smallville. Starostka Elda ví, kudy do Parního města. Řekni jí, že tě posílá odboj."])
3 repeat_dialogue_pages = Array[String](["Běž! Dokud hoří, stráže tě v kouři nevidí."])
```
- Breather in the ashes: burnt hall (scorched brick back tiles), Brann, health pack, no hazards.

### c1_c05 — escape over the roofs
```
   012345678901234567890123456789012345678901234567890123456789
10 ZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZZ
 9 Z..........................WWW.............................Z
 8 Z...........................O...h.......a......hC..........Z
 7 Z...............................WWW....WWW....WWW.........TZ
 6 Z..........................h..S...................G.x.....ZZ
 5 ....................G.h...RRRRR......hV.........RRRRRR....ZZ
 4 .......haV........RRRRR...ZZZZZ....RRRRRRR...==.ZZZZZZ....ZZ
 3 .@y.l..RRRRR...==.ZZZZZ...ZZoZZ....ZZZZZZZ......ZZoZZZ.lE.ZZ
 2 _____..ZZZoZ......ZZbZZ...ZZZZZ....ZZZbZZZ......ZZZZZZ_____Z
 1 ZZZZZ..ZZZZZ^^^^^^ZZZZZ^^^ZZZZZ^^^^ZZZZZZZ^^^^^^ZZZZZZZZZZZZ
 0 ZZZZZ%%ZZZZZ%%%%%%ZZZZZ%%%ZZZZZ%%%%ZZZZZZZ%%%%%%ZZZZZZZZZZZZ
```
```props
decor burning = true
E next_level = "res://levels/c2/chapter2.tscn"
E stage_title = "KAPITOLA 1: ZÁKLADNA ODBOJE"
E stage_index = 1
E max_stage_crystals = 7
```
- Main: ledge -> H1 (h3, vent) gap 2; -> grate (gap 3) -> H2 (h4, guard) gap 1; -> H3 (h5, debris) gap 3; -> H4 (h4, vent) gap 4; -> grate (gap 3) -> H5 (h5, guard) gap 1; drop to the cliff road, turret on the pole, E at the end.
- Crystal: spring on H3 (col 30) or jump -> high planks h7 cols 32-34 / 39-41 / 46-48 (gaps 4, 3-wide landings), crystal at col 48.

**Open item:** check which RespawnPoint a06 uses when the player falls back in from a07. If needed, add one on the h11 ledge.
