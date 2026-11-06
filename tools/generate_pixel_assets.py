#!/usr/bin/env python3
import os
from PIL import Image, ImageDraw

ASSETS_DIR = "assets/sprites"
os.makedirs(ASSETS_DIR, exist_ok=True)

def create_hero():
    # 32x32 Hero Knight
    img = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    
    # Cape (Carmesim)
    d.rectangle([9, 14, 23, 26], fill=(160, 28, 36, 255))
    d.rectangle([10, 26, 22, 28], fill=(120, 20, 28, 255))
    
    # Legs / Greaves
    d.rectangle([11, 23, 14, 29], fill=(70, 75, 85, 255))
    d.rectangle([17, 23, 20, 29], fill=(70, 75, 85, 255))
    d.rectangle([11, 29, 14, 30], fill=(45, 48, 55, 255)) # sabatons
    d.rectangle([17, 29, 20, 30], fill=(45, 48, 55, 255))
    
    # Torso (Steel breastplate)
    d.rectangle([11, 13, 20, 22], fill=(130, 140, 155, 255))
    d.rectangle([13, 15, 18, 20], fill=(170, 180, 195, 255)) # chest shine
    d.line([(11, 22), (20, 22)], fill=(60, 45, 30, 255)) # leather belt
    d.point((15, 22), fill=(220, 180, 40, 255)) # gold buckle
    d.point((16, 22), fill=(220, 180, 40, 255))
    
    # Pauldrons
    d.rectangle([9, 13, 11, 17], fill=(100, 110, 125, 255))
    d.rectangle([20, 13, 22, 17], fill=(100, 110, 125, 255))
    
    # Helmet (Greathelm with visor slit)
    d.rectangle([11, 5, 20, 13], fill=(120, 130, 145, 255))
    d.rectangle([12, 4, 19, 5], fill=(100, 110, 125, 255)) # helmet top
    d.rectangle([12, 6, 15, 8], fill=(160, 170, 185, 255)) # brow shine
    d.rectangle([12, 9, 19, 10], fill=(20, 20, 25, 255)) # visor dark slit
    d.point((14, 9), fill=(255, 215, 50, 255)) # glowing left eye
    d.point((17, 9), fill=(255, 215, 50, 255)) # glowing right eye
    d.line([(15, 4), (16, 4)], fill=(200, 30, 30, 255)) # helmet plume
    d.line([(15, 3), (16, 3)], fill=(220, 40, 40, 255))
    
    # Shield (Left side, heater shield with gold cross)
    d.polygon([(6, 14), (11, 14), (11, 22), (8, 25), (6, 22)], fill=(35, 60, 120, 255))
    d.line([(6, 14), (11, 14)], fill=(210, 175, 40, 255)) # gold border
    d.line([(8, 16), (9, 21)], fill=(210, 175, 40, 255)) # gold emblem
    
    # Sword (Right hand, sheathed/at ready)
    d.line([(22, 16), (22, 18)], fill=(60, 45, 30, 255)) # hilt
    d.line([(20, 18), (24, 18)], fill=(210, 175, 40, 255)) # guard
    d.line([(22, 19), (22, 28)], fill=(210, 220, 235, 255)) # steel blade
    d.point((22, 29), fill=(180, 190, 205, 255)) # tip
    
    img.save(f"{ASSETS_DIR}/hero.png")
    print("Hero sprite created!")

def create_hero_attack():
    # 32x32 Hero Knight Mid-Attack (blade thrust/swing)
    img = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    
    # Cape
    d.rectangle([6, 15, 17, 26], fill=(160, 28, 36, 255))
    # Legs
    d.rectangle([8, 23, 11, 29], fill=(70, 75, 85, 255))
    d.rectangle([14, 23, 17, 29], fill=(70, 75, 85, 255))
    # Torso
    d.rectangle([8, 13, 17, 22], fill=(130, 140, 155, 255))
    d.line([(8, 22), (17, 22)], fill=(60, 45, 30, 255))
    # Head
    d.rectangle([9, 5, 17, 13], fill=(120, 130, 145, 255))
    d.rectangle([10, 9, 17, 10], fill=(20, 20, 25, 255))
    d.point((14, 9), fill=(255, 215, 50, 255))
    d.point((16, 9), fill=(255, 215, 50, 255))
    
    # Extended arm & Forward Sword slash
    d.line([(16, 15), (21, 15)], fill=(120, 130, 145, 255))
    d.line([(21, 13), (21, 17)], fill=(210, 175, 40, 255)) # crossguard
    d.line([(22, 15), (31, 15)], fill=(230, 240, 255, 255)) # shining blade
    d.line([(22, 14), (30, 14)], fill=(180, 220, 255, 200)) # blade glow
    
    img.save(f"{ASSETS_DIR}/hero_attack.png")
    print("Hero attack sprite created!")

def create_slime():
    # 24x24 Slime
    img = Image.new("RGBA", (24, 24), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    
    # Base slime body
    d.ellipse([3, 7, 20, 21], fill=(40, 185, 65, 255))
    d.ellipse([5, 9, 18, 19], fill=(70, 215, 95, 255)) # inner core
    d.ellipse([6, 8, 11, 12], fill=(160, 245, 175, 255)) # highlight top
    
    # Menacing eyes
    d.ellipse([6, 12, 10, 16], fill=(240, 250, 240, 255))
    d.ellipse([13, 12, 17, 16], fill=(240, 250, 240, 255))
    d.ellipse([8, 13, 10, 15], fill=(15, 45, 20, 255)) # pupils looking forward
    d.ellipse([15, 13, 17, 15], fill=(15, 45, 20, 255))
    
    img.save(f"{ASSETS_DIR}/enemy_slime.png")
    print("Slime sprite created!")

def create_skeleton():
    # 32x32 Skeleton Warrior
    img = Image.new("RGBA", (32, 32), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    
    # Legs (Bones)
    d.line([(12, 22), (12, 29)], fill=(215, 210, 195, 255))
    d.line([(19, 22), (19, 29)], fill=(215, 210, 195, 255))
    d.point((11, 29), fill=(180, 175, 160, 255))
    d.point((20, 29), fill=(180, 175, 160, 255))
    
    # Pelvis & Spine
    d.rectangle([12, 20, 19, 21], fill=(190, 185, 170, 255))
    d.line([(15, 14), (15, 20)], fill=(215, 210, 195, 255))
    d.line([(16, 14), (16, 20)], fill=(215, 210, 195, 255))
    
    # Ribcage
    d.line([(12, 15), (19, 15)], fill=(225, 220, 205, 255))
    d.line([(11, 17), (20, 17)], fill=(225, 220, 205, 255))
    d.line([(12, 19), (19, 19)], fill=(200, 195, 180, 255))
    
    # Skull
    d.rectangle([11, 6, 20, 13], fill=(235, 230, 215, 255))
    d.rectangle([13, 12, 18, 14], fill=(215, 210, 195, 255)) # jaw
    # Eye sockets (Glowing crimson/evil red)
    d.rectangle([12, 8, 15, 10], fill=(20, 10, 10, 255))
    d.rectangle([16, 8, 19, 10], fill=(20, 10, 10, 255))
    d.point((13, 9), fill=(255, 30, 30, 255))
    d.point((17, 9), fill=(255, 30, 30, 255))
    d.point((15, 11), fill=(40, 20, 20, 255)) # nasal cavity
    
    # Left Shield (Old wood round shield)
    d.ellipse([5, 13, 12, 23], fill=(95, 60, 35, 255))
    d.ellipse([7, 15, 10, 21], fill=(130, 130, 140, 255)) # iron boss
    
    # Right Sword (Rusted blade)
    d.line([(22, 17), (27, 27)], fill=(155, 110, 80, 255)) # rust
    d.line([(23, 17), (28, 27)], fill=(175, 180, 190, 255)) # edge
    
    img.save(f"{ASSETS_DIR}/enemy_skeleton.png")
    print("Skeleton sprite created!")

def create_necromancer():
    # 36x36 Boss Necromancer
    img = Image.new("RGBA", (36, 36), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    
    # Robes (Deep dark purple/black with gold hem)
    d.polygon([(11, 14), (25, 14), (29, 33), (7, 33)], fill=(32, 20, 48, 255))
    d.rectangle([7, 32, 29, 34], fill=(215, 175, 45, 255)) # gold hem
    d.line([(18, 14), (18, 32)], fill=(185, 145, 35, 255))
    
    # Hood & Shadowy Face
    d.polygon([(11, 13), (18, 4), (25, 13)], fill=(40, 25, 60, 255))
    d.rectangle([13, 9, 23, 14], fill=(10, 5, 15, 255)) # deep shadow inside hood
    # Evil Glowing Eyes
    d.point((15, 11), fill=(255, 40, 60, 255))
    d.point((16, 11), fill=(255, 100, 120, 255))
    d.point((20, 11), fill=(255, 40, 60, 255))
    d.point((21, 11), fill=(255, 100, 120, 255))
    
    # Necromancer Staff (Left side)
    d.line([(6, 6), (6, 32)], fill=(85, 60, 40, 255)) # wooden staff
    # Skull top on staff
    d.ellipse([3, 3, 9, 8], fill=(220, 215, 200, 255))
    d.point((4, 5), fill=(0, 255, 200, 255)) # soul flame eye
    d.point((7, 5), fill=(0, 255, 200, 255))
    d.ellipse([2, 1, 10, 9], outline=(0, 240, 190, 120)) # aura
    
    img.save(f"{ASSETS_DIR}/boss_necromancer.png")
    print("Boss Necromancer sprite created!")

def create_tiles():
    # 64x64 Tileset image:
    # Top-Left (0,0,32,32): Dungeon Stone Wall
    # Top-Right (32,0,64,32): Cobblestone Floor
    # Bottom-Left (0,32,32,64): Mossy Floor
    # Bottom-Right (32,32,64,64): Dungeon Door / Gate
    img = Image.new("RGBA", (64, 64), (0, 0, 0, 255))
    d = ImageDraw.Draw(img)
    
    # 1. Stone Wall (0,0 to 32,32)
    d.rectangle([0, 0, 31, 31], fill=(38, 40, 48, 255))
    for y in range(0, 32, 8):
        d.line([(0, y), (31, y)], fill=(20, 22, 28, 255))
    for x in [8, 24]:
        d.line([(x, 0), (x, 8)], fill=(20, 22, 28, 255))
    for x in [16]:
        d.line([(x, 8), (x, 16)], fill=(20, 22, 28, 255))
    for x in [8, 24]:
        d.line([(x, 16), (x, 24)], fill=(20, 22, 28, 255))
    for x in [16]:
        d.line([(x, 24), (x, 31)], fill=(20, 22, 28, 255))
    # Stone highlights
    d.line([(1, 1), (7, 1)], fill=(55, 58, 70, 255))
    d.line([(9, 9), (15, 9)], fill=(55, 58, 70, 255))
    
    # 2. Cobblestone Floor (32,0 to 64,32)
    d.rectangle([32, 0, 63, 31], fill=(50, 52, 60, 255))
    # Tile mortar grooves
    d.rectangle([32, 0, 47, 15], outline=(35, 36, 42, 255))
    d.rectangle([47, 0, 63, 15], outline=(35, 36, 42, 255))
    d.rectangle([32, 16, 47, 31], outline=(35, 36, 42, 255))
    d.rectangle([47, 16, 63, 31], outline=(35, 36, 42, 255))
    # Pebble dots
    d.point((36, 6), fill=(65, 68, 78, 255))
    d.point((54, 8), fill=(65, 68, 78, 255))
    d.point((40, 22), fill=(65, 68, 78, 255))
    d.point((58, 24), fill=(65, 68, 78, 255))
    
    # 3. Mossy Floor (0,32 to 32,64)
    d.rectangle([0, 32, 31, 63], fill=(48, 52, 54, 255))
    d.rectangle([0, 32, 31, 63], outline=(35, 38, 38, 255))
    # Moss patches (Verde esmeralda escuro)
    d.ellipse([4, 36, 12, 44], fill=(35, 75, 40, 255))
    d.ellipse([18, 48, 26, 56], fill=(40, 85, 45, 255))
    d.point((6, 38), fill=(60, 120, 65, 255))
    d.point((20, 50), fill=(60, 120, 65, 255))
    
    # 4. Dungeon Exit Gate / Stairs (32,32 to 64,64)
    d.rectangle([32, 32, 63, 63], fill=(22, 20, 28, 255))
    for i, offset in enumerate([35, 40, 45, 50, 55]):
        val = 60 + i * 15
        d.rectangle([36, offset, 59, offset + 3], fill=(val, val - 5, val + 10, 255))
    d.rectangle([32, 32, 63, 63], outline=(180, 140, 40, 255), width=2) # Golden arch border
    
    img.save(f"{ASSETS_DIR}/tiles_dungeon.png")
    print("Tileset created!")

def create_props():
    # 64x64 Props Spritesheet:
    # (0,0,16,16): Chest Closed
    # (16,0,32,16): Chest Open
    # (32,0,48,16): Clay Pot
    # (48,0,64,16): Torch
    # (0,16,16,32): Gold Coin
    # (16,16,32,32): Health Potion
    # (32,16,48,32): Mana Potion
    # (48,16,64,32): Soulshot Sparkle
    img = Image.new("RGBA", (64, 64), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    
    # 1. Chest Closed (0,0 to 16,16)
    d.rectangle([2, 4, 13, 13], fill=(110, 65, 30, 255))
    d.rectangle([2, 4, 13, 7], fill=(140, 85, 40, 255)) # lid
    d.line([(2, 7), (13, 7)], fill=(40, 20, 10, 255)) # seam
    d.rectangle([2, 4, 3, 13], fill=(210, 175, 40, 255)) # iron strap left
    d.rectangle([12, 4, 13, 13], fill=(210, 175, 40, 255)) # iron strap right
    d.rectangle([7, 6, 8, 9], fill=(240, 200, 50, 255)) # gold lock
    
    # 2. Chest Open (16,0 to 32,16)
    d.rectangle([18, 7, 29, 14], fill=(80, 45, 20, 255))
    d.rectangle([18, 2, 29, 5], fill=(140, 85, 40, 255)) # open lid
    d.rectangle([19, 6, 28, 8], fill=(255, 220, 60, 255)) # sparkling gold treasure inside!
    
    # 3. Clay Pot (32,0 to 48,16)
    d.ellipse([35, 4, 44, 14], fill=(180, 85, 45, 255))
    d.rectangle([37, 2, 42, 4], fill=(150, 70, 35, 255)) # lip
    d.line([(36, 6), (37, 10)], fill=(215, 120, 75, 255)) # highlight
    
    # 4. Torch (48,0 to 64,16)
    d.rectangle([54, 6, 57, 14], fill=(100, 65, 30, 255)) # wood bracket
    d.ellipse([52, 1, 59, 7], fill=(255, 120, 20, 255)) # outer flame
    d.ellipse([54, 2, 57, 5], fill=(255, 230, 80, 255)) # inner bright flame
    
    # 5. Gold Coin (0,16 to 16,32)
    d.ellipse([4, 19, 12, 27], fill=(235, 185, 30, 255))
    d.ellipse([5, 20, 11, 26], fill=(255, 220, 60, 255))
    d.point((7, 22), fill=(255, 255, 180, 255)) # twinkle
    
    # 6. Health Potion (16,16 to 32,32)
    d.rectangle([22, 18, 25, 20], fill=(140, 100, 60, 255)) # cork
    d.ellipse([19, 21, 28, 30], fill=(225, 30, 45, 255)) # ruby bottle
    d.point((21, 23), fill=(255, 150, 160, 255)) # glass shine
    
    # 7. Mana Potion (32,16 to 48,32)
    d.rectangle([38, 18, 41, 20], fill=(140, 100, 60, 255)) # cork
    d.ellipse([35, 21, 44, 30], fill=(30, 110, 235, 255)) # sapphire bottle
    d.point((37, 23), fill=(160, 200, 255, 255)) # glass shine
    
    # 8. Slash VFX (48,16 to 64,32)
    d.arc([49, 17, 63, 31], start=180, end=300, fill=(230, 245, 255, 255), width=3)
    d.arc([51, 19, 61, 29], start=190, end=290, fill=(130, 210, 255, 200), width=2)
    
    img.save(f"{ASSETS_DIR}/props_spritesheet.png")
    print("Props spritesheet created!")

def create_slash_effect():
    # 48x48 Dynamic Slash Arc
    img = Image.new("RGBA", (48, 48), (0, 0, 0, 0))
    d = ImageDraw.Draw(img)
    # Arc of steel energy
    d.arc([4, 4, 44, 44], start=160, end=330, fill=(255, 255, 255, 255), width=4)
    d.arc([6, 6, 42, 42], start=170, end=320, fill=(100, 200, 255, 220), width=2)
    d.arc([2, 2, 46, 46], start=165, end=310, fill=(40, 140, 255, 120), width=1)
    img.save(f"{ASSETS_DIR}/slash_effect.png")
    print("Slash VFX created!")

if __name__ == "__main__":
    create_hero()
    create_hero_attack()
    create_slime()
    create_skeleton()
    create_necromancer()
    create_tiles()
    create_props()
    create_slash_effect()
    print("All pixel art assets generated successfully!")
