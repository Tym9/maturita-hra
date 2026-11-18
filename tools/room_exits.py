import sys, re
sys.path.insert(0, "tools")
import level_check as lc
datas, layout = lc.parse_doc(open(sys.argv[1], encoding="utf-8").read())
R = {}
for rid, sx, sy in layout["rooms"]:
    rows = datas[rid]["rows"]; R[rid] = (sx, sy, len(rows[0]) // 20, len(rows) // 11, rows)
main = [r for r, _, _ in layout["rooms"] if not re.search(r"\d[a-z]$", r)]
sol = lambda ch: ch in lc.SOLID
out = []
for a, b in zip(main, main[1:]):
    ax, ay, aw, ah, ar = R[a]; bx, by, bw, bh, br = R[b]
    if by == ay + ah:  # dolů
        cols = [c for c in range(len(ar[0])) if not sol(ar[-1][c]) and bx * 20 <= ax * 20 + c < (bx + bw) * 20 and not sol(br[0][ax * 20 + c - bx * 20])]
        c = cols[len(cols) // 2]
        out.append(f"{a}>{b}:D:{ax*320 + c*16 + 8}:{ay*180 + (len(ar)-1)*16 + 8}:{len(cols)}")
    elif bx == ax + aw:  # vpravo
        best = None
        for r in range(len(ar) - 1):
            wy = ay * 180 + r * 16
            if not sol(ar[r][-1]) and sol(ar[r + 1][-1]) and by * 180 <= wy < (by + bh) * 180:
                best = r
        out.append(f"{a}>{b}:R:{(ax+aw)*320 - 24}:{ay*180 + best*16 + 7}:1" if best is not None else f"{a}>{b}:R:NOFLOOR")
    else:
        out.append(f"{a}>{b}:??")
print(" ".join(out))
