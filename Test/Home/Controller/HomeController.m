//
//  HomeController.m
//  Test
//
//  Created by SC on 2020/10/22.
//

#import "HomeController.h"
#import <GPUImage/GPUImage.h>
#import <Masonry/Masonry.h>
@interface HomeController ()
//渲染View
@property (strong, nonatomic) GPUImageView *randerView;
//图片输出
@property (strong, nonatomic) GPUImagePicture *imageOutPut;
//图片输出滤镜处理
@property (strong, nonatomic) GPUImageFilter *imageHandleFilter;
//照相机输出
@property (strong, nonatomic) GPUImageVideoCamera *cameraOutPut;
//双输入
@property (strong, nonatomic) GPUImageTwoInputFilter *twoInputFilter;
//平移缩放
@property (strong, nonatomic) GPUImageTransformFilter *transformFilter;
@end

@implementation HomeController

- (void)loadView
{
    [super loadView];
    [self.view addSubview:self.randerView];
    [self.randerView mas_makeConstraints:^(MASConstraintMaker *make) {
        make.edges.mas_equalTo(self.view);
    }];
}

-(void)viewDidLoad
{
    [super viewDidLoad];
}

-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [super touchesBegan:touches withEvent:event];
    
    [self setupFilter];

}

-(void)setupFilter
{
    [self.twoInputFilter removeAllTargets];
    [self.transformFilter removeAllTargets];
    [self.cameraOutPut removeAllTargets];
    [self.imageHandleFilter removeAllTargets];
    [self.imageOutPut removeAllTargets];
    
    [self.imageOutPut addTarget:self.twoInputFilter];
//    [self.imageHandleFilter addTarget:self.twoInputFilter];
//    [self.imageHandleFilter setFrameProcessingCompletionBlock:^(GPUImageOutput *output, CMTime time) {
//
//        [output useNextFrameForImageCapture];
//
//    }];
    
//    [self.cameraOutPut addTarget:self.transformFilter];
    [self.cameraOutPut addTarget:self.twoInputFilter];
    
    [self.twoInputFilter addTarget:self.randerView];
    
    [self.imageOutPut processImage];
    [self.cameraOutPut startCameraCapture];
    
}

#pragma mark -- Getter

-(GPUImageTwoInputFilter *)twoInputFilter
{
    if (_twoInputFilter == nil) {
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

-(GPUImagePicture *)imageOutPut
{
    if (_imageOutPut == nil) {
        UIImage *image = [UIImage imageNamed:@"2021_07_06_14_11_IMG_0711.jpg"];
        _imageOutPut = [[GPUImagePicture alloc] initWithImage:image];
    }
    return _imageOutPut;
}

- (GPUImageFilter *)imageHandleFilter
{
    if (!_imageHandleFilter) {
        _imageHandleFilter = [[GPUImageFilter alloc] init];
    }
    return _imageHandleFilter;
}

-(GPUImageVideoCamera *)cameraOutPut
{
    if (_cameraOutPut == nil) {
        _cameraOutPut = [[GPUImageVideoCamera alloc] initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:AVCaptureDevicePositionBack];
        _cameraOutPut.outputImageOrientation = [UIApplication sharedApplication].statusBarOrientation;
    }
    return _cameraOutPut;
}

-(GPUImageTransformFilter *)transformFilter
{
    if (_transformFilter == nil) {
        _transformFilter = [[GPUImageTransformFilter alloc] init];
        _transformFilter.anchorTopLeft = YES;
        CGAffineTransform transform = CGAffineTransformIdentity;
        transform = CGAffineTransformScale(transform, 0.3, 0.3);
        transform = CGAffineTransformTranslate(transform, (10.0/self.view.frame.size.width)/transform.a, (10.0/self.view.frame.size.width)/transform.a);
        [_transformFilter setAffineTransform:transform];
    }
    return _transformFilter;
}

@end
