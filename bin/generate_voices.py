#!/usr/bin/env python3
import os
import subprocess
import yaml
import sys

SOUNDS_DIR = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "sounds")

def main():
    voices_path = os.path.join(os.path.dirname(os.path.dirname(os.path.abspath(__file__))), "docs", "voices.yml")
    with open(voices_path) as f:
        config = yaml.safe_load(f)

    voice = config["voice"]
    sounds = config["sounds"]

    for name, text in sounds.items():
        aiff_path = os.path.join(SOUNDS_DIR, f"{name}.aiff")
        mp3_path = os.path.join(SOUNDS_DIR, f"{name}.mp3")

        if os.path.exists(aiff_path):
            print(f"SKIP: {name}.aiff already exists")
        else:
            print(f"GENERATE: {name}.aiff")
            subprocess.run(["say", "-v", voice, "-o", aiff_path, text], check=True)

        if os.path.exists(mp3_path):
            print(f"SKIP: {name}.mp3 already exists")
            continue

        if not os.path.exists(aiff_path):
            print(f"ERROR: {name}.aiff not found, cannot convert to mp3")
            continue

        print(f"CONVERT: {name}.aiff -> {name}.mp3")
        wav_path = aiff_path.replace(".aiff", ".wav")
        subprocess.run(["afconvert", "-f", "WAVE", "-d", "LEI16", aiff_path, wav_path], check=True)
        subprocess.run(["lame", "-b", "128", wav_path, mp3_path], check=True)
        os.remove(wav_path)

    print("DONE")

if __name__ == "__main__":
    main()
