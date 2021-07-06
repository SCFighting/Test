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
@property (strong, nonatomic) GPUImagePicture *imageOutPut;
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
    UIImage *image = [UIImage imageNamed:@"2021_07_06_14_11_IMG_0711.jpg"];
    self.imageOutPut = [[GPUImagePicture alloc] initWithImage:image];
    [self.imageOutPut addTarget:self.randerView];
    [self.imageOutPut processImage];
}

#pragma mark -- Getter

-(GPUImageView *)randerView
{
    if (_randerView == nil) {
        _randerView = [[GPUImageView alloc] init];
    }
    return _randerView;
}

@end
