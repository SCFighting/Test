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
//摄像头输出
@property (strong, nonatomic) GPUImageVideoCamera *videoCamera;
//图片输出
@property (strong, nonatomic) GPUImagePicture *pictureOutPut;
//图片处理
@property (strong, nonatomic) GPUImageSepiaFilter *stillImageFilter;
//双输入
@property (strong, nonatomic) GPUImageTwoInputFilter *twoInputFilter;
//渲染
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
    [self.pictureOutPut addTarget:self.stillImageFilter];
    [self.stillImageFilter addTarget:self.randerView];
    
    [self.pictureOutPut processImage];
    [self.stillImageFilter useNextFrameForImageCapture];
    [self.stillImageFilter setFrameProcessingCompletionBlock:^(GPUImageOutput *,CMTime) {
        NSLog(@"------------");
    }];
    
    // Do any additional setup after loading the view.
}

#pragma mark -- GPUImageVideoCameraDelegate
//
//-(void)willOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer output:(AVCaptureOutput *)output
//{
//}

#pragma mark -- Getter

-(GPUImageVideoCamera *)videoCamera
{
    if (_videoCamera == nil) {
        _videoCamera = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionFront];
        _videoCamera.outputImageOrientation = UIInterfaceOrientationPortrait;
    }
    return _videoCamera;
}

- (GPUImagePicture *)pictureOutPut
{
    if (!_pictureOutPut) {
        UIImage *image = [UIImage imageNamed:@"1242-2688"];
        _pictureOutPut = [[GPUImagePicture alloc] initWithImage:image];
    }
    return _pictureOutPut;
}

-(GPUImageSepiaFilter *)stillImageFilter
{
    if (!_stillImageFilter) {
        _stillImageFilter = [[GPUImageSepiaFilter alloc] init];
    }
    return _stillImageFilter;
}

-(GPUImageTwoInputFilter *)twoInputFilter
{
    if (!_twoInputFilter) {
        _twoInputFilter = [[GPUImageTwoInputFilter alloc] init];
    }
    return _twoInputFilter;
}

-(GPUImageView *)randerView
{
    if (_randerView == nil) {
        _randerView = [[GPUImageView alloc] init];
    }
    return _randerView;
}

@end
