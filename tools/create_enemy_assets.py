import zlib, struct, os, shutil

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

# 1. STEAM BULLET (12x12)
bullet_data = [(0, 0, 0, 0)] * (12 * 12)
for y in range(12):
    for x in range(12):
        dx = x - 5.5
        dy = y - 5.5
        dist = (dx*dx + dy*dy) ** 0.5
        if dist <= 2.0:
            bullet_data[y * 12 + x] = (255, 255, 255, 255)
        elif dist <= 3.5:
            bullet_data[y * 12 + x] = (80, 220, 255, 240)
        elif dist <= 4.8:
            bullet_data[y * 12 + x] = (255, 150, 40, 200)
        elif dist <= 5.8:
            bullet_data[y * 12 + x] = (200, 90, 20, 110)

make_png(12, 12, bullet_data, 'assets/enemies/steam_bullet.png')

# 2. SHOOTER SPRITESHEET (48x24: Frame 0 = Aim, Frame 1 = Fire)
W, H = 48, 24
shooter_data = [(0, 0, 0, 0)] * (W * H)

def draw_shooter_frame(ox, is_firing):
    # Palette
    C_OUT = (25, 20, 30, 255)      # Dark outline
    C_HELM = (180, 115, 45, 255)   # Brass helmet
    C_HELM_D = (130, 75, 25, 255)  # Dark brass
    C_GOG = (60, 230, 220, 255)    # Glowing cyan goggles
    C_COAT = (50, 45, 65, 255)     # Dark purple-grey coat
    C_COAT_L = (75, 70, 95, 255)   # Coat highlight
    C_BELT = (100, 60, 25, 255)    # Leather belt
    C_GUN = (195, 150, 55, 255)    # Brass rifle
    C_GUN_D = (140, 100, 35, 255)  # Dark rifle barrel
    C_STEAM = (120, 235, 255, 220) # Steam flash
    
    # Helmet (top: y=3 to 9, x=7 to 13)
    for y in range(3, 10):
        for x in range(7, 14):
            shooter_data[y * W + (ox + x)] = C_HELM
    # Helmet outline / shaded bottom
    for x in range(8, 13):
        shooter_data[3 * W + (ox + x)] = C_OUT
        shooter_data[9 * W + (ox + x)] = C_HELM_D
    shooter_data[4 * W + (ox + 7)] = C_OUT
    shooter_data[4 * W + (ox + 13)] = C_OUT
    
    # Goggles (y=5 to 7, x=10 to 14)
    shooter_data[6 * W + (ox + 10)] = C_OUT
    shooter_data[6 * W + (ox + 11)] = C_GOG
    shooter_data[6 * W + (ox + 12)] = C_GOG
    shooter_data[6 * W + (ox + 13)] = C_GOG
    shooter_data[5 * W + (ox + 11)] = (220, 255, 255, 255) # glint
    
    # Body / Coat (y=10 to 18, x=6 to 14)
    for y in range(10, 19):
        for x in range(6, 15):
            shooter_data[y * W + (ox + x)] = C_COAT
    for y in range(11, 16):
        shooter_data[y * W + (ox + 7)] = C_COAT_L
    
    # Belt / Buckle
    for x in range(6, 15):
        shooter_data[15 * W + (ox + x)] = C_BELT
    shooter_data[15 * W + (ox + 10)] = C_HELM
    shooter_data[15 * W + (ox + 11)] = C_HELM
    
    # Legs (y=19 to 22)
    for y in range(19, 23):
        shooter_data[y * W + (ox + 7)] = C_OUT
        shooter_data[y * W + (ox + 8)] = C_COAT_L
        shooter_data[y * W + (ox + 12)] = C_OUT
        shooter_data[y * W + (ox + 13)] = C_COAT_L
    
    # Boots (y=22 to 23)
    for x in range(6, 9):
        shooter_data[22 * W + (ox + x)] = C_BELT
        shooter_data[23 * W + (ox + x)] = C_OUT
    for x in range(12, 15):
        shooter_data[22 * W + (ox + x)] = C_BELT
        shooter_data[23 * W + (ox + x)] = C_OUT
        
    # Steam Rifle (Held forward pointing right)
    recoil_x = -1 if is_firing else 0
    gun_y = 12
    # Stock
    for x in range(10 + recoil_x, 13 + recoil_x):
        shooter_data[gun_y * W + (ox + x)] = C_GUN_D
    # Barrel extending to x=21
    for x in range(13 + recoil_x, 21 + recoil_x):
        shooter_data[gun_y * W + (ox + x)] = C_GUN
        shooter_data[(gun_y + 1) * W + (ox + x)] = C_GUN_D
    # Pressure Gauge dial on rifle
    shooter_data[(gun_y - 1) * W + (ox + 14 + recoil_x)] = C_HELM
    shooter_data[(gun_y - 1) * W + (ox + 15 + recoil_x)] = (255, 255, 255, 255)
    
    # Muzzle flash / steam puff if firing
    if is_firing:
        # Steam puff at muzzle
        for px in range(21, 24):
            shooter_data[(gun_y - 1) * W + (ox + px)] = C_STEAM
            shooter_data[gun_y * W + (ox + px)] = (255, 240, 180, 255)
            shooter_data[(gun_y + 1) * W + (ox + px)] = C_STEAM

draw_shooter_frame(0, False) # Frame 0: Aim
draw_shooter_frame(24, True) # Frame 1: Fire with steam puff & recoil

make_png(W, H, shooter_data, 'assets/enemies/shooter.png')

# 3. Copy drone frames from Kenney characters into assets/enemies/
shutil.copy('assets/Tiles/Characters/tile_0024.png', 'assets/enemies/drone_0.png')
shutil.copy('assets/Tiles/Characters/tile_0025.png', 'assets/enemies/drone_1.png')
shutil.copy('assets/Tiles/Characters/tile_0026.png', 'assets/enemies/drone_2.png')

# 4. Copy patrol guard frames
shutil.copy('assets/Tiles/Characters/tile_0021.png', 'assets/enemies/patrol_0.png')
shutil.copy('assets/Tiles/Characters/tile_0022.png', 'assets/enemies/patrol_1.png')
shutil.copy('assets/Tiles/Characters/tile_0023.png', 'assets/enemies/patrol_2.png')

print("All enemy graphics generated successfully!")
