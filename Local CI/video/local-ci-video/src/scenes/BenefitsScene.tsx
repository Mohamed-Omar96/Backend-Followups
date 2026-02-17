import React from 'react';
import {AbsoluteFill, useCurrentFrame, interpolate} from 'remotion';

export const BenefitsScene: React.FC = () => {
  const frame = useCurrentFrame();

  // Title animation - slower
  const titleOpacity = interpolate(frame, [0, 30], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  // Benefits appear one by one - slower for readability
  const benefit1Opacity = interpolate(frame, [40, 70], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  const benefit2Opacity = interpolate(frame, [80, 110], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  const benefit3Opacity = interpolate(frame, [120, 150], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  const benefit4Opacity = interpolate(frame, [160, 190], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  const benefit5Opacity = interpolate(frame, [200, 230], [0, 1], {
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
      <div style={{maxWidth: 1500, width: '100%'}}>
        {/* Title */}
        <h2
          style={{
            fontSize: 80,
            fontWeight: 'bold',
            color: 'white',
            marginBottom: 60,
            opacity: titleOpacity,
            textAlign: 'center',
          }}
        >
          💪 Key Benefits
        </h2>

        {/* Benefits Grid */}
        <div
          style={{
            display: 'grid',
            gridTemplateColumns: '1fr 1fr',
            gap: 40,
          }}
        >
          <BenefitCard
            opacity={benefit1Opacity}
            icon="⚡"
            title="Instant Feedback"
            description="No waiting 30+ minutes for CI servers"
          />
          <BenefitCard
            opacity={benefit2Opacity}
            icon="🎯"
            title="Catch Issues Early"
            description="Find problems before code review"
          />
          <BenefitCard
            opacity={benefit3Opacity}
            icon="🔄"
            title="Consistent Everywhere"
            description="Same checks locally and in cloud CI"
          />
          <BenefitCard
            opacity={benefit4Opacity}
            icon="💰"
            title="Reduced Costs"
            description="Fewer failed builds on cloud infrastructure"
          />
        </div>

        {/* Bottom highlight */}
        <div
          style={{
            marginTop: 50,
            padding: 40,
            backgroundColor: 'rgba(255, 255, 255, 0.15)',
            borderRadius: 20,
            opacity: benefit5Opacity,
            backdropFilter: 'blur(10px)',
            textAlign: 'center',
          }}
        >
          <p
            style={{
              fontSize: 42,
              color: 'white',
              fontWeight: 'bold',
              margin: 0,
            }}
          >
            Ship with confidence. Every single time. 🚀
          </p>
        </div>
      </div>
    </AbsoluteFill>
  );
};

const BenefitCard: React.FC<{
  opacity: number;
  icon: string;
  title: string;
  description: string;
}> = ({opacity, icon, title, description}) => {
  return (
    <div
      style={{
        backgroundColor: 'rgba(255, 255, 255, 0.15)',
        padding: 40,
        borderRadius: 20,
        opacity,
        backdropFilter: 'blur(10px)',
        border: '2px solid rgba(255, 255, 255, 0.2)',
      }}
    >
      <div style={{fontSize: 72, marginBottom: 20}}>{icon}</div>
      <h3
        style={{
          fontSize: 44,
          color: 'white',
          fontWeight: 'bold',
          marginBottom: 15,
          margin: 0,
        }}
      >
        {title}
      </h3>
      <p
        style={{
          fontSize: 32,
          color: 'rgba(255, 255, 255, 0.9)',
          margin: 0,
          marginTop: 15,
          lineHeight: 1.5,
        }}
      >
        {description}
      </p>
    </div>
  );
};
