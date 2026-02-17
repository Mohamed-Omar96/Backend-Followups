# AGENTS.md — video/

Guidelines for AI assistants working in the `video/` folder.

## Folder Purpose

This folder is a self-contained multimedia workspace for the Rails 8.1 Local CI demo video. It is **not** part of the Rails application — changes here have no effect on `bin/ci`, tests, or the main app.

## Subproject Boundaries

### `local-ci-voice/` (Python / Chatterbox TTS)
- Python 3.11 with `venv` — always activate before running scripts: `source venv/bin/activate`
- Do not install packages globally; use `pip install` inside the venv
- Generated audio files (`.wav`) go in `scene_audio/`
- The Perth watermarker bug requires this fix at the top of every script:
  ```python
  import perth
  perth.PerthImplicitWatermarker = perth.DummyWatermarker
  ```

### `local-ci-video/` (Node.js / Remotion)
- Node 18+ required; use `npm` (not yarn/bun) — `package-lock.json` is committed
- Remotion Studio: `npm start` | Render: `npm run build`
- Scene components live in `src/scenes/`; shared config in `src/Video.tsx` and `src/Root.tsx`
- Audio files referenced via `staticFile()` must be placed in `public/`

## Task Patterns

| Task | Approach |
|------|----------|
| Add/edit narration text | Edit the relevant `generate_*.py` in `local-ci-voice/` and re-run |
| Adjust scene timing | Edit `Sequence` `durationInFrames` in `local-ci-video/src/Video.tsx` |
| Add a new scene | Create `src/scenes/NewScene.tsx`, register in `src/Video.tsx` |
| Integrate audio into video | Copy `.wav` to `local-ci-video/public/` and add `<Audio>` component |
| Render final video | `cd local-ci-video && npm run build` |

## Conventions

- Keep Python scripts idempotent — re-running should overwrite, not duplicate, output files
- Scene names must be consistent across voice scripts and video components
- Do not commit large model files (`~/.cache/chatterbox/`) or rendered output (`out/video.mp4`)
