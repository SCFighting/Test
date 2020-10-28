//
//  EFEffectManager.m
//  EffectSdkDemo
//
//  Created by 美摄 on 2019/12/11.
//  Copyright © 2019 美摄. All rights reserved.
//

#import "EFEffectManager.h"
#import "UIImage+Extension.h"
#import <CoreMotion/CoreMotion.h>
#import "EffectRenderCore.h"
#import "NvBuffer.h"
#import "NvUtils.h"

@interface EFEffectManager()

@property (nonatomic, assign) GLuint outputTexture;
@property (nonatomic, assign) GLuint outputTexture1;

//@property (nonatomic, strong,readwrite) EAGLContext *glContext;

@property (nonatomic, strong) EffectRenderCore* effectRenderCore;

@property (nonatomic, strong,readwrite) NSMutableArray* effectArray;

//拍照
@property (nonatomic, assign) GLuint photoOutputTexture;
@property (nonatomic, strong) CMMotionManager *coreMotionManager;
@property (nonatomic, assign) UIDeviceOrientation lastEffectiveDeviceOrientation;

@property (nonatomic, assign) CMTime firstTime;
@property (nonatomic, assign) CMTime currentRenderTime;

@end

@implementation EFEffectManager

-(instancetype)init{
    self = [super init];
    if(self){
        [self initializeEffect];
    }
    return self;
}

-(void)initializeEffect{
    // 授权sdk
    NSString *licPath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"8671-306-beb7713c51230829dcb9876c9f009470.lic"];
    if (![NvsEffectSdkContext verifySdkLicenseFile:licPath]) {
        NSLog(@"Invalid license!");
    }
    
//    // 创建opengl环境
//    self.glContext = [[EAGLContext alloc] initWithAPI:kEAGLRenderingAPIOpenGLES2];
//    [EAGLContext setCurrentContext:self.glContext];
    
    // 初始化sdk
    self.effectContext = [NvsEffectSdkContext sharedInstance:NvsEffectSdkContextFlag_NoFlag];
    
    // 安装滤镜资源包
    NSString *fxPackagePath = [[[NSBundle mainBundle] bundlePath] stringByAppendingPathComponent:@"D41B1BC6-23AC-4508-9C8A-F6430BB37C3F.videofx"];
    NvsAssetPackageManagerError err = [self.effectContext.assetPackageManager installAssetPackage:fxPackagePath license:nil type:NvsAssetPackageType_VideoFx sync:YES assetPackageId:nil];
    if (err != NvsAssetPackageManagerError_NoError
        && err != NvsAssetPackageManagerError_AlreadyInstalled) {
        NSLog(@"Failed to install package!");
    }
    
    // 创建sdk特效渲染环境
    self.renderCore = [self.effectContext createEffectRenderCore];
    self.effectRenderCore = [[EffectRenderCore alloc] initWithRender:self.renderCore];
    
    BOOL result = [self.renderCore initializeWithFlags:NvsInitializeFlag_SUPPORT_4K];//[self.renderCore initialize];
    if (!result) {
        NSLog(@"self.renderCore initialize error");
    }
    
    self.effectArray = [NSMutableArray array];
    
    [self enableTakePhoto];
}

-(void)enableTakePhoto{
    //拍照所需
    if (self.coreMotionManager == nil){
        self.coreMotionManager = [[CMMotionManager alloc] init];
    }
    [self.coreMotionManager startAccelerometerUpdates];
    self.lastEffectiveDeviceOrientation = UIDeviceOrientationUnknown;
}

-(BOOL)appendVideoEffect:(NvsVideoEffect*)effect{
    if (!effect) {
        return false;
    }
    [self removeRenderEffect:effect];
    [self.effectRenderCore addRenderEffect:effect];
    [self.effectArray addObject:effect];
    return YES;
}

-(BOOL)removeRenderEffect:(NvsVideoEffect*)effect{
    if (!effect) {
        return false;
    }
    int j = 0;
    NSString *string = @"";
    for (int i = 0; i < self.effectArray.count; i++) {
        if (self.effectArray[i] != nil) {
            NvsVideoEffect* tempeffect = (NvsVideoEffect*)self.effectArray[i];
            if ([effect.builtinName isEqualToString:tempeffect.builtinName] || [effect.packageId isEqualToString:tempeffect.packageId]) {
                j = i;
                string = tempeffect.builtinName.length != 0?tempeffect.builtinName:tempeffect.packageId;
                break;
            }
        }
    }
    if (self.effectArray.count != 0 && string.length != 0) {
        [self.effectArray removeObjectAtIndex:j];
        [self.effectRenderCore removeRenderEffect:string];
    }
    return YES;
}

-(void)prepareTextureIdWithWidth:(int)width height:(int)height{
    if (_outputTexture != 0) {
        return;
    }
    self.outputTexture = [EffectRenderCore createTextureWithWidth:width height:height];
    self.outputTexture1 = [EffectRenderCore createTextureWithWidth:width height:height];
}

- (void)bindTexture:(GLint)texture {
    glBindTexture(GL_TEXTURE_2D, texture);
    [self glCheckError];
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
}

- (void)glCheckError {
    GLenum glErr = glGetError();
    if (glErr != GL_NO_ERROR) {
        NSLog(@"GL error:%d", glErr);
    }
}

-(GLint)textureIdFromSampleBuffer:(CMSampleBufferRef)sampleBuffer output:(AVCaptureOutput *)output isFlipHorizontally:(BOOL)isFlip{
    if (CMTIME_IS_INVALID(self.firstTime)) {
        self.firstTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    }
    CMTime newTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    self.currentRenderTime = CMTimeSubtract(newTime, self.firstTime);
    
    CVPixelBufferRef pixelBuffer = NULL;
    if (self.proportion == 1 && self.takePhotoEnable) {
        pixelBuffer = [NvBuffer modifyImage:sampleBuffer withProportion:1];
    }else{
        pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    }
    
    int bufferWidth = (int)CVPixelBufferGetWidth(pixelBuffer);
    int bufferHeight = (int)CVPixelBufferGetHeight(pixelBuffer);
    if (self.outputTexture == 0) {
        self.outputTexture = [EffectRenderCore createTextureWithWidth:bufferWidth height:bufferHeight];
    }
    [self.effectRenderCore renderEffect:pixelBuffer timestamp:(int64_t)(self.currentRenderTime.value / 1000) outputTextID:self.outputTexture flip:isFlip displayRotation:0 cameraRotation:[self calcRecordingVideoRotation:output isFrontCamera:isFlip] isImageDetectionMode:NO];
    
    [self bindTexture:self.outputTexture];
    
    if (self.proportion == 1) {
        //在1：1比例下，这里需要释放
        CVPixelBufferRelease(pixelBuffer);
    }
    return self.outputTexture;
}

-(CVPixelBufferRef)pixelBufferFromSampleBuffer:(CMSampleBufferRef)sampleBuffer output:(AVCaptureOutput *)output isFlipHorizontally:(BOOL)isFlip{
    if (CMTIME_IS_INVALID(self.firstTime)) {
        self.firstTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    }
    CMTime newTime = CMSampleBufferGetPresentationTimeStamp(sampleBuffer);
    self.currentRenderTime = CMTimeSubtract(newTime, self.firstTime);
    
    // 采集的buffer上传到纹理
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferRef pixelBufferOutput =  nil;
    if (self.effectArray.count > 0) {
       NvsEffectCoreError error = [self.renderCore renderEffects:self.effectArray inputImage:pixelBuffer displayRotation:[self calcRecordingVideoRotation:output isFrontCamera:isFlip] isFlipHorizontally:isFlip timestamp:(int64_t)(self.currentRenderTime.value / 1000) flags:0 outputFrameFormat:NvsEffectPixelFormat_BGRA outputFrameIsBT601:true outputImage:&pixelBufferOutput];
        if (error != NvsEffectCoreError_NoError) {
            NSLog(@"NvsEffectCoreError==%d",error);
        }
        
    }
    return pixelBufferOutput;
}

-(UIImage*)processingPhoto:(AVCapturePhoto *)photo
                    output:(AVCapturePhotoOutput *)output
        isFlipHorizontally:(BOOL)isFlip API_AVAILABLE(ios(11.0)){
    CMTime newTime= CMTimeSubtract(photo.timestamp, self.firstTime);
    return [self processingPhoto:photo output:output timestamp:(int64_t)(newTime.value / 1000) isFlipHorizontally:isFlip];
}

-(UIImage*)processingPhoto:(AVCapturePhoto *)photo output:(AVCapturePhotoOutput *)output timestamp:(int64_t)timestamp isFlipHorizontally:(BOOL)isFlip API_AVAILABLE(ios(11.0)){
    //isFlip该参数间接反映了是否为前置摄像头，返回yes是前置
    CGImagePropertyOrientation orientation = [[photo.metadata objectForKey:(NSString*)kCGImagePropertyOrientation] intValue];
    int imageRotation = 0;
    if (orientation == kCGImagePropertyOrientationRight || orientation == kCGImagePropertyOrientationRightMirrored)
        imageRotation = 90;
    else if (orientation == kCGImagePropertyOrientationDown || orientation == kCGImagePropertyOrientationDownMirrored)
        imageRotation = 180;
    else if (orientation == kCGImagePropertyOrientationLeft || orientation == kCGImagePropertyOrientationLeftMirrored)
        imageRotation = 270;
    
    unsigned int tempWidth = (unsigned int)CVPixelBufferGetWidth(photo.pixelBuffer);
    unsigned int tempHeight = (unsigned int)CVPixelBufferGetHeight(photo.pixelBuffer);
    
    CVPixelBufferRef buffer = NULL;
    if (self.proportion == 1.0) {
        //按1：1比例裁剪，手机支持拍照的分辨率没有1：1，所以需要对图片进行裁剪，画幅要裁剪成1：1
        NSData *data = photo.fileDataRepresentation;
        UIImage *tempImage = [UIImage imageWithData:data];
        UIImage *tempImage_1 = [tempImage modifyImageSize:CGSizeMake(tempHeight, tempHeight)];
        if ([self isTailoringBuffer:CGSizeMake(tempWidth, tempHeight)]) {
            if (isFlip) {
                CGImageRef temp = [tempImage_1 CGImage];
                buffer = [NvBuffer pixelBufferFromCGImage:temp];
            }else{
                UIImage *tempImage_2 = [tempImage_1 scaleImageSize:[self bufferSize]];
                CGImageRef temp = [tempImage_2 CGImage];
                buffer = [NvBuffer pixelBufferFromCGImage:temp];
            }
        }else{
            CGImageRef temp = [tempImage_1 CGImage];
            buffer = [NvBuffer pixelBufferFromCGImage:temp];
        }
    }else if ([self isTailoringBuffer:CGSizeMake(tempWidth, tempHeight)]){
         //按比例缩放，因为某些手机支持拍照的分辨率过大，影响性能，所以需要对大尺寸图片进行缩放，画幅比例要保持和预览的一致
        NSData *data = photo.fileDataRepresentation;
        UIImage *tempImage = [UIImage imageWithData:data];
        UIImage *image2 = [tempImage scaleImageSize:[self bufferSize]];
        CGImageRef temp = [image2 CGImage];
        imageRotation = 0;
        buffer = [NvBuffer pixelBufferFromCGImage:temp];
    }else{
        buffer = photo.pixelBuffer;
    }
    
    unsigned int width = (unsigned int)CVPixelBufferGetWidth(buffer);
    unsigned int height = (unsigned int)CVPixelBufferGetHeight(buffer);
    
    //swap
    if(imageRotation == 90 || imageRotation == 270) {
        unsigned int temp = width;
        width = height;
        height = temp;
    }
    
    if (!self.photoOutputTexture || self.photoOutputTexture == 0) {
        self.photoOutputTexture = [EffectRenderCore createTextureWithWidth:width height:height];
    }
       
    // 采集的buffer上传到纹理
    BOOL isFrontCamera = isFlip;
    int rotationAngle = [self calcRecordingVideoRotation:output isFrontCamera:isFrontCamera];
    rotationAngle = (imageRotation + rotationAngle) % 360;
    int displayAngle = imageRotation;
    if (isFrontCamera){
        displayAngle = 360 - displayAngle;
    }
    
    [self.effectRenderCore renderEffect:buffer timestamp:timestamp outputTextID:self.photoOutputTexture flip:isFrontCamera displayRotation:displayAngle cameraRotation:rotationAngle isImageDetectionMode:YES];

    [self bindTexture:self.photoOutputTexture];
    
    NvsEffectVideoResolution videoEditRes;
    videoEditRes.imageWidth = width;
    videoEditRes.imageHeight = height;
    videoEditRes.imagePAR = (NvsEffectRational){1, 1};
    
    //下传到buffer
    CVPixelBufferRef pixelBufferOutput =  nil;
    [self.renderCore downloadPixelBufferFromTexture:self.photoOutputTexture inputVideoResolution:&videoEditRes outputFrameFormat:NvsEffectPixelFormat_BGRA isBT601:false outputFrame:&pixelBufferOutput];
    
    UIImage *image = [NvBuffer uiImageFromPixelBuffer:pixelBufferOutput];
    UIImage* cpImage = [image drawRoundedRectImage:0 width:image.size.width height:image.size.height];
    
    CVPixelBufferRelease(pixelBufferOutput);
    if (self.proportion == 1.0 || [self isTailoringBuffer:CGSizeMake(tempWidth, tempHeight)]) {
        CVPixelBufferRelease(buffer);
    }
    
    if (_photoOutputTexture > 0){
        glDeleteTextures(1, &_photoOutputTexture);
        _photoOutputTexture = 0;
    }
    
    return cpImage;
}

#pragma mark 是否需要对buffer进行裁剪
- (BOOL)isTailoringBuffer:(CGSize)size{
    if ([[NvUtils iphoneType] isEqualToString:@"iPhone 6 Plus"] && (size.width > 3000 || size.height > 3000 )) {
        return YES;
    }
    return NO;
}

#pragma mark 手机性能不佳，返回一个适合的大小进行拍照
- (CGSize)bufferSize{
    if ([[NvUtils iphoneType] isEqualToString:@"iPhone 6 Plus"]) {
        if (self.proportion == 3.0/4) {
            return CGSizeMake(960, 1280);
        }else if (self.proportion == 9.0/16){
            return CGSizeMake(720, 1280);
        }else if (self.proportion == 1){
            return CGSizeMake(960, 960);
        }
    }
    return CGSizeZero;
}

- (int)calcRecordingVideoRotation:(AVCaptureOutput*)output isFrontCamera:(BOOL)isFrontCamera{
    const int capturedVideoAngle = [self getVideoConnectionOrientation:output];
    const int deviceAngle = [self getUiDeviceOrientationAngle];
    return [self calcRotationAngleBetween:capturedVideoAngle andgle2:0 invert:isFrontCamera];
}

#pragma mark -- 获取设备选择方法

- (int)getVideoConnectionOrientation:(AVCaptureOutput*)output {
    AVCaptureConnection *captureConnection = [output connectionWithMediaType:AVMediaTypeVideo];
    if (!captureConnection) {
        return 0;
    }
    
    if (!captureConnection.supportsVideoOrientation){
        return 0;
    }
    
     int capturedVideoAngle = 0;
      const AVCaptureVideoOrientation capturedVideoOrientation = [captureConnection videoOrientation];
      switch (capturedVideoOrientation) {
      default:
      case AVCaptureVideoOrientationPortrait:
          capturedVideoAngle = 0;
          break;
      case AVCaptureVideoOrientationLandscapeRight:
          capturedVideoAngle = 90;
          break;
      case AVCaptureVideoOrientationPortraitUpsideDown:
          capturedVideoAngle = 180;
          break;
      case AVCaptureVideoOrientationLandscapeLeft:
          capturedVideoAngle = 270;
          break;
      }
      return capturedVideoAngle;
}

- (int)getUiDeviceOrientationAngle
{
    UIDeviceOrientation deviceOrientation = UIDeviceOrientationUnknown;
       if (self.coreMotionManager != nil) {
           CMAccelerometerData *accData = self.coreMotionManager.accelerometerData;
           if (accData != nil) {
               // Convert from G to m/s2, and flip axes:
               CMAcceleration acc = accData.acceleration;
               // skip update if NaN
               if (acc.x == acc.x && acc.y == acc.y && acc.z == acc.z) {
                   static const float G = 9.8066;
                   const float x = (float)(acc.x) * G * -1;
                   const float y = (float)(acc.y) * G * -1;
                   const float z = (float)(acc.z) * G * -1;

                   if (y > 7.35)
                       deviceOrientation = UIDeviceOrientationPortrait;
                   else if (y < -7.35)
                       deviceOrientation = UIDeviceOrientationPortraitUpsideDown;
                   else if (x > 7.35)
                       deviceOrientation = UIDeviceOrientationLandscapeLeft;
                   else if (x < -7.35)
                       deviceOrientation = UIDeviceOrientationLandscapeRight;
                   else if (z > 7.35)
                       deviceOrientation = UIDeviceOrientationFaceUp;
                   else if (z < -7.35)
                       deviceOrientation = UIDeviceOrientationFaceDown;
               }
           }
       }

       if (deviceOrientation == UIDeviceOrientationPortrait ||
           deviceOrientation == UIDeviceOrientationPortraitUpsideDown ||
           deviceOrientation == UIDeviceOrientationLandscapeLeft ||
           deviceOrientation == UIDeviceOrientationLandscapeRight)
           self.lastEffectiveDeviceOrientation = deviceOrientation;
       else if (self.lastEffectiveDeviceOrientation != UIDeviceOrientationUnknown)
           deviceOrientation = self.lastEffectiveDeviceOrientation;
       else
           deviceOrientation = UIDeviceOrientationPortrait;

       switch (deviceOrientation) {
       default:
       case UIDeviceOrientationPortrait:
           return 0;
       case UIDeviceOrientationPortraitUpsideDown:
           return 180;
       case UIDeviceOrientationLandscapeLeft:
           return 90;
       case UIDeviceOrientationLandscapeRight:
           return 270;
       }
}

- (int)calcRotationAngleBetween:(int)angle1 andgle2:(int)angle2 invert:(BOOL)invert
{
    angle1 = angle1 % 360;
    if (angle1 < 0)
        angle1 += 360;

    angle2 = angle2 % 360;
    if (angle2 < 0)
        angle2 += 360;

    int rotationAngle = (angle1 - angle2 + 360) % 360;
    if (invert)
        rotationAngle = (360 - rotationAngle) % 360;

    return rotationAngle;
}

////安装资源
- (NSString*)installAssetPackage:(NSString *)assetPackageFilePath license:(NSString * _Nullable)licenseFilePath type:(NvsAssetPackageType)type{
    NSMutableString* sceneId = [[NSMutableString alloc] initWithString:@""];
    NvsAssetPackageManagerError error = [self.effectContext.assetPackageManager installAssetPackage:assetPackageFilePath license:licenseFilePath type:type sync:YES assetPackageId:sceneId];
    if (error != NvsAssetPackageManagerError_NoError && error != NvsAssetPackageManagerError_AlreadyInstalled) {
        NSLog(@"包裹安装失败");
        return nil;
    }else if(error == NvsAssetPackageManagerError_AlreadyInstalled){
        [self.effectContext.assetPackageManager upgradeAssetPackage:assetPackageFilePath license:licenseFilePath type:type sync:YES assetPackageId:sceneId];
    }
    return sceneId;
}

- (void)cleanupGLResource
{
    if (_outputTexture > 0){
        glDeleteTextures(1, &_outputTexture);
    }
    if (_photoOutputTexture > 0){
        glDeleteTextures(1, &_photoOutputTexture);
    }
    
    _outputTexture = 0;
    _photoOutputTexture = 0;
}

-(void)dealloc{
    [self.effectRenderCore cleanupResource];
    if (_photoOutputTexture > 0) {
        glDeleteTextures(1, &_photoOutputTexture);
    }
    if (_outputTexture > 0){
        glDeleteTextures(1, &_outputTexture);
    }
    if (_outputTexture1 > 0){
        glDeleteTextures(1, &_outputTexture1);
    }
    [self.renderCore clearCacheResources];
    for (NvsVideoEffect *faceEffectModel in self.effectArray) {
        [self.renderCore clearEffectResources:faceEffectModel];
    }
    [self.renderCore cleanUp];
//    [NvsEffectSdkContext destroyInstance];
    
    if (self.coreMotionManager)
        [self.coreMotionManager stopAccelerometerUpdates];
    self.coreMotionManager = nil;
}

- (CVPixelBufferRef)downloadPixelBufferFromTextureOutputTexture:(GLint)output FromSampleBuffer:(CMSampleBufferRef)sampleBuffer{
    CVPixelBufferRef pixelBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    int bufferWidth = (int)CVPixelBufferGetWidth(pixelBuffer);
    int bufferHeight = (int)CVPixelBufferGetHeight(pixelBuffer);
    NvsEffectVideoResolution resolution = [self createResolutionWithSize:CGSizeMake(bufferWidth, bufferHeight)];
    [_renderCore downloadPixelBufferFromTexture:output inputVideoResolution:&resolution outputFrameFormat:NvsEffectPixelFormat_BGRA isBT601:NO outputFrame:&pixelBuffer];
    return pixelBuffer;
}

- (NvsEffectVideoResolution )createResolutionWithSize:(CGSize)size{
    NvsEffectVideoResolution resolution;
    resolution.imageWidth = size.width;
    resolution.imageHeight = size.height;
    resolution.imagePAR = (NvsEffectRational){1, 1};
    return resolution;
}

@end

