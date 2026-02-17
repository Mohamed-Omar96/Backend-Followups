#!/bin/bash

# Capture terminal session of ./bin/ci running
# This creates a clean terminal recording that can be used in the video

echo "🎬 Preparing to capture terminal session..."
echo ""
echo "This will:"
echo "  1. Clear the terminal"
echo "  2. Run ./bin/ci in the parent directory"
echo "  3. Save output to terminal-output.txt"
echo ""
read -p "Press Enter to start recording..."

# Clear terminal for clean recording
clear

# Save raw output
echo "Running: ./bin/ci"
echo "=========================="
echo ""

cd "../" && ./bin/ci 2>&1 | tee "local-ci-video/terminal-output.txt"

echo ""
echo ""
echo "✅ Terminal session captured!"
echo "📁 Output saved to: terminal-output.txt"
echo ""
echo "You can use this output to:"
echo "  - Reference exact timing and messages"
echo "  - Copy real terminal text"
echo "  - Create animated terminal recordings with tools like asciinema"
