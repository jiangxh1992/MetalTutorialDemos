/*
See LICENSE folder for this sample’s licensing information.

Abstract:
Implementation of renderer class that perfoms Metal setup and per-frame rendering.
*/
@import simd;
@import ModelIO;
@import MetalKit;

#import "Renderer.h"
#import "AAPLMesh.h"
#import "AAPLMathUtilities.h"
#import "ShaderTypes.h"


@implementation Renderer
{
    id <MTLDevice> _device;
    id <MTLCommandQueue> _commandQueue;

    MTLVertexDescriptor *_defaultVertexDescriptor;

    id <MTLRenderPipelineState> _pipelineState;

    id <MTLDepthStencilState> _relaxedDepthState;
    id <MTLBuffer> _uniformBuffer;

    matrix_float4x4 _projectionMatrix;
    float _rotation;

    NSArray<AAPLMesh *> *_meshes;
}

-(nonnull instancetype)initWithMetalKitView:(nonnull MTKView *)view;
{
    self = [super init];
    if(self)
    {
        _device = view.device;

        [self loadMetalWithMetalKitView:view];
        [self loadAssets];
    }

    return self;
}

- (void)loadMetalWithMetalKitView:(nonnull MTKView *)view
{
    view.depthStencilPixelFormat = MTLPixelFormatDepth32Float_Stencil8;
    view.colorPixelFormat = MTLPixelFormatBGRA8Unorm_sRGB;
    view.sampleCount = 1;
    
    _rotation = 0;
    
    id <MTLLibrary> defaultLibrary = [_device newDefaultLibrary];

    const MTLResourceOptions storageMode = MTLResourceStorageModeShared;
    _uniformBuffer = [_device newBufferWithLength:sizeof(Uniforms)
                                                  options:storageMode];
    _defaultVertexDescriptor = [[MTLVertexDescriptor alloc] init];

    // Positions.
    _defaultVertexDescriptor.attributes[0].format = MTLVertexFormatFloat3;
    _defaultVertexDescriptor.attributes[0].offset = 0;
    _defaultVertexDescriptor.attributes[0].bufferIndex = 0;

    // Texture coordinates.
    _defaultVertexDescriptor.attributes[1].format = MTLVertexFormatFloat2;
    _defaultVertexDescriptor.attributes[1].offset = 12;
    _defaultVertexDescriptor.attributes[1].bufferIndex = 0;
    
    // Normals
    _defaultVertexDescriptor.attributes[2].format = MTLVertexFormatHalf4;
    _defaultVertexDescriptor.attributes[2].offset = 20;
    _defaultVertexDescriptor.attributes[2].bufferIndex = 0;
    
    // ...

    _defaultVertexDescriptor.layouts[0].stride = 44;
    _defaultVertexDescriptor.layouts[0].stepRate = 1;
    _defaultVertexDescriptor.layouts[0].stepFunction = MTLVertexStepFunctionPerVertex;

    id <MTLFunction> vertexStandardMaterial = [defaultLibrary newFunctionWithName:@"vertexShader"];
    id <MTLFunction> fragmentStandardMaterial = [defaultLibrary newFunctionWithName:@"fragmentShader"];
    
    // Create a render pipeline state descriptor.
    MTLRenderPipelineDescriptor * renderPipelineStateDescriptor = [MTLRenderPipelineDescriptor new];

    renderPipelineStateDescriptor.label = @"Forward Lighting";
    renderPipelineStateDescriptor.sampleCount = view.sampleCount;
    renderPipelineStateDescriptor.vertexDescriptor = _defaultVertexDescriptor;
    renderPipelineStateDescriptor.vertexFunction = vertexStandardMaterial;
    renderPipelineStateDescriptor.fragmentFunction = fragmentStandardMaterial;
    renderPipelineStateDescriptor.colorAttachments[0].pixelFormat = view.colorPixelFormat;
    renderPipelineStateDescriptor.depthAttachmentPixelFormat = view.depthStencilPixelFormat;
    renderPipelineStateDescriptor.stencilAttachmentPixelFormat = view.depthStencilPixelFormat;
    
    NSError* error = NULL;
    _pipelineState = [_device newRenderPipelineStateWithDescriptor:renderPipelineStateDescriptor
                                       error:&error];
        
    NSAssert(_pipelineState, @"Failed to create pipeline state: %@", error);

    MTLDepthStencilDescriptor *depthStateDesc = [[MTLDepthStencilDescriptor alloc] init];

    {
        depthStateDesc.depthCompareFunction = MTLCompareFunctionLessEqual;
        depthStateDesc.depthWriteEnabled = YES;
        _relaxedDepthState = [_device newDepthStencilStateWithDescriptor:depthStateDesc];
    }
    _commandQueue = [_device newCommandQueue];
}

// 加载模型
- (void)loadAssets
{
    // Create and load assets into Metal objects.
    NSError *error = nil;

    MDLVertexDescriptor *modelIOVertexDescriptor =
        MTKModelIOVertexDescriptorFromMetal(_defaultVertexDescriptor);
    modelIOVertexDescriptor.attributes[0].name  = MDLVertexAttributePosition;
    modelIOVertexDescriptor.attributes[1].name  = MDLVertexAttributeTextureCoordinate;
    modelIOVertexDescriptor.attributes[2].name    = MDLVertexAttributeNormal;
    //modelIOVertexDescriptor.attributes[3].name   = MDLVertexAttributeTangent;
    //modelIOVertexDescriptor.attributes[4].name = MDLVertexAttributeBitangent;
    NSURL *modelFileURL = [[NSBundle mainBundle] URLForResource:@"Temple.obj" withExtension:nil];
    NSAssert(modelFileURL, @"Could not find model (%@) file in bundle", modelFileURL.absoluteString);
    _meshes = [AAPLMesh newMeshesFromURL:modelFileURL
                 modelIOVertexDescriptor:modelIOVertexDescriptor
                             metalDevice:_device
                                   error:&error];
    
    NSAssert(_meshes, @"Could not find model (%@) file in bundle", error);
}

/// Update app state for the current frame.
- (void)updateGameState
{
    Uniforms * uniforms = (Uniforms*)_uniformBuffer.contents;
    // P
    uniforms->projectionMatrix = _projectionMatrix;
    // V
    uniforms->viewMatrix = matrix_multiply(matrix4x4_translation(0, -100, 1100),
                                           matrix4x4_rotation(-0.5, (vector_float3){1,0,0}));
    // M
    uniforms->modelMatrix = matrix_multiply(matrix4x4_rotation(_rotation, (vector_float3){0,1,0}),
                                            matrix4x4_translation(0, 0, 0));
    // MV
    uniforms->modelViewMatrix = matrix_multiply(uniforms->viewMatrix, uniforms->modelMatrix);
        
    // 平行光
    uniforms->directionalLightDirection = (vector_float3){-1.0,-1.0,-1.0};
    uniforms->directionalLightColor = (vector_float3){0.8,0.8,0.8};
    
    uniforms->IL = 10.0f;
    uniforms->Kd = 0.1f;
    uniforms->Ks = 0.9f;
    uniforms->Ia = 3.0f;
    uniforms->Ka = 0.1f;
    //uniforms->shininess = 15.0f;
    
    uniforms->f = 0.015;
    uniforms->m = 0.8;
    
    uniforms->cameraPos = (vector_float3){0,100,-1100};

    _rotation += 0.002f;
}

/// Called whenever the view changes orientation or size.
- (void) mtkView:(nonnull MTKView *)view drawableSizeWillChange:(CGSize)size
{
    float aspect = size.width / (float)size.height;
    float _fov = 65.0f * (M_PI / 180.0f);
    float _nearPlane = 1.0f;
    float _farPlane = 1500.0f;
    _projectionMatrix = matrix_perspective_left_hand(_fov, aspect, _nearPlane, _farPlane);
}

/// Draw the mesh objects with the given render command encoder.
- (void)drawMeshes:(id<MTLRenderCommandEncoder>)renderEncoder
{
    for (__unsafe_unretained AAPLMesh *mesh in _meshes)
    {
        __unsafe_unretained MTKMesh *metalKitMesh = mesh.metalKitMesh;

        // Set the mesh's vertex buffers.
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

        // Draw each submesh of the mesh.
        for(AAPLSubmesh *submesh in mesh.submeshes)
        {
            // Set any textures that you read or sample in the render pipeline.
            [renderEncoder setFragmentTexture:submesh.textures[0]
                                      atIndex:0];

            [renderEncoder setFragmentTexture:submesh.textures[1]
                                      atIndex:1];

            [renderEncoder setFragmentTexture:submesh.textures[2]
                                      atIndex:2];
            [renderEncoder setFragmentBuffer:_uniformBuffer offset:0 atIndex:1];

            MTKSubmesh *metalKitSubmesh = submesh.metalKitSubmmesh;

            [renderEncoder drawIndexedPrimitives:metalKitSubmesh.primitiveType
                                      indexCount:metalKitSubmesh.indexCount
                                       indexType:metalKitSubmesh.indexType
                                     indexBuffer:metalKitSubmesh.indexBuffer.buffer
                               indexBufferOffset:metalKitSubmesh.indexBuffer.offset];
        }
    }
}

- (void) drawInMTKView:(nonnull MTKView *)view
{
    id <MTLCommandBuffer> commandBuffer = [_commandQueue commandBuffer];
    commandBuffer.label = @"MyCommand";

    [self updateGameState];

    MTLRenderPassDescriptor *renderPassDescriptor = view.currentRenderPassDescriptor;
  
    if(renderPassDescriptor != nil)
    {
        id <MTLRenderCommandEncoder> renderEncoder =
            [commandBuffer renderCommandEncoderWithDescriptor:renderPassDescriptor];

        [renderEncoder setCullMode:MTLCullModeBack];

        [renderEncoder pushDebugGroup:@"Render Forward Lighting"];
        [renderEncoder setRenderPipelineState:_pipelineState];
        [renderEncoder setDepthStencilState:_relaxedDepthState];
        [renderEncoder setVertexBuffer:_uniformBuffer offset:0 atIndex:1];
        [self drawMeshes:renderEncoder];
        [renderEncoder popDebugGroup];

        [renderEncoder endEncoding];
    }

    // Schedule a presentation for the current drawable, after the framebuffer is complete.
    [commandBuffer presentDrawable:view.currentDrawable];

    // Finalize rendering here and send the command buffer to the GPU.
    [commandBuffer commit];
}

@end
