"""Sprity (24x24) a portréty (32x32) nových postav kapitol 1-3 do assets/npc/ (styl jako create_npc_assets.py).
Spuštění: python tools/create_story_npcs.py"""
import os
from make_room_tiles import write_png

OUT = (20, 16, 24, 255)
SKIN, SKIN_D = (240, 190, 150, 255), (195, 140, 100, 255)
EYE = (30, 25, 35, 255)
BRASS, BRASS_D = (210, 160, 50, 255), (140, 95, 25, 255)
CLEAR = (0, 0, 0, 0)

# name: (vlasy, kabát, doplněk, kalhoty, rám portrétu, styl)
CHARS = {
    "mira": ((215, 215, 225, 255), (47, 138, 128, 255), (192, 57, 43, 255), (45, 40, 55, 255), (47, 138, 128, 255), "commander"),
    "brann": ((110, 70, 40, 255), (122, 74, 42, 255), (60, 55, 60, 255), (50, 45, 50, 255), (170, 100, 50, 255), "smith"),
    "elda": ((190, 190, 200, 255), (106, 74, 138, 255), (120, 90, 60, 255), (95, 70, 50, 255), (106, 74, 138, 255), "elder"),
    "tobi": ((110, 75, 45, 255), (60, 95, 150, 255), (150, 100, 60, 255), (60, 95, 150, 255), (60, 95, 150, 255), "kid"),
    "hron": ((90, 85, 80, 255), (70, 78, 90, 255), (60, 55, 60, 255), (45, 45, 50, 255), (150, 60, 50, 255), "smith"), # lisař z Parního města
}


def sprite(hair, coat, acc, pants, style):
    top = 6 if style == "kid" else 3 # dítě je menší
    px = [[CLEAR] * 24 for _ in range(24)]
    for y in range(24):
        for x in range(24):
            if 20 <= y <= 22 and 8 <= x <= 15:
                px[y][x] = (40, 32, 36, 255) # boty
            elif 16 <= y <= 19 and 8 <= x <= 15:
                px[y][x] = pants if style != "elder" else coat # sukně staré paní je ze šátku
            elif top + 8 <= y <= 15 and (6 if style == "smith" else 7) <= x <= (17 if style == "smith" else 16):
                px[y][x] = OUT if x in (6, 7, 16, 17) and (x <= 7 or x >= 16) else coat
                if style == "smith" and 12 <= y <= 15 and 9 <= x <= 14:
                    px[y][x] = (140, 85, 45, 255) # zástěra
                if style == "commander" and y == top + 8:
                    px[y][x] = acc # šála
                if style == "commander" and x == 12 and y in (13, 15):
                    px[y][x] = BRASS # knoflíky
            elif top <= y <= top + 7 and 8 <= x <= 15:
                if y == top or x in (8, 15):
                    px[y][x] = OUT
                elif y <= top + 2 and style != "smith":
                    px[y][x] = hair
                elif y == top + 3:
                    px[y][x] = EYE if x in (10, 13) else SKIN
                else:
                    px[y][x] = hair if style == "smith" and y >= top + 5 else SKIN # plnovous kováře
            if style == "kid" and y == top and 7 <= x <= 16:
                px[y][x] = acc # čepice se štítkem
            if style == "elder" and y == top - 1 and 10 <= x <= 13:
                px[y][x] = hair # drdol
    if style == "commander": # monokl
        px[top + 3][13] = BRASS
    if style == "smith": # kladivo
        for y in range(10, 19):
            px[y][19] = (150, 110, 70, 255)
        for x in range(18, 22):
            px[10][x] = px[11][x] = (150, 150, 165, 255)
    if style == "elder": # hůl
        for y in range(11, 23):
            px[y][18] = acc
    return [c for row in px for c in row]


def portrait(hair, coat, acc, frame, style):
    px = [[(28, 24, 34, 255)] * 32 for _ in range(32)]
    for y in range(32):
        for x in range(32):
            if x in (0, 31) or y in (0, 31):
                px[y][x] = frame
                continue
            if x in (1, 30) or y in (1, 30):
                px[y][x] = OUT
                continue
            if 22 <= y <= 30 and 4 <= x <= 27:
                px[y][x] = coat
                if style == "commander" and 22 <= y <= 24 and 9 <= x <= 22:
                    px[y][x] = acc
                if style == "smith" and 10 <= x <= 21:
                    px[y][x] = (140, 85, 45, 255)
            fy = 10 if style == "kid" else 7
            if fy <= y <= 22 and 9 <= x <= 22:
                px[y][x] = SKIN_D if x in (9, 22) else SKIN
            if style != "smith" and ((fy - 2 <= y <= fy + 2 and 8 <= x <= 23) or (fy + 3 <= y <= fy + 9 and x in (8, 9, 22, 23))):
                px[y][x] = hair
            if style == "smith" and 17 <= y <= 24 and 9 <= x <= 22:
                px[y][x] = hair # vousy
            if y == fy + 6 and x in (12, 13, 18, 19):
                px[y][x] = EYE if x in (13, 19) else (255, 255, 255, 255)
            if style == "kid" and fy - 3 <= y <= fy - 1 and 6 <= x <= 25:
                px[y][x] = acc # kšilt
            if style == "kid" and y == fy + 9 and x in (11, 13, 18, 20):
                px[y][x] = SKIN_D # pihy
            if style == "elder" and fy - 5 <= y <= fy - 3 and 12 <= x <= 19:
                px[y][x] = hair # drdol
    if style == "commander": # mosazný monokl a jizva
        for y in range(11, 16):
            for x in range(16, 21):
                if y in (11, 15) or x in (16, 20):
                    px[y][x] = BRASS
        for y in range(9, 15):
            px[y][11] = SKIN_D
    return [c for row in px for c in row]


def main():
    out = os.path.join(os.path.dirname(__file__), "..", "assets", "npc")
    for name, (hair, coat, acc, pants, frame, style) in CHARS.items():
        spr = sprite(hair, coat, acc, pants, style)
        por = portrait(hair, coat, acc, frame, style)
        write_png(os.path.join(out, f"{name}_sprite.png"), [spr[y * 24:(y + 1) * 24] for y in range(24)])
        write_png(os.path.join(out, f"{name}_portrait.png"), [por[y * 32:(y + 1) * 32] for y in range(32)])
        print("wrote", name)


if __name__ == "__main__":
    main()
