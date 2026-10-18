# Dokumentace Projektu: 2D Plošinovka (Steampunk Odyssey)

Vítej v dokumentaci pro moderní 2D přesnou plošinovku vytvořenou v Godot Engine 4.6. Hra kombinuje dynamické prvky pohybu inspirované Celeste s klasickými mechanikami Super Mario Bros. Hra byla kompletně vizuálně přepracována pomocí vlastních textur, procedurálního steampunkového stylu a uspořádána do ucelené kampaně s kapitolami (**Prolog + 3 Etapy + Boss aréna**).

---

## 🎮 Ovládání a Mechaniky Pohybu

- **Pohyb vlevo / vpravo:** A / D (plynulá akcelerace a tření)
- **Skok:** W
  - **Coyote Time:** Umožňuje skočit ještě chvíli (0.1s) poté, co hráč opustil okraj plošiny.
  - **Jump Cut:** Uvolnění klávesy W během vzestupu zkrátí výšku skoku pro maximální kontrolu.
- **Přikrčení:** Držet S (zmenší velikost kolizního tvaru na polovinu, sníží rychlost pohybu)
- **Wall-Cling, Wall-Climb & Wall-Jump (Wall Stamina System):**
  - **Celeste-style Šplhání (Climb):** Pokud hráč drží směr do zdi, přichytí se k ní. V tomto stavu se může aktivně pohybovat nahoru a dolů po stěně:
    - **Pohyb nahoru:** Držet **W** (klávesa pro skok / nahoru). Postava začne šplhat vzhůru.
    - **Pohyb dolů:** Držet **S** (klávesa pro skrčení / dolů). Postava začne slézat dolů.
    - **Visení na místě (Cling):** Pokud hráč nedrží vertikální směr, zůstane pevně viset na místě.
  - **Výdrž (8 sekund):** Na celý proces šplhání a visení má hráč celkovou zásobu **8 sekund staminy**.
  - **Visual Cooldown Bar:** Při aktivním držení na stěně se nad hlavou postavy objeví barevný ukazatel, který postupně mizí a plynule mění barvu ze **zelené** (plná výdrž) přes žlutou do **červené** (vyčerpání).
  - Pokud hráč směr do stěny pustí, sklouzává dolů pomalým skluzem.
  - Pokud stamina klesne na 0, bar zmizí, hráč ztrácí kontakt se zdí, padá dolů plnou gravitací a nemůže provést Wall-Jump, dokud opět nedopadne na zem.
  - Wall-Jump na stěně mírně vyčerpává výdrž.
- **Dash:** Stiskni Space. Umožňuje bleskový skok jakýmkoliv směrem (včetně diagonálního). Dash se resetuje po dopadu na zem.

---

## 🎨 Grafický Kabát a Styl

Hra využívá speciální autorské pixel-artové textury nakopírované ze složky `assets/aseprite`:
- **Hlavní postava:** Má plynulé animace pro nečinnost (`idle`), chůzi (`walk`), skok/pád (`jump`) a lezení po stěnách (`climb`). Vše se vykresluje pomocí `AnimatedSprite2D` a přizpůsobuje se retro rozlišení.
- **Plošiny a překážky:** Jsou tvořeny dlaždicovou (opakující se) texturou `block-trava.png` s jemným retro měřítkem. Skript automaticky barví (moduluje) tyto plošiny podle unikátních barev každého levelu, což vytváří jedinečnou atmosféru.
- **Bodáky (Pasti):** Jsou nahrazeny detailním spritem `trap.png`.
- **Atmosférické pozadí:** Každá úroveň má statické pixel-artové pozadí `background.png` vykreslované na pozadí, což dodává hře hloubku.

---

## 🎛️ Hlavní Menu a Herní Smyčka (res://global.gd)

- **Hlavní Scéna:** Projekt začíná na landing page `main_menu.tscn`, která obsahuje přehledný panel (ScrollContainer) s tlačítky pro Tutoriál a jednotlivé etapy hry (Sektor 1: Šachta, Sektor 2: Doly, Sektor 3: Reaktor).
- **Statistiky na obrazovce (Autoload res://global.gd):**
  - **Počítadlo Smrtí (Death Count - vlevo nahoře):** Sleduje celkový počet úmrtí hráče.
  - **Počítadlo Zabití (Kill Count - vpravo nahoře):** Zobrazuje celkový počet zničených nepřátel.
  - Obě počítadla se při návratu do hlavního menu nulují.
- **Zóna Cíle (level_end.tscn):** Zlatý portál na konci každého levelu, který automaticky vyvolá StageClearScreen a načte další etapu v pořadí.

---

## 🗺️ Přehled Kampaně

1. **Prolog: Na Povrchu (tutorial_level.tscn) [Celeste-Style Redesign, 6 velkých místností / 16 obrazovek]:** Úvod do ovládání, skákání, plazení pod nízkými stropy, Wall-Jumpů a sestupu po starém lešení do rokle, kde začíná Kapitola 1 (Základna odboje).
2. **Etapa 1: Staré dílny / Šachta (level1.tscn) [Celeste-Style Redesign]:**
   - Level je tvořen **6 velkými Celeste místnostmi (19 obrazovek)** – kamera v každé jede za hráčem; hráč má jen hasák, dvojskok a lezení po zdech (bez háku a dashe).
   - **Místnost 1 – Vstupní slévárna (2x1):** skákání, dvojskok na plovoucí plošinu se strážcem, bodáky, drolící můstek a pád dírou do šachty.
   - **Místnost 2 – Sklad ventilů (3x2):** sestup věží k Celeste klíči, nesení klíče halou (parní tryska, střelec s krytím, dron nad bodáky, tryska u pilíře) k zamčené bráně; volitelný krystal přes drolící plošiny pod stropní tryskou.
   - **Místnost 3 – Vertikální šachta (1x3):** schody plošin nad bodáky, lezení po zdi (stamina) a drolící můstek s dronem; krystal v bočním výklenku.
   - **Místnost 4 – Přetlaková komora (2x2):** diagonální sestup po ostrůvcích nad polem bodáků, strážce a parní tryska na ostrově, volitelný krystal dvěma dvojskoky.
   - **Místnost 5 – Jádro generátoru (1x2):** gravitační výtah – anomálie otočí gravitaci, hráč „padá“ vzhůru úzkou šachtou mezi bodáky, projde po stropě a druhou anomálií se vrátí na balkón.
   - **Místnost 6 – Vstup do krystalových dolů (2x1):** závěrečný klidnější úsek s bodáky a portálem do Etapy 2.
3. **Etapa 2: Krystalové doly (level2.tscn) [Celeste-Style Redesign]:**
   - Level je tvořen **6 velkými Celeste místnostmi (21 obrazovek)**; hlavní novinkou je **dash (Gravity Coil)** od Rustyho, hák hráč ještě nemá.
   - **Místnost 1 – Krystalový vestibul (2x2):** výuka dashe – mezera 12 dlaždic, kterou přeskočí jen skok + dash; pod ní bezpečná jáma se schody zpět, stěna na druhé straně je pokrytá bodáky.
   - **Místnost 2 – Krystalová propast (2x2):** dash přes 16 dlaždic širokou propast s bodáky na ostrůvek s dronem; krystal nad ostrůvkem (skok + dvojskok + dash nahoru).
   - **Místnost 3 – Větrná šachta (1x2):** lezení po pilíři a skok s dashem přes šachtu na výstupní římsu (pravá stěna s bodáky nejde vylézt).
   - **Místnost 4 – Safírová geoda (3x2):** drolící se schody, strážce, střelec a parní tryska; Celeste klíč na odbočce přes široký skok s dashem, krystal nad klíčem (diagonální dash) a brána.
   - **Místnost 5 – Chrám gravitace (1x2):** gravitační výtah – chůze po stropě, přeskok stropního příkopu s bodáky a návrat druhou anomálií na balkón.
   - **Místnost 6 – Výtah do reaktoru (3x1):** závěrečná zkouška – dva široké příkopy s bodáky (skok + dvojskok + dash) s ostrůvkem s tryskou, drolící schody ke krystalu a portál do Etapy 3; styl reaktoru předznamenává další etapu.
4. **Etapa 3: Předpolí reaktoru (level3.tscn) [Celeste-Style Redesign]:**
   - Level je tvořen **6 velkými Celeste místnostmi (20 obrazovek)**; hlavní novinkou je **přitahovací hák** od Vesper, který se kombinuje s dashem a lezením.
   - **Místnost 1 – Kotevní hala (2x2):** výuka háku – propast 16 dlaždic se 3 kotvami nad bezpečným dnem se schody zpět; převis na druhé straně nedovolí propast obejít lezením; krystal nad propastí.
   - **Místnost 2 – Parní galerie (2x1):** příkop s bodáky přes 2 kotvy, mezi nimi stropní parní tryska (načasování), strážce a střelec.
   - **Místnost 3 – Chladicí šachta (1x3):** sestup po plošinách a drolících prknech, bodáky na stěnách, boční trysky, strážce a dron; krystal nad šachtou jen s hákem.
   - **Místnost 4 – Gravitační komora (3x2):** anomálie otočí gravitaci, chůze po stropě přes bodáky a tunelem s tryskou ke klíči, druhá anomálie vrátí hráče do vzdálené haly k bráně.
   - **Místnost 5 – Jádro reaktoru (1x3):** lezení úzkou dírou na římsu a žebřík ze 3 kotev mezi stěnami s bodáky; krystal u vrcholu.
   - **Místnost 6 – Předsíň reaktoru (2x1):** finální příkop se 2 kotvami a tryskou v dráze letu, truhla se zásobami před bossem a portál do boss arény.
5. **Boss Aréna: Velín reaktoru (boss_room.tscn):** Finální komora reaktoru po dokončení Etapy 3.
---


## 🛠️ Maturitní projekt – Etapa 1+2: nové pohybové mechaniky

- **Přitahovací hák (grappling hook) s mířením myší a poškozením:**
  - **Inventář & výbava:** hák je položka v inventáři (`ui/inventory_ui.tscn`), zobrazená ve spodním HUD slotu `[1] 🪝 Hák`. Lze jej zapnout/vypnout klávesou **1** nebo kliknutím myší na slot. Ve výchozím stavu je aktivní.
  - **Míření myší & zaměřovač (HookReticle):** při vybaveném háku se zobrazuje dynamický zaměřovač s laserovým naváděním:
    - **Zlatý kroužek:** míří na kotvu (`mechanics/grapple_point.tscn`) v dosahu (88 px) a v přímé viditelnosti; zeď hák zastaví, ale nezachytí.
    - **Červený rámeček [ X ]:** míří na nepřítele v dosahu.
    - **Bronzový kroužek:** prázdný prostor / mimo dosah.
  - **Vystřelení (L-Klik / R-Klik / E):**
    - Pokud zasáhne **nepřítele**, udělí mu poškození (**2 DMG**), nepřítel červeně zabliká a po vyčerpání životů padne (+1 zabití do počítadla).
    - Pokud míří na **kotvu**, hák se pevně zachytí a plynule přitáhne hráče rychlostí 380 px/s (hák se chytá jen kotev, aby level design určoval, kde jde použít).
    - **Katapultový odskok (Slingshot jump):** stiskem **W (skok)** během přitahování hráč hák odpojí a vystřelí se dopředu/nahoru s obnoveným dashem i dvojskokem.
- **Prohození gravitace:** energetické anomálie (`mechanics/gravity_anomaly.tscn`) volají `set_gravity_dir()` na hráči. Režim `TOGGLE` gravitaci při vstupu přepne, režim `WHILE_INSIDE` ji obrátí jen uvnitř anomálie. Hráč se při obrácené gravitaci překlopí a chodí po stropě.
- **Testovací místnost:** `test/test_movement.tscn` (v menu tlačítko „Test pohybu“) obsahuje ověřovací úseky pro dvojskok, míření a přitahování hákem, útok hákem na cvičného nepřítele i gravitační chodbu.

---

## 💾 Maturitní projekt – Ukládání hry, pauza a mřížkový inventář (Grid Inventory & Truhla)

### 1. Systém ukládání hry (SaveManager)
- **Autoload:** `autoload/save_manager.gd` registrovaný globálně v `project.godot`.
- **Ukládání do JSON souboru (`user://save.json`):**
  - Ukládá aktuální scénu, pozici hráče (spawn checkpoint), počet HP a maximální životy, sebrané krystaly a jejich unikátní ID, statistiky (smrti, zabití) a kompletní stav mřížkového inventáře hráče (souřadnice X, Y i rozměry po rotaci).
  - Tlačítko **"Pokračovat"** v hlavním menu je aktivní pouze tehdy, pokud existuje platný save soubor.
  - V menu pauzy (`ui/pause_menu.tscn`) klávesou `[ESC]` lze hru kdykoliv uložit, pokračovat, restartovat od checkpointu nebo se vrátit do hlavního menu.

### 2. Mřížkový inventář (Grid Inventory - styl Resident Evil / Backpack Hero)
- **Třída `GridInventory` (`mechanics/grid_inventory.gd`):** spravuje matici buněk $6 \times 4$, ověřuje AABB kolize předmětů a podporuje ukládání/načítání.
- **Různé rozměry a tvary předmětů (`mechanics/item_data.gd`):**
  - 🔧 **Hasák (Wrench):** $1 \times 2$ (vertikální obdélník) – zbraň na blízko (LMB/F, 2 poškození).
  - 🪝 **Přitahovací hák (Grapple Hook):** $2 \times 1$ (horizontální obdélník) – přitahování ke kotvám (RMB/LMB).
  - ⚡ **Gravitační cívka (Gravity Coil):** $2 \times 2$ (čtverec) – pohání bleskový Dash a uděluje průrazné poškození (2 poškození + knockback).
  - ✚ **Lékárnička (Health Pack):** $1 \times 1$ – obnovuje 1 ztracené srdíčko.
  - 🗝 **Klíč od šachty (Mine Key):** $1 \times 2$ – odemyká bezpečnostní zábrany v dole.
- **Rotace a manipulace:**
  - Klávesa **[R]** nebo **Pravé tlačítko myši (RMB)** prohodí šířku a výšku drženého předmětu (např. otočení hasáku z $1 \times 2$ na $2 \times 1$).
  - Vizuální preview (zelené = volné místo, červené = kolize s jiným předmětem nebo přesah z mřížky).
  - Samostatné okno batohu (`ui/backpack_window.tscn`) otevírané klávesou **[I]** nebo **[Tab]**.

### 3. Gravity Coil (Dash jako zbraň)
- Schopnost Dash je nyní podmíněna přítomností předmětu **Gravity Coil** v batohu hráče.
- Bez cívky se zobrazí plovoucí varování `⚠️ Chybí Gravity Coil!`.
- S cívkou hráč při stisku Mezerníku získá fialový energetický plášť a při průletu nepřítelem mu udělí **2 poškození** a knockback. Stejně tak hasák a hák vyžadují přítomnost příslušného předmětu v inventáři.

### 4. Interaktivní truhla se split-screen rozložením (Chest)
- **Prefab truhly (`mechanics/chest.tscn`):** umístěna na začátku Levelu 1 mezi hráčem a NPC Otisem na pozici `(65, 153)`.
- **Interakce klávesou [E]:** po přiblížení se zobrazí odznak `[E] Otevřít` a stiskem klávesy se otevře okno truhly (`ui/chest_window.tscn`).
- **Split-Screen UI:**
  - Vlevo: **Batoh hráče ($6 \times 4$)**.
  - Vpravo: **Obsah truhly ($6 \times 4$)**.
  - Truhla obsahuje výchozí výstroj: Hasák, Hák, Gravity Coil, Lékárničku a Klíč od šachty.
  - Hráč může kliknutím vyzvednout libovolný předmět z truhly, libovolně jej natočit klávesou `[R]` a umístit do svého batohu.

---

## 🔑 Celeste-style létající klíč & klíčový blok (CelesteKey & KeyBlock)
- **Létající klíč (`mechanics/celeste_key.tscn`):**
  - Vznáší se na své výchozí pozici (např. vyvýšený trám v Sektoru 1-0).
  - Po sebrání hráčem přejde do stavu `FOLLOWING` a plynule následuje hráče vzduchem jako společník (plynulý elastický lerp s vlněním a náklonem).
  - **Reset při smrti hráče:** pokud hráč zemře dříve, než klíč použije v zámku, klíč se okamžitě vrátí na svou výchozí pozici (respawne se) a hráč jej u sebe po oživení nemá.
- **Klíčový blok / brána (`mechanics/key_block.tscn`):**
  - Pevný blok prostředí (StaticBody2D) s klíčovou dírkou, který brání v průchodu (např. bezpečnostní zábrana šachty na souřadnicích `(616, 310)`).
  - Když se k němu přiblíží hráč s klíčem: klíč se odpoutá, vletí do klíčové dírky, otočí se o 90°, odemkne zámek se zábleskem a zmizí.
  - Blok se rozpadne, vypne svou kolizi a trvale uvolní průchod do další části mapy.

---

## ⚙️ Steampunkové environmentální hrozby (SteamVent & CrumblingPlatform)
- **Časovaná parní tryska (`mechanics/steam_vent.tscn`):**
  - Pravidelně cykluje mezi třemi stavy:
    1. `IDLE` (2.0 s): tryska je neaktivní, z mřížky stoupá jen nepatrný kouř.
    2. `WARN` (0.5 s): tryska vibruje a syčí varovným přetlakem.
    3. `BLAST` (1.0 s): prudký výtrysk horké páry, který popálí hráče (**1 poškození**) a odhodí ho tlakovou vlnou.
- **Padající / drolící se plošina (`mechanics/crumbling_platform.tscn`):**
  - Pevná kamenná/kovová plošina, která po došlápnutí hráče začne 0.5 s vibrovat s prasklinami (`SHAKING`).
  - Po 0.5 s se zřítí (`FALLEN`), vypne svou kolizi a zmizí.
  - Po 2.5 s se automaticky plynule obnoví (`SOLID`) a je opět připravena ke skoku.

---

## 🎒 Progresivní odemykání nástrojů v sub-etapách (Celeste / Metroidvania Progression)
Hráč začíná s prázdným batohem a postupně si odemyká nástroje v jednotlivých sub-etapách od příběhových NPC:

1. **Sub-etapa 1: Povrchové ruiny (Otis):**
   - Hráč získá od Otise v dílně pouze **Hasák (Wrench)** a lékárničku.
   - V této sub-etapě **nemá** Gravity Coil ani Hák.
   - Výzvy a překážky jsou vybalancovány tak, aby stačil základní běh, dvojskok, šplh po zdi a útok hasákem na blízko.
2. **Sub-etapa 2: Parní šachty & Křižovatka (Rusty):**
   - Hráč získá od těžaře Rustyho **Gravitační cívku (Gravity Coil)**.
   - Nyní kombinuje **Hasák + Gravity Coil Dash**: překonává dlouhé propasti, parní trysky, drolící se mosty a získá létající Celeste klíč.
   - Hráč **stále nemá Hák** a žádná překážka v této části hák nevyžaduje.
3. **Sub-etapa 3: Velká propast & Reaktor (Vesper):**
   - Hráč získá od rebelky Vesper **Přitahovací hák (Grapple Hook)**.
   - Nyní kombinuje **všechny 3 nástroje současně (Hasák + Gravity Coil + Hák)**: míření pravým tlačítkem na zlaté kotvy nad propastí, katapultový odskok do dashe a překonání gravitační komory na stropě.

---





