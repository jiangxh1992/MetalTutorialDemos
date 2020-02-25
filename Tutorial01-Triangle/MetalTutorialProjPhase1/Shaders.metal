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
    float2 pos[[attribute(0)]];
    float2 uv[[attribute(1)]];
} VertexAttr;


vertex ColorInOut vertexShader(VertexAttr in [[stage_in]])
{
    ColorInOut out;

    float4 position = vector_float4(in.pos, 0 , 1.0);
    out.position = position;
    out.texCoord = in.uv;

    return out;
}

fragment half4 fragmentShader(ColorInOut in [[stage_in]],
                               texture2d<half> mtltexture01 [[texture(0)]])
{
    // 纹理采样对象
    constexpr sampler textureSampler (mag_filter::linear,
    min_filter::linear);
    
    // 采样贴图
    const half4 color = mtltexture01.sample(textureSampler, in.texCoord);
    
    return color;
}
