//
//  RiseFilter.metal
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

fragment float4 riseEffect(VertexIO vertexIn [[ stage_in ]],
    texture2d<float, access::sample> inputTexture [[ texture(0) ]], 
    texture2d<float, access::sample> blowout [[ texture(1) ]], 
    texture2d<float, access::sample> map [[ texture(2) ]], 
    texture2d<float, access::sample> overlay [[ texture(3) ]], 
    sampler textureSampler [[ sampler(0) ]])
{
    constexpr sampler s(coord::normalized, address::clamp_to_edge, filter::linear);
    float4 texel = inputTexture.sample(s, vertexIn.textureCoord);
    float4 inputTexel = texel;
    float3 bbTexel = blowout.sample(s, vertexIn.textureCoord).rgb;

    texel.r = overlay.sample(s, float2(bbTexel.r, texel.r)).r;
    texel.g = overlay.sample(s, float2(bbTexel.g, texel.g)).g;
    texel.b = overlay.sample(s, float2(bbTexel.b, texel.b)).b;

    float3 mapped;
    mapped.r = map.sample(s, float2(texel.r, .16666)).r;
    mapped.g = map.sample(s, float2(texel.g, .5)).g;
    mapped.b = map.sample(s, float2(texel.b, .83333)).b;

    texel.rgb = mapped;
    texel.rgb = mix(inputTexel.rgb, texel.rgb, 1.0);
    return texel;
}
