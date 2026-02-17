import React from 'react';
import {AbsoluteFill, useCurrentFrame, interpolate, spring, useVideoConfig} from 'remotion';

export const TitleScene: React.FC = () => {
  const frame = useCurrentFrame();
  const {fps} = useVideoConfig();

  // Spring animation for title
  const titleSpring = spring({
    frame,
    fps,
    config: {
      damping: 100,
    },
  });

  const titleOpacity = interpolate(titleSpring, [0, 1], [0, 1]);
  const titleScale = interpolate(titleSpring, [0, 1], [0.8, 1]);

  // Subtitle appears after title - slower
  const subtitleOpacity = interpolate(frame, [40, 70], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  return (
    <AbsoluteFill
      style={{
        background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)',
        justifyContent: 'center',
        alignItems: 'center',
        padding: 80,
      }}
    >
      <div style={{textAlign: 'center'}}>
        {/* Main Title */}
        <h1
          style={{
            fontSize: 120,
            fontWeight: 'bold',
            color: 'white',
            margin: 0,
            opacity: titleOpacity,
            transform: `scale(${titleScale})`,
            textShadow: '0 4px 20px rgba(0,0,0,0.3)',
          }}
        >
          Rails 8.1 Local CI
        </h1>

        {/* Subtitle */}
        <p
          style={{
            fontSize: 48,
            color: 'rgba(255, 255, 255, 0.9)',
            marginTop: 30,
            opacity: subtitleOpacity,
            fontWeight: 300,
          }}
        >
          Run CI Locally, Ship With Confidence
        </p>
      </div>
    </AbsoluteFill>
  );
};
