# Local CI Video Assets

This folder contains the multimedia assets for showcasing Rails 8.1 Local CI.

## Structure

```
video/
├── local-ci-video/   # Remotion video project (React-based video rendering)
├── local-ci-voice/   # Chatterbox TTS narration generator (Python)
├── README.md         # This file
├── AGENTS.md         # AI assistant guidelines for this folder
└── CLAUDE.md         # Claude Code instructions for this folder
```

## Subprojects

### `local-ci-video/`

A Remotion project that renders a 30-second promotional video demonstrating Rails 8.1 Local CI. Built with React + TypeScript.

```bash
cd local-ci-video
npm install
npm start        # Open Remotion Studio
npm run build    # Render to out/video.mp4
```

### `local-ci-voice/`

Python TTS pipeline using Chatterbox TTS to generate narration audio for the video scenes.

```bash
cd local-ci-voice
source venv/bin/activate
python generate_scene_narrations.py   # Generate all scene audio
deactivate
```

## Workflow

1. **Generate narration audio** — run scripts in `local-ci-voice/` to produce `.wav` files per scene
2. **Integrate audio** — copy `.wav` files into `local-ci-video/public/` (see `local-ci-video/AUDIO_INTEGRATION.md`)
3. **Preview video** — `npm start` in `local-ci-video/`
4. **Render final video** — `npm run build` in `local-ci-video/`
