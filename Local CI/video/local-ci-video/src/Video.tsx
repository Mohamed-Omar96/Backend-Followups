import React from 'react';
import {AbsoluteFill, Sequence, useCurrentFrame, Audio, staticFile} from 'remotion';
import {TitleScene} from './scenes/TitleScene';
import {ProblemScene} from './scenes/ProblemScene';
import {SolutionScene} from './scenes/SolutionScene';
import {DemoScene} from './scenes/DemoScene';
import {BenefitsScene} from './scenes/BenefitsScene';
import {CTAScene} from './scenes/CTAScene';

export const Video: React.FC = () => {
  return (
    <AbsoluteFill style={{backgroundColor: '#0f172a'}}>
      {/* Audio narration - plays at start of each scene */}
      <Sequence from={0}>
        <Audio src={staticFile('title.wav')} volume={0.8} />
      </Sequence>
      <Sequence from={120}>
        <Audio src={staticFile('problem.wav')} volume={0.8} />
      </Sequence>
      <Sequence from={365}>
        <Audio src={staticFile('solution.wav')} volume={0.8} />
      </Sequence>
      <Sequence from={605}>
        <Audio src={staticFile('demo.wav')} volume={0.8} playbackRate={0.85} />
      </Sequence>
      <Sequence from={1226}>
        <Audio src={staticFile('benefits.wav')} volume={0.8} />
      </Sequence>
      <Sequence from={1491}>
        <Audio src={staticFile('cta.wav')} volume={0.8} />
      </Sequence>

      {/* Scene 1: Title - 3.56s audio = 107 frames, give 120 frames */}
      <Sequence from={0} durationInFrames={120}>
        <TitleScene />
      </Sequence>

      {/* Scene 2: Problem - 7.68s audio + 0.5s pause = 245 frames */}
      <Sequence from={120} durationInFrames={245}>
        <ProblemScene />
      </Sequence>

      {/* Scene 3: Solution - 6.96s audio + 1s pause = 240 frames */}
      <Sequence from={365} durationInFrames={240}>
        <SolutionScene />
      </Sequence>

      {/* Scene 4: Demo - 18.20s audio + 2.5s pause = 621 frames */}
      <Sequence from={605} durationInFrames={621}>
        <DemoScene />
      </Sequence>

      {/* Scene 5: Benefits - 8.32s audio + 0.5s pause = 265 frames */}
      <Sequence from={1226} durationInFrames={265}>
        <BenefitsScene />
      </Sequence>

      {/* Scene 6: CTA - 4.68s audio + 0.5s pause = 165 frames */}
      <Sequence from={1491} durationInFrames={165}>
        <CTAScene />
      </Sequence>
    </AbsoluteFill>
  );
};
