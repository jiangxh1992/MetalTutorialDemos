#include <metal_stdlib>
#include <simd/simd.h>
#include "ShaderTypes.h"
using namespace metal;

typedef struct
{
    float3 position [[attribute(0)]];
    float2 texCoord [[attribute(1)]];
    half3 normal    [[attribute(2)]];
    //half3 tangent   [[attribute(3)]];
    //half3 bitangent [[attribute(4)]];
} Vertex;

typedef struct
{
    float4 position [[position]];
    float4 worldPos;
    float2 texCoord;
    float4 normal;
} ColorInOut;

vertex ColorInOut vertexShader(Vertex in [[ stage_in ]],
                               constant Uniforms & uniforms [[ buffer(1) ]])
{
    ColorInOut out;
    float4 position = float4(in.position, 1.0);
    out.position = uniforms.projectionMatrix * uniforms.modelViewMatrix * position;
    out.worldPos = uniforms.modelMatrix * position;
    out.texCoord = in.texCoord;
    out.normal = normalize(uniforms.modelMatrix * float4((float3)in.normal,0));
    return out;
}

fragment half4 fragmentShader(ColorInOut in [[ stage_in ]],
                              constant Uniforms & uniforms [[ buffer(1) ]],
                              texture2d<half> baseColorMap [[ texture(0) ]])
{
    constexpr sampler linearSampler(mip_filter::linear, mag_filter::linear, min_filter::linear, s_address::repeat, t_address::repeat);
    
    half4 color_sample  = baseColorMap.sample(linearSampler,in.texCoord.xy);
    
    // 法线
    float3 N = in.normal.xyz;
    // 入射光方向
    float3 L = - normalize(uniforms.directionalLightDirection);
    // 视线方向
    float3 V = normalize(uniforms.cameraPos - in.worldPos.xyz);
    // 反射光方向
    //float3 R = normalize(2 * fmax(dot(N, L), 0) * N - L);
    // 半角向量
    float3 H = normalize(L + V);
    
    // Lambert diffuse
    float diffuse = uniforms.IL * uniforms.Kd * max(dot(float3(in.normal.xyz),L),0.0);
    
    // Specular(Blinn-Phong)
    float specular = uniforms.IL * uniforms.Ks * pow(fmax(dot(N, H), 0), uniforms.shininess);
    
    // Ambient Glow
    float ambient = uniforms.Ia * uniforms.Ka;
    
    float3 out = float3(uniforms.directionalLightColor) * float3(color_sample.xyz) * (diffuse + specular + ambient);
    
    return half4(half3(out.xyz),1.0f);
}
