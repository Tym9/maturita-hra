# Plán maturitní práce: 2D steampunk/fantasy plošinovka (Godot 4.6, GDScript)

**Téma:** 2D skákačka s příběhem ve stylu Celeste · **Vedoucí:** Ing. Pavel Knotek · **Žák:** Matěj Kročil · **Výstup:** spustitelná hra pro Windows + dokumentace

---

## 1. Mapování zadání na funkce

| Oblast zadání | Požadavek | Řešení v projektu |
|---|---|---|
| Pohyb | plynulý pohyb, **double-jump** | `player.gd` – základ z hry `ppj-2d-` (coyote time, jump cut) + počítadlo skoků |
| Pohyb | **grappling hook** | raycast / projectile na `grapple_point` (Node2D) → tah/kyvadlo; vizuálně `Line2D` |
| Pohyb | **prohození gravitace** (anomálie) | `Area2D` „GravityAnomaly“ → otočí `up_direction` a gravitaci hráče |
| Překážky | ≥3 typy | propasti, pohyblivé plošiny, gravitační zóny (+ ostny, padající plošiny) |
| Souboj | ≥2 způsoby útoku | melee (hasák/klíč) + střela/„pára“ na dálku |
| Souboj | HP nepřátel, reakce na zásah | `HealthComponent`, knockback, blikání |
| Nepřátelé | ≥3 typy, ≥10 kusů | Hlídka (patrola), Střelec (dálkový), Dron (létající) – znovupoužitelné scény |
| Boss | ≥2 útoky/fáze | Správce reaktoru: fáze 1 (střelba/shockwave), fáze 2 (gravitace + rychlé výpady) |
| Hrozby | ≥3 typy | ostny, pára/trysky (časované), padající plošiny, propast |
| Příběh | ≥3 úrovně, ≥3 NPC, ≥5 dialogových scén | 3 levely + boss aréna, 3–4 NPC, `EventTrigger` |
| Předměty | ≥3 typy, UI/inventář | lékárnička (HP), krystal (sbírka), klíč/baterie (postup), HUD s počty |
| Technika | menu (Nová hra/Pokračovat/Konec), UI | `main_menu.tscn`, `hud.tscn`, pauza |
| Technika | ukládání pozice | `SaveManager` autoload → JSON v `user://save.json` |
| Technika | spouštěče událostí | `EventTrigger` (Area2D) – dialog, změna prostředí, příběhová událost |
| Dokončení | závěrečná obrazovka po bossovi | `ending.tscn` |
| Testování | ≥3 testeři | testovací protokol (tabulka chyb + poznatky) do dokumentace |

---

## 2. Navržená architektura

```
ppj-maturita/
├─ project.godot
├─ autoload/   game_state.gd, save_manager.gd, dialogue_manager.gd
├─ player/     player.tscn/.gd, grapple_hook.gd, attack.gd
├─ enemies/    enemy_base.gd, patrol, shooter, drone, boss
├─ hazards/    spikes, steam_vent, falling_platform, moving_platform, gravity_anomaly
├─ items/      pickup_base.gd, health_pack, crystal, key
├─ npc/        npc.tscn, dialogy (Resource/JSON)
├─ levels/     level1, level2, level3, boss_arena
├─ ui/         main_menu, hud, dialogue_box, inventory, pause, ending
├─ assets/     grafika, zvuk
└─ docs/       dokumentace, testování
```

---

## 3. Etapy vývoje (každá = hratelný stav + Git commit)

1. **Základ projektu** – nový repozitář, struktura, input mapa, autoload kostry, převzetí pohybu z `ppj-2d-`.
2. **Pohybové mechaniky** – double-jump, grappling hook, gravitační anomálie + testovací místnost.
3. **Souboj + nepřátelé** – `HealthComponent`, 2 útoky, 3 typy nepřátel, knockback a vizuální odezva.
4. **Hrozby a překážky** – 3+ typy (propast, pohyblivé/padající plošiny, pára, ostny).
5. **Předměty + HUD/inventář** – 3 typy předmětů, zobrazení HP a sbírek.
6. **Příběh, NPC a události** – dialogový box, ≥3 NPC, ≥5 dialogových scén, `EventTrigger`.
7. **Levely 1–3** – skládání mechanik do úrovní s postupným představováním (≥10 nepřátel celkem).
8. **Boss + konec** – boss se 2 fázemi, závěrečná obrazovka.
9. **Menu + ukládání** – Nová hra / Pokračovat / Konec, `SaveManager`, pauza.
10. **Testování, ladění, export** – 3 testeři, oprava chyb, export `.exe` pro Windows.
11. **Dokumentace** – uživatelská + technická (PDF/A), resumé, prezentace, citace ČSN ISO 690 (+ citace AI dle směrnice školy).
