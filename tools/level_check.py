"""Kontrola průchodnosti ASCII kapitol (LEVEL_*.md) simulací pohybu hráče podle player.gd.

  python tools/level_check.py LEVEL_c1.md                 # celá kapitola podle ```layout
  python tools/level_check.py LEVEL_c1.md --room c1_b03   # jen jedna místnost (výstupy, krystaly)
  python tools/level_check.py LEVEL_c1.md --map out.png [--scale 8]  # + mapa (px na dlaždici, výchozí 4)

Simuluje snímek po snímku (60 Hz) stejné pořadí jako player.gd: zeď / gravitace, vodorovný pohyb,
skok (coyote, skok od zdi, šplhací skok, dvojskok), useknutí skoku, posun s kolizí po osách.
Prohledává makra (rozběh, výdrž skoku, směr ve vzduchu, otočka, čas dvojskoku) z klidových stavů
(stojí, drží zeď, pružina). Nepřátelé, páry, padající kameny, krystalové bodáky a hlavy lisů se ignorují (časování);
mřížky se berou jako pevné; KeyBlock (L) se pro krystaly bere jako otevřený, když je klíč dosažitelný.
Dash (8 směrů, 400 px/s na 0.2 s, obnova na zemi / pružinou / krystalem dashe `*`) jen s `kit dash`
v bloku ```layout nebo s přepínačem --dash (--nodash ho vypne: okřídlené krystaly). Hák (`kit hook` / --hook / --nohook): kotvy `+`,
dosah 88 px na dohled, přitažení 380 px/s, u kotvy dolet s hybností, katapult skokem nebo puštění; obnoví dash i dvojskok.
Vrták (`kit drill` / --drill): hráč se u vrtatelné skály `r` zastaví a provrtá ji (bere se jako volná).
Komplex (c7): `:` gravitační pole (obdélník kolem souvislé skupiny; uvnitř gravitace vzhůru), `-` tlumicí pole (bez dashe a háku),
`n` anomální zeď (pevná; dash jí proletí rovně 300 px/s a vrátí dash i dvojskok, zablokovaný průlet = smrt),
`[` `]` rytmické bloky (berou se jako pevné), `i` tesla oblouk a `?` ozvěna (časované, ignorují se).
`m` = roztavená struska (smrt jako bodáky), `Q` = ozubená pila (časovaná, ignoruje se).
S --room se hlásí i propad dnem (B<sloupec>): výstup do místnosti pod ní, nebo jáma."""
import math, re, sys, os
from collections import deque

DT = 1 / 60
G, SPEED, ACC, FRIC = 980.0, 150.0, 800.0, 1000.0
JUMP, AIRJ, WJX, WJY = -300.0, -270.0, 200.0, -250.0
SLIDE, CLIMB, COYOTE, CUT, STAMINA = 50.0, 60.0, 0.1, 0.5, 8.0
HW, HH = 7.0, 9.0
TILE, SW, SH, SCREEN_W, SCREEN_H = 16, 20, 11, 320, 180
TOP_OVER = 24.0  # chapter.gd TOP_OVERSHOOT: nad otevřený strop jen kousek
DASH_SPEED, DASH_TIME, DASH_COOL = 400.0, 0.2, 0.4  # player.gd perform_dash
DIRS8 = ((1, 0), (-1, 0), (0, -1), (0, 1), (1, -1), (-1, -1), (1, 1), (-1, 1))
HOOK_RANGE, HOOK_PULL, HOOK_ARRIVE, HOOK_TIME = 88.0, 380.0, 16.0, 1.6  # player.gd GRAPPLE_*
DRILL_RANGE = 28.0  # player.gd DRILL_RANGE
GLIDE_SPEED = 300.0  # anomaly_wall.gd glide_speed

SOLID = set("#BWZR%_&L~=PAJUYrn[]")  # P = těleso lisu (hlava je časovaná, ignoruje se); A sníh, J skála, U čedič, Y žhavá skála
KNOWN = SOLID | set(". wzobdtqkFlfayxpgh@^v<>SVIOGTDMCc*KHXN!E12345678}mQu+ej:-i?")  # + kotva háku, r vrtatelná skála (pevná bez `kit drill`), e důlní lezec, j výdřeva (zadní vrstva); } vítr, Q pila, u záplava strusky (časované, ignorují se)


# ---------- čtení .md (stejná pravidla jako tools/ascii_room_builder.gd) ----------
def grid_rows(block):
    ruler = block[0].strip() if block else ""
    if not ruler or not ruler.isdigit():
        return block
    left = block[0].find(ruler)
    rows = []
    for line in block[1:]:
        label = line[:left].strip()
        if len(line) > left and re.fullmatch(r"-?\d+", label):
            rows.append(line[left:left + len(ruler)])
    return rows


def parse_doc(text):
    rooms, layout, rid, fence, block = {}, None, "", "", []
    for line in text.split("\n"):
        line = line.rstrip("\r")
        if line.startswith("```"):
            if not fence:
                info = line[3:].strip()
                fence = info if info in ("props", "layout") else ("grid" if info == "" and rid and rid not in rooms else "other")
                block = []
                continue
            if fence == "grid":
                rooms[rid] = {"rows": grid_rows(block), "props": []}
            elif fence == "props" and rid in rooms:
                rooms[rid]["props"] = [l for l in block if "=" in l]
            elif fence == "layout":
                layout = {"chapter": "", "rooms": []}
                for l in block:
                    p = l.split()
                    if len(p) == 3 and re.fullmatch(r"-?\d+", p[1]) and re.fullmatch(r"-?\d+", p[2]):
                        layout["rooms"].append((p[0], int(p[1]), int(p[2])))
                    elif len(p) >= 2 and p[0] == "chapter":
                        layout["chapter"] = p[1]
                    elif p and p[0] == "kit":
                        layout["kit"] = set(p[1:])
            fence = ""
        elif fence:
            block.append(line)
        elif line.startswith("### "):
            rid = line[4:].strip().split(" ")[0]
    return rooms, layout


def floats(s):
    return [float(v) for v in re.findall(r"-?\d+(?:\.\d+)?", s)]


class Room:
    def __init__(self, rid, data, sx=0, sy=0):
        self.id, self.rows = rid, data["rows"]
        self.h = len(self.rows)
        self.w = max((len(r) for r in self.rows), default=0)
        self.screens = (max(1, math.ceil(self.w / SW)), max(1, math.ceil(self.h / SH)))
        self.ox, self.oy = sx * SCREEN_W, sy * SCREEN_H
        self.sx, self.sy = sx, sy
        self.solid = [[(c in SOLID) for c in r.ljust(self.w, ".")] for r in self.rows]
        self.respawns, self.springs, self.spikes, self.crystals, self.keys, self.ends, self.locks = [], [], [], [], [], [], []
        self.shards, self.anchors = [], []
        used = set()
        for y, r in enumerate(self.rows):
            for x, c in enumerate(r):
                if (x, y) in used:
                    continue
                X, Y = self.ox + x * TILE, self.oy + y * TILE
                if c == "@":
                    self.respawns.append((X + 8, Y + 16 - HH))
                elif c == "S":
                    self.springs.append([X + 8, Y + 16, 0.0, -1.0, 420.0, 0.2])
                elif c in "Cc":  # c = krystal za falešnou zdí
                    self.crystals.append((X + 8, Y + 8))
                elif c == "K":
                    self.keys.append((X + 8, Y + 8))
                elif c == "+":
                    self.anchors.append((X + 8, Y + 8))
                elif c == "*":
                    self.shards.append((X + 8, Y + 8))
                elif c == "m":  # struska: hladina 3 px pod horní hranou dlaždice, smrtí o další 3 px níž (molten_slag.gd)
                    n = 1
                    while self.at(x + n, y) == "m":
                        used.add((x + n, y))
                        n += 1
                    self.spikes.append((X + 3, Y + 6, X + n * TILE - 3, Y + 16))
                elif c == "E":
                    self.ends.append((X + 8 - 25, Y + 8 - 100, X + 8 + 25, Y + 8 + 100))
                elif c == "L":
                    self.locks.append((x, y))
                elif c in "^v<>":
                    d = (1, 0) if c in "^v" else (0, 1)
                    n = 1
                    while self.at(x + d[0] * n, y + d[1] * n) == c:
                        used.add((x + d[0] * n, y + d[1] * n))
                        n += 1
                    L = n * TILE
                    if c == "^": self.spikes.append((X + 2, Y + 16 - 18, X + L - 2, Y + 16 + 6))
                    if c == "v": self.spikes.append((X + 2, Y - 6, X + L - 2, Y + 18))
                    if c == "<": self.spikes.append((X + 16 - 18, Y + 2, X + 16 + 6, Y + L - 2))
                    if c == ">": self.spikes.append((X - 6, Y + 2, X + 18, Y + L - 2))
        self.fields, self.damps = self.boxes(":"), self.boxes("-")
        # Vrtatelná skála: svislý běh `r` = jeden DrillableRock. shortcut: sousední běhy se stejným rozsahem řad
        # se berou jako jedna skála (jinak kombinace provrtaných sloupců násobí stavy); přesné pro vrtání ze země,
        # optimistické pro víc sloupců vrtaných ve vzduchu. Rozdělit, kdyby to pouštělo nehratelné místnosti.
        runs = []
        for x in range(self.w):
            y = 0
            while y < self.h:
                if self.at(x, y) != "r":
                    y += 1
                    continue
                y0 = y
                while self.at(x, y) == "r":
                    y += 1
                runs.append((y0, y, x))
        self.rocks = []  # (buňky, obdélník px)
        for y0, y1, x in sorted(runs):
            cells = [(x, yy) for yy in range(y0, y1)]
            last = self.rocks[-1] if self.rocks else None
            if last and last[1][1] == self.oy + y0 * TILE and last[1][3] == self.oy + y1 * TILE and last[1][2] == self.ox + x * TILE:
                self.rocks[-1] = (last[0] + cells, (last[1][0], last[1][1], last[1][2] + TILE, last[1][3]))
            else:
                self.rocks.append((cells, (self.ox + x * TILE, self.oy + y0 * TILE, self.ox + (x + 1) * TILE, self.oy + y1 * TILE)))
        for line in data["props"]: # pružiny z props: S/S2 direction / strength / side_lock
            m = re.match(r"\s*S(\d*)\s+(\w+)\s*=\s*(.+)", line)
            if not m:
                continue
            idx = [int(m.group(1)) - 1] if m.group(1) else range(len(self.springs))
            for i in idx:
                if 0 <= i < len(self.springs):
                    v = floats(m.group(3))
                    if m.group(2) == "direction" and len(v) == 2:
                        l = math.hypot(*v) or 1.0
                        self.springs[i][2:4] = [v[0] / l, v[1] / l]
                    elif m.group(2) == "strength" and v:
                        self.springs[i][4] = v[0]
                    elif m.group(2) == "side_lock" and v:
                        self.springs[i][5] = v[0]

    def boxes(self, ch):
        """Obdélníky (px) kolem souvislých skupin znaku ch (8 sousedů): pole gravitace / tlumení."""
        out, seen = [], set()
        for y, r in enumerate(self.rows):
            for x, c in enumerate(r):
                if c != ch or (x, y) in seen:
                    continue
                todo, cells = [(x, y)], []
                seen.add((x, y))
                while todo:
                    cx, cy = todo.pop()
                    cells.append((cx, cy))
                    for dx in (-1, 0, 1):
                        for dy in (-1, 0, 1):
                            n = (cx + dx, cy + dy)
                            if n not in seen and self.at(*n) == ch:
                                seen.add(n)
                                todo.append(n)
                xs, ys = [c[0] for c in cells], [c[1] for c in cells]
                out.append((self.ox + min(xs) * TILE, self.oy + min(ys) * TILE, self.ox + (max(xs) + 1) * TILE, self.oy + (max(ys) + 1) * TILE))
        return out

    def at(self, x, y):
        if 0 <= y < self.h and 0 <= x < len(self.rows[y]):
            return self.rows[y][x]
        return ""

    def contains(self, px, py):
        return self.ox <= px < self.ox + self.screens[0] * SCREEN_W and self.oy <= py < self.oy + self.screens[1] * SCREEN_H


class World:
    def __init__(self, rooms):
        self.rooms = rooms
        self.cell = {}
        for r in rooms:
            for i in range(r.screens[0]):
                for j in range(r.screens[1]):
                    if (r.sx + i, r.sy + j) in self.cell:
                        raise SystemExit(f"CHYBA: místnosti {self.cell[(r.sx + i, r.sy + j)].id} a {r.id} se překrývají")
                    self.cell[(r.sx + i, r.sy + j)] = r
        self.springs = [s for r in rooms for s in r.springs]
        self.spikes = [s for r in rooms for s in r.spikes]
        self.shards = [s for r in rooms for s in r.shards]
        self.anchors = [a for r in rooms for a in r.anchors]
        n = 0
        for r in rooms:  # indexy kotev místnosti do self.anchors
            r.anchor_ids = list(range(n, n + len(r.anchors)))
            n += len(r.anchors)
        self.rocks, r_of = [], {}
        for r in rooms:  # skály: globální indexy, buňka -> index
            r.rock_ids = frozenset(range(len(self.rocks), len(self.rocks) + len(r.rocks)))
            r.rock_of = {}
            for cells, rect in r.rocks:
                for c in cells:
                    r.rock_of[c] = len(self.rocks)
                self.rocks.append(rect)
        self.fields = [f for r in rooms for f in r.fields]
        self.damps = [f for r in rooms for f in r.damps]
        self.ghost = False  # právě se letí anomální zdí (průlet): `n` je průchozí
        self.kit_hook = self.kit_drill = False
        self.broken = frozenset()  # provrtané skály stavu, který se právě simuluje (P.br)
        self.kit_dash = False
        self.drops = None  # --room: sloupce propadu dnem
        self.open_locks = False
        self.edges = True  # chapter.gd: bok/strop bez souseda = neviditelná stěna, smrt jen propadem dnem

    def room_at(self, px, py):
        return self.cell.get((math.floor(px / SCREEN_W), math.floor(py / SCREEN_H)))

    def solid(self, px, py):
        r = self.room_at(px, py)
        if r is None:
            return False
        tx, ty = int((px - r.ox) // TILE), int((py - r.oy) // TILE)
        if 0 <= ty < r.h and 0 <= tx < r.w and r.solid[ty][tx]:
            c = r.rows[ty][tx]
            if c == "r":
                return r.rock_of[(tx, ty)] not in self.broken
            return not ((self.open_locks and c == "L") or (self.ghost and c == "n"))
        return False

    def in_rock(self, x, y, ch="r"):
        for px, py in ((x - HW, y - HH), (x + HW - 0.01, y - HH), (x - HW, y + HH - 0.01), (x + HW - 0.01, y + HH - 0.01), (x, y)):
            r = self.room_at(px, py)
            if r and r.at(int((px - r.ox) // TILE), int((py - r.oy) // TILE)) == ch:
                return True
        return False

    def in_box(self, boxes, x, y):
        return any(x - HW < c and x + HW > a and y - HH < d and y + HH > b for a, b, c, d in boxes)

    def sight(self, x0, y0, x1, y1):
        n = max(1, int(math.hypot(x1 - x0, y1 - y0) / 4))
        return not any(self.solid(x0 + (x1 - x0) * i / n, y0 + (y1 - y0) * i / n) for i in range(n + 1))

    def tile_top(self, px, py):
        r = self.room_at(px, py)
        return r.oy + int((py - r.oy) // TILE) * TILE

    def hits(self, x, y):
        s = self.solid
        x0, x1, y0, y1 = x - HW, x + HW - 0.01, y - HH, y + HH - 0.01
        return s(x0, y0) or s(x1, y0) or s(x0, y) or s(x1, y) or s(x0, y1) or s(x1, y1)

    def deadly(self, x, y, room=None):
        x0, x1, y0, y1 = x - HW, x + HW, y - HH, y + HH
        for a, b, c, d in self.spikes:
            if x0 < c and x1 > a and y0 < d and y1 > b:
                return True
        if self.room_at(x, y) is not None:
            return False
        return not self.edges or room is None or y >= room.oy + room.screens[1] * SCREEN_H


# ---------- hráč ----------
class P:
    __slots__ = ("x", "y", "vx", "vy", "floor", "wall", "normal", "coyote", "air", "stamina", "lock", "cut", "cool", "room",
                 "dash", "dcool", "dt", "last", "hx", "hy", "g", "gl", "dead", "br")

    def __init__(self, x, y):
        self.x, self.y, self.vx, self.vy = x, y, 0.0, 0.0
        self.floor, self.wall, self.normal = True, False, 0
        self.coyote, self.air, self.stamina, self.lock, self.cut, self.cool = COYOTE, 1, STAMINA, 0.0, False, 0.0
        self.room = None
        self.dash, self.dcool, self.dt = True, 0.0, 0.0
        self.last, self.hx, self.hy = -1, 0.0, 0.0  # poslední kotva háku v tomto letu, směr přitažení
        self.g, self.gl, self.dead = 1, None, False  # směr gravitace (-1 v poli `:`), směr průletu anomální zdí, smrt při průletu
        self.br = frozenset()  # provrtané skály aktuální místnosti (smrt = nový stav od startu, skály zpět)

    def copy(self):
        p = P.__new__(P)
        for k in P.__slots__:
            setattr(p, k, getattr(self, k))
        return p


def toward(v, t, d):
    return min(v + d, t) if v < t else max(v - d, t)


def step(w, p, dirn, press, release, held, dash=None):
    g = -1 if w.fields and w.in_box(w.fields, p.x, p.y) else 1
    if p.gl is None and g != p.g:  # player.gd set_gravity_dir: svislá rychlost na půl
        p.g, p.vy = g, p.vy * 0.5
    if dash is not None and w.kit_dash and p.gl is None and p.dash and p.dcool <= 0 and p.dt <= 0 and not (w.damps and w.in_box(w.damps, p.x, p.y)):
        l = math.hypot(*dash)
        p.dt, p.dash, p.dcool, p.lock, p.cut = DASH_TIME, False, DASH_COOL, 0.0, False
        p.vx, p.vy = dash[0] / l * DASH_SPEED, dash[1] / l * DASH_SPEED
    if p.gl is None and p.dt > 0 and (p.vx or p.vy):  # dash mířící do anomální zdi -> průlet
        l = math.hypot(p.vx, p.vy)
        if w.in_rock(p.x + p.vx / l * 16.0, p.y + p.vy / l * 16.0, "n"):
            p.gl, p.dt = (p.vx / l, p.vy / l), 0.0
    if p.gl is not None:  # průlet: rovně 300 px/s bez gravitace a ovládání; venku dash i dvojskok zpět
        p.g = g
        p.vx, p.vy = p.gl[0] * GLIDE_SPEED, p.gl[1] * GLIDE_SPEED
        x0, y0, was_in = p.x, p.y, w.in_rock(p.x, p.y, "n")
        move(w, p)
        if math.hypot(p.x - x0, p.y - y0) < GLIDE_SPEED * DT * 0.5:
            p.dead = True  # zablokovaný výstup
        elif was_in and not w.in_rock(p.x, p.y, "n"):
            p.gl, p.dash, p.dcool, p.air, p.lock, p.cut = None, True, 0.0, 1, 0.1, False
        return None
    if p.dt > 0:  # let dashe: bez gravitace a vstupu, na konci player.gd vynuluje svislou rychlost
        p.dt -= DT
        if p.dt > 0:
            move(w, p)
            return touch(w, p)
        p.vy = 0.0
    if p.dcool > 0:
        p.dcool -= DT
    on_wall = p.wall and not p.floor
    away = on_wall and dirn == p.normal
    grabbing = on_wall and p.stamina > 0 and not away and p.vy * g >= -CLIMB
    if on_wall:
        if grabbing:
            p.vy = -CLIMB * g if held else 0.0
            p.stamina -= DT
        else:
            p.vy = p.vy + G * g * DT if p.stamina <= 0 else g * min((p.vy + G * g * DT) * g, SLIDE)
        p.coyote -= DT
    elif not p.floor:
        p.vy += G * g * DT
        p.coyote -= DT
    else:
        p.coyote, p.air, p.stamina, p.dash = COYOTE, 1, STAMINA, True
        if p.vy * g >= 0:
            p.lock = 0.0
    if p.lock > 0:
        p.lock -= DT
    elif dirn:
        p.vx = toward(p.vx, dirn * SPEED, ACC * DT)
    elif grabbing:
        p.vx = -p.normal * 10.0
    else:
        p.vx = toward(p.vx, 0.0, FRIC * DT)
    if press:
        jumped = True
        if p.coyote > 0:
            p.vy, p.coyote = JUMP * g, 0.0
        elif on_wall and p.stamina > 0:
            p.stamina -= 0.3
            if dirn == -p.normal or (grabbing and not dirn):
                p.vy, p.vx = AIRJ * g, -p.normal * SPEED
            else:
                p.vx, p.vy = p.normal * WJX, WJY * g
            p.air = 1
        elif p.air > 0 and not p.floor:
            p.vy, p.air = AIRJ * g, p.air - 1
        else:
            jumped = False
        if jumped:
            p.cut = True
    if p.cut and release and p.vy * g < 0:
        p.vy *= CUT
    move(w, p)
    return touch(w, p)


def move(w, p):
    """Posun po osách s kolizí (move_and_slide), neviditelné boky a strop bez souseda."""
    w.broken = p.br
    w.ghost = p.gl is not None
    p.wall = False
    nx = p.x + p.vx * DT
    if p.vx != 0 and w.hits(nx, p.y):
        if p.vx > 0:
            nx = math.floor((nx + HW - 0.01) / TILE) * TILE - HW - 0.001
            p.normal = -1
        else:
            nx = (math.floor((nx - HW) / TILE) + 1) * TILE + HW + 0.001
            p.normal = 1
        if w.hits(nx, p.y):
            nx = p.x
        p.vx, p.wall = 0.0, True
    r = p.room or w.room_at(p.x, p.y)
    if w.edges and r:  # neviditelný bok bez souseda: zastaví, ale nedá se po něm lézt
        x0, x1 = r.ox, r.ox + r.screens[0] * SCREEN_W
        yy = min(max(p.y, r.oy), r.oy + r.screens[1] * SCREEN_H - 1)
        if nx < x0 + HW and w.room_at(x0 - 1, yy) is None:
            nx, p.vx = x0 + HW, max(p.vx, 0.0)
        elif nx > x1 - HW and w.room_at(x1 + 1, yy) is None:
            nx, p.vx = x1 - HW, min(p.vx, 0.0)
    p.x = nx
    ny = p.y + p.vy * DT
    p.floor = False
    xs = (p.x - HW, p.x + HW - 0.01)
    vdir = (1 if p.vy > 0 else -1) if p.vy else p.g  # klidový stav: přichycení k podlaze (ve směru gravitace) o 1 px
    probe = ny + (float(p.g) if p.vy == 0 else 0.0)
    if w.hits(p.x, probe):
        if vdir > 0:
            foot = probe + HH - 0.01
            tops = [w.tile_top(sx, foot) for sx in xs if w.solid(sx, foot)]
            ny = min(tops) - HH - 0.001 if tops else p.y
        else:
            head = probe - HH
            bottoms = [w.tile_top(sx, head) + TILE for sx in xs if w.solid(sx, head)]
            ny = max(bottoms) + HH + 0.001 if bottoms else p.y
            if w.hits(p.x, ny):
                ny = p.y
        p.vy, p.floor = 0.0, vdir == p.g  # podlaha jen ve směru gravitace (v poli je to strop)
    if w.edges and r and ny < r.oy - TOP_OVER and w.room_at(p.x, r.oy - 1) is None:
        ny, p.vy = r.oy - TOP_OVER, max(p.vy, 0.0)
    p.y = ny
    p.room = w.room_at(p.x, p.y) or r
    if p.br and p.room is not r:  # shortcut: skály opuštěné místnosti zapomene (návrat = zase pevné), jinak stavy dalších místností násobí
        p.br = p.br & p.room.rock_ids


def touch(w, p):
    """Pružina -> ("spring", i); krystal dashe, který dash opravdu obnoví -> ("shard", i); jinak None."""
    p.cool -= DT
    if p.cool <= 0:
        for i, (sx, sy, dx, dy, st, lock) in enumerate(w.springs):
            if p.x - HW < sx + 7 and p.x + HW > sx - 7 and p.y - HH < sy - 2 and p.y + HH > sy - 10:
                return ("spring", i)
    if w.kit_dash and not p.dash and p.dt <= 0:
        for i, (sx, sy) in enumerate(w.shards):  # dash_shard.gd: kruh r 9 px
            cx, cy = min(max(sx, p.x - HW), p.x + HW), min(max(sy, p.y - HH), p.y + HH)
            if (cx - sx) ** 2 + (cy - sy) ** 2 < 81:
                p.dash, p.dcool, p.stamina = True, 0.0, STAMINA
                return ("shard", i)
    return None


def hook_pull(w, p, i):
    """Hák na kotvu i: přímé přitažení 380 px/s až na 16 px. -> P u kotvy (hx, hy = směr tahu) nebo None."""
    ax, ay = w.anchors[i]
    p.dt, p.lock, p.cut = 0.0, 0.0, False
    for _ in range(int(HOOK_TIME * 60)):
        dx, dy = ax - p.x, ay - p.y
        d = math.hypot(dx, dy)
        if d < HOOK_ARRIVE:
            p.last, p.air, p.dash, p.dcool, p.stamina, p.coyote, p.floor = i, 1, True, 0.0, STAMINA, 0.0, False
            return p
        p.hx, p.hy = dx / d, dy / d
        p.vx, p.vy = p.hx * HOOK_PULL, p.hy * HOOK_PULL
        x0, y0 = p.x, p.y
        move(w, p)
        if w.deadly(p.x, p.y, p.room) or math.hypot(p.x - x0, p.y - y0) < 2.0:
            return None  # zaseknutí o roh se bere jako neprůchozí (opatrný odhad)
    return None


def launch(p, spring, vx):
    sx, sy, dx, dy, st, lock = spring
    p.vx, p.vy, p.lock = dx * st, dy * st, lock
    if abs(dy) < 0.3:
        p.vy = -160.0
    elif abs(dx) < 0.3:
        p.vx, p.lock = vx, 0.0
    p.air, p.stamina, p.cut, p.coyote, p.cool, p.floor = 1, STAMINA, False, 0.0, 0.25, False
    p.dash, p.dcool, p.dt = True, 0.0, 0.0  # pressure_spring.gd: launch + refill_dash


# ---------- makra ----------
def air_plans(dirs):
    plans = []
    for a1 in dirs:
        alts = [None] + [(14, a2) for a2 in (-1, 0, 1) if a2 != a1]
        for sw in alts:
            for dj in (None, 10, 20, 32):
                plans.append((a1, sw, dj))
    return plans


FLOOR_MACROS = [(rd, rf, hold, plan) for rd, rf in ((0, 0), (-1, 12), (1, 12)) for hold in (8, 40)
                for plan in air_plans((rd,) if rd else (-1, 0, 1))]
WALL_MACROS = ["climb", "wall", "drop"]


def simulate(w, p, plan_fn, goals, max_frames=170, extras=None):
    """-> ('floor'|'wall'|'spring'|'shard', P, index) nebo None; goals = množina dotčených cílů (krystaly, E).
    plan_fn(f) -> (směr, drží skok) nebo (směr, drží skok, směr dashe | None)."""
    airborne = not p.floor
    prev_held = False
    for f in range(max_frames):
        act = plan_fn(f)
        dirn, held = act[0], act[1]
        press, release = held and not prev_held, prev_held and not held
        prev_held = held
        ev = step(w, p, dirn, press, release, held, act[2] if len(act) > 2 else None)
        if p.dead or w.deadly(p.x, p.y, p.room):
            if not p.dead and w.drops is not None and w.room_at(p.x, p.y) is None:
                r0 = w.rooms[0]
                if p.y > r0.oy + r0.h * TILE:
                    w.drops.add(int((p.x - r0.ox) // TILE))
            return None
        for gi, g in enumerate(w.goals):
            if (g[0] - p.x) ** 2 + (g[1] - p.y) ** 2 < 144 if len(g) == 2 else (p.x - HW < g[2] and p.x + HW > g[0] and p.y - HH < g[3] and p.y + HH > g[1]):
                goals.add(gi)
        if extras is not None and w.kit_hook and p.gl is None and p.room is not None and p.room.anchor_ids and f % 6 == 0 and not (w.damps and w.in_box(w.damps, p.x, p.y)):
            for i in p.room.anchor_ids:  # hák: každých 6 snímků v dosahu a na dohled zkus přitažení (vedlejší větev)
                ax, ay = w.anchors[i]
                d2 = (ax - p.x) ** 2 + (ay - p.y) ** 2
                if i != p.last and HOOK_ARRIVE ** 2 < d2 <= HOOK_RANGE ** 2 and w.sight(p.x, p.y, ax, ay):
                    q = hook_pull(w, p.copy(), i)
                    if q is not None:
                        extras.append(("anchor", q, i))
        if extras is not None and w.kit_drill and p.dt <= 0 and p.gl is None and p.room is not None and f % 3 == 0:
            for i in p.room.rock_ids - p.br:  # vrták: skála do DRILL_RANGE na dohled -> stav na místě bez rychlosti, skála pryč
                a, b, c, d = w.rocks[i]
                nx, ny = min(max(p.x, a), c), min(max(p.y, b), d)
                dist = math.hypot(nx - p.x, ny - p.y)
                if dist <= DRILL_RANGE and (dist <= 1.0 or w.sight(p.x, p.y, p.x + (nx - p.x) * (1 - 1 / dist), p.y + (ny - p.y) * (1 - 1 / dist))):
                    q = p.copy()
                    q.vx = q.vy = q.lock = 0.0
                    q.cut, q.br = False, p.br | {i}
                    extras.append(("floor" if q.floor else "drill", q, i))
        if ev:
            return (ev[0], p, ev[1])
        if p.dt > 0 or p.gl is not None:
            airborne = True
            continue
        if not p.floor:
            airborne = True
        elif airborne and f > 0:
            return ("floor", p, -1)
        if p.wall and not p.floor and p.vy == 0 and p.stamina > 0 and dirn != p.normal:
            return ("wall", p, -1)
    return None


def floor_plan(rd, rf, hold, plan):
    a1, sw, dj = plan
    def fn(f):
        if f < rf:
            return rd, False
        j = f - rf
        d = a1 if sw is None or j < sw[0] else sw[1]
        if dj is not None and j >= dj - 1:
            return d, j >= dj and j < dj + 30
        return d, j < hold
    return fn


def walk_plan(d):
    return lambda f: (d if f < 8 else 0, False)


def wall_plans(normal):
    toward_w, away = -normal, normal
    out = []
    for a in (toward_w, 0):  # šplhací skok (výš po zdi / přes hranu)
        for dj in (None, 10, 20):
            out.append((toward_w, a, dj, 40))
    for a in (away, 0, toward_w):  # skok od zdi
        for dj in (None, 8, 16, 26):
            out.append((away, a, dj, 40))
    for dj in (None, 8, 18):  # pustit se
        out.append((away, away, dj, -1))
    return out


def wall_fn(d0, a, dj, hold):
    def fn(f):
        if hold < 0:
            return d0 if f < 6 else a, dj is not None and dj <= f < dj + 30
        if f < 2:
            return d0, f == 0 or f < hold
        d = a
        if dj is not None and f >= dj - 1:
            return d, dj <= f < dj + 30
        return d, f < hold
    return fn


def after_dash(t, d, a, dj):
    """Krok plánu od dashe v snímku t: dash d, pak směr a, volitelně dvojskok dj snímků po startu dashe."""
    def fn(j):
        if j == t:
            return a, False, d
        if dj is not None and j >= t + dj - 1:
            return a, t + dj <= j < t + dj + 30
        return a, False
    return fn


def dash_floor_plans():
    out = []
    for rd, rf in ((0, 0), (-1, 12), (1, 12)):
        for t in (0, 8, 20, "dj"):  # 0 = dash ze země, jinak skok a dash v t; dj = skok, dvojskok, dash
            for d in DIRS8:
                if (t == 0 and d[1] > 0) or (rd and d[0] == -rd):
                    continue  # dolů ze země nejde (skrčení); proti rozběhu se nedashuje
                for dj in ((None,) if t == "dj" else (None, 14)):
                    out.append((rd, rf, t, d, dj))
    return out


def dash_floor_fn(rd, rf, t, d, dj):
    a = d[0] or rd
    tt = 26 if t == "dj" else t
    tail = after_dash(tt, d, a, dj)
    def fn(f):
        if f < rf:
            return rd, False
        j = f - rf
        if j < tt:
            if t == "dj":
                return rd, j < 12 or j >= 14
            return rd, True
        return tail(j)
    return fn


def dash_wall_plans(normal):
    away, toward = normal, -normal
    dirs = [d for d in DIRS8 if d[0] in (away, 0)]
    out = []
    for kind, d0, times, ds in (("jump", away, (6, 14), dirs), ("drop", away, (4,), dirs), ("direct", away, (0,), dirs),
                                ("climb", toward, (10,), [(toward, -1), (toward, 0), (0, -1), (away, -1), (away, 0)])):
        for t in times:
            for d in ds:
                for dj in (None, 14):
                    out.append((kind, d0, t, d, dj))
    return out


def dash_wall_fn(kind, d0, t, d, dj):
    tail = after_dash(t, d, d[0] or d0, dj)
    def fn(f):
        if f < t:
            return d0, kind in ("jump", "climb")
        return tail(f)
    return fn


def dash_air_fn(t, d, dj, a0=0):
    tail = after_dash(t, d, d[0] or a0, dj)
    return lambda f: (a0, False) if f < t else tail(f)


DASH_FLOOR = dash_floor_plans()


def key_of(kind, p, extra=None):
    if kind == "floor":
        return ("F", round(p.x / 8), round(p.y))
    if kind == "wall":
        return ("W", round(p.x), round(p.y / 6), p.normal, p.dash)
    if kind == "shard":
        return ("D", extra, p.air)
    if kind == "anchor":
        return ("A", extra, round(math.atan2(p.hy, p.hx) / (math.pi / 4)))
    if kind == "drill":
        return ("R", round(p.x / 8), round(p.y / 8), p.air, p.dash)
    return ("S", extra)


def rest(p):
    q = p.copy()
    q.vx = q.vy = 0.0
    q.lock = 0.0
    q.last = -1
    return q


def search(w, starts, allow=None, stop=None, budget=10 ** 9):
    """BFS. allow(room)->bool omezí rozbalování; stop(state)->bool ukončí. Vrací (navštívené stavy, dotčené cíle)."""
    seen, goals, q = {}, set(), deque()
    for p in starts:
        k = key_of("floor", p) + (p.br,)
        seen[k] = p
        q.append((k, p))
    while q and budget > 0:
        k, p = q.popleft()
        if stop and stop(p):
            return seen, goals, p
        r = w.room_at(p.x, p.y)
        if allow and not allow(r):
            continue
        w.broken = p.br
        succ = []
        sim = lambda *a, **kw: simulate(*a, extras=succ, **kw)
        if k[0] == "F":
            for d in (-1, 1):
                succ.append(sim(w, rest(p), walk_plan(d), goals))
            for rd, rf, hold, plan in FLOOR_MACROS:
                budget -= 1
                succ.append(sim(w, rest(p), floor_plan(rd, rf, hold, plan), goals))
            if w.kit_dash:
                for m in DASH_FLOOR:
                    budget -= 1
                    succ.append(sim(w, rest(p), dash_floor_fn(*m), goals))
        elif k[0] == "W":
            base = rest(p)
            base.wall, base.floor = True, False
            for dy in (-6, 6):  # lezení po stěně
                c = base.copy()
                c.y += dy
                side = c.x - HW - 1 if c.normal == 1 else c.x + HW + 1
                if not w.hits(c.x, c.y) and (w.solid(side, c.y - HH + 2) or w.solid(side, c.y) or w.solid(side, c.y + HH - 2)) and not w.deadly(c.x, c.y, c.room):
                    succ.append(("wall", c, -1))
            for d0, a, dj, hold in wall_plans(p.normal):
                budget -= 1
                succ.append(sim(w, base.copy(), wall_fn(d0, a, dj, hold), goals))
            if w.kit_dash and p.dash:
                for m in dash_wall_plans(p.normal):
                    budget -= 1
                    succ.append(sim(w, base.copy(), dash_wall_fn(*m), goals))
        elif k[0] in "DR":  # krystal dashe: hned dash, nebo let dál; po vrtání ve vzduchu: pád z klidu, dash jen když ho má
            if k[0] == "D" or (w.kit_dash and p.dash):
                for t0 in ((0,) if k[0] == "D" else (0, 12)):
                    for d in DIRS8:
                        for dj in (None, 14):
                            budget -= 1
                            succ.append(sim(w, p.copy(), dash_air_fn(t0, d, dj), goals))
            for a1, sw, dj in air_plans((-1, 0, 1)):
                budget -= 1
                def fn(f, a1=a1, sw=sw, dj=dj):
                    d = a1 if sw is None or f < sw[0] else sw[1]
                    return d, dj is not None and dj <= f < dj + 30
                succ.append(sim(w, p.copy(), fn, goals))
        elif k[0] == "A":  # u kotvy háku: dolet s hybností tahu, katapult skokem, nebo puštění; dash i dvojskok obnoveny
            for vx, vy in ((p.hx * HOOK_PULL, -100.0 * p.g), (p.hx * 260.0, JUMP * 0.9 * p.g), (0.0, -100.0 * p.g)):
                for a1, sw, dj in air_plans((-1, 0, 1)):
                    budget -= 1
                    c = p.copy()
                    c.vx, c.vy = vx, vy
                    def fn(f, a1=a1, sw=sw, dj=dj):
                        d = a1 if sw is None or f < sw[0] else sw[1]
                        return d, dj is not None and dj <= f < dj + 30
                    succ.append(sim(w, c, fn, goals))
                if w.kit_dash:
                    for t0 in (2, 12):
                        for d in DIRS8:
                            for dj in (None, 14):
                                budget -= 1
                                c = p.copy()
                                c.vx, c.vy = vx, vy
                                succ.append(sim(w, c, dash_air_fn(t0, d, dj), goals))
        else:
            spring = w.springs[k[1]]
            for vx in (-SPEED, 0.0, SPEED):
                for a1, sw, dj in air_plans((-1, 0, 1)):
                    budget -= 1
                    c = p.copy()
                    launch(c, spring, vx)
                    def fn(f, a1=a1, sw=sw, dj=dj):
                        d = a1 if sw is None or f < sw[0] else sw[1]
                        return d, dj is not None and dj <= f < dj + 30
                    succ.append(sim(w, c, fn, goals))
            if w.kit_dash:
                for t in (8, 20):
                    for d in DIRS8:
                        for dj in (None, 14):
                            budget -= 1
                            c = p.copy()
                            launch(c, spring, 0.0)
                            succ.append(sim(w, c, dash_air_fn(t, d, dj), goals))
        for res in succ:
            if res is None:
                continue
            kind, s, si = res
            nk = key_of(kind, s, si) + (s.br,)
            if nk not in seen:
                seen[nk] = s
                q.append((nk, s))
    return seen, goals, None


# ---------- výstup ----------
def lint(rooms, layout):
    errors = 0
    for r in rooms.values():
        bad = sorted({c for row in r.rows for c in row if c not in KNOWN})
        if bad:
            print(f"CHYBA {r.id}: neznámé znaky {''.join(bad)}")
            errors += 1
        if not r.respawns:
            print(f"CHYBA {r.id}: chybí @ (RespawnPoint)")
            errors += 1
        if r.w % SW or r.h % SH:
            print(f"VAROVÁNÍ {r.id}: {r.w}x{r.h} dlaždic není násobek 20x11")
        if any(len(row) != r.w for row in r.rows):
            print(f"VAROVÁNÍ {r.id}: řádky mají různou délku")
    return errors


def render(path, w, seen, goals, k=4):
    from make_room_tiles import write_png
    xs = [r.ox for r in w.rooms] + [r.ox + r.screens[0] * SCREEN_W for r in w.rooms]
    ys = [r.oy for r in w.rooms] + [r.oy + r.screens[1] * SCREEN_H for r in w.rooms]
    X0, Y0 = min(xs), min(ys)
    W, H = (max(xs) - X0) // k, (max(ys) - Y0) // k
    px = [[(12, 12, 16, 255)] * W for _ in range(H)]
    col = {"#": (90, 96, 120), "A": (225, 230, 240), "J": (110, 100, 95), "B": (200, 160, 70), "W": (130, 85, 50), "Z": (130, 90, 70), "R": (150, 60, 45), "%": (120, 70, 200),
           "_": (110, 100, 70), "&": (120, 65, 50), "L": (90, 80, 130), "~": (80, 80, 80), "=": (190, 130, 60), "^": (230, 40, 50),
           "v": (230, 40, 50), "<": (230, 40, 50), ">": (230, 40, 50), "S": (60, 220, 200), "C": (120, 240, 255), "G": (230, 80, 230),
           "T": (230, 80, 230), "D": (230, 80, 230), "E": (80, 255, 80), "@": (255, 255, 255), "N": (255, 230, 90), **{d: (255, 230, 90) for d in "12345678"},
           "V": (240, 150, 60), "I": (255, 90, 160), "O": (200, 120, 80), "K": (255, 240, 120), "F": (70, 76, 100), "P": (240, 90, 40), "c": (120, 240, 255),
           "U": (70, 62, 66), "Y": (150, 70, 40), "m": (255, 110, 20), "*": (90, 255, 230), "Q": (255, 60, 60), "+": (255, 220, 60), "r": (150, 130, 110), "e": (230, 80, 230),
           ":": (70, 40, 120), "-": (60, 60, 66), "n": (30, 110, 110), "[": (200, 120, 60), "]": (60, 120, 200), "i": (255, 240, 120), "?": (160, 60, 200)}
    back = set("wzobdtqk")
    for r in w.rooms:
        for ty, row in enumerate(r.rows):
            for tx, c in enumerate(row):
                color = col.get(c, (40, 34, 30) if c in back else None)
                if color is None:
                    continue
                X, Y = (r.ox + tx * TILE - X0) // k, (r.oy + ty * TILE - Y0) // k
                for yy in range(Y, min(H, Y + 4)):
                    for xx in range(X, min(W, X + 4)):
                        px[yy][xx] = color + (255,)
        for x in range((r.ox - X0) // k, min(W, (r.ox + r.screens[0] * SCREEN_W - X0) // k)):
            for y in ((r.oy - Y0) // k, (r.oy + r.screens[1] * SCREEN_H - Y0) // k - 1):
                if 0 <= y < H:
                    px[y][x] = (60, 60, 70, 255)
        for y in range((r.oy - Y0) // k, min(H, (r.oy + r.screens[1] * SCREEN_H - Y0) // k)):
            x = (r.ox - X0) // k
            px[y][x] = (60, 60, 70, 255)
    for key, s in seen.items():
        X, Y = int((s.x - X0) // k), int((s.y + HH - 1 - Y0) // k)
        if 0 <= X < W and 0 <= Y < H:
            px[Y][X] = (80, 255, 120, 255) if key[0] == "F" else (255, 200, 80, 255)
    write_png(path, px)
    print("mapa:", path)


def main():
    sys.stdout.reconfigure(encoding="utf-8")
    args = sys.argv[1:]
    if not args:
        print(__doc__)
        return 1
    md = args[0]
    only = args[args.index("--room") + 1] if "--room" in args else None
    map_path = args[args.index("--map") + 1] if "--map" in args else None
    scale = int(args[args.index("--scale") + 1]) if "--scale" in args else 4
    datas, layout = parse_doc(open(md, encoding="utf-8").read())
    if only:
        if only not in datas:
            raise SystemExit(f"místnost {only} v {md} není")
        rooms = {only: Room(only, datas[only])}
    else:
        if not layout:
            raise SystemExit("chybí blok ```layout (nebo použij --room)")
        rooms = {}
        for rid, sx, sy in layout["rooms"]:
            if rid not in datas:
                raise SystemExit(f"CHYBA: layout zmiňuje {rid}, ale mřížka chybí")
            rooms[rid] = Room(rid, datas[rid], sx, sy)
    errors = lint(rooms, layout)
    world = World(list(rooms.values()))
    world.kit_dash = ("--dash" in args or "dash" in (layout or {}).get("kit", ())) and "--nodash" not in args  # --nodash: okřídlený krystal bez dashe
    world.kit_hook = ("--hook" in args or "hook" in (layout or {}).get("kit", ())) and "--nohook" not in args
    world.kit_drill = ("--drill" in args or "drill" in (layout or {}).get("kit", ())) and "--nodrill" not in args
    world.goals = [c for r in world.rooms for c in r.crystals] + [k for r in world.rooms for k in r.keys] + [e for r in world.rooms for e in r.ends]
    names = [f"C@{r.id}" for r in world.rooms for _ in r.crystals] + [f"K@{r.id}" for r in world.rooms for _ in r.keys] + [f"E@{r.id}" for r in world.rooms for _ in r.ends]
    ordered = [world.rooms[i] for i in range(len(world.rooms)) if not re.search(r"\d[a-z]$", world.rooms[i].id)] # větve (c1_a03b) mimo hlavní cestu

    if only:
        world.edges = False  # samotná místnost: okraje se hlásí jako výstupy
        r = world.rooms[0]
        for i, (x, y) in enumerate(r.respawns):
            world.drops = set()
            seen, goals, _ = search(world, [P(x, y)])
            exits = set()
            for s in seen.values():
                for edge, ok in (("L", s.x < r.ox + 12), ("R", s.x > r.ox + r.w * TILE - 12), ("T", s.y < r.oy + 12)):
                    if ok:
                        exits.add(f"{edge}{int((s.y - r.oy) // TILE) if edge in 'LR' else int((s.x - r.ox) // TILE)}")
            drops = sorted(world.drops)
            spans, a = [], None
            for j, c in enumerate(drops):
                if a is None:
                    a = c
                if j + 1 == len(drops) or drops[j + 1] != c + 1:
                    spans.append(f"B{a}" if a == c else f"B{a}-{c}")
                    a = None
            print(f"{r.id} @{i + 1} ({int(x // TILE)},{int(y // TILE)}): stavů {len(seen)}, u okrajů {sorted(exits) or '-'}, propad dnem {' '.join(spans) or '-'}, cíle {sorted(names[g] for g in goals) or '-'}")
            print(f"   (výstup = dosažený stav u okraje; propad dnem = sloupce, kde hráč vypadne dolů: výstup do místnosti pod ní, nebo jáma){' [dash]' if world.kit_dash else ''}{' [hook]' if world.kit_hook else ''}{' [drill]' if world.kit_drill else ''}")
        if map_path:
            render(map_path, world, seen, goals, scale)
        return 1 if errors else 0

    start = ordered[0].respawns[0]
    seen, goals, _ = search(world, [P(*start)])
    world.open_locks = True
    if any(n.startswith("K@") for n in (names[g] for g in goals)):
        _, goals2, _ = search(world, [P(*start)])
        goals |= goals2
    world.open_locks = False
    reached = sorted(names[g] for g in goals)
    total_c = sum(len(r.crystals) for r in world.rooms)
    got_c = sum(1 for n in reached if n.startswith("C@"))
    end_ok = any(n.startswith("E@") for n in reached)
    print(f"Start {ordered[0].id}: stavů {len(seen)}, konec (E) {'ANO' if end_ok else 'NE'}, krystaly {got_c}/{total_c}")
    missing = [names[i] for i in range(len(names)) if i not in goals]
    if missing:
        print("  nedosažené:", ", ".join(missing))
    if not end_ok:
        errors += 1
    visited = {world.room_at(s.x, s.y).id for s in seen.values() if world.room_at(s.x, s.y)}
    for r in world.rooms:
        if r.id not in visited:
            print(f"  místnost {r.id} se z hlavní cesty nedá navštívit")
    # Každý respawn musí vést dál (do další místnosti hlavní cesty, v poslední na E)
    for i, r in enumerate(ordered):
        nxt = ordered[i + 1] if i + 1 < len(ordered) else None
        for j, (x, y) in enumerate(r.respawns):
            if nxt:
                stop = lambda s, nxt=nxt: nxt.contains(s.x, s.y)
            else:
                stop = lambda s, r=r: any(s.x - HW < e[2] and s.x + HW > e[0] and s.y - HH < e[3] and s.y + HH > e[1] for e in r.ends)
            _, g, hit = search(world, [P(x, y)], allow=lambda rr, r=r: rr is r, stop=stop)
            if hit is None and not (nxt is None and any(names[k].startswith("E@") for k in g)):
                print(f"  CHYBA {r.id} @{j + 1}: z respawnu se nedá dostat do {nxt.id if nxt else 'E'}")
                errors += 1
    for r in world.rooms: # z větve (c1_c02b) se musí jít vrátit
        if r in ordered:
            continue
        for j, (x, y) in enumerate(r.respawns):
            _, _, hit = search(world, [P(x, y)], allow=lambda rr, r=r: rr is r, stop=lambda s, r=r: world.room_at(s.x, s.y) not in (r, None))
            if hit is None:
                print(f"  CHYBA {r.id} @{j + 1}: z větve se nedá vrátit do jiné místnosti")
                errors += 1
    if map_path:
        render(map_path, world, seen, goals, scale)
    print("OK" if errors == 0 else f"{errors} chyb")
    return 1 if errors else 0


if __name__ == "__main__":
    sys.exit(main())
