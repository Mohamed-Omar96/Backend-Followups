import React from 'react';
import {AbsoluteFill, useCurrentFrame, interpolate, spring, useVideoConfig} from 'remotion';

export const SolutionScene: React.FC = () => {
  const frame = useCurrentFrame();
  const {fps} = useVideoConfig();

  // Title animation - slower
  const titleOpacity = interpolate(frame, [0, 30], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  // DHH quote appears - slower
  const quoteOpacity = interpolate(frame, [50, 80], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  // Solution points - slower
  const point1Opacity = interpolate(frame, [120, 150], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  const point2Opacity = interpolate(frame, [160, 190], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  return (
    <AbsoluteFill
      style={{
        background: 'linear-gradient(135deg, #10b981 0%, #059669 100%)',
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
            color: 'white',
            marginBottom: 40,
            opacity: titleOpacity,
            textAlign: 'center',
          }}
        >
          ✨ The Solution
        </h2>

        {/* DHH Quote */}
        <div
          style={{
            backgroundColor: 'rgba(255, 255, 255, 0.1)',
            padding: 40,
            borderRadius: 20,
            borderLeft: '8px solid white',
            marginBottom: 50,
            opacity: quoteOpacity,
          }}
        >
          <p
            style={{
              fontSize: 36,
              color: 'white',
              fontStyle: 'italic',
              margin: 0,
              lineHeight: 1.6,
            }}
          >
            "Run the <strong>exact same CI checks</strong> on your laptop that run on the
            server. One configuration, everywhere."
          </p>
          <p
            style={{
              fontSize: 28,
              color: 'rgba(255, 255, 255, 0.8)',
              marginTop: 20,
              marginBottom: 0,
            }}
          >
            — DHH, Rails Creator
          </p>
        </div>

        {/* Solution Points */}
        <div style={{display: 'flex', gap: 40}}>
          <SolutionCard
            opacity={point1Opacity}
            title="config/ci.rb"
            description="One file defines your entire CI workflow"
          />
          <SolutionCard
            opacity={point2Opacity}
            title="bin/ci"
            description="One command runs everywhere"
          />
        </div>
      </div>
    </AbsoluteFill>
  );
};

const SolutionCard: React.FC<{
  opacity: number;
  title: string;
  description: string;
}> = ({opacity, title, description}) => {
  return (
    <div
      style={{
        flex: 1,
        backgroundColor: 'rgba(255, 255, 255, 0.15)',
        padding: 40,
        borderRadius: 20,
        opacity,
        backdropFilter: 'blur(10px)',
      }}
    >
      <h3
        style={{
          fontSize: 48,
          color: 'white',
          fontWeight: 'bold',
          marginBottom: 20,
          fontFamily: 'monospace',
        }}
      >
        {title}
      </h3>
      <p
        style={{
          fontSize: 32,
          color: 'rgba(255, 255, 255, 0.9)',
          margin: 0,
        }}
      >
        {description}
      </p>
    </div>
  );
};
