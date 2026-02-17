#!/usr/bin/env python3
"""
Simple CLI for Chatterbox TTS

Usage:
    python tts.py "Your text here" [output.wav]

Examples:
    python tts.py "Hello world!" hello.wav
    python tts.py "This is a test"  # saves to output.wav
"""

import sys
import perth
perth.PerthImplicitWatermarker = perth.DummyWatermarker

from chatterbox import ChatterboxTTS
import soundfile as sf

def main():
    if len(sys.argv) < 2:
        print(__doc__)
        sys.exit(1)

    text = sys.argv[1]
    output_file = sys.argv[2] if len(sys.argv) > 2 else "output.wav"

    print(f"🎙️  Loading Chatterbox TTS...")
    tts = ChatterboxTTS.from_pretrained(device='cpu')

    print(f"\n📝 Generating: {output_file}")
    if len(text) > 80:
        print(f"   Text: {text[:77]}...")
    else:
        print(f"   Text: {text}")

    audio_tensor = tts.generate(text=text)
    audio_numpy = audio_tensor.squeeze().cpu().numpy()

    sf.write(output_file, audio_numpy, samplerate=24000)

    duration = len(audio_numpy) / 24000
    print(f"\n✅ Generated: {output_file} ({duration:.2f}s)")
    print(f"🔊 Play with: afplay {output_file}")

if __name__ == "__main__":
    main()
