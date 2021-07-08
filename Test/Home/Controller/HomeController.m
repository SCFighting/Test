//
//  HomeController.m
//  Test
//
//  Created by SC on 2020/10/22.
//

#import "HomeController.h"
#import <GPUImage/GPUImage.h>
#import <Masonry/Masonry.h>
#import "GPUImagePPPPTFilter.h"
@interface HomeController ()
//渲染View
@property (strong, nonatomic) GPUImageView *randerView;
//图片输出
@property (strong, nonatomic) GPUImagePicture *imageOutPut;
//照相机输出
@property (strong, nonatomic) GPUImageVideoCamera *cameraOutPut;
//双输入
@property (strong, nonatomic) GPUImagePPPPTFilter *twoInputFilter;
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
    
    
    [self.cameraOutPut addTarget:self.twoInputFilter];
    [self.imageOutPut addTarget:self.transformFilter];
    [self.transformFilter addTarget:self.twoInputFilter];
    
    [self.twoInputFilter addTarget:self.randerView];
    [self.cameraOutPut startCameraCapture];

    [self.imageOutPut processImage];
    
}

#pragma mark -- Getter

-(GPUImagePPPPTFilter *)twoInputFilter
{
    if (_twoInputFilter == nil) {
        _twoInputFilter = [[GPUImagePPPPTFilter alloc] init];
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
        UIImage *image = [UIImage imageNamed:@"ppt_portrait_blackbackground.png"];
        _imageOutPut = [[GPUImagePicture alloc] initWithImage:image];
    }
    return _imageOutPut;
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
