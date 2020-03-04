//
//  Shaders.metal
//  Triangle
//
//  Created by Xinhou Jiang on 2020/2/20.
//  Copyright © 2020 Xinhou Jiang. All rights reserved.
//

// File for Metal kernel and shader functions

#include <metal_stdlib>
#include <simd/simd.h>

// Including header shared between this Metal shader code and Swift/C code executing Metal API commands
#import "ShaderTypes.h"

using namespace metal;

typedef struct
{
    float4 position [[position]];
    float2 texCoord;
} ColorInOut;

typedef struct
{
    float3 pos[[attribute(0)]];
    float2 uv[[attribute(1)]];
    float3 normal[[attribute(2)]];
    float3 tangent[[attribute(3)]];
    float3 bitangent[[attribute(4)]];
} VertexAttr;


vertex ColorInOut vertexShader(VertexAttr in [[stage_in]],
                               constant Uniforms & uniforms [[buffer(1)]])
{
    ColorInOut out;

    float4 position = float4(in.pos, 1.0);
    out.position = uniforms.projectionMatrix * uniforms.modelViewMatrix * position;
    out.texCoord = in.uv;

    return out;
}

fragment half4 fragmentShader(ColorInOut in [[stage_in]],
                               texture2d<half> baseColorTex [[texture(0)]],
                              texture2d<half> normalTex [[texture(1)]],
                              texture2d<half> specularTex [[texture(2)]])
{
    // 纹理采样对象
    constexpr sampler textureSampler (mip_filter::linear,mag_filter::linear,
                                      min_filter::linear,s_address::repeat,t_address::repeat);
    
    // 采样贴图
    const half4 color = baseColorTex.sample(textureSampler, in.texCoord);
    
    return color;
}
