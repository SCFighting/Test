//
//  EffectRenderCore.h
//  ARScene
//
//  Created by 刘铁华 on 2019/11/8.
//  Copyright © 2019 meicam.com. All rights reserved.
//

#ifndef EffectRenderCore_h
#define EffectRenderCore_h
#import <NvEffectSdkCore/NvsEffectSdkContext.h>
#import <NvEffectSdkCore/NvsEffectRenderCore.h>
#import <GLKit/GLKit.h>

@interface EffectRenderCore : NSObject

- (instancetype)initWithRender:(NvsEffectRenderCore*)renderCore;

- (void)addRenderEffect:(NvsVideoEffect*)effect;
- (void)removeRenderEffect:(NSString*)effectId;
- (void)cleanupResource;

+(GLuint)createTextureWithWidth:(int)width height:(int)height;

- (int)renderEffect:(CVPixelBufferRef)inputImage timestamp:(int64_t)currentTimeStamp outputTextID:(int)tex flip:(BOOL)isFlip displayRotation:(int)rotation cameraRotation:(int)camerRotation isImageDetectionMode:(BOOL)isImageMode;

@end

#endif /* EffectRenderCore_h */
