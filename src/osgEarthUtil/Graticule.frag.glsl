#version 110
#pragma vp_entryPoint "oe_graticule_fragment"
#pragma vp_location   "fragment_coloring"
#pragma vp_order      "0.6"

uniform float oe_graticule_lineWidth;
uniform float oe_graticule_resolution;
uniform vec4  oe_graticule_color;
uniform mat4 osg_ViewMatrixInverse;

varying vec2 oe_graticule_coord;

void oe_graticule_fragment(inout vec4 color)
{
    // double the effective res for longitude since it has twice the span
    vec2 gr = vec2(0.5*oe_graticule_resolution, oe_graticule_resolution);
    vec2 distanceToLine = mod(oe_graticule_coord, gr);
    vec2 dx = abs(dFdx(oe_graticule_coord));
    vec2 dy = abs(dFdy(oe_graticule_coord));
    vec2 dF = vec2(max(dx.s, dy.s), max(dx.t, dy.t)) * oe_graticule_lineWidth;

    if ( any(lessThan(distanceToLine, dF)))
    {
        // Fade out the lines as you get closer to the ground.
        vec3 eye = osg_ViewMatrixInverse[3].xyz;
        float hae = length(eye) - 6378137.0;
        float maxHAE = 2000.0;
        float alpha = clamp(hae / maxHAE, 0.0, 1.0);
        color.rgb = mix(color.rgb, oe_graticule_color.rgb, oe_graticule_color.a * alpha);
    }
}