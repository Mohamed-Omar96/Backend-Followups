# Audio Integration with Chatterbox TTS

This video now includes AI-generated narration using Chatterbox TTS!

## 🎙️ Audio Files

All narration audio files are in `public/`:

- `title.wav` (3.44s) - Scene 1: Title
- `problem.wav` (4.52s) - Scene 2: Problem
- `solution.wav` (4.68s) - Scene 3: Solution
- `demo.wav` (6.64s) - Scene 4: Demo
- `benefits.wav` (4.84s) - Scene 5: Benefits
- `cta.wav` (4.36s) - Scene 6: CTA

## 🔊 How It Works

Each scene has synchronized narration using Remotion's `<Audio>` component:

```tsx
<Audio src={staticFile('title.wav')} startFrom={0} volume={0.8} />
<Audio src={staticFile('problem.wav')} startFrom={120} volume={0.8} />
// ... etc
```

- **`startFrom`**: Frame number when audio should start
- **`volume`**: Volume level (0.0 to 1.0)
- **`staticFile()`**: Loads from `public/` folder

## 🎬 Preview & Render

### Preview with audio:
```bash
npm start
# Opens http://localhost:3000 with audio playback
```

### Render video with audio:
```bash
# Render as MP4
npm run build

# Or use Remotion CLI
npx remotion render Video out/video.mp4

# Render specific frame range
npx remotion render Video out/video.mp4 --frames=0-500
```

## 🛠️ Regenerating Audio

To regenerate narrations:

```bash
cd ../local-ci-voice
source venv/bin/activate

# Edit text in generate_scene_narrations.py
python generate_scene_narrations.py

# Copy to Remotion
cp scene_audio/*.wav ../local-ci-video/public/
```

## 🎚️ Audio Adjustments

### Volume Control

Adjust individual scene volumes:
```tsx
<Audio src={staticFile('title.wav')} volume={1.0} />  // Full volume
<Audio src={staticFile('demo.wav')} volume={0.6} />   // Quieter
```

### Timing Adjustments

Adjust when audio starts (in frames):
```tsx
<Audio src={staticFile('title.wav')} startFrom={10} />  // Start 10 frames in
```

### Audio Duration

Audio files automatically stop when they end. To loop or trim:
```tsx
<Audio
  src={staticFile('title.wav')}
  startFrom={0}
  endAt={90}  // Stop at frame 90
/>
```

## 📊 Scene Timing Reference

| Scene | Start Frame | Duration | Audio File |
|-------|-------------|----------|------------|
| Title | 0 | 120 (4s) | title.wav (3.44s) |
| Problem | 120 | 210 (7s) | problem.wav (4.52s) |
| Solution | 330 | 210 (7s) | solution.wav (4.68s) |
| Demo | 540 | 480 (16s) | demo.wav (6.64s) |
| Benefits | 1020 | 240 (8s) | benefits.wav (4.84s) |
| CTA | 1260 | 150 (5s) | cta.wav (4.36s) |

Total: 1410 frames = 47 seconds @ 30fps

## 🎵 Adding Background Music

To add background music alongside narration:

```tsx
{/* Background music (lower volume) */}
<Audio src={staticFile('background_music.mp3')} volume={0.2} />

{/* Narration (higher volume on top) */}
<Audio src={staticFile('title.wav')} volume={0.8} />
```

## 🔧 Troubleshooting

**Audio not playing?**
- Check files exist in `public/` folder
- Verify audio format is supported (.wav, .mp3, .m4a)
- Check browser console for errors

**Audio out of sync?**
- Adjust `startFrom` values
- Ensure frame rates match (30fps)
- Check audio file durations

**Audio too loud/quiet?**
- Adjust `volume` prop (0.0 - 1.0)
- Or normalize audio files using ffmpeg:
  ```bash
  ffmpeg -i input.wav -af "loudnorm" output.wav
  ```

## 📚 Resources

- [Remotion Audio Docs](https://www.remotion.dev/docs/audio)
- [Chatterbox TTS](https://github.com/resemble-ai/chatterbox)
- [Audio Timing Calculator](https://www.remotion.dev/docs/miscellaneous/snippets/audio-visualization)
