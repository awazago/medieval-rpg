#!/usr/bin/env python3
"""
Generates retro 16-bit sound effects (WAV) for the 2D Dungeon Crawler.
Uses standard Python library (wave, struct, math, random).
"""
import wave
import struct
import math
import random
import os

OUTPUT_DIR = "assets/audio"
SAMPLE_RATE = 44100

def write_wav(filename, samples):
    os.makedirs(OUTPUT_DIR, exist_ok=True)
    filepath = os.path.join(OUTPUT_DIR, filename)
    with wave.open(filepath, 'w') as wav:
        wav.setnchannels(1)  # Mono
        wav.setsampwidth(2)  # 16-bit
        wav.setframerate(SAMPLE_RATE)
        packed = bytearray()
        for s in samples:
            # Clamp to 16-bit signed range
            val = max(-32767, min(32767, int(s * 32767.0)))
            packed.extend(struct.pack('<h', val))
        wav.writeframes(packed)
    print(f"Generated {filepath} ({len(samples)} samples)")

def gen_slash():
    # Fast frequency drop with white noise burst
    duration = 0.16
    n = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        progress = i / n
        env = (1.0 - progress) ** 1.5
        freq = 900.0 * (1.0 - progress * 0.8)
        sine = math.sin(2.0 * math.pi * freq * t)
        noise = random.uniform(-0.5, 0.5) * (1.0 - progress)
        s = (sine * 0.4 + noise * 0.6) * env * 0.7
        samples.append(s)
    return samples

def gen_hit_enemy():
    # Punchy low impact + crunch
    duration = 0.18
    n = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(n):
        progress = i / n
        env = math.exp(-progress * 15.0)
        freq = 240.0 * (1.0 - progress * 0.7)
        sine = math.sin(2.0 * math.pi * freq * (i / SAMPLE_RATE))
        noise = random.uniform(-1.0, 1.0) * math.exp(-progress * 25.0)
        s = (sine * 0.6 + noise * 0.4) * env * 0.85
        samples.append(s)
    return samples

def gen_hit_player():
    # Heavy thud
    duration = 0.25
    n = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(n):
        progress = i / n
        env = math.exp(-progress * 10.0)
        freq = 150.0 * (1.0 - progress * 0.5)
        sine = math.sin(2.0 * math.pi * freq * (i / SAMPLE_RATE))
        noise = random.uniform(-0.8, 0.8) * math.exp(-progress * 20.0)
        s = (sine * 0.7 + noise * 0.3) * env * 0.9
        samples.append(s)
    return samples

def gen_dash():
    # Whoosh wind sound
    duration = 0.2
    n = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(n):
        progress = i / n
        # Envelope rises then falls
        env = math.sin(progress * math.pi)
        noise = random.uniform(-1.0, 1.0)
        # Filtered-like sweep
        freq = 400.0 + 800.0 * progress
        sine = math.sin(2.0 * math.pi * freq * (i / SAMPLE_RATE))
        s = (noise * 0.7 + sine * 0.3) * env * 0.5
        samples.append(s)
    return samples

def gen_coin():
    # Two crisp crystal bell tones: B5 (987Hz) to E6 (1318Hz)
    duration = 0.28
    n = int(SAMPLE_RATE * duration)
    samples = []
    split = int(n * 0.35)
    for i in range(n):
        if i < split:
            t = i / SAMPLE_RATE
            freq = 987.77
            env = math.exp(-(i / split) * 3.0)
        else:
            t = (i - split) / SAMPLE_RATE
            freq = 1318.51
            env = math.exp(-((i - split) / (n - split)) * 4.0)
        sine = math.sin(2.0 * math.pi * freq * t)
        harmonic = math.sin(2.0 * math.pi * freq * 2.0 * t) * 0.3
        s = (sine + harmonic) * env * 0.5
        samples.append(s)
    return samples

def gen_potion():
    # Magical shimmer ascending
    duration = 0.35
    n = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(n):
        progress = i / n
        env = math.sin(progress * math.pi) * 0.8
        freq = 440.0 + 660.0 * (progress ** 1.5)
        sine = math.sin(2.0 * math.pi * freq * (i / SAMPLE_RATE))
        vibrato = math.sin(2.0 * math.pi * 15.0 * (i / SAMPLE_RATE)) * 20.0
        sine2 = math.sin(2.0 * math.pi * (freq + vibrato) * 1.5 * (i / SAMPLE_RATE)) * 0.3
        s = (sine + sine2) * env * 0.6
        samples.append(s)
    return samples

def gen_pot_break():
    # Ceramic smash
    duration = 0.22
    n = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(n):
        progress = i / n
        env = math.exp(-progress * 18.0)
        noise = random.uniform(-1.0, 1.0)
        t = i / SAMPLE_RATE
        high_ring = math.sin(2.0 * math.pi * 1800.0 * t) * math.exp(-progress * 25.0)
        s = (noise * 0.7 + high_ring * 0.3) * env * 0.8
        samples.append(s)
    return samples

def gen_chest_open():
    # Creak + sparkling chime
    duration = 0.45
    n = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(n):
        progress = i / n
        t = i / SAMPLE_RATE
        if progress < 0.4:
            # Wooden creak
            env = math.sin((progress / 0.4) * math.pi)
            freq = 180.0 + random.uniform(-30, 30)
            s = math.sin(2.0 * math.pi * freq * t) * env * 0.5
        else:
            # Chime
            p2 = (progress - 0.4) / 0.6
            env = math.exp(-p2 * 4.0)
            chime = math.sin(2.0 * math.pi * 1174.66 * t) + 0.5 * math.sin(2.0 * math.pi * 1760.0 * t)
            s = chime * env * 0.6
        samples.append(s)
    return samples

def gen_level_up():
    # Glorious 4-note ascending fanfare: C5, E5, G5, C6
    notes = [523.25, 659.25, 783.99, 1046.50]
    duration_per_note = 0.12
    samples = []
    for idx, freq in enumerate(notes):
        n = int(SAMPLE_RATE * (duration_per_note if idx < 3 else duration_per_note * 2.5))
        for i in range(n):
            t = i / SAMPLE_RATE
            p = i / n
            env = math.exp(-p * (3.0 if idx < 3 else 1.5))
            sine = math.sin(2.0 * math.pi * freq * t)
            harm = math.sin(2.0 * math.pi * freq * 2.0 * t) * 0.25
            samples.append((sine + harm) * env * 0.55)
    return samples

def gen_spell_cast():
    # Dark magic zap
    duration = 0.3
    n = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(n):
        progress = i / n
        env = (1.0 - progress) ** 1.2
        freq = 700.0 - 450.0 * progress + math.sin(progress * 40.0) * 100.0
        sine = math.sin(2.0 * math.pi * freq * (i / SAMPLE_RATE))
        noise = random.uniform(-0.3, 0.3)
        s = (sine * 0.7 + noise * 0.3) * env * 0.7
        samples.append(s)
    return samples

def gen_boss_roar():
    # Deep intimidating monster rumble
    duration = 0.6
    n = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(n):
        progress = i / n
        env = math.sin(progress * math.pi) ** 0.8
        freq = 90.0 + math.sin(progress * 12.0) * 30.0
        sine = math.sin(2.0 * math.pi * freq * (i / SAMPLE_RATE))
        noise = random.uniform(-0.6, 0.6)
        s = (sine * 0.6 + noise * 0.4) * env * 0.85
        samples.append(s)
    return samples

def gen_ambient_loop():
    # 4-second atmospheric ambient dungeon drone
    duration = 4.0
    n = int(SAMPLE_RATE * duration)
    samples = []
    for i in range(n):
        t = i / SAMPLE_RATE
        # Low drone around 55 Hz (A1) and 82.4 Hz (E2) with slow phase modulation
        drone1 = math.sin(2.0 * math.pi * 55.0 * t) * 0.4
        drone2 = math.sin(2.0 * math.pi * 82.4 * t) * 0.25
        drone3 = math.sin(2.0 * math.pi * 110.0 * t + math.sin(t * 0.5)) * 0.15
        sub = math.sin(2.0 * math.pi * 27.5 * t) * 0.2
        # Gentle breath/reverb noise
        noise = random.uniform(-0.04, 0.04) * (0.8 + 0.2 * math.sin(t * 2.0))
        # Ensure smooth loop endpoints with gentle window
        loop_window = 1.0
        if i < 4410:
            loop_window = i / 4410.0
        elif i > n - 4410:
            loop_window = (n - i) / 4410.0
        s = (drone1 + drone2 + drone3 + sub + noise) * 0.45 * loop_window
        samples.append(s)
    return samples

def main():
    print("Synthesizing retro game sound effects...")
    write_wav("slash.wav", gen_slash())
    write_wav("hit_enemy.wav", gen_hit_enemy())
    write_wav("hit_player.wav", gen_hit_player())
    write_wav("dash.wav", gen_dash())
    write_wav("coin.wav", gen_coin())
    write_wav("potion.wav", gen_potion())
    write_wav("pot_break.wav", gen_pot_break())
    write_wav("chest_open.wav", gen_chest_open())
    write_wav("level_up.wav", gen_level_up())
    write_wav("spell_cast.wav", gen_spell_cast())
    write_wav("boss_roar.wav", gen_boss_roar())
    write_wav("ambient_drone.wav", gen_ambient_loop())
    print("All audio files generated successfully!")

if __name__ == "__main__":
    main()
