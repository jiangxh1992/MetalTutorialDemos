//
//  ShaderTypes.h
//  UniformBuffer
//
//  Created by Xinhou Jiang on 2020/3/17.
//  Copyright © 2020 Xinhou Jiang. All rights reserved.
//

//
//  Header containing types and enum constants shared between Metal shaders and Swift/ObjC source
//
#ifndef ShaderTypes_h
#define ShaderTypes_h

#ifdef __METAL_VERSION__
#define NS_ENUM(_type, _name) enum _name : _type _name; enum _name : _type
#define NSInteger metal::int32_t
#else
#import <Foundation/Foundation.h>
#endif

#include <simd/simd.h>

typedef NS_ENUM(NSInteger, BufferIndex)
{
    BufferIndexMeshPositions = 0,
    BufferIndexMeshGenerics  = 1,
    BufferIndexUniforms      = 2
};

typedef NS_ENUM(NSInteger, VertexAttribute)
{
    VertexAttributePosition  = 0,
    VertexAttributeTexcoord  = 1,
};

typedef NS_ENUM(NSInteger, TextureIndex)
{
    TextureIndexColor    = 0,
};

typedef struct
{
    matrix_float4x4 projectionMatrix;
    matrix_float4x4 modelViewMatrix;
    matrix_float4x4 modelMatrix;
    matrix_float4x4 viewMatrix;
        
    vector_float3 directionalLightDirection;
    vector_float3 directionalLightColor;
    
    float IL; // 平行光源强度
    float Kd; // 漫反射光系数
    float Ks; // 镜面反射系数
    float Ia; // 环境光强度
    float Ka; // 环境光系数
    //float shininess; // 镜面反射高光指数
    
    float f; // 菲涅耳系数
    float m; // 法线分布粗糙度
    
    vector_float3 cameraPos;
} Uniforms;

#endif /* ShaderTypes_h */

