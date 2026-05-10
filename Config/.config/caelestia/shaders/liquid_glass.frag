// ╔══════════════════════════════════════════════════════╗
// ║   Liquid Glass GLSL Shader — Hyprland                ║
// ║   iOS-style refraction + edge glow + grain           ║
// ╚══════════════════════════════════════════════════════╝

precision mediump float;

varying vec2 v_texcoord;
uniform sampler2D tex;
uniform float time;

const float REFRACTION  = 0.007;
const float ABERRATION  = 0.003;
const float EDGE_GLOW   = 0.18;
const float WAVE_SPEED  = 0.4;
const float WAVE_FREQ_X = 10.0;
const float WAVE_FREQ_Y = 8.0;
const float NOISE_SCALE = 0.012;

float rand(vec2 co) {
    return fract(sin(dot(co, vec2(12.9898, 78.233))) * 43758.5453);
}

void main() {
    vec2 uv = v_texcoord;

    float wave = sin(uv.x * WAVE_FREQ_X + time * WAVE_SPEED)
               * cos(uv.y * WAVE_FREQ_Y + time * WAVE_SPEED * 0.8);
    vec2 distort = uv + vec2(wave * REFRACTION);

    float noise = rand(uv * 200.0) * NOISE_SCALE;
    distort += noise;

    float r = texture2D(tex, distort + vec2( ABERRATION, 0.0)).r;
    float g = texture2D(tex, distort                         ).g;
    float b = texture2D(tex, distort - vec2( ABERRATION, 0.0)).b;
    float a = texture2D(tex, distort).a;

    vec4 color = vec4(r, g, b, a);

    float edgeX = smoothstep(0.44, 0.50, abs(uv.x - 0.5));
    float edgeY = smoothstep(0.44, 0.50, abs(uv.y - 0.5));
    float edge  = max(edgeX, edgeY);
    color.rgb  += edge * EDGE_GLOW * vec3(0.88, 0.94, 1.0);

    float innerGlow = smoothstep(0.3, 0.0, length(uv - 0.5));
    color.rgb += innerGlow * 0.04 * vec3(1.0, 1.0, 1.05);

    gl_FragColor = color;
}
