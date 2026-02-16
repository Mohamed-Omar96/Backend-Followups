#!/bin/bash

# Render the Rails 8.1 Local CI video
# Usage: ./render.sh [quality]
# Default quality: 90

QUALITY=${1:-90}

echo "🎬 Rendering Rails 8.1 Local CI video..."
echo "📊 Quality: $QUALITY"
echo ""

npm run build -- --quality=$QUALITY

if [ $? -eq 0 ]; then
  echo ""
  echo "✅ Video rendered successfully!"
  echo "📁 Output: out/video.mp4"
  echo ""
  echo "To view the video:"
  echo "  open out/video.mp4"
else
  echo ""
  echo "❌ Rendering failed. Please check the errors above."
  exit 1
fi
