#include <metal_stdlib>
#include <simd/simd.h>
#include "ShaderTypes.h"
using namespace metal;

typedef struct
{
    float3 position [[attribute(0)]];
    float2 texCoord [[attribute(1)]];
    //half3 normal    [[attribute(2)]];
    //half3 tangent   [[attribute(3)]];
    //half3 bitangent [[attribute(4)]];
} Vertex;

typedef struct
{
    float4 position [[position]];
    float2 texCoord;
} ColorInOut;

vertex ColorInOut vertexShader(Vertex in [[ stage_in ]])
{
    ColorInOut out;
    float4 position = vector_float4(in.position/500.0f + float3(0,-0.3,0), 1.0);
    out.position = position;
    out.texCoord = in.texCoord;
    return out;
}

fragment half4 fragmentShader(ColorInOut in [[ stage_in ]],
                              texture2d<half> baseColorMap [[ texture(0) ]])
{
    constexpr sampler linearSampler(mip_filter::linear, mag_filter::linear, min_filter::linear, s_address::repeat, t_address::repeat);
    
    half4 color_sample  = baseColorMap.sample(linearSampler,in.texCoord.xy);
    
    return color_sample;
}
