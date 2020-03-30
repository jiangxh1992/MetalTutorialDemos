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
    
    float Kd; // 漫反射光强度
    float Ks; // 镜面反射强度
    float shininess; // 镜面反射高光系数
    
    vector_float3 cameraPos;
} Uniforms;

#endif /* ShaderTypes_h */

