#!/usr/bin/env python3
"""
Generate narration for each scene in the Remotion video
"""

# Fix for Perth watermarker issue
import perth
perth.PerthImplicitWatermarker = perth.DummyWatermarker

from chatterbox import ChatterboxTTS
import soundfile as sf
import os

# Scene narrations (shorter, scene-specific)
SCENES = {
    "title": "Rails 8.1 Local CI. Standardize your testing workflow.",

    "problem": "Testing inconsistencies between local and CI servers cause frustration and wasted time.",

    "solution": "Rails 8.1 introduces Local CI. One command, everywhere. No duplication.",

    "demo": "Run bin slash ci. Setup, style checks, security audits, and tests execute in sequence with timing.",

    "benefits": "Catch issues early. Same workflow locally and remotely. Faster development cycles.",

    "cta": "Upgrade to Rails 8.1 today and experience standardized CI workflows."
}

def main():
    print("🎙️  Loading Chatterbox TTS...")
    tts = ChatterboxTTS.from_pretrained(device='cpu')

    output_dir = "scene_audio"
    os.makedirs(output_dir, exist_ok=True)

    for scene_name, text in SCENES.items():
        print(f"\n📝 Generating: {scene_name}.wav")
        print(f"   Text: {text}")

        audio_tensor = tts.generate(text=text)
        audio_numpy = audio_tensor.squeeze().cpu().numpy()

        output_file = os.path.join(output_dir, f"{scene_name}.wav")
        sf.write(output_file, audio_numpy, samplerate=24000)

        duration = len(audio_numpy) / 24000
        print(f"   ✅ {duration:.2f}s")

    print(f"\n🎉 All narrations generated in: {output_dir}/")
    print("\n📂 Files created:")
    for scene in SCENES.keys():
        print(f"   - {scene}.wav")

    print("\n💡 Next step: Copy these to your Remotion public folder")
    print(f"   cp {output_dir}/*.wav ../local-ci-video/public/")

if __name__ == "__main__":
    main()
