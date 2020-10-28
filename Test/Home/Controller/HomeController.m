//
//  HomeController.m
//  Test
//
//  Created by SC on 2020/10/22.
//

#import "HomeController.h"
#import <GPUImage/GPUImage.h>
#import <Masonry/Masonry.h>
#import "EFEffectManager.h"
#import "EFARSceneFaceEffectModel.h"
@interface HomeController ()<GPUImageVideoCameraDelegate,EFARSceneFaceEffectModelDelegate>
@property (strong, nonatomic) GPUImageVideoCamera *videoCamera;
@property (strong, nonatomic) GPUImageView *randerView;
@property (strong, nonatomic) EFEffectManager *effectManager;
@property (strong, nonatomic) EFARSceneFaceEffectModel *faceEffectModel;
@end

@implementation HomeController

-(void)loadView
{
    [super loadView];
    [self.view addSubview:self.randerView];
    [self.randerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
}

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.videoCamera addTarget:self.randerView];
    [self.videoCamera startCameraCapture];
    // Do any additional setup after loading the view.
}

#pragma mark -- GPUImageVideoCameraDelegate

-(void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer output:(AVCaptureOutput *)output
{
    GLint lint;
//            dispatch_sync(dispatch_get_main_queue(), ^{
    lint = [self.effectManager textureIdFromSampleBuffer:sampleBuffer output:output isFlipHorizontally:YES];
    
    CVImageBufferRef pixelBuffer = [self.effectManager downloadPixelBufferFromTextureOutputTexture:lint FromSampleBuffer:sampleBuffer];
    //livewindow 绘制
    if (pixelBuffer != nil) {
        [self.videoCamera processVideoSampleBuffer:sampleBuffer imageBufferRef:pixelBuffer];
    }else{
        pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
        [self.videoCamera processVideoSampleBuffer:sampleBuffer imageBufferRef:pixelBuffer];
    }
//            });
    
    
    CVPixelBufferRelease(pixelBuffer);
    if (lint > 0) {
        lint = 0;
    }
}

#pragma mark -- EFARSceneFaceEffectModelDelegate

/// 如果没有检测到人脸会走这个回调
- (void)notifyFace
{
    NSLog(@"888888888");
}

#pragma mark -- Getter

-(GPUImageVideoCamera *)videoCamera
{
    if (_videoCamera == nil) {
        _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionFront];
        _videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
        _videoCamera.delegate = self;
    }
    return _videoCamera;
}

-(GPUImageView *)randerView
{
    if (_randerView == nil) {
        _randerView = [[GPUImageView alloc] init];
    }
    return _randerView;
}

- (EFEffectManager *)effectManager
{
    if (_effectManager == nil) {
        _effectManager = [[EFEffectManager alloc] init];
        _effectManager.proportion = 4.0/3;
    }
    return _effectManager;
}

-(EFARSceneFaceEffectModel *)faceEffectModel
{
    if (_faceEffectModel == nil) {
        _faceEffectModel = [[EFARSceneFaceEffectModel alloc] init];
        _faceEffectModel.delegate = self;
        //使用
        NvsVideoEffect* videoEffect = [self.faceEffectModel createVideoEffectWithContext:self.effectManager.effectContext];
        [self.effectManager appendVideoEffect:videoEffect];
        
        [_faceEffectModel enableBeauty:YES];
        [_faceEffectModel enableBeautyType:YES];
        [_faceEffectModel useLutWhiten:YES];
    }
    return _faceEffectModel;
}

@end
