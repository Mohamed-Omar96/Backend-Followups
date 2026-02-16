# CLAUDE.md — video/

Instructions for Claude Code when working inside the `video/` folder.

> This folder is a multimedia workspace, separate from the Rails app. The Rails CI system (`bin/ci`) does not cover this folder.

## Subprojects

| Folder | Language | Key Command |
|--------|----------|-------------|
| `local-ci-voice/` | Python 3.11 + venv | `source venv/bin/activate && python <script>.py` |
| `local-ci-video/` | Node 18 + Remotion | `npm start` / `npm run build` |

## Rules

1. **Never run `bin/ci` for changes here** — it only covers the Rails app, not these multimedia projects.
2. **Always use the venv** for Python work in `local-ci-voice/`. Do not use system Python.
3. **Do not install global npm packages** in `local-ci-video/` — use `npx` or local `node_modules/.bin/`.
4. **Do not commit** rendered output (`out/`), model caches, or generated `.wav` files unless explicitly asked.
5. **Scope is narrow** — do not refactor the video/voice projects beyond what the current task requires.

## Common Tasks

```bash
# Generate narrations
cd local-ci-voice
source venv/bin/activate
python generate_scene_narrations.py

# Preview video
cd local-ci-video
npm start

# Render video
cd local-ci-video
npm run build
```

## References

- `local-ci-voice/README.md` — TTS setup and usage
- `local-ci-video/README.md` — Remotion project details
- `local-ci-video/AUDIO_INTEGRATION.md` — How to wire audio into video scenes
