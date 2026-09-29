#include <flutter/runtime_effect.glsl>
precision highp float;

uniform vec2 uSize;
uniform vec2 uImageSize;
uniform float uPhase;
uniform sampler2D uImage;
out vec4 fragColor;

float region(vec2 uv, vec2 center, vec2 radius, float angle) {
  vec2 p = uv - center;
  float c = cos(angle), s = sin(angle);
  p = mat2(c, -s, s, c) * p;
  return 1.0 - smoothstep(0.45, 1.0, length(p / radius));
}

void main() {
  // Same centered BoxFit.cover mapping as the static Image widget.
  float scale = max(uSize.x / uImageSize.x, uSize.y / uImageSize.y);
  vec2 uv = (FlutterFragCoord().xy + (uImageSize * scale - uSize) * 0.5) / (uImageSize * scale);
  float upperRight = region(uv, vec2(0.86, 0.115), vec2(0.23, 0.044), -0.48);
  float upperLeft = region(uv, vec2(0.035, 0.30), vec2(0.10, 0.10), 0.0);
  float lowerLeft = region(uv, vec2(0.065, 0.695), vec2(0.10, 0.11), 0.45);
  float lowerRight = region(uv, vec2(0.94, 0.80), vec2(0.10, 0.095), -0.45);
  float mask = clamp(upperRight + upperLeft + lowerLeft + lowerRight, 0.0, 1.0);
  float wave = sin(uPhase + uv.y * 38.0 - uv.x * 16.0);
  float ripple = sin(uPhase * 2.0 - uv.y * 62.0 + uv.x * 24.0);
  vec2 flow = vec2(0.0035 * wave, 0.0025 * ripple) * mask;
  vec4 original = texture(uImage, uv + flow);
  // Animate the existing gold texture, without drawing any new particles.
  float glow = 1.0 + mask * (0.32 * wave + 0.16 * ripple);
  fragColor = vec4(original.rgb * glow, original.a);
}
