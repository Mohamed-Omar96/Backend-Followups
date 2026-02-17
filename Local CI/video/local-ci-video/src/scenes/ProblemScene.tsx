import React from 'react';
import {AbsoluteFill, useCurrentFrame, interpolate, Easing} from 'remotion';

export const ProblemScene: React.FC = () => {
  const frame = useCurrentFrame();

  // Title animation - slower
  const titleOpacity = interpolate(frame, [0, 30], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  // Problem items animate in one by one - slower for readability
  const problem1Opacity = interpolate(frame, [40, 70], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  const problem2Opacity = interpolate(frame, [80, 110], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  const problem3Opacity = interpolate(frame, [120, 150], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  const problem4Opacity = interpolate(frame, [160, 190], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  return (
    <AbsoluteFill
      style={{
        backgroundColor: '#1e293b',
        justifyContent: 'center',
        alignItems: 'center',
        padding: 100,
      }}
    >
      <div style={{maxWidth: 1400, width: '100%'}}>
        {/* Title */}
        <h2
          style={{
            fontSize: 80,
            fontWeight: 'bold',
            color: '#ef4444',
            marginBottom: 60,
            opacity: titleOpacity,
            textAlign: 'center',
          }}
        >
          😓 The Problem
        </h2>

        {/* Problem items */}
        <div style={{display: 'flex', flexDirection: 'column', gap: 40}}>
          <ProblemItem
            opacity={problem1Opacity}
            icon="✅"
            text="Tests pass locally on your machine"
            color="#10b981"
          />
          <ProblemItem
            opacity={problem2Opacity}
            icon="❌"
            text="CI fails on GitHub Actions/CircleCI"
            color="#ef4444"
          />
          <ProblemItem
            opacity={problem3Opacity}
            icon="⏱️"
            text="30+ minutes waiting for CI feedback"
            color="#f59e0b"
          />
          <ProblemItem
            opacity={problem4Opacity}
            icon="💸"
            text="Wasted time debugging environment differences"
            color="#f59e0b"
          />
        </div>
      </div>
    </AbsoluteFill>
  );
};

const ProblemItem: React.FC<{
  opacity: number;
  icon: string;
  text: string;
  color: string;
}> = ({opacity, icon, text, color}) => {
  return (
    <div
      style={{
        display: 'flex',
        alignItems: 'center',
        gap: 30,
        padding: 40,
        backgroundColor: 'rgba(255, 255, 255, 0.05)',
        borderRadius: 20,
        opacity,
        borderLeft: `8px solid ${color}`,
      }}
    >
      <span style={{fontSize: 64}}>{icon}</span>
      <span style={{fontSize: 48, color: 'white', fontWeight: 500}}>{text}</span>
    </div>
  );
};
