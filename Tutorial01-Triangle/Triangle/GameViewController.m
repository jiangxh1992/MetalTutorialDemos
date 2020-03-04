//
//  GameViewController.m
//  Triangle
//
//  Created by Xinhou Jiang on 2020/2/20.
//  Copyright © 2020 Xinhou Jiang. All rights reserved.
//

#import "GameViewController.h"
#import "Renderer.h"

@implementation GameViewController
{
    MTKView *_view;

    Renderer *_renderer; // 渲染器
}

- (void)viewDidLoad
{
    [super viewDidLoad];

    // 将UIView转为MetalKit View，用于Metal渲染
    _view = (MTKView *)self.view;

    // 图形上下文，GPU设备
    _view.device = MTLCreateSystemDefaultDevice();
    // 默认背景色
    _view.backgroundColor = UIColor.blackColor;

    if(!_view.device)
    {
        NSLog(@"Metal is not supported on this device");
        self.view = [[UIView alloc] initWithFrame:self.view.frame];
        return;
    }

    // 初始化渲染器，设置渲染器的渲染对象为_view
    _renderer = [[Renderer alloc] initWithMetalKitView:_view];
    // _view尺寸变化事件，传递给render渲染器
    [_renderer mtkView:_view drawableSizeWillChange:_view.bounds.size];
    // 设置MTKView的delegate为_render，在_render中处理drawableSizeWillChange回调事件
    _view.delegate = _renderer;
}

@end
