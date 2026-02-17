import React from 'react';
import {AbsoluteFill, useCurrentFrame, interpolate} from 'remotion';

export const DemoScene: React.FC = () => {
  const frame = useCurrentFrame();

  // Terminal appears quickly
  const terminalOpacity = interpolate(frame, [0, 20], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  // Command prompt appears quickly
  const promptProgress = interpolate(frame, [20, 30], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  // Command typing animation - realistic typing speed
  const commandProgress = interpolate(frame, [30, 50], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  // CI header appears immediately after Enter pressed
  const headerProgress = interpolate(frame, [55, 65], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  // Mimicking real CI timing with pauses between steps
  // Setup: 3.59s (77 frames)
  const step1Progress = interpolate(frame, [70, 147], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });
  // PAUSE after Setup (15 frames / 0.5s)

  // Style Ruby: 5.31s (115 frames) - longest step
  const step2Progress = interpolate(frame, [162, 277], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });
  // PAUSE after Style Ruby (12 frames / 0.4s)

  // Security: 0.86s (20 frames) - very fast!
  const step3Progress = interpolate(frame, [289, 309], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });
  // PAUSE after Security (10 frames / 0.3s)

  // Tests Rails: 4.12s (90 frames)
  const step4Progress = interpolate(frame, [319, 409], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  // PAUSE after Tests finish (5 frames)

  // Success message appears right after tests finish
  const successProgress = interpolate(frame, [414, 425], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  // PAUSE after success message (8 frames / 0.25s)

  // Total time displays
  const totalTimeProgress = interpolate(frame, [433, 443], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  // PAUSE at end to let viewer absorb completion (40 frames / 1.3s)
  // Scene continues until frame ~483 before transitioning to Benefits

  const command = './bin/ci';
  const visibleCommand = command.slice(0, Math.floor(commandProgress * command.length));

  return (
    <AbsoluteFill
      style={{
        backgroundColor: '#0f172a',
        justifyContent: 'center',
        alignItems: 'center',
        padding: 40,
      }}
    >
      <div style={{maxWidth: 1700, width: '100%', maxHeight: '100%'}}>
        {/* Terminal - Full screen like real terminal */}
        <div
          style={{
            backgroundColor: '#1a1d29',
            borderRadius: 12,
            padding: 25,
            paddingBottom: 40,
            opacity: terminalOpacity,
            boxShadow: '0 25px 70px rgba(0, 0, 0, 0.6)',
            border: '1px solid #2d3142',
            fontFamily: 'Monaco, Menlo, monospace',
            maxHeight: '100%',
            overflow: 'hidden',
          }}
        >
          {/* Terminal Header */}
          <div
            style={{
              display: 'flex',
              gap: 8,
              marginBottom: 25,
              paddingBottom: 15,
              borderBottom: '1px solid #2d3142',
            }}
          >
            <div style={{width: 12, height: 12, borderRadius: '50%', backgroundColor: '#ff5f56'}} />
            <div style={{width: 12, height: 12, borderRadius: '50%', backgroundColor: '#ffbd2e'}} />
            <div style={{width: 12, height: 12, borderRadius: '50%', backgroundColor: '#27c93f'}} />
          </div>

          {/* Command Prompt - Simple without username */}
          {promptProgress > 0 && (
            <div style={{marginBottom: 25, opacity: promptProgress}}>
              <span style={{color: '#27c93f', fontSize: 28, fontFamily: 'monospace'}}>
                ${' '}
              </span>
              <span
                style={{
                  color: '#e2e8f0',
                  fontSize: 28,
                  fontFamily: 'monospace',
                }}
              >
                {visibleCommand}
                {commandProgress > 0 && commandProgress < 1 && (
                  <span style={{opacity: frame % 20 < 10 ? 1 : 0}}>▊</span>
                )}
              </span>
            </div>
          )}

          {/* CI Header */}
          {headerProgress > 0 && (
            <div style={{marginBottom: 20, opacity: headerProgress}}>
              <p
                style={{
                  fontSize: 28,
                  color: '#e2e8f0',
                  fontWeight: 'bold',
                  margin: 0,
                  fontFamily: 'monospace',
                }}
              >
                Continuous Integration
              </p>
              <p
                style={{
                  fontSize: 22,
                  color: '#64748b',
                  margin: 0,
                  marginTop: 5,
                  fontFamily: 'monospace',
                }}
              >
                Running tests, style checks, and security audits
              </p>
            </div>
          )}

          {/* CI Steps - Detailed output with REAL timing from actual run */}
          <div style={{display: 'flex', flexDirection: 'column', gap: 12, fontSize: 20}}>
            {step1Progress > 0 && (
              <DetailedCIStep
                progress={step1Progress}
                name="Setup"
                command="bin/setup --skip-server"
                output={[
                  "== Installing dependencies ==",
                  "The Gemfile's dependencies are satisfied",
                  "== Preparing database ==",
                  "== Removing old logs and tempfiles =="
                ]}
                time="3.59s"
              />
            )}
            {step2Progress > 0 && (
              <DetailedCIStep
                progress={step2Progress}
                name="Style: Ruby"
                command="bin/rubocop"
                output={[
                  "Inspecting 30 files",
                  "..............................",
                  "30 files inspected, no offenses detected"
                ]}
                time="5.31s"
              />
            )}
            {step3Progress > 0 && (
              <DetailedCIStep
                progress={step3Progress}
                name="Security: Gem audit"
                command="bin/bundler-audit"
                output={["No vulnerabilities found"]}
                time="0.86s"
              />
            )}
            {step4Progress > 0 && (
              <DetailedCIStep
                progress={step4Progress}
                name="Tests: Rails"
                command="bin/rails test"
                output={[
                  "Running 12 tests in a single process",
                  "# Running:",
                  "............",
                  "12 runs, 18 assertions, 0 failures, 0 errors, 0 skips"
                ]}
                time="4.12s"
              />
            )}
          </div>

          {/* Success Message */}
          {successProgress > 0 && (
            <div style={{marginTop: 15, opacity: successProgress}}>
              <p
                style={{
                  fontSize: 24,
                  color: '#27c93f',
                  fontWeight: 'bold',
                  margin: 0,
                  fontFamily: 'monospace',
                }}
              >
                ✅ All CI checks passed!
              </p>
              <p
                style={{
                  fontSize: 20,
                  color: '#64748b',
                  margin: 0,
                  marginTop: 3,
                  fontFamily: 'monospace',
                }}
              >
                Your changes are ready for review
              </p>
            </div>
          )}

          {/* Total Time - matches actual CI run */}
          {totalTimeProgress > 0 && (
            <div style={{marginTop: 12, opacity: totalTimeProgress}}>
              <p
                style={{
                  fontSize: 24,
                  color: '#27c93f',
                  fontWeight: 'bold',
                  margin: 0,
                  fontFamily: 'monospace',
                }}
              >
                ✅ Continuous Integration passed in 13.89s
              </p>
            </div>
          )}

          {/* Command prompt returns */}
          {totalTimeProgress > 0 && (
            <div style={{marginTop: 15, opacity: totalTimeProgress}}>
              <span style={{color: '#27c93f', fontSize: 26, fontFamily: 'monospace'}}>
                ${' '}
              </span>
              <span
                style={{
                  color: '#e2e8f0',
                  fontSize: 26,
                  fontFamily: 'monospace',
                  opacity: frame % 30 < 15 ? 1 : 0,
                }}
              >
                ▊
              </span>
            </div>
          )}
        </div>
      </div>
    </AbsoluteFill>
  );
};

const DetailedCIStep: React.FC<{
  progress: number;
  name: string;
  command: string;
  output: string[];
  time: string;
}> = ({progress, name, command, output, time}) => {
  // Step name and command appear immediately when progress starts
  const headerProgress = interpolate(progress, [0, 0.1], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  // Output lines appear progressively (first 60% of the step duration)
  const outputStartProgress = 0.1;
  const outputEndProgress = 0.6;
  const outputDuration = outputEndProgress - outputStartProgress;
  const linesPerStep = output.length;

  // Success message appears after output and a pause (last 20% of step)
  const successProgress = interpolate(progress, [0.8, 1], [0, 1], {
    extrapolateLeft: 'clamp',
    extrapolateRight: 'clamp',
  });

  return (
    <div
      style={{
        marginBottom: 6,
      }}
    >
      {/* Step name in purple */}
      {headerProgress > 0 && (
        <p
          style={{
            fontSize: 22,
            color: '#a78bfa',
            fontWeight: 'bold',
            margin: 0,
            marginBottom: 3,
            fontFamily: 'monospace',
            opacity: headerProgress,
          }}
        >
          {name}
        </p>
      )}

      {/* Command in gray */}
      {headerProgress > 0 && (
        <p
          style={{
            fontSize: 18,
            color: '#64748b',
            margin: 0,
            marginBottom: 5,
            fontFamily: 'monospace',
            opacity: headerProgress,
          }}
        >
          {command}
        </p>
      )}

      {/* Output lines appear one by one */}
      {output.map((line, i) => {
        const lineStart = outputStartProgress + (i / linesPerStep) * outputDuration;
        const lineEnd = outputStartProgress + ((i + 1) / linesPerStep) * outputDuration;
        const lineProgress = interpolate(progress, [lineStart, lineEnd], [0, 1], {
          extrapolateLeft: 'clamp',
          extrapolateRight: 'clamp',
        });

        return lineProgress > 0 ? (
          <p
            key={i}
            style={{
              fontSize: 18,
              color: '#94a3b8',
              margin: 0,
              marginBottom: 2,
              fontFamily: 'monospace',
              opacity: lineProgress,
            }}
          >
            {line}
          </p>
        ) : null;
      })}

      {/* Success message appears after pause - mimics real CI waiting */}
      {successProgress > 0 && (
        <p
          style={{
            fontSize: 20,
            color: '#27c93f',
            fontWeight: 'bold',
            margin: 0,
            marginTop: 5,
            fontFamily: 'monospace',
            opacity: successProgress,
          }}
        >
          ✅ {name} passed in {time}
        </p>
      )}
    </div>
  );
};
