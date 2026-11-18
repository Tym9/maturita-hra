"""Ruční kontroly, které level_check.py nedělá: věci ve vzduchu, zavřené budky, stropy polí."""
import sys
sys.path.insert(0, "tools")
import level_check as lc
datas, layout = lc.parse_doc(open(sys.argv[1], encoding="utf-8").read())
SOL = lc.SOLID | set("Fc")
for rid, d in datas.items():
    rows = d["rows"]; H = len(rows); W = max(len(r) for r in rows)
    at = lambda x, y: rows[y][x] if 0 <= y < H and 0 <= x < len(rows[y]) else ""
    out = []
    for y, r in enumerate(rows):
        for x, c in enumerate(r):
            below, above = at(x, y + 1), at(x, y - 1)
            if c in "lfayxpgh@X!N12345678GTIS^e" and below not in SOL and not (c == "^" and below == "^"):
                out.append(f"{c}({x},{H-1-y}) nemá pod sebou pevnou dlaždici ('{below}')")
            if c in "vO" and above not in SOL:
                out.append(f"{c}({x},{H-1-y}) nemá nad sebou pevnou dlaždici ('{above}')")
            if c == "<" and at(x + 1, y) not in SOL: out.append(f"<({x},{H-1-y}) nemá vpravo zeď")
            if c == ">" and at(x - 1, y) not in SOL: out.append(f">({x},{H-1-y}) nemá vlevo zeď")
    # dron vidí 120 px: u respawnu by útočil hned po příchodu / po smrti (pokud mezi nimi není zeď)
    for y, r in enumerate(rows):
        for x, c in enumerate(r):
            if c != "D":
                continue
            for y2, r2 in enumerate(rows):
                for x2, c2 in enumerate(r2):
                    if c2 == "@" and (x - x2) ** 2 + (y - y2) ** 2 < 8.2 ** 2:
                        n = max(abs(x - x2), abs(y - y2)) * 2
                        if not any(at(round(x2 + (x - x2) * i / n), round(y2 + (y - y2) * i / n)) in SOL for i in range(n + 1)):
                            out.append(f"D({x},{H-1-y}) vidí na respawn @({x2},{H-1-y2})")
    # dosažitelnost vzduchem (r, L, n průchozí) od @
    seen = set(); todo = [(x, y) for y, r in enumerate(rows) for x, c in enumerate(r) if c == "@"]
    seen.update(todo)
    while todo:
        x, y = todo.pop()
        for dx, dy in ((1, 0), (-1, 0), (0, 1), (0, -1)):
            n = (x + dx, y + dy); c = at(*n)
            if c and n not in seen and (c not in SOL or c in "rLnFc=[]"):
                seen.add(n); todo.append(n)
    for y, r in enumerate(rows):
        for x, c in enumerate(r):
            if c in "!HXKCc12345678NE*+S" and (x, y) not in seen:
                out.append(f"{c}({x},{H-1-y}) je v uzavřeném prostoru")
    room = lc.Room(rid, d)
    for a, b, c2, d2 in room.fields:
        x0, x1, y0, y1 = a // 16, c2 // 16, b // 16, d2 // 16
        if y0 == 0 or any(at(x, y0 - 1) not in SOL and at(x, y0 - 1) != "v" for x in range(x0, x1)):
            out.append(f"pole x{x0}-{x1-1} řádky {H-y1}-{H-1-y0}: nad polem není souvislý strop")
        if x0 == 0 or x1 == W or y1 == H:
            out.append(f"pole x{x0}-{x1-1}: dotýká se okraje místnosti")
        for y, r in enumerate(rows):
            for x, c in enumerate(r):
                if c == "@" and x0 - 2 <= x < x1 + 2 and y0 - 2 <= y < y1 + 2:
                    out.append(f"@({x},{H-1-y}) je u pole blíž než 2 dlaždice")
        cells = sum(1 for y in range(y0, y1) for x in range(x0, x1) if at(x, y) == ":")
        if cells < 0.6 * (x1 - x0) * (y1 - y0):
            out.append(f"pole x{x0}-{x1-1} řádky {H-y1}-{H-1-y0}: jen {cells} z {(x1-x0)*(y1-y0)} buněk je ':' (není to čistý obdélník?)")
    fb, db = room.fields, room.damps
    for f in fb:
        for g in db:
            if f[0] < g[2] and f[2] > g[0] and f[1] < g[3] and f[3] > g[1]:
                out.append("gravitační a tlumicí pole se překrývají")
    if out:
        print(rid); [print("   ", o) for o in out]
print("lint hotov")
