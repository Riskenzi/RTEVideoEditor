//
//  PassTh.metal
//  RTEVideoEditor
//
//  Created by weidong fu on 2020/1/11.
//  Copyright © 2020 Free. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;
#include <simd/simd.h>
#import "../../RTEShaderTypes.h"
using namespace RTEMetal;

fragment float4 sutroEffect(VertexIO vertexIn [[ stage_in ]],
    texture2d<float, access::sample> inputTexture [[ texture(0) ]], 
    texture2d<float, access::sample> curves [[ texture(1) ]], 
    texture2d<float, access::sample> edgeBurn [[ texture(2) ]], 
    texture2d<float, access::sample> softLight [[ texture(3) ]], 
    texture2d<float, access::sample> sutroMetal [[ texture(4) ]], 
    texture2d<float, access::sample> vignetteMap [[ texture(5) ]],
    sampler textureSampler [[ sampler(0) ]])
{
    constexpr sampler s(coord::normalized, address::clamp_to_edge, filter::linear);
    float4 texel = inputTexture.sample(s, vertexIn.textureCoord);
    float4 inputTexel = texel;
    float2 tc = (2.0 * vertexIn.textureCoord) - 1.0;
    float d = dot(tc, tc);
    float2 lookup = float2(d, texel.r);
    texel.r = vignetteMap.sample(s, lookup).r;
    lookup.y = texel.g;
    texel.g = vignetteMap.sample(s, lookup).g;
    lookup.y = texel.b;
    texel.b    = vignetteMap.sample(s, lookup).b;

    float3 rgbPrime = float3(0.1019, 0.0, 0.0);
    float m = dot(float3(.3, .59, .11), texel.rgb) - 0.03058;
    texel.rgb = mix(texel.rgb, rgbPrime + m, 0.32);

    float3 metal = sutroMetal.sample(s, vertexIn.textureCoord).rgb;
    texel.r = softLight.sample(s, float2(metal.r, texel.r)).r;
    texel.g = softLight.sample(s, float2(metal.g, texel.g)).g;
    texel.b = softLight.sample(s, float2(metal.b, texel.b)).b;

    texel.rgb = texel.rgb * edgeBurn.sample(s, vertexIn.textureCoord).rgb;

    texel.r = curves.sample(s, float2(texel.r, .16666)).r;
    texel.g = curves.sample(s, float2(texel.g, .5)).g;
    texel.b = curves.sample(s, float2(texel.b, .83333)).b;
    texel.rgb = mix(inputTexel.rgb, texel.rgb, 1.0);
    return texel;
}
