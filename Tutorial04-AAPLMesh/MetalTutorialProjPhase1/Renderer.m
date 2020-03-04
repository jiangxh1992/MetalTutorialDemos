//
//  Renderer.m
//
//  Created by Xinhou Jiang on 2020/2/20.
//  Copyright © 2020 Xinhou Jiang. All rights reserved.
//

#import <simd/simd.h>
#import "Renderer.h"
#import "ShaderTypes.h"
#import "AAPLMesh.h"

@implementation Renderer
{
    id <MTLDevice> _device;
    id <MTLCommandQueue> _commandQueue;

    id <MTLRenderPipelineState> _pipelineState;
    id <MTLRenderPipelineState> _myResolvePipelineState;
    id <MTLDepthStencilState> _depthState;
    
    MTLVertexDescriptor *vertexDescriptor;
        
    matrix_float4x4 projectionMatrix;
    
    NSArray<AAPLMesh *> *meshes;
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
    // layout
    vertexDescriptor.layouts[0].stride = 20;
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

            [renderEncoder setFragmentTexture:submesh.textures[2]
                                      atIndex:2];

            [renderEncoder setFragmentTexture:submesh.textures[1]
                                      atIndex:1];

            MTKSubmesh *metalKitSubmesh = submesh.metalKitSubmmesh;

            [renderEncoder drawIndexedPrimitives:metalKitSubmesh.primitiveType
                                      indexCount:metalKitSubmesh.indexCount
                                       indexType:metalKitSubmesh.indexType
                                     indexBuffer:metalKitSubmesh.indexBuffer.buffer
                               indexBufferOffset:metalKitSubmesh.indexBuffer.offset];
        }
    }
}

- (void)drawInMTKView:(nonnull MTKView *)view
{
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
}

@end
