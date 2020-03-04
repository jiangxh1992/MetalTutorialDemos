//
//  Renderer.m
//
//  Created by Xinhou Jiang on 2020/2/20.
//  Copyright © 2020 Xinhou Jiang. All rights reserved.
//

#import <simd/simd.h>
#import "Renderer.h"
#import "ShaderTypes.h"
#import "AAPLMathUtilities.h"
#import "AAPLMesh.h"

@implementation Renderer
{
    id <MTLDevice> _device;
    id <MTLCommandQueue> _commandQueue;

    id <MTLRenderPipelineState> _pipelineState;
    id <MTLRenderPipelineState> _myResolvePipelineState;
    id <MTLDepthStencilState> _depthState;
        
    id<MTLTexture> mtltexture01;
    
    MTLVertexDescriptor *vertexDescriptor;
    
    id<MTLBuffer> uniformBuffer;
    
    matrix_float4x4 projectionMatrix;
    
    NSArray<AAPLMesh *> *meshes;
    
    float _rotation;
}

-(nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)view;
{
    self = [super init];
    if(self)
    {
        _device = view.device;
        [self _loadMetalWithView:view];
        [self _loadAssets];
    }
    return self;
}

- (void)_loadMetalWithView:(nonnull MTKView *)view;
{
    view.depthStencilPixelFormat = MTLPixelFormatDepth32Float_Stencil8;
    view.colorPixelFormat = MTLPixelFormatBGRA8Unorm_sRGB;
    view.sampleCount = 1;

    id<MTLLibrary> defaultLibrary = [_device newDefaultLibrary];
    
    vertexDescriptor = [[MTLVertexDescriptor alloc] init];
    // pos
    vertexDescriptor.attributes[0].format = MTLVertexFormatFloat3;
    vertexDescriptor.attributes[0].offset = 0;
    vertexDescriptor.attributes[0].bufferIndex = 0;
    // uv
    vertexDescriptor.attributes[1].format = MTLVertexFormatFloat2;
    vertexDescriptor.attributes[1].offset = 12;
    vertexDescriptor.attributes[1].bufferIndex = 0;
    
    vertexDescriptor.attributes[2].format = MTLVertexFormatFloat3;
    vertexDescriptor.attributes[2].offset = 20;
    vertexDescriptor.attributes[2].bufferIndex = 0;
    
    vertexDescriptor.attributes[3].format = MTLVertexFormatFloat3;
    vertexDescriptor.attributes[3].offset = 32;
    vertexDescriptor.attributes[3].bufferIndex = 0;

    vertexDescriptor.attributes[4].format = MTLVertexFormatFloat3;
    vertexDescriptor.attributes[4].offset = 44;
    vertexDescriptor.attributes[4].bufferIndex = 0;
    // layout
    vertexDescriptor.layouts[0].stride = 56;
    vertexDescriptor.layouts[0].stepRate = 1;
    vertexDescriptor.layouts[0].stepFunction = MTLVertexStepFunctionPerVertex;

    id <MTLFunction> vertexFunction = [defaultLibrary newFunctionWithName:@"vertexShader"];
    id <MTLFunction> fragmentFunction = [defaultLibrary newFunctionWithName:@"fragmentShader"];

    MTLRenderPipelineDescriptor *pipelineStateDescriptor = [[MTLRenderPipelineDescriptor alloc] init];
    pipelineStateDescriptor.label = @"MyPipeline";
    pipelineStateDescriptor.sampleCount = view.sampleCount;
    pipelineStateDescriptor.vertexDescriptor = vertexDescriptor;
    pipelineStateDescriptor.vertexFunction = vertexFunction;
    pipelineStateDescriptor.fragmentFunction = fragmentFunction;
    pipelineStateDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat;
    pipelineStateDescriptor.depthAttachmentPixelFormat = view.depthStencilPixelFormat;
    pipelineStateDescriptor.stencilAttachmentPixelFormat = view.depthStencilPixelFormat;

    NSError *error = NULL;
    _pipelineState = [_device newRenderPipelineStateWithDescriptor:pipelineStateDescriptor error:&error];
    if (!_pipelineState)
    {
        NSLog(@"Failed to created pipeline state, error %@", error);
    }
    
    MTLDepthStencilDescriptor *depthStateDesc = [[MTLDepthStencilDescriptor alloc] init];
    depthStateDesc.depthCompareFunction = MTLCompareFunctionLess;
    depthStateDesc.depthWriteEnabled = YES;
    _depthState = [_device newDepthStencilStateWithDescriptor:depthStateDesc];

    _commandQueue = [_device newCommandQueue];
}

- (void)_loadAssets
{
    NSError *error;
    
    // load obj model
    MDLVertexDescriptor *modelIOVertexDescriptor = MTKModelIOVertexDescriptorFromMetal(vertexDescriptor);
    modelIOVertexDescriptor.attributes[0].name = MDLVertexAttributePosition;
    modelIOVertexDescriptor.attributes[1].name = MDLVertexAttributeNormal;
    NSURL *modelUrl = [[NSBundle mainBundle] URLForResource:@"Temple.obj" withExtension:nil];
    meshes = [AAPLMesh newMeshesFromURL:modelUrl modelIOVertexDescriptor:modelIOVertexDescriptor metalDevice:_device error:&error];
    if(!meshes || error){
        NSLog(@"load meshes from url failure");
    }
    
    // 加载贴图
    MTKTextureLoader* textureLoader = [[MTKTextureLoader alloc] initWithDevice:_device];
    NSDictionary *textureLoaderOptions =
    @{
      MTKTextureLoaderOptionTextureUsage       : @(MTLTextureUsageShaderRead),
      MTKTextureLoaderOptionTextureStorageMode : @(MTLStorageModePrivate)
      };
    mtltexture01 = [textureLoader newTextureWithName:@"texture01"
                                         scaleFactor:1.0
                                              bundle:nil
                                             options:textureLoaderOptions
                                               error:&error];
    if(!mtltexture01 || error)
    {
        NSLog(@"Error creating texture %@", error.localizedDescription);
    }
    
    // uniformbuffer
    uniformBuffer = [_device newBufferWithLength:sizeof(Uniforms) options:MTLResourceStorageModeShared];
    uniformBuffer.label = @"MyUniformBuffer";
    
    _rotation = 0;
}

/// Draw our AAPLMesh objects with the given renderEncoder
- (void)drawMeshes:(id<MTLRenderCommandEncoder>)renderEncoder
{
    for (__unsafe_unretained AAPLMesh *mesh in meshes)
    {
        __unsafe_unretained MTKMesh *metalKitMesh = mesh.metalKitMesh;

        // Set mesh's vertex buffers
        for (NSUInteger bufferIndex = 0; bufferIndex < metalKitMesh.vertexBuffers.count; bufferIndex++)
        {
            __unsafe_unretained MTKMeshBuffer *vertexBuffer = metalKitMesh.vertexBuffers[bufferIndex];
            if((NSNull*)vertexBuffer != [NSNull null])
            {
                [renderEncoder setVertexBuffer:vertexBuffer.buffer
                                        offset:vertexBuffer.offset
                                       atIndex:bufferIndex];
            }
        }

        // Draw each submesh of our mesh
        for(AAPLSubmesh *submesh in mesh.submeshes)
        {
            // Set any textures read/sampled from our render pipeline
            [renderEncoder setFragmentTexture:submesh.textures[0]
                                      atIndex:0];

            [renderEncoder setFragmentTexture:submesh.textures[1]
                                      atIndex:1];
            
            [renderEncoder setFragmentTexture:submesh.textures[2]
                                      atIndex:2];

            MTKSubmesh *metalKitSubmesh = submesh.metalKitSubmmesh;

            [renderEncoder drawIndexedPrimitives:metalKitSubmesh.primitiveType
                                      indexCount:metalKitSubmesh.indexCount
                                       indexType:metalKitSubmesh.indexType
                                     indexBuffer:metalKitSubmesh.indexBuffer.buffer
                               indexBufferOffset:metalKitSubmesh.indexBuffer.offset];
        }
    }
}

// 每帧更新全局数据
-(void)updateGameState
{
    Uniforms *uniforms = (Uniforms*)uniformBuffer.contents;
    uniforms->projectionMatrix = projectionMatrix;
    // V
    matrix_float4x4 viewMatrix = matrix_multiply(matrix4x4_translation(0.0, 0, 1000.5),
                                        matrix_multiply(matrix4x4_rotation(-0.5,(vector_float3){1,0,0}),
                                                    matrix4x4_rotation(0, (vector_float3){0,1,0} )));
    // M
    matrix_float4x4 modelMatrix = matrix4x4_rotation(_rotation, (vector_float3){0,1,0});
    modelMatrix = matrix_multiply(modelMatrix, matrix4x4_translation(0.0,0,0));
    // MV
    uniforms->modelViewMatrix = matrix_multiply(viewMatrix, modelMatrix);
    
    _rotation += 0.02f;
}

- (void)drawInMTKView:(nonnull MTKView *)view
{
    [self updateGameState];
    
    id <MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    commandBuffer.label = @"MyCommand";
    MTLRenderPassDescriptor* renderPassDescriptor = view.currentRenderPassDescriptor;
    if(renderPassDescriptor != nil)
    {
        id <MTLRenderCommandEncoder> renderEncoder =
        [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];
        renderEncoder.label = @"MyRenderEncoder";

        [renderEncoder pushDebugGroup:@"DrawMehses"];
        [renderEncoder setRenderPipelineState:_pipelineState];
        [renderEncoder setDepthStencilState:_depthState];
        [renderEncoder setVertexBuffer:uniformBuffer offset:0 atIndex:1];
        [self drawMeshes:renderEncoder];
        [renderEncoder popDebugGroup];

        [renderEncoder endEncoding];
        [commandBuffer presentDrawable:view.currentDrawable];
    }

    [commandBuffer commit];
}

- (void)mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size
{
    /// Respond to drawable size or orientation changes here
    
    // 根据视图尺寸调整相机视角
    float aspect = size.width / (float)size.height;
    float fov = 65.0f * (M_PI / 180.0f);
    float nearZ = 0.1f;
    float farZ = 1500.0f;
    projectionMatrix = matrix_perspective_left_hand(fov, aspect, nearZ, farZ);
}

@end
