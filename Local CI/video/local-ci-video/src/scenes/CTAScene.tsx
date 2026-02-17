import React from 'react';
import {AbsoluteFill, useCurrentFrame, interpolate, spring, useVideoConfig} from 'remotion';

export const CTAScene: React.FC = () => {
  const frame = useCurrentFrame();
  const {fps} = useVideoConfig();

  // Title animation with spring
  const titleSpring = spring({
    frame,
    fps,
    config: {
      damping: 100,
    },
  });

  const titleOpacity = interpolate(titleSpring, [0, 1], [0, 1]);
  const titleScale = interpolate(titleSpring, [0, 1], [0.9, 1]);

  // Subtitle and CTA appear after title - slower
  const subtitleOpacity = interpolate(frame, [40, 70], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  const ctaOpacity = interpolate(frame, [90, 120], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  return (
    <AbsoluteFill
      style={{
        background: 'linear-gradient(135deg, #0f172a 0%, #1e293b 100%)',
        justifyContent: 'center',
        alignItems: 'center',
        padding: 100,
      }}
    >
      <div style={{textAlign: 'center', maxWidth: 1400}}>
        {/* Main Title */}
        <h1
          style={{
            fontSize: 100,
            fontWeight: 'bold',
            color: 'white',
            marginBottom: 40,
            opacity: titleOpacity,
            transform: `scale(${titleScale})`,
          }}
        >
          Ready to Level Up?
        </h1>

        {/* Subtitle */}
        <p
          style={{
            fontSize: 48,
            color: '#94a3b8',
            marginBottom: 60,
            opacity: subtitleOpacity,
            lineHeight: 1.6,
          }}
        >
          Start using Rails 8.1 Local CI today
          <br />
          and transform your development workflow
        </p>

        {/* CTA Box */}
        <div
          style={{
            display: 'inline-block',
            backgroundColor: '#10b981',
            padding: '40px 80px',
            borderRadius: 20,
            opacity: ctaOpacity,
            boxShadow: '0 20px 60px rgba(16, 185, 129, 0.3)',
          }}
        >
          <p
            style={{
              fontSize: 56,
              color: 'white',
              fontWeight: 'bold',
              margin: 0,
              fontFamily: 'monospace',
            }}
          >
            ./bin/ci
          </p>
        </div>

        {/* Footer text */}
        <p
          style={{
            fontSize: 36,
            color: '#64748b',
            marginTop: 60,
            opacity: ctaOpacity,
          }}
        >
          One command. Everywhere. Always.
        </p>
      </div>
    </AbsoluteFill>
  );
};
