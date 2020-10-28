//
//  EFEffectManager.h
//  EffectSdkDemo
//
//  Created by 美摄 on 2019/12/11.
//  Copyright © 2019 美摄. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <AVFoundation/AVFoundation.h>
//#import "EFLiveWindow.h"
#import "EFFaceEffectModel.h"
#import <NvEffectSdkCore/NvsEffectSdkContext.h>
#import <NvEffectSdkCore/NvsEffectAssetPackageManager.h>

NS_ASSUME_NONNULL_BEGIN

typedef void(^EFEffectManagerBlock)(void);
@interface EFEffectManager : NSObject

//@property (nonatomic, readonly) EAGLContext *glContext;

@property (nonatomic, strong) NvsEffectSdkContext *effectContext;
@property (nonatomic, strong) NvsEffectRenderCore *renderCore;
@property (nonatomic, copy) EFEffectManagerBlock callBack;

/// 画幅比例
@property (nonatomic, assign) CGFloat proportion;

@property (nonatomic, assign) BOOL takePhotoEnable;
-(instancetype)init;
-(instancetype)initWithEffectQueue:(dispatch_queue_t)effectQueue ;

-(BOOL)appendVideoEffect:(NvsVideoEffect*)effect;

-(BOOL)removeRenderEffect:(NvsVideoEffect*)effect;

-(GLint)textureIdFromSampleBuffer:(CMSampleBufferRef)sampleBuffer output:(AVCaptureOutput *)output isFlipHorizontally:(BOOL)isFlip;

-(CVPixelBufferRef)pixelBufferFromSampleBuffer:(CMSampleBufferRef)sampleBuffer output:(AVCaptureOutput *)output isFlipHorizontally:(BOOL)isFlip;

- (CVPixelBufferRef)downloadPixelBufferFromTextureOutputTexture:(GLint)output FromSampleBuffer:(CMSampleBufferRef)sampleBuffer;

-(UIImage*)processingPhoto:(AVCapturePhoto *)photo
                    output:(AVCapturePhotoOutput *)output
        isFlipHorizontally:(BOOL)isFlip API_AVAILABLE(ios(11.0));

////安装资源
- (NSString*)installAssetPackage:(NSString *)assetPackageFilePath license:(NSString * _Nullable )licenseFilePath type:(NvsAssetPackageType)type;

- (void)cleanupGLResource;

@end

NS_ASSUME_NONNULL_END
