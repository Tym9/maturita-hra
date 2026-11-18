SEZNAM GRAFIKY – PPJ 2D (steampunk/fantasy, styl Celeste)
Měřítko: obrazovka 320×180 px, dlaždice 16×16 px, postava v hře ~16×24 px (hitbox 14×18).
Barvy: smrtící = červená/oranžová, pomocné = tyrkysová/mosazná. Animace = počet snímků v závorce (doporučení).
[MÁ] = už existuje grafika (často jen placeholder), [KÓD] = teď kreslené kódem/tvary, [CHYBÍ] = nic.

==================================================
1. HRÁČ (Matěj, člen odboje)
==================================================
[MÁ]    stání / idle (3)                – assets/aseprite/postava.png (snímky 128×128)
[MÁ]    chůze / běh (8)                 – chuze.png
[MÁ]    skok (9)                        – SKOK.png
[MÁ]    lezení po zdi (4)               – lezeni.png
[CHYBÍ] pád (2–3)
[CHYBÍ] skluz po zdi (2)
[CHYBÍ] držení na zdi bez pohybu (1–2) + vyčerpání staminy (blikání/třes)
[CHYBÍ] dvojskok (3–4)
[CHYBÍ] přikrčení + plazení (2 + 4)
[CHYBÍ] dash (2–3) + odraz po dashi
[CHYBÍ] útok hasákem (3–4) – i ve skoku
[CHYBÍ] hák: výstřel (2), visení/houpání (2–3)
[CHYBÍ] zásah / zranění (1–2)
[CHYBÍ] smrt (4–6) + objevení po respawnu (3–4)
[CHYBÍ] klouzání anomální zdí (1–2)
[CHYBÍ] dopad / přistání (2)
[CHYBÍ] mluvení s NPC (volitelné)
(otočení gravitace = stejné snímky převrácené)

==================================================
2. ZBRANĚ A VYBAVENÍ (ikony do batohu, 1 buňka = 16 px)
==================================================
[KÓD] Hasák (wrench)            1×2 buňky = 16×32
[KÓD] Přitahovací hák           2×1 = 32×16
[KÓD] Gravitační cívka (dash)   2×2 = 32×32
[KÓD] Důlní vrták               2×1 = 32×16
[KÓD] Klíč od šachty            1×2 = 16×32
[KÓD] Lékárnička                1×1 = 16×16
[KÓD] Gravitační krystal        1×1 = 16×16
[KÓD] Éterický krystal          1×1 = 16×16
[CHYBÍ] Hák ve hře: hlava háku + lano (tile 1×4 px opakovatelný)
[KÓD]   Zaměřovač háku (kurzor myši)

==================================================
3. SBĚRATELNÉ PŘEDMĚTY VE SVĚTĚ
==================================================
[KÓD] Krystal NORMAL (levitace 4–6, třpyt)
[KÓD] Krystal WINGED (s křídly, mávání 4, odlet)
[KÓD] Krystal HIDDEN (schovaný / odhalený)
[KÓD] Krystal GRAND (velký, srdce kapitoly)
[KÓD] Krystal „duch“ (už sebraný, průhledný)
[KÓD] Lékárnička ve světě
[KÓD] Celeste klíč (levitace) + Klíčový blok (zamčený / otevírání)
[KÓD] Truhla (zavřená / otevřená) + výzva „E“
[KÓD] Cíl úrovně (zlatý portál / brána)

==================================================
4. NEPŘÁTELÉ
==================================================
[MÁ]    Strážce (patrol_guard): chůze (3 – patrol_0..2), [CHYBÍ] natahování klíčku před otočkou (3), zásah, smrt
[MÁ]    Střelec / turret (shooter.png 48×24): [CHYBÍ] míření (laser), výstřel, zničení
[MÁ]    Parní střela (steam_bullet.png 12×12)
[MÁ]    Dron (drone_0..2): hlídka; [CHYBÍ] zaměření (rudé oko), nálet, omráčení (hvězdičky), smrt
[KÓD]   Tlaková mina: klid, nafukování (3), výbuch (4)
[KÓD]   Jeskynní plazivec (cave crawler): lezení po zdi/stropu (4), smrt
[KÓD]   Anomální ozvěna (fialový stín hráče – může být shader/tint hráčových snímků)
[CHYBÍ] BOSS Reactor Warden (korporátní mech): klid, salva střel, úder pístem, odhalené jádro,
        fáze 2 (gravitace, teslovy výboje), fáze 3 (přetížení), zničení; aréna 2×1 obrazovky

==================================================
5. POSTAVY (NPC) – sprite (idle 2–4) + portrét do dialogu (32×32 nebo větší)
==================================================
[MÁ placeholder] Otis       – starý mentor, mechanik
[MÁ placeholder] Mira       – velitelka odboje v Základně
[MÁ placeholder] Brann      – odboj, Základna
[MÁ placeholder] Elda       – Smallville
[MÁ placeholder] Tobi       – kluk ze Smallville
[MÁ placeholder] Rusty      – horník v dolech
[MÁ placeholder] Vesper     – inženýrka odboje (i portrét pro vysílačku)
[MÁ placeholder] Hron       – dělník z kantýny v Parním městě
[KÓD]            Obecné NPC (npc_base)
(teď 24×24 sprite a 32×32 portrét, generované tools/create_story_npcs.py)

==================================================
6. PASTI A PŘEKÁŽKY (stavy v závorce)
==================================================
[KÓD] Bodáky 16×16 – nahoru / dolů / doleva / doprava
[KÓD] Parní tryska (klid, syčení – varování, výtrysk páry 4 dlaždice vysoký)
[KÓD] Drolící mříž / shnilé prkno 32×16 (klid, třes, zřícení, návrat)
[KÓD] Lis / píst (těleso 32×16, tyč, hlava; rudé varovné světlo, úder)
[KÓD] Ozubená pila + kolejnice
[KÓD] Teslova cívka ×2 + výboj mezi nimi (klid, rozzáření, výboj)
[KÓD] Padající kámen (visí, prach + třes, pád, rozpad)
[KÓD] Roztavená struska (hladina animovaná, bubliny, stoupání)
[KÓD] Nestabilní krystalové bodce (prasklina, žhnoucí prasklina, vysunuté bodce)
[KÓD] Pružina (klid, stlačená, šikmá varianta)
[KÓD] Dash střep (plný, vypotřebovaný – tlumený, dorůstání)
[KÓD] Dopravní pás (levý konec, střed, pravý konec; animované šipky)
[KÓD] Důlní vozík + kolejnice (jízda, náraz)
[KÓD] Kotva háku (pevná, pohyblivá, lámavá s prasklinami)
[KÓD] Vrtatelná skála (popraskaná dlaždice) + úlomky
[KÓD] Měch (klid, nafukování) + proudnice větru
[KÓD] Horský vítr (sněhové proudnice, varování = první vločky)
[KÓD] Rytmické bloky A / B (pevný, duch)
[KÓD] Gravitační anomálie (pole, třpyt)
[KÓD] Anomální zeď (hvězdné pole)
[KÓD] Tlumicí pole (šedé pole + přeškrtnutá ikona)
[KÓD] Brána (zavřená / otevřená) + spínač (vypnutý / zapnutý)
[—]   Falešná zeď = stejná dlaždice jako okolí (nic nového)

==================================================
7. DLAŽDICE 16×16 (assets/placeholder/room_tiles.png, 8 sloupců × 3 řádky)
==================================================
Pevné (s kolizí):
[MÁ] #  kámen
[MÁ] B  mosaz (potrubí, stroje, lávky)
[MÁ] W  prkna
[MÁ] Z  rezavý plech
[MÁ] R  střešní šindel
[MÁ] %  zem s krystalovou nákazou
[MÁ] _  hlína se suchou trávou
[MÁ] &  cihly
[MÁ] J  horská skála
[MÁ] J* horská skála se sněhem navrchu (automaticky na horní hraně)
Zadní stěny (bez kolize):
[MÁ] w  dřevěná stěna
[MÁ] z  plechová stěna
[MÁ] o  rozsvícené okno
[MÁ] b  zatlučené okno
[MÁ] d  dveře
[MÁ] t  plachta odboje
[MÁ] q  cihlová zeď
[MÁ] k  tmavá skála (jeskyně)
Doporučení: pro hlavní materiály (kámen, skála, sníh, mosaz, cihly, hlína) udělat
okrajové varianty (rohy, hrany, výplň – sada 16 nebo 47 dlaždic) pro autotiling.
Staré levely 1–3 a tutoriál kreslí plošiny kódem ve 7 stylech: Steam Bronze, Industrial
Slate, Rust Mines, High Tech, Surface Grass, Wood Timber, Stone Masonry.

==================================================
8. POZADÍ (320×180 na obrazovku, vodorovně navazující, ideálně 3–4 vrstvy paralaxy)
==================================================
[KÓD] Prolog / Povrch – krajina za soumraku, slunce, mraky, vzducholodě, jehličnaté kopce
[KÓD] Kap. 1 Základna odboje – zakouřená obloha, těžní věže, plechové chatrče se světýlky, antény
[KÓD] Kap. 2 Smallville – chalupy (i rozbité), krystalové jehly, korporátní stožár s kabely
[KÓD] Kap. 3 Parní město – cihlové továrny, mosazné kopule, komíny s párou, hodinová věž,
      vzducholoď s reflektorem, potrubí, žlutý smog
[KÓD] Kap. 4 Severní stěna – zasněžené štíty, moře mraků, záře města pod mraky, lanovka
      se stožáry a gondolou, světla sídla ve skále, sněhové vločky
[KÓD] Kap. 5 Staré dílny / Šachta, Kap. 6 Krystalové doly (vchod, interiér, krystaly),
      Kap. 7 Reaktor (jádro), boss aréna
Společné prvky: přechod oblohy, zastřené slunce, pásy smogu, levitující kameny s fialovou
září (anomálie), hřeben s prasklinami nákazy.

==================================================
9. DEKORACE (bez kolize, stojí na zemi)
==================================================
[KÓD] Lucerna / plynová lampa
[KÓD] Korouhev odboje (tyrkysová)
[KÓD] Anténa
[KÓD] Suchý / větrem ohnutý strom
[KÓD] Krystal nákazy (fialový)
[KÓD] Korporátní stožár s reflektorem
[KÓD] Oheň / kamna
[KÓD] Korporátní prapor (rudý)

==================================================
10. UI
==================================================
[KÓD] Hlavní menu: pozadí, logo hry, tlačítka (normál / najetí / stisk)
[KÓD] HUD: srdíčka (plné, prázdné, animace ztráty), počítadlo krystalů s ikonou
[KÓD] Hotbar vybavení (sloty)
[KÓD] Batoh: okno + buňka mřížky 16×16 (prázdná / obsazená / zvýrazněná)
[KÓD] Okno truhly
[KÓD] Dialogové okno: rámeček, jmenovka, rámeček portrétu, šipka „pokračovat“
[KÓD] Pauza menu
[KÓD] Obrazovka konce kapitoly (statistiky) + závěrečný souhrn
[CHYBÍ] Titulní karta kapitoly / sekce
[KÓD] Výzva k interakci (klávesa E)
[CHYBÍ] Ikona ukládání (checkpoint)

==================================================
11. EFEKTY
==================================================
[KÓD] Seknutí hasákem (oblouk)
[CHYBÍ] Stopa / ozvěny při dashi
[CHYBÍ] Prach při rozběhu a dopadu, obláček dvojskoku, jiskry při skluzu po zdi
[KÓD] Záblesk zásahu nepřítele / hráče
[KÓD] Třpyt krystalu + efekt sebrání
[KÓD] Pára, kouř, výbuch miny, omráčení dronu
[KÓD] Smrt hráče (rozpad) + zatmění + respawn
