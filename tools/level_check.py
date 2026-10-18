"""Kontrola průchodnosti ASCII kapitol (LEVEL_*.md) simulací pohybu hráče podle player.gd.

  python tools/level_check.py LEVEL_c1.md                 # celá kapitola podle ```layout
  python tools/level_check.py LEVEL_c1.md --room c1_b03   # jen jedna místnost (výstupy, krystaly)
  python tools/level_check.py LEVEL_c1.md --map out.png [--scale 8]  # + mapa (px na dlaždici, výchozí 4)

Simuluje snímek po snímku (60 Hz) stejné pořadí jako player.gd: zeď / gravitace, vodorovný pohyb,
skok (coyote, skok od zdi, šplhací skok, dvojskok), useknutí skoku, posun s kolizí po osách.
Prohledává makra (rozběh, výdrž skoku, směr ve vzduchu, otočka, čas dvojskoku) z klidových stavů
(stojí, drží zeď, pružina). Nepřátelé, páry, padající kameny, krystalové bodáky a hlavy lisů se ignorují (časování);
mřížky se berou jako pevné; KeyBlock (L) se pro krystaly bere jako otevřený, když je klíč dosažitelný.
Bez dash a háku (kit kapitol c1-c3)."""
import math, re, sys, os
from collections import deque

DT = 1 / 60
G, SPEED, ACC, FRIC = 980.0, 150.0, 800.0, 1000.0
JUMP, AIRJ, WJX, WJY = -300.0, -270.0, 200.0, -250.0
SLIDE, CLIMB, COYOTE, CUT, STAMINA = 50.0, 60.0, 0.1, 0.5, 8.0
HW, HH = 7.0, 9.0
TILE, SW, SH, SCREEN_W, SCREEN_H = 16, 20, 11, 320, 180

SOLID = set("#BWZR%_&L~=P")  # P = těleso lisu (hlava je časovaná, ignoruje se)
KNOWN = SOLID | set(". wzobdtqkFlfayxpgh@^v<>SVIOGTDMCc*KHXN!E12345678")


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
        self.open_locks = False

    def room_at(self, px, py):
        return self.cell.get((math.floor(px / SCREEN_W), math.floor(py / SCREEN_H)))

    def solid(self, px, py):
        r = self.room_at(px, py)
        if r is None:
            return False
        tx, ty = int((px - r.ox) // TILE), int((py - r.oy) // TILE)
        if 0 <= ty < r.h and 0 <= tx < r.w and r.solid[ty][tx]:
            return not (self.open_locks and r.rows[ty][tx] == "L")
        return False

    def tile_top(self, px, py):
        r = self.room_at(px, py)
        return r.oy + int((py - r.oy) // TILE) * TILE

    def hits(self, x, y):
        s = self.solid
        x0, x1, y0, y1 = x - HW, x + HW - 0.01, y - HH, y + HH - 0.01
        return s(x0, y0) or s(x1, y0) or s(x0, y) or s(x1, y) or s(x0, y1) or s(x1, y1)

    def deadly(self, x, y):
        x0, x1, y0, y1 = x - HW, x + HW, y - HH, y + HH
        for a, b, c, d in self.spikes:
            if x0 < c and x1 > a and y0 < d and y1 > b:
                return True
        return self.room_at(x, y) is None


# ---------- hráč ----------
class P:
    __slots__ = ("x", "y", "vx", "vy", "floor", "wall", "normal", "coyote", "air", "stamina", "lock", "cut", "cool")

    def __init__(self, x, y):
        self.x, self.y, self.vx, self.vy = x, y, 0.0, 0.0
        self.floor, self.wall, self.normal = True, False, 0
        self.coyote, self.air, self.stamina, self.lock, self.cut, self.cool = COYOTE, 1, STAMINA, 0.0, False, 0.0

    def copy(self):
        p = P.__new__(P)
        for k in P.__slots__:
            setattr(p, k, getattr(self, k))
        return p


def toward(v, t, d):
    return min(v + d, t) if v < t else max(v - d, t)


def step(w, p, dirn, press, release, held):
    on_wall = p.wall and not p.floor
    away = on_wall and dirn == p.normal
    grabbing = on_wall and p.stamina > 0 and not away and p.vy >= -CLIMB
    if on_wall:
        if grabbing:
            p.vy = -CLIMB if held else 0.0
            p.stamina -= DT
        else:
            p.vy = p.vy + G * DT if p.stamina <= 0 else min(p.vy + G * DT, SLIDE)
        p.coyote -= DT
    elif not p.floor:
        p.vy += G * DT
        p.coyote -= DT
    else:
        p.coyote, p.air, p.stamina = COYOTE, 1, STAMINA
        if p.vy >= 0:
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
            p.vy, p.coyote = JUMP, 0.0
        elif on_wall and p.stamina > 0:
            p.stamina -= 0.3
            if dirn == -p.normal or (grabbing and not dirn):
                p.vy, p.vx = AIRJ, -p.normal * SPEED
            else:
                p.vx, p.vy = p.normal * WJX, WJY
            p.air = 1
        elif p.air > 0 and not p.floor:
            p.vy, p.air = AIRJ, p.air - 1
        else:
            jumped = False
        if jumped:
            p.cut = True
    if p.cut and release and p.vy < 0:
        p.vy *= CUT
    # posun po osách s kolizí
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
    p.x = nx
    ny = p.y + p.vy * DT
    p.floor = False
    xs = (p.x - HW, p.x + HW - 0.01)
    if p.vy >= 0:
        probe = ny + (1.0 if p.vy == 0 else 0.0) # klidový stav: přichycení k podlaze o 1 px
        if w.hits(p.x, probe):
            foot = probe + HH - 0.01
            tops = [w.tile_top(sx, foot) for sx in xs if w.solid(sx, foot)]
            ny = min(tops) - HH - 0.001 if tops else p.y
            p.vy, p.floor = 0.0, True
    elif w.hits(p.x, ny):
        head = ny - HH
        bottoms = [w.tile_top(sx, head) + TILE for sx in xs if w.solid(sx, head)]
        ny = max(bottoms) + HH + 0.001 if bottoms else p.y
        if w.hits(p.x, ny):
            ny = p.y
        p.vy = 0.0
    p.y = ny
    # pružina
    p.cool -= DT
    if p.cool <= 0:
        for i, (sx, sy, dx, dy, st, lock) in enumerate(w.springs):
            if p.x - HW < sx + 7 and p.x + HW > sx - 7 and p.y - HH < sy - 2 and p.y + HH > sy - 10:
                return i
    return -1


def launch(p, spring, vx):
    sx, sy, dx, dy, st, lock = spring
    p.vx, p.vy, p.lock = dx * st, dy * st, lock
    if abs(dy) < 0.3:
        p.vy = -160.0
    elif abs(dx) < 0.3:
        p.vx, p.lock = vx, 0.0
    p.air, p.stamina, p.cut, p.coyote, p.cool, p.floor = 1, STAMINA, False, 0.0, 0.25, False


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


def simulate(w, p, plan_fn, goals, max_frames=170):
    """-> ('floor'|'wall'|'spring', P, spring_i) nebo None; goals = množina dotčených cílů (krystaly, E)."""
    airborne = not p.floor
    prev_held = False
    for f in range(max_frames):
        dirn, held = plan_fn(f)
        press, release = held and not prev_held, prev_held and not held
        prev_held = held
        si = step(w, p, dirn, press, release, held)
        if w.deadly(p.x, p.y):
            return None
        for gi, g in enumerate(w.goals):
            if (g[0] - p.x) ** 2 + (g[1] - p.y) ** 2 < 144 if len(g) == 2 else (p.x - HW < g[2] and p.x + HW > g[0] and p.y - HH < g[3] and p.y + HH > g[1]):
                goals.add(gi)
        if si >= 0:
            return ("spring", p, si)
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


def key_of(kind, p, extra=None):
    if kind == "floor":
        return ("F", round(p.x / 8), round(p.y))
    if kind == "wall":
        return ("W", round(p.x), round(p.y / 6), p.normal)
    return ("S", extra)


def rest(p):
    q = p.copy()
    q.vx = q.vy = 0.0
    q.lock = 0.0
    return q


def search(w, starts, allow=None, stop=None, budget=10 ** 9):
    """BFS. allow(room)->bool omezí rozbalování; stop(state)->bool ukončí. Vrací (navštívené stavy, dotčené cíle)."""
    seen, goals, q = {}, set(), deque()
    for p in starts:
        k = key_of("floor", p)
        seen[k] = p
        q.append((k, p))
    while q and budget > 0:
        k, p = q.popleft()
        if stop and stop(p):
            return seen, goals, p
        r = w.room_at(p.x, p.y)
        if allow and not allow(r):
            continue
        succ = []
        if k[0] == "F":
            for d in (-1, 1):
                succ.append(simulate(w, rest(p), walk_plan(d), goals))
            for rd, rf, hold, plan in FLOOR_MACROS:
                budget -= 1
                succ.append(simulate(w, rest(p), floor_plan(rd, rf, hold, plan), goals))
        elif k[0] == "W":
            base = rest(p)
            base.wall, base.floor = True, False
            for dy in (-6, 6):  # lezení po stěně
                c = base.copy()
                c.y += dy
                side = c.x - HW - 1 if c.normal == 1 else c.x + HW + 1
                if not w.hits(c.x, c.y) and (w.solid(side, c.y - HH + 2) or w.solid(side, c.y) or w.solid(side, c.y + HH - 2)) and not w.deadly(c.x, c.y):
                    succ.append(("wall", c, -1))
            for d0, a, dj, hold in wall_plans(p.normal):
                budget -= 1
                succ.append(simulate(w, base.copy(), wall_fn(d0, a, dj, hold), goals))
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
                    succ.append(simulate(w, c, fn, goals))
        for res in succ:
            if res is None:
                continue
            kind, s, si = res
            nk = key_of(kind, s, si)
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
    col = {"#": (90, 96, 120), "B": (200, 160, 70), "W": (130, 85, 50), "Z": (130, 90, 70), "R": (150, 60, 45), "%": (120, 70, 200),
           "_": (110, 100, 70), "&": (120, 65, 50), "L": (90, 80, 130), "~": (80, 80, 80), "=": (190, 130, 60), "^": (230, 40, 50),
           "v": (230, 40, 50), "<": (230, 40, 50), ">": (230, 40, 50), "S": (60, 220, 200), "C": (120, 240, 255), "G": (230, 80, 230),
           "T": (230, 80, 230), "D": (230, 80, 230), "E": (80, 255, 80), "@": (255, 255, 255), "N": (255, 230, 90), **{d: (255, 230, 90) for d in "12345678"},
           "V": (240, 150, 60), "I": (255, 90, 160), "O": (200, 120, 80), "K": (255, 240, 120), "F": (70, 76, 100), "P": (240, 90, 40), "c": (120, 240, 255)}
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
    world.goals = [c for r in world.rooms for c in r.crystals] + [k for r in world.rooms for k in r.keys] + [e for r in world.rooms for e in r.ends]
    names = [f"C@{r.id}" for r in world.rooms for _ in r.crystals] + [f"K@{r.id}" for r in world.rooms for _ in r.keys] + [f"E@{r.id}" for r in world.rooms for _ in r.ends]
    ordered = [world.rooms[i] for i in range(len(world.rooms)) if not re.search(r"\d[a-z]$", world.rooms[i].id)] # větve (c1_a03b) mimo hlavní cestu

    if only:
        r = world.rooms[0]
        for i, (x, y) in enumerate(r.respawns):
            seen, goals, _ = search(world, [P(x, y)])
            exits = set()
            for s in seen.values():
                for edge, ok in (("L", s.x < r.ox + 12), ("R", s.x > r.ox + r.w * TILE - 12), ("T", s.y < r.oy + 12)):
                    if ok:
                        exits.add(f"{edge}{int((s.y - r.oy) // TILE) if edge in 'LR' else int((s.x - r.ox) // TILE)}")
            print(f"{r.id} @{i + 1} ({int(x // TILE)},{int(y // TILE)}): stavů {len(seen)}, u okrajů {sorted(exits) or '-'}, cíle {sorted(names[g] for g in goals) or '-'}")
            print("   (výstup = dosažený stav u okraje; propad dolů do jámy se nehlásí)")
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
