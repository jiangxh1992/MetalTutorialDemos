//
//  ShaderTypes.h
//  Triangle
//
//  Created by Xinhou Jiang on 2020/2/20.
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

typedef struct
{
    vector_float2 pos;
} Vertex;

#endif /* ShaderTypes_h */

