# Rails 8.1 Local CI Video

A professional video presentation showcasing the power and advantages of Rails 8.1's Local CI feature for backend teams.

## Overview

This Remotion project creates a compelling 30-second video demonstrating:
- The problems with traditional CI workflows
- Rails 8.1 Local CI as the solution
- **Live demonstration using REAL data** from your actual `./bin/ci` output
- Key benefits for development teams

### 🎯 Uses Actual CI Data

The demo scene shows the **exact output** from running `./bin/ci` in your project:
- Setup: 4.11s
- Style: Ruby: 5.07s
- Security: Gem audit: 0.68s
- Tests: Rails: 5.31s
- **Total: 15.18s**

## Video Structure

The video is divided into 6 scenes:

1. **Title Scene** (3 seconds) - Eye-catching introduction
2. **Problem Scene** (5 seconds) - Illustrates pain points of traditional CI
3. **Solution Scene** (5 seconds) - Introduces Rails 8.1 Local CI with DHH quote
4. **Demo Scene** (7 seconds) - Shows `./bin/ci` command execution
5. **Benefits Scene** (6 seconds) - Highlights key advantages
6. **CTA Scene** (4 seconds) - Call to action

**Total Duration**: 30 seconds at 30fps (900 frames)

## Getting Started

### Prerequisites

- Node.js 18+
- npm or yarn

### Installation

```bash
cd local-ci-video
npm install
```

### Development

Start the Remotion Studio to preview and edit the video:

```bash
npm start
```

This will open the Remotion Studio in your browser where you can:
- Preview all scenes
- Adjust timing and animations
- Make real-time edits

### Rendering

Render the final video:

```bash
npm run build
```

The video will be saved to `out/video.mp4`.

### Advanced Rendering Options

```bash
# Render with custom quality
npx remotion render Video out/video.mp4 --quality 100

# Render specific frame range
npx remotion render Video out/video.mp4 --frames=0-300

# Render as GIF
npx remotion render Video out/video.gif

# Render with different dimensions
npx remotion render Video out/video.mp4 --width=1280 --height=720
```

## Customization

### Changing Duration

Edit `src/Root.tsx` and adjust `durationInFrames`:

```typescript
<Composition
  id="Video"
  component={Video}
  durationInFrames={900} // 30 seconds at 30fps
  fps={30}
  width={1920}
  height={1080}
/>
```

### Adjusting Scene Timing

Edit `src/Video.tsx` and modify the `Sequence` components:

```typescript
<Sequence from={0} durationInFrames={90}>
  <TitleScene />
</Sequence>
```

### Styling

Each scene component in `src/scenes/` can be customized:
- Colors and gradients
- Font sizes and styles
- Animation timing
- Layout and spacing

## Video Specifications

- **Resolution**: 1920x1080 (Full HD)
- **Frame Rate**: 30 fps
- **Duration**: 30 seconds
- **Format**: MP4 (H.264)
- **Aspect Ratio**: 16:9

## Scenes Breakdown

### TitleScene
- Purple gradient background
- Spring animation for smooth entrance
- Main title and subtitle with staggered appearance

### ProblemScene
- Dark background to emphasize problems
- Red accent color for issues
- Items animate in sequentially

### SolutionScene
- Green gradient representing success
- DHH quote for authority
- Two-column layout for key concepts

### DemoScene
- Terminal-style interface
- Command typing animation
- CI steps appear progressively
- Success message at the end

### BenefitsScene
- Purple gradient for premium feel
- 2x2 grid of benefit cards
- Icons and clear messaging
- Bottom highlight with call-out

### CTAScene
- Dark background for focus
- Large, centered call to action
- Prominent display of `./bin/ci` command
- Spring animation for impact

## Technical Details

Built with:
- **Remotion 4.x** - Video framework
- **React 19** - Component library
- **TypeScript** - Type safety
- **CSS-in-JS** - Styling

## Project Files

- `src/` - Video components and scenes
- `src/scenes/DemoScene.tsx` - **Animated terminal with real CI data**
- `terminal-output.txt` - Raw output from actual `./bin/ci` run
- `capture-terminal.sh` - Helper script to capture fresh terminal output
- `render.sh` - Quick render script

## Resources

- [Remotion Documentation](https://www.remotion.dev/)
- [Rails 8.1 Local CI Guide](../LOCAL_CI_GUIDE.md) - Full guide to Local CI
- [Project README](../README.md) - Main project documentation

## Credits

Created to showcase Rails 8.1's Local CI feature, inspired by DHH's vision of standardizing CI workflows across local and cloud environments.
