import zlib, struct, os

os.makedirs('assets/npc', exist_ok=True)

def make_png(width, height, rgba_data, filename):
    raw = bytearray()
    for y in range(height):
        raw.append(0) # filter byte none
        for x in range(width):
            raw.extend(rgba_data[y * width + x])
    compressed = zlib.compress(bytes(raw))
    
    ihdr_data = struct.pack('>IIBBBBB', width, height, 8, 6, 0, 0, 0)
    def chunk(tag, data):
        return struct.pack('>I', len(data)) + tag + data + struct.pack('>I', zlib.crc32(tag + data) & 0xffffffff)
        
    png = b'\x89PNG\r\n\x1a\n' + chunk(b'IHDR', ihdr_data) + chunk(b'IDAT', compressed) + chunk(b'IEND', b'')
    with open(filename, 'wb') as f:
        f.write(png)
    print(f"Created {filename}")

# Paleta
C_OUT = (20, 16, 24, 255)       # Tmavý obrys
C_SKIN = (240, 190, 150, 255)   # Světlá kůže
C_SKIN_D = (195, 140, 100, 255) # Stínovaná kůže
C_BRASS = (210, 160, 50, 255)   # Mosaz
C_BRASS_D = (140, 95, 25, 255)  # Tmavá mosaz
C_CYAN = (60, 225, 240, 255)    # Neonová modrá
C_WHITE = (255, 255, 255, 255)
C_GREY = (180, 180, 195, 255)
C_GREY_D = (110, 110, 125, 255)

# ==============================================================================
# 1. OTIS - Starý mechanik (Sprite 24x24 & Portrait 32x32)
# ==============================================================================
# Otis Sprite (24x24)
otis_spr = [(0, 0, 0, 0)] * (24 * 24)
for y in range(24):
    for x in range(24):
        # Nohy / boty (y: 19..23)
        if 19 <= y <= 22 and 7 <= x <= 16:
            otis_spr[y * 24 + x] = (60, 45, 35, 255)
        # Zástěra / tělo (y: 11..18, x: 7..16)
        elif 11 <= y <= 18 and 6 <= x <= 17:
            if y == 11 or x == 6 or x == 17:
                otis_spr[y * 24 + x] = C_OUT
            elif 13 <= y <= 17 and 9 <= x <= 14:
                otis_spr[y * 24 + x] = (140, 85, 45, 255) # Kožená hnědá zástěra
            else:
                otis_spr[y * 24 + x] = (180, 170, 155, 255) # Košile
        # Hlava & vousy (y: 3..10, x: 8..15)
        elif 3 <= y <= 10 and 8 <= x <= 15:
            if y == 3 or x == 8 or x == 15:
                otis_spr[y * 24 + x] = C_OUT
            elif y <= 5: # Vlasy / čepice
                otis_spr[y * 24 + x] = C_GREY_D
            elif y == 6: # Oči & kůže
                otis_spr[y * 24 + x] = C_SKIN if x not in (10, 13) else (40, 30, 40, 255)
            elif y >= 7: # Hustý šedý plnovous
                otis_spr[y * 24 + x] = C_GREY if y == 7 or x in (9, 14) else (220, 220, 230, 255)
        # Mosazné brýle na čele (y: 4, x: 9..14)
        if y == 4 and 9 <= x <= 14:
            otis_spr[y * 24 + x] = C_BRASS if x not in (11, 12) else C_BRASS_D
        # Hasák v ruce (x: 18..21, y: 10..18)
        if 10 <= y <= 18 and x == 19:
            otis_spr[y * 24 + x] = (190, 190, 205, 255)
        if y in (10, 11) and 18 <= x <= 20:
            otis_spr[y * 24 + x] = C_BRASS

make_png(24, 24, otis_spr, 'assets/npc/otis_sprite.png')

# Otis Portrait (32x32)
otis_port = [(28, 24, 34, 255)] * (32 * 32) # Tmavý rám pozadí
for y in range(32):
    for x in range(32):
        # Okraj portrétu
        if x in (0, 31) or y in (0, 31):
            otis_port[y * 32 + x] = C_BRASS_D
            continue
        if x in (1, 30) or y in (1, 30):
            otis_port[y * 32 + x] = C_OUT
            continue
            
        # Zástěra a ramena (y: 22..30, x: 4..27)
        if 22 <= y <= 30 and 4 <= x <= 27:
            if 8 <= x <= 23:
                otis_port[y * 32 + x] = (130, 80, 40, 255)
            else:
                otis_port[y * 32 + x] = (160, 150, 140, 255)
        # Hlava (y: 6..24, x: 8..23)
        if 6 <= y <= 23 and 8 <= x <= 23:
            otis_port[y * 32 + x] = C_SKIN
            if x in (8, 23):
                otis_port[y * 32 + x] = C_SKIN_D
        # Šedé vlasy nahoře a po stranách
        if (6 <= y <= 9 and 8 <= x <= 23) or (9 <= y <= 18 and x in (8, 9, 22, 23)):
            otis_port[y * 32 + x] = C_GREY
        # Mosazné steampunk brýle na čele (y: 8..11, x: 10..21)
        if 8 <= y <= 11 and 10 <= x <= 21:
            if x in (10, 15, 16, 21) or y in (8, 11):
                otis_port[y * 32 + x] = C_BRASS_D
            elif x in (11, 12, 13, 14, 17, 18, 19, 20):
                otis_port[y * 32 + x] = C_CYAN if (x, y) in ((12, 9), (13, 9), (18, 9), (19, 9)) else (40, 160, 180, 255)
        # Oči (y: 13, x: 12, 19)
        if y == 13 and x in (12, 13, 18, 19):
            otis_port[y * 32 + x] = (30, 25, 35, 255) if x in (13, 19) else C_WHITE
        # Šedý knír a plnovous (y: 16..24, x: 9..22)
        if 16 <= y <= 24 and 9 <= x <= 22:
            otis_port[y * 32 + x] = (225, 225, 235, 255) if y in (16, 17) else C_GREY

make_png(32, 32, otis_port, 'assets/npc/otis_portrait.png')

# ==============================================================================
# 2. RUSTY - Parní horník (Sprite 24x24 & Portrait 32x32)
# ==============================================================================
rusty_spr = [(0, 0, 0, 0)] * (24 * 24)
for y in range(24):
    for x in range(24):
        # Boty
        if 20 <= y <= 22 and 7 <= x <= 16:
            rusty_spr[y * 24 + x] = (40, 35, 45, 255)
        # Montérky (y: 12..19, x: 7..16)
        elif 12 <= y <= 19 and 7 <= x <= 16:
            rusty_spr[y * 24 + x] = (50, 75, 110, 255) if 14 <= y <= 18 else (150, 90, 40, 255)
        # Hlava a helma (y: 2..11, x: 7..16)
        elif 2 <= y <= 11 and 7 <= x <= 16:
            if y <= 5: # Železná důlní helma
                rusty_spr[y * 24 + x] = (120, 125, 135, 255)
            elif y == 6: # Škvíra helmy / oči
                rusty_spr[y * 24 + x] = (30, 20, 25, 255)
            else: # Respirátor / vousy
                rusty_spr[y * 24 + x] = (90, 80, 70, 255)
        # Svítilna na helmě (y: 3..4, x: 11..12) - Žlutě žhnoucí
        if 3 <= y <= 4 and 11 <= x <= 12:
            rusty_spr[y * 24 + x] = (255, 230, 80, 255)
        # Parní trubka vzadu (x: 5..6, y: 8..14)
        if 8 <= y <= 14 and x in (5, 6):
            rusty_spr[y * 24 + x] = C_BRASS

make_png(24, 24, rusty_spr, 'assets/npc/rusty_sprite.png')

rusty_port = [(28, 24, 34, 255)] * (32 * 32)
for y in range(32):
    for x in range(32):
        if x in (0, 31) or y in (0, 31):
            rusty_port[y * 32 + x] = (100, 110, 120, 255)
            continue
        if x in (1, 30) or y in (1, 30):
            rusty_port[y * 32 + x] = C_OUT
            continue
            
        # Ocelový oblek a chrániče ramen (y: 22..30, x: 4..27)
        if 22 <= y <= 30 and 4 <= x <= 27:
            rusty_port[y * 32 + x] = (60, 75, 105, 255) if 9 <= x <= 22 else (110, 115, 125, 255)
        # Helma (y: 4..16, x: 7..24)
        if 4 <= y <= 16 and 7 <= x <= 24:
            rusty_port[y * 32 + x] = (125, 130, 140, 255)
            if y == 4 or x in (7, 24):
                rusty_port[y * 32 + x] = (80, 85, 95, 255)
        # Velká důlní svítilna uprostřed helmy (y: 7..12, x: 13..18)
        if 7 <= y <= 12 and 13 <= x <= 18:
            if x in (13, 18) or y in (7, 12):
                rusty_port[y * 32 + x] = C_BRASS
            else:
                rusty_port[y * 32 + x] = (255, 240, 110, 255) if (x, y) in ((15, 9), (16, 9), (15, 10), (16, 10)) else (230, 175, 40, 255)
        # Tvář a štěrbiny respirátoru (y: 17..24, x: 9..22)
        if 17 <= y <= 24 and 9 <= x <= 22:
            if y in (17, 18): # Oči za sklem
                rusty_port[y * 32 + x] = (40, 35, 45, 255) if x in (12, 19) else C_SKIN_D
            else: # Mosazno-ocelový respirátor
                rusty_port[y * 32 + x] = C_BRASS_D if x % 2 == 0 else (90, 85, 95, 255)

make_png(32, 32, rusty_port, 'assets/npc/rusty_portrait.png')

# ==============================================================================
# 3. VESPER - Rebelující technička (Sprite 24x24 & Portrait 32x32)
# ==============================================================================
vesper_spr = [(0, 0, 0, 0)] * (24 * 24)
for y in range(24):
    for x in range(24):
        # Boty
        if 20 <= y <= 22 and 8 <= x <= 15:
            vesper_spr[y * 24 + x] = (40, 30, 50, 255)
        # Kalhoty a bunda (y: 11..19, x: 7..16)
        elif 11 <= y <= 19 and 7 <= x <= 16:
            if y >= 16:
                vesper_spr[y * 24 + x] = (50, 45, 60, 255) # Tmavé kalhoty
            elif 13 <= y <= 15:
                vesper_spr[y * 24 + x] = (230, 100, 35, 255) # Oranžová vesta / šátek
            else:
                vesper_spr[y * 24 + x] = (80, 70, 95, 255)
        # Hlava a vlasy (y: 3..10, x: 8..15)
        elif 3 <= y <= 10 and 8 <= x <= 15:
            if y <= 5: # Tmavé vlasy
                vesper_spr[y * 24 + x] = (45, 35, 55, 255)
            elif y == 6: # Neonové brýle
                vesper_spr[y * 24 + x] = C_CYAN
            else: # Obličej
                vesper_spr[y * 24 + x] = C_SKIN
        # Krystal v ruce (x: 17..19, y: 12..14)
        if 12 <= y <= 14 and 17 <= x <= 19:
            vesper_spr[y * 24 + x] = (80, 240, 255, 255)

make_png(24, 24, vesper_spr, 'assets/npc/vesper_sprite.png')

vesper_port = [(28, 24, 34, 255)] * (32 * 32)
for y in range(32):
    for x in range(32):
        if x in (0, 31) or y in (0, 31):
            vesper_port[y * 32 + x] = (220, 110, 40, 255) # Oranžový lem
            continue
        if x in (1, 30) or y in (1, 30):
            vesper_port[y * 32 + x] = C_OUT
            continue
            
        # Bunda a oranžový šátek (y: 22..30, x: 4..27)
        if 22 <= y <= 30 and 4 <= x <= 27:
            if 10 <= x <= 21:
                vesper_port[y * 32 + x] = (230, 110, 40, 255) # Oranžový šátek
            else:
                vesper_port[y * 32 + x] = (65, 55, 80, 255) # Kožená bunda
        # Tvář (y: 10..22, x: 9..22)
        if 10 <= y <= 22 and 9 <= x <= 22:
            vesper_port[y * 32 + x] = C_SKIN
            if x in (9, 22):
                vesper_port[y * 32 + x] = C_SKIN_D
        # Tmavé vlasy po stranách a ofina (y: 5..14)
        if (5 <= y <= 10 and 8 <= x <= 23) or (11 <= y <= 18 and x in (8, 9, 22, 23)):
            vesper_port[y * 32 + x] = (45, 35, 55, 255)
        # Zářící neonově azurové kyber-brýle (y: 12..15, x: 10..21)
        if 12 <= y <= 15 and 10 <= x <= 21:
            if x in (10, 15, 16, 21) or y in (12, 15):
                vesper_port[y * 32 + x] = (20, 35, 45, 255)
            else:
                vesper_port[y * 32 + x] = (160, 250, 255, 255) if (x, y) in ((12, 13), (13, 13), (18, 13), (19, 13)) else C_CYAN
        # Rty / ústa (y: 19, x: 14..17)
        if y == 19 and 14 <= x <= 17:
            vesper_port[y * 32 + x] = (195, 110, 105, 255)

make_png(32, 32, vesper_port, 'assets/npc/vesper_portrait.png')
print("All NPC sprites & portraits generated successfully!")
