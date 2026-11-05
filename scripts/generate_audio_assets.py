#!/usr/bin/env python3
"""
Gerador de Trilha Sonora Medieval e Efeitos Sonoros (SFX) para Godot 4
Sintetiza trilhas orquestradas medievais em loop e efeitos sonoros com qualidade 44.1kHz 16-bit.
"""
import math
import os
import struct
import wave

AUDIO_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "audio")
MUSIC_DIR = os.path.join(AUDIO_DIR, "music")
SFX_DIR = os.path.join(AUDIO_DIR, "sfx")

SAMPLE_RATE = 44100

def write_wav(file_path, samples):
    """Escreve um arquivo WAV mono de 16-bit com normalização suave."""
    max_val = max(abs(s) for s in samples) if samples else 1.0
    if max_val == 0: max_val = 1.0
    scale = 32000.0 / max_val
    
    with wave.open(file_path, "wb") as wav_file:
        wav_file.setnchannels(1)
        wav_file.setsampwidth(2)
        wav_file.setframerate(SAMPLE_RATE)
        
        packed = bytearray()
        for s in samples:
            val = int(clamp(s * scale, -32767, 32767))
            packed.extend(struct.pack("<h", val))
        wav_file.writeframes(packed)
    print(f" -> Arquivo de áudio gerado com sucesso: {os.path.basename(file_path)}")

def clamp(v, low, high):
    return max(low, min(v, high))

# ----------------- GERADORES DE SFX -----------------

def gen_soulshot_activate():
    """Som cintilante de ativação de Soulshots (sweep ascendente com harmônicos de cristal)."""
    duration = 0.55
    total_samples = int(SAMPLE_RATE * duration)
    samples = []
    
    for i in range(total_samples):
        t = i / SAMPLE_RATE
        env = (1.0 - (t / duration)) ** 1.5
        # Frequência sobe de 400Hz para 1600Hz
        freq = 400.0 + (1200.0 * (t / duration) ** 2)
        s1 = math.sin(2.0 * math.pi * freq * t)
        s2 = 0.5 * math.sin(2.0 * math.pi * (freq * 2.02) * t)
        s3 = 0.25 * math.sin(2.0 * math.pi * (freq * 3.01) * t)
        samples.append((s1 + s2 + s3) * env)
    return samples

def gen_soulshot_hit():
    """Impacto estrondoso clássico do golpe com Soulshot (punch grave + estilhaço brilhante)."""
    duration = 0.75
    total_samples = int(SAMPLE_RATE * duration)
    samples = []
    
    for i in range(total_samples):
        t = i / SAMPLE_RATE
        # Decay rápido
        env = math.exp(-t * 8.0)
        # Punch grave de 95Hz descendo para 35Hz
        bass_freq = max(35.0, 95.0 - (t * 120.0))
        bass = math.sin(2.0 * math.pi * bass_freq * t) * 1.5
        # Ruído metálico de estilhaço cortante
        noise = (math.sin(t * 14201.2) * math.cos(t * 22104.5)) * math.exp(-t * 22.0)
        # Brilho cortante
        shimmer = math.sin(2.0 * math.pi * 880.0 * t) * math.exp(-t * 12.0)
        samples.append((bass + noise * 0.8 + shimmer * 0.5) * env)
    return samples

def gen_level_up():
    """Fanfarra triunfante mágica de Level Up (Arpeggio ascendente dourado C-E-G-C-E)."""
    notes = [261.63, 329.63, 392.00, 523.25, 659.25, 783.99, 1046.50]
    duration_per_note = 0.16
    tail = 0.8
    total_duration = (len(notes) * duration_per_note) + tail
    total_samples = int(SAMPLE_RATE * total_duration)
    samples = [0.0] * total_samples
    
    for note_idx, freq in enumerate(notes):
        start_sample = int(note_idx * duration_per_note * SAMPLE_RATE)
        note_len = int((duration_per_note + 0.6) * SAMPLE_RATE)
        
        for i in range(note_len):
            idx = start_sample + i
            if idx >= total_samples: break
            t = i / SAMPLE_RATE
            env = math.exp(-t * 4.5)
            s1 = math.sin(2.0 * math.pi * freq * t)
            s2 = 0.4 * math.sin(2.0 * math.pi * (freq * 2.0) * t)
            s3 = 0.2 * math.sin(2.0 * math.pi * (freq * 3.0) * t)
            samples[idx] += (s1 + s2 + s3) * env * 0.45
            
    return samples

def gen_sword_swing():
    """Corte ágil de espada no ar."""
    duration = 0.28
    total_samples = int(SAMPLE_RATE * duration)
    samples = []
    
    for i in range(total_samples):
        t = i / SAMPLE_RATE
        env = math.sin(math.pi * (t / duration)) ** 2
        # Ruído filtrado dinâmico
        noise = (math.sin(t * 9871.2) * math.sin(t * 14201.5))
        freq = 300.0 + (450.0 * (1.0 - abs(t - 0.14) / 0.14))
        tone = math.sin(2.0 * math.pi * freq * t)
        samples.append((noise * 0.6 + tone * 0.4) * env)
    return samples

def gen_magic_cast():
    """Zumbido de conjuração mágica elemental."""
    duration = 0.9
    total_samples = int(SAMPLE_RATE * duration)
    samples = []
    
    for i in range(total_samples):
        t = i / SAMPLE_RATE
        env = math.sin(math.pi * (t / duration))
        lfo = 1.0 + 0.25 * math.sin(2.0 * math.pi * 6.5 * t)
        s1 = math.sin(2.0 * math.pi * 220.0 * lfo * t)
        s2 = 0.5 * math.sin(2.0 * math.pi * 440.0 * lfo * t)
        s3 = 0.3 * math.sin(2.0 * math.pi * 660.0 * lfo * t)
        samples.append((s1 + s2 + s3) * env * 0.5)
    return samples

def gen_coins_pickup():
    """Tilintar metálico brilhante de moedas de ouro (Adena)."""
    duration = 0.35
    total_samples = int(SAMPLE_RATE * duration)
    samples = [0.0] * total_samples
    
    clinks = [(0.0, 1975.5), (0.07, 2489.0), (0.13, 3135.9)]
    for delay, freq in clinks:
        start_i = int(delay * SAMPLE_RATE)
        for i in range(int(0.2 * SAMPLE_RATE)):
            idx = start_i + i
            if idx >= total_samples: break
            t = i / SAMPLE_RATE
            env = math.exp(-t * 22.0)
            samples[idx] += math.sin(2.0 * math.pi * freq * t) * env * 0.5
    return samples

# ----------------- GERADORES DE MÚSICA -----------------

def gen_medieval_track(title, chord_progression, melody_notes, bpm=72):
    """Gera uma trilha orquestrada medieval em loop (Acordes suaves + Harpa/Flauta arpejada)."""
    beat_sec = 60.0 / bpm
    bar_sec = beat_sec * 4.0
    total_duration = len(chord_progression) * bar_sec
    total_samples = int(SAMPLE_RATE * total_duration)
    samples = [0.0] * total_samples
    
    # 1. Base harmônica de cordas e drones profundos
    for bar_idx, chord in enumerate(chord_progression):
        start_bar = int(bar_idx * bar_sec * SAMPLE_RATE)
        bar_len = int(bar_sec * SAMPLE_RATE)
        
        for i in range(bar_len):
            idx = start_bar + i
            if idx >= total_samples: break
            t = (start_bar + i) / SAMPLE_RATE
            # Envelope suave entre compassos
            env = math.sin(math.pi * (i / bar_len)) ** 0.5
            
            chord_signal = 0.0
            for note_freq in chord:
                # Fundamental + harmônico suave
                s = math.sin(2.0 * math.pi * note_freq * t) + 0.35 * math.sin(2.0 * math.pi * (note_freq * 2.0) * t)
                chord_signal += s * 0.15
            samples[idx] += chord_signal * env
            
    # 2. Melodia de Harpa/Flauta
    note_duration = beat_sec * 0.5
    for m_idx, (m_bar, beat_offset, freq) in enumerate(melody_notes):
        start_time = (m_bar * bar_sec) + (beat_offset * beat_sec)
        start_sample = int(start_time * SAMPLE_RATE)
        note_samples = int(note_duration * 1.8 * SAMPLE_RATE)
        
        for i in range(note_samples):
            idx = start_sample + i
            if idx >= total_samples: break
            t = i / SAMPLE_RATE
            # Envelope de dedilhado com ressonância
            env = math.exp(-t * 3.5)
            tone = math.sin(2.0 * math.pi * freq * t) + 0.4 * math.sin(2.0 * math.pi * (freq * 2.01) * t)
            samples[idx] += tone * env * 0.28
            
    # Normalização e crossfade perfeito de loop
    fade_len = int(SAMPLE_RATE * 0.4)
    for i in range(fade_len):
        factor = i / float(fade_len)
        samples[i] = (samples[i] * factor) + (samples[total_samples - fade_len + i] * (1.0 - factor))
    samples = samples[:-fade_len]
    return samples

def build_all_audio():
    print("=== Iniciando Síntese da Trilha Sonora e Efeitos de Áudio de Aethelgard ===")
    
    # SFX
    write_wav(os.path.join(SFX_DIR, "soulshot_activate.wav"), gen_soulshot_activate())
    write_wav(os.path.join(SFX_DIR, "soulshot_hit.wav"), gen_soulshot_hit())
    write_wav(os.path.join(SFX_DIR, "level_up.wav"), gen_level_up())
    write_wav(os.path.join(SFX_DIR, "sword_swing.wav"), gen_sword_swing())
    write_wav(os.path.join(SFX_DIR, "magic_cast.wav"), gen_magic_cast())
    write_wav(os.path.join(SFX_DIR, "coins_pickup.wav"), gen_coins_pickup())
    
    # 1. Trilha da Vila de Highstone (Tema de Serenidade Medieval Dórico)
    chords_village = [
        [146.83, 220.0, 261.63], # Dm (D, A, C)
        [174.61, 261.63, 329.63], # F (F, C, E)
        [196.00, 293.66, 349.23], # G (G, D, F)
        [146.83, 220.0, 293.66]  # Dm (D, A, D)
    ]
    melody_village = [
        (0, 0.0, 293.66), (0, 1.0, 329.63), (0, 2.0, 349.23), (0, 3.0, 440.00),
        (1, 0.0, 523.25), (1, 2.0, 440.00), (1, 3.0, 392.00),
        (2, 0.0, 392.00), (2, 1.5, 440.00), (2, 2.5, 523.25),
        (3, 0.0, 440.00), (3, 2.0, 293.66)
    ]
    write_wav(os.path.join(MUSIC_DIR, "dawn_isle_village.wav"), gen_medieval_track("Dawn Isle Village", chords_village, melody_village, bpm=68))
    
    # 2. Trilha da Cripta Esquecida (Tema Sombrio e Eclético)
    chords_crypt = [
        [110.0, 164.81, 220.0],  # Am (A, E, A)
        [103.83, 155.56, 207.65], # G#m (Tensão cromática)
        [110.0, 164.81, 261.63],  # Am (A, E, C)
        [98.0, 146.83, 196.0]     # G drone
    ]
    melody_crypt = [
        (0, 0.0, 220.0), (0, 2.5, 207.65),
        (1, 1.0, 246.94), (1, 2.5, 220.0),
        (2, 0.0, 329.63), (2, 2.0, 311.13),
        (3, 1.0, 220.0), (3, 3.0, 164.81)
    ]
    write_wav(os.path.join(MUSIC_DIR, "ancient_crypt.wav"), gen_medieval_track("Ancient Crypt", chords_crypt, melody_crypt, bpm=52))
    
    # 3. Trilha de Batalha de Raid Boss Valthor (Percussão de Guerra e Tensão)
    chords_boss = [
        [73.42, 110.0, 146.83],  # Low D Power
        [87.31, 130.81, 174.61], # Low F Power
        [65.41, 98.0, 130.81],   # Low C Power
        [82.41, 123.47, 164.81]  # Low E Power
    ]
    melody_boss = [
        (0, 0.0, 146.83), (0, 0.5, 146.83), (0, 1.0, 174.61), (0, 2.0, 220.00), (0, 3.0, 196.00),
        (1, 0.0, 174.61), (1, 1.0, 220.00), (1, 2.0, 261.63), (1, 3.0, 246.94),
        (2, 0.0, 196.00), (2, 1.0, 174.61), (2, 2.0, 164.81), (2, 3.0, 146.83),
        (3, 0.0, 164.81), (3, 1.5, 196.00), (3, 2.5, 220.00), (3, 3.5, 293.66)
    ]
    write_wav(os.path.join(MUSIC_DIR, "boss_valthor_battle.wav"), gen_medieval_track("Boss Valthor Battle", chords_boss, melody_boss, bpm=118))
    print("=== Concluída a geração de todos os arquivos de áudio ===")

if __name__ == "__main__":
    build_all_audio()
