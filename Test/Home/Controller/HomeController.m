//
//  HomeController.m
//  Test
//
//  Created by SC on 2020/10/22.
//

#import "HomeController.h"
#import <GPUImage/GPUImage.h>
#import <Masonry/Masonry.h>
@interface HomeController ()<GPUImageVideoCameraDelegate>
@property (strong, nonatomic) GPUImageVideoCamera *videoCamera;
@property (strong, nonatomic) GPUImageView *randerView;
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

@end
