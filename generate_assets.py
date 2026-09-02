import os
from PIL import Image, ImageDraw, ImageFilter, ImageEnhance

base_dir = r"C:\Users\ITcenter\WorldOfAzathoth\assets\sprites"
os.makedirs(os.path.join(base_dir, "player"), exist_ok=True)
os.makedirs(os.path.join(base_dir, "enemies"), exist_ok=True)
os.makedirs(os.path.join(base_dir, "tilesets"), exist_ok=True)
os.makedirs(os.path.join(base_dir, "backgrounds"), exist_ok=True)

# 1. PLAYER SPRITE SHEET (32x64 frame, 4 frames for idle/run)
def create_player_spritesheet():
    img = Image.new("RGBA", (128, 64), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    for i in range(4):
        x = i * 32
        # Body armor (Dark Blue/Grey steel)
        draw.rectangle([x+10, 24, x+22, 50], fill=(40, 45, 60, 255), outline=(15, 20, 30, 255))
        # Cape (Deep Violet)
        draw.polygon([(x+8, 26), (x+4, 58 + (i%2)*2), (x+14, 52)], fill=(70, 20, 90, 255))
        # Head / Helmet (Silver)
        draw.rectangle([x+11, 12, x+21, 24], fill=(160, 175, 200, 255), outline=(30, 40, 60, 255))
        # Glowing Visor (Cyan Nightmare Light)
        draw.rectangle([x+13, 16, x+19, 18], fill=(0, 230, 255, 255))
        # Glowing Sword (Rune Blade)
        sword_y = 20 + (i % 2) * 2
        draw.rectangle([x+22, sword_y, x+25, sword_y+26], fill=(0, 255, 200, 255))
        draw.polygon([(x+23.5, sword_y-6), (x+21, sword_y), (x+26, sword_y)], fill=(200, 255, 240, 255))
        # Legs
        draw.rectangle([x+11, 50, x+15, 62 - (i%2)*3], fill=(20, 25, 35, 255))
        draw.rectangle([x+17, 50, x+21, 62 - ((i+1)%2)*3], fill=(20, 25, 35, 255))

    img.save(os.path.join(base_dir, "player", "player_sheet.png"))
    print("Player spritesheet created.")

# 2. ENEMY SPRITE SHEETS
def create_enemy_spritesheets():
    # Dreamling (Small Nightmare Shadow)
    img1 = Image.new("RGBA", (128, 32), (0, 0, 0, 0))
    draw1 = ImageDraw.Draw(img1)
    for i in range(4):
        x = i * 32
        # Shadow Body (Dark Purple Fog)
        draw1.ellipse([x+6, 6, x+26, 28], fill=(30, 10, 40, 230), outline=(80, 20, 100, 255))
        # Red Glowing Eyes
        draw1.rectangle([x+11, 12, x+14, 15], fill=(255, 30, 30, 255))
        draw1.rectangle([x+18, 12, x+21, 15], fill=(255, 30, 30, 255))
        # Claws
        draw1.line([(x+4, 22), (x+10, 28)], fill=(120, 40, 150, 255), width=2)
        draw1.line([(x+28, 22), (x+22, 28)], fill=(120, 40, 150, 255), width=2)
    img1.save(os.path.join(base_dir, "enemies", "dreamling_sheet.png"))

    # Mirror Husk (Corrupted Reflection)
    img2 = Image.new("RGBA", (128, 64), (0, 0, 0, 0))
    draw2 = ImageDraw.Draw(img2)
    for i in range(4):
        x = i * 32
        # Glassy Broken Body
        draw2.polygon([(x+16, 8), (x+26, 24), (x+20, 56), (x+10, 40)], fill=(180, 220, 240, 180), outline=(255, 255, 255, 255))
        # Cracks
        draw2.line([(x+16, 8), (x+20, 30)], fill=(40, 80, 120, 255), width=1)
        # Empty Void Eye
        draw2.ellipse([x+14, 16, x+20, 24], fill=(10, 10, 15, 255))
    img2.save(os.path.join(base_dir, "enemies", "mirror_husk_sheet.png"))
    print("Enemy spritesheets created.")

# 3. TILESET (Dark Surreal Gothic Gold & Stone Tileset)
def create_tileset():
    # 128x128 tileset (4x4 tiles of 32x32)
    img = Image.new("RGBA", (128, 128), (0, 0, 0, 0))
    draw = ImageDraw.Draw(img)
    
    # Tile 1: Top Platform Tile (Golden Carved Stone)
    draw.rectangle([0, 0, 32, 32], fill=(45, 40, 55, 255))
    draw.rectangle([0, 0, 32, 6], fill=(210, 170, 60, 255)) # Gold top rim
    draw.line([(0, 6), (32, 6)], fill=(255, 230, 120, 255), width=1)
    # Engravings
    draw.rectangle([6, 12, 12, 24], fill=(30, 25, 40, 255), outline=(140, 110, 40, 255))
    draw.rectangle([20, 12, 26, 24], fill=(30, 25, 40, 255), outline=(140, 110, 40, 255))
    
    # Tile 2: Dirt / Solid Inner Block
    draw.rectangle([32, 0, 64, 32], fill=(25, 20, 35, 255))
    draw.line([(32, 0), (64, 0)], fill=(40, 35, 55, 255))
    draw.rectangle([40, 8, 56, 24], fill=(18, 15, 25, 255))

    # Tile 3: Decorative Pillar Top
    draw.rectangle([64, 0, 96, 32], fill=(50, 45, 65, 255))
    draw.polygon([(64, 0), (96, 0), (90, 10), (70, 10)], fill=(220, 180, 50, 255))
    
    img.save(os.path.join(base_dir, "tilesets", "pride_palace_tileset.png"))
    print("Tileset created.")

create_player_spritesheet()
create_enemy_spritesheets()
create_tileset()
