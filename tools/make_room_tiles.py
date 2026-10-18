"""Placeholder atlas pro místnosti: assets/placeholder/room_tiles.png (8x2 dlaždic po 16 px).
Řádek 0 = pevné (kámen a mosaz zůstávají z původního obrázku), řádek 1 = zadní dekor bez kolize.
Spuštění: python tools/make_room_tiles.py"""
import os, struct, zlib

T = 16
COLS, ROWS = 8, 2
OUT = os.path.join(os.path.dirname(__file__), "..", "assets", "placeholder", "room_tiles.png")


def read_png(path):
    data = open(path, "rb").read()
    pos, idat, w, h, ctype = 8, b"", 0, 0, 6
    while pos < len(data):
        n, kind = struct.unpack(">I4s", data[pos:pos + 8])
        body = data[pos + 8:pos + 8 + n]
        if kind == b"IHDR":
            w, h, depth, ctype = struct.unpack(">IIBB", body[:10])
            assert depth == 8 and ctype in (2, 6), "jen 8bit RGB/RGBA"
        elif kind == b"IDAT":
            idat += body
        pos += 12 + n
    bpp = 4 if ctype == 6 else 3
    raw, stride, out, prev = zlib.decompress(idat), w * bpp, [], bytearray(w * bpp)
    for y in range(h):
        f, line = raw[y * (stride + 1)], bytearray(raw[y * (stride + 1) + 1:(y + 1) * (stride + 1)])
        for i in range(stride):
            a = line[i - bpp] if i >= bpp else 0
            b, c = prev[i], prev[i - bpp] if i >= bpp else 0
            if f == 1: line[i] = (line[i] + a) & 255
            elif f == 2: line[i] = (line[i] + b) & 255
            elif f == 3: line[i] = (line[i] + (a + b) // 2) & 255
            elif f == 4:
                p = a + b - c
                pa, pb, pc = abs(p - a), abs(p - b), abs(p - c)
                line[i] = (line[i] + (a if pa <= pb and pa <= pc else b if pb <= pc else c)) & 255
        out.append([tuple(line[x * bpp:x * bpp + bpp]) + ((255,) if bpp == 3 else ()) for x in range(w)])
        prev = line
    return out


def write_png(path, px):
    h, w = len(px), len(px[0])
    raw = b"".join(b"\x00" + bytes(c for p in row for c in p) for row in px)
    chunk = lambda k, d: struct.pack(">I", len(d)) + k + d + struct.pack(">I", zlib.crc32(k + d) & 0xFFFFFFFF)
    png = b"\x89PNG\r\n\x1a\n" + chunk(b"IHDR", struct.pack(">IIBBBBB", w, h, 8, 6, 0, 0, 0))
    open(path, "wb").write(png + chunk(b"IDAT", zlib.compress(raw, 9)) + chunk(b"IEND", b""))


def rgb(h, a=255):
    return (int(h[1:3], 16), int(h[3:5], 16), int(h[5:7], 16), a)


def noise(x, y, s):
    n = (x * 374761393 + y * 668265263 + s * 2246822519) & 0xFFFFFFFF
    n = (n ^ (n >> 13)) * 1274126177 & 0xFFFFFFFF
    return (n & 0xFFFF) / 65535.0


def shade(c, k):
    return tuple(max(0, min(255, int(v * k))) for v in c[:3]) + (c[3],)


def tile(fn, seed):
    return [[fn(x, y, noise(x, y, seed)) for x in range(T)] for y in range(T)]


def wood(x, y, n, dark=1.0):
    if y % 4 == 3: return shade(rgb("#3a2414"), dark)
    base = rgb("#6b4226") if (y // 4) % 2 else rgb("#7a4c2b")
    if (x in (1, 14)) and y % 4 == 1: return shade(rgb("#c9a050"), dark) # hřebíky
    return shade(base, dark * (0.9 + 0.2 * n))


def scrap(x, y, n, dark=1.0):
    base = rgb("#6e6258")
    if n > 0.82 or (noise(x // 3, y // 3, 7) > 0.7): base = rgb("#8a4a24") # rez
    k = 1.15 if x % 4 in (0, 1) else 0.8 # vlnitý plech
    if y == 0: k = 1.3
    if (x, y) in ((2, 2), (13, 2), (2, 13), (13, 13)): return shade(rgb("#b0a090"), dark)
    return shade(base, dark * k * (0.92 + 0.15 * n))


def roof(x, y, n):
    # překrývané šindele: 4 px široké, spodní hrana zaoblená a ve stínu
    xx, yy = (x + (2 if (y // 4) % 2 else 0)) % 4, y % 4
    if yy == 3 and xx in (0, 3): return rgb("#2e1410")
    if yy == 3: return rgb("#5a2418")
    if xx == 0: return rgb("#4a1e16")
    return shade(rgb("#8a3a26"), (1.15 - 0.1 * yy) * (0.92 + 0.15 * n))


def vein(x, y):
    return abs(x - (8 + 4 * ((y // 3) % 2 * 2 - 1) * (y % 3) / 3)) < 1.2


def blight(x, y, n):
    if vein(x, y): return rgb("#c08aff") if n > 0.5 else rgb("#9b5cff")
    if n > 0.97: return rgb("#e0c0ff")
    return shade(rgb("#2e2620"), 0.85 + 0.3 * n)


def ground(x, y, n):
    top = 2 + int(noise(x, 0, 11) * 3)
    if y < top - 1: return (0, 0, 0, 0) if y < top - 2 else rgb("#8a8358")
    if y < top + 1: return rgb("#6f6a46") if n > 0.4 else rgb("#8a8358")
    return shade(rgb("#4a3a2c"), 0.8 + 0.35 * n)


def brick(x, y, n, dark=1.0):
    off = 4 if (y // 4) % 2 else 0
    if y % 4 == 3 or (x + off) % 8 == 7: return shade(rgb("#3a2a26"), dark)
    return shade(rgb("#6a3a2e"), dark * (0.85 + 0.3 * n))


def siding(x, y, n):
    if x % 4 == 3: return rgb("#1e140e")
    return shade(rgb("#3b2a1e") if (x // 4) % 2 else rgb("#33241a"), 0.9 + 0.2 * n)


def window(lit):
    def f(x, y, n):
        if 3 <= x <= 12 and 3 <= y <= 12:
            if x in (3, 12) or y in (3, 12): return rgb("#2a1c12")
            if not lit: return rgb("#141010") if not (abs(x - y) < 1.5 or abs(x + y - 15) < 1.5) else rgb("#6b4a2e")
            if x in (7, 8) or y in (7, 8): return rgb("#2a1c12")
            return rgb("#f2c060") if (x + y) % 5 else rgb("#e0a040")
        return siding(x, y, n)
    return f


def door(x, y, n):
    if x in (1, 14): return rgb("#2a1c12")
    if (x, y) in ((11, 8), (11, 9)): return rgb("#e0b050")
    return shade(rgb("#4a3020"), (0.75 if x % 4 == 0 else 1.0) * (0.9 + 0.2 * n))


def tarp(x, y, n):
    if 9 <= x <= 13 and 3 <= y <= 7: return rgb("#a07a3a") if (x + y) % 2 else rgb("#8a6630") # záplata
    fold = 0.8 if (x + y // 2) % 6 == 0 else 1.0
    return shade(rgb("#2f6e6a"), fold * (0.9 + 0.2 * n))


def rock_back(x, y, n):
    return shade(rgb("#1c1a22"), 0.85 + 0.35 * n)


def main():
    old = read_png(OUT)
    keep = [[[old[y][x + i * T] for x in range(T)] for y in range(T)] for i in range(2)] if len(old[0]) >= 2 * T else None
    solid = keep + [tile(wood, 1), tile(scrap, 2), tile(roof, 3), tile(blight, 4), tile(ground, 5), tile(brick, 6)]
    back = [tile(lambda x, y, n: siding(x, y, n), 7), tile(lambda x, y, n: scrap(x, y, n, 0.55), 8), tile(window(True), 9),
            tile(window(False), 10), tile(door, 11), tile(tarp, 12), tile(lambda x, y, n: brick(x, y, n, 0.55), 13), tile(rock_back, 14)]
    px = [[(0, 0, 0, 0)] * (COLS * T) for _ in range(ROWS * T)]
    for r, row in enumerate((solid, back)):
        for c, t in enumerate(row):
            for y in range(T):
                for x in range(T):
                    px[r * T + y][c * T + x] = t[y][x]
    write_png(OUT, px)
    print("wrote", os.path.normpath(OUT), COLS * T, "x", ROWS * T)


if __name__ == "__main__":
    main()
