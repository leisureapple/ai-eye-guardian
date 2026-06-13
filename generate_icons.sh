#!/bin/bash

# Create icons directory if it doesn't exist
mkdir -p icons

# Create SVG template
create_svg_icon() {
  local size=$1
  local output=$2

  cat > /tmp/icon_${size}.svg << 'EOF'
<svg xmlns="http://www.w3.org/2000/svg" viewBox="0 0 128 128">
  <!-- Background gradient -->
  <defs>
    <linearGradient id="grad" x1="0%" y1="0%" x2="100%" y2="100%">
      <stop offset="0%" style="stop-color:#667eea;stop-opacity:1" />
      <stop offset="100%" style="stop-color:#764ba2;stop-opacity:1" />
    </linearGradient>
  </defs>
  <rect width="128" height="128" fill="url(#grad)" rx="20"/>

  <!-- Eye -->
  <circle cx="64" cy="50" r="20" fill="#ffffff"/>
  <circle cx="64" cy="50" r="12" fill="#667eea"/>
  <circle cx="68" cy="46" r="6" fill="#ffffff"/>

  <!-- Rooster head -->
  <ellipse cx="64" cy="85" rx="15" ry="12" fill="#ff6b6b"/>

  <!-- Rooster comb -->
  <path d="M 70 73 Q 75 68 72 60 Q 70 65 68 68 Z" fill="#ff6b6b"/>

  <!-- Rooster beak -->
  <polygon points="79,85 92,83 79,87" fill="#ffd700"/>

  <!-- Rooster eye -->
  <circle cx="70" cy="83" r="2" fill="#000000"/>
</svg>
EOF

  # Try to convert with ImageMagick
  if command -v convert &> /dev/null; then
    convert -density 300 -resize ${size}x${size} /tmp/icon_${size}.svg $output 2>/dev/null && echo "Created $output"
  else
    echo "Warning: ImageMagick not found. Skipping icon generation at ${size}x${size}"
    echo "Install ImageMagick to generate PNG icons: sudo apt-get install imagemagick"
  fi
}

# Generate icons for different sizes
create_svg_icon 16 icons/icon-16.png
create_svg_icon 32 icons/icon-32.png
create_svg_icon 48 icons/icon-48.png
create_svg_icon 128 icons/icon-128.png

# Clean up
rm -f /tmp/icon_*.svg

echo "Icons generated in ./icons/"
