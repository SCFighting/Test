//
//  EffectRenderCore.m
//  ARScene
//
//  Created by 刘铁华 on 2019/11/8.
//  Copyright © 2019 meicam.com. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EffectRenderCore.h"
#import <CoreMedia/CoreMedia.h>
#import <OpenGLES/ES2/gl.h>
#import <OpenGLES/ES2/glext.h>
#import <AVFoundation/AVFoundation.h>
#import <CoreVideo/CVPixelBuffer.h>
#import <CoreFoundation/CFBase.h>
#import <NvEffectSdkCore/NvsARSceneManipulate.h>


@interface EffectRenderCore ()

@end

@implementation EffectRenderCore
{
    NvsEffectRenderCore* m_renderCore;
    BOOL  m_isInitialized;
    NSMutableArray*  m_effectList;
    NSMutableArray*  m_removeEffectList;
    NSLock* m_lock;
    
    GLuint m_inputTexture;
    GLuint m_outputTexture;
    GLuint m_tempTexture;
    
    int m_processTextureWidth;
    int m_processTextureHeight;
}

- (instancetype)initWithRender:(NvsEffectRenderCore*)renderCore
{
    self = [super init];
    
    m_renderCore = renderCore;
    m_isInitialized = false;
    m_effectList = [[NSMutableArray alloc] init];
    m_removeEffectList = [[NSMutableArray alloc] init];
    m_lock = [[NSLock alloc] init];
    
    m_inputTexture = 0;
    m_outputTexture = 0;
    m_tempTexture = 0;
    
    m_processTextureWidth = 0;
    m_processTextureHeight = 0;
    
    return self;
}

- (void)dealloc {
    [self cleanupResource];
}

+ (void)glCheckError {
    GLenum glErr = glGetError();
    if (glErr != GL_NO_ERROR) {
        NSLog(@"Render Core GL error:%d", glErr);
    }
}

- (void)addRenderEffect:(NvsVideoEffect*)effect
{
    if (effect == nil)
        return;
    
    [m_lock lock];
    
    [m_effectList addObject:effect];
    
    [m_lock unlock];
}

- (void)removeRenderEffect:(NSString*)effectId
{
    [m_lock lock];
    
    for (int i = 0; i < m_effectList.count; i++) {
        if (m_effectList[i] != nil) {
            NvsVideoEffect* effect = (NvsVideoEffect*)m_effectList[i];
            if ([effect.builtinName isEqualToString:effectId] || [effect.packageId isEqualToString:effectId]) {
                [m_effectList removeObject:effect];
                [m_removeEffectList addObject:effect];
            }
        }
    }
    
    [m_lock unlock];
}

- (void)cleanupResource
{
    if (m_renderCore == nil)
        return;
    
    [m_lock lock];
    
    for (int i = 0; i < m_effectList.count; i++) {
        if (m_effectList[i] != nil) {
            NvsVideoEffect* effect = (NvsVideoEffect*)m_effectList[i];
            [m_renderCore clearEffectResources:effect];
        }
    }
    
    [m_effectList removeAllObjects];
    for (int i = 0; i < m_removeEffectList.count; i++) {
        if (m_removeEffectList[i] != nil) {
            NvsVideoEffect* effect = (NvsVideoEffect*)m_removeEffectList[i];
            [m_renderCore clearEffectResources:effect];
        }
    }
    [m_removeEffectList removeAllObjects];
    [m_lock unlock];
    
    [m_renderCore clearCacheResources];
    [m_renderCore cleanUp];
    
    if (m_inputTexture > 0)
        glDeleteTextures(1, &m_inputTexture);
    if (m_outputTexture > 0)
        glDeleteTextures(1, &m_outputTexture);
    if (m_tempTexture > 0)
        glDeleteTextures(1, &m_tempTexture);
    
    m_inputTexture = 0;
    m_outputTexture = 0;
    m_tempTexture = 0;
    m_renderCore = nil;
}

- (int)renderEffect:(CVPixelBufferRef)inputImage timestamp:(int64_t)currentTimeStamp outputTextID:(int)tex flip:(BOOL)isFlip displayRotation:(int)rotation cameraRotation:(int)camerRotation isImageDetectionMode:(BOOL)isImageMode
{
    GLint fboBuffer;
    glGetIntegerv(GL_FRAMEBUFFER_BINDING, &fboBuffer);
    
    int ret = [self renderEffectInternal:inputImage timestamp:currentTimeStamp outputTextID:tex flip:isFlip displayRotation:rotation cameraRotation:camerRotation isImageDetectionMode:isImageMode];
    
    if (fboBuffer != 0)
        glBindFramebuffer(GL_FRAMEBUFFER, fboBuffer);
    
    return ret;
}

- (int)renderEffectInternal:(CVPixelBufferRef)inputImage timestamp:(int64_t)currentTimeStamp outputTextID:(int)tex flip:(BOOL)isFlip displayRotation:(int)rotation cameraRotation:(int)camerRotation isImageDetectionMode:(BOOL)isImageMode
{
    if (m_renderCore == nil)
        return -1;
    
   NSMutableArray* renderList = [[NSMutableArray alloc] init];
    [m_lock lock];
    //clean up removed effect
    for (int i = 0; i < m_removeEffectList.count; i++) {
        if (m_removeEffectList[i] != nil) {
            NvsVideoEffect* effect = (NvsVideoEffect*)m_removeEffectList[i];
            [m_renderCore clearEffectResources:effect];
        }
    }
    [m_removeEffectList removeAllObjects];
    
    //add to render list
    for (int i = 0; i < m_effectList.count; i++) {
        [renderList addObject:m_effectList[i]];
    }
    [m_lock unlock];
    
    if (!m_isInitialized)
        m_isInitialized = [m_renderCore initializeWithFlags:NvsInitializeFlag_SUPPORT_4K];
    
    BOOL buddyBufferIsFlip = isFlip;
    if (renderList.count < 1) {
        //no effect to render
        [m_renderCore uploadPixelBufferToTexture:inputImage displayRotation:rotation horizontalFlip:isFlip outputTexId:tex];
        return 0;
    }
    
    unsigned int imageWidth = (unsigned int)CVPixelBufferGetWidth(inputImage);
    unsigned int imageHeight = (unsigned int)CVPixelBufferGetHeight(inputImage);
    unsigned int width = imageWidth;
    unsigned int height = imageHeight;
    if (rotation == 90 || rotation == 270) {
        unsigned int temp = width;
        width = height;
        height = temp;
    }
    
    //check texture is valid
    if (m_processTextureWidth != width || m_processTextureHeight != height) {
        if (m_inputTexture > 0)
            glDeleteTextures(1, &m_inputTexture);
        if (m_tempTexture > 0)
            glDeleteTextures(1, &m_tempTexture);
        if (m_outputTexture > 0)
            glDeleteTextures(1, &m_outputTexture);
        
        m_inputTexture = 0;
        m_tempTexture = 0;
        m_outputTexture = 0;
    }
    
    m_processTextureWidth = width;
    m_processTextureHeight = height;
    
    NvsEffectVideoResolution videoEditRes;
    videoEditRes.imageWidth = width;
    videoEditRes.imageHeight = height;
    videoEditRes.imagePAR = (NvsEffectRational){1, 1};
    
    //init input texture
    if (m_inputTexture == 0) {
        m_inputTexture = [EffectRenderCore createTextureWithWidth:width height:height];
    }
    //upload to texture
    [m_renderCore uploadPixelBufferToTexture:inputImage displayRotation:rotation horizontalFlip:isFlip outputTexId:m_inputTexture];
    
    CVPixelBufferRef buddyPixelBuffer = inputImage;
       
    //fill video frame info
    NvsEffectVideoFrameInfo videoFrameInfo;
    [self fillVideoFrameInfoFromPixelBuffer:buddyPixelBuffer videoFrameInfo:&videoFrameInfo];
    videoFrameInfo.flipHorizontally = buddyBufferIsFlip;
    videoFrameInfo.displayRotation = rotation;
             
    GLuint inputTexture = m_inputTexture;
    GLuint outputTexture = 0;
    if (renderList.count == 1)
        outputTexture = tex;
    else {
        if (m_outputTexture == 0) {
            m_tempTexture = [EffectRenderCore createTextureWithWidth:width height:height];
            m_outputTexture = [EffectRenderCore createTextureWithWidth:width height:height];
        }
        outputTexture = m_outputTexture;
    }
    
    //render effect list
    NvsEffectCoreError renderError = NvsEffectCoreError_NoError;
    for (int i = 0; i < renderList.count; i++) {
        NvsVideoEffect* effect = (NvsVideoEffect*)renderList[i];
        if (effect == nil) {
            NSLog(@"current effect is invalid!");
            continue;
        }
        
         if ( i == (renderList.count - 1))
             outputTexture = tex;
        
        //render effect
        if ([effect.builtinName isEqualToString:@"AR Scene"]) {
            CVReturn ret = CVPixelBufferLockBaseAddress(buddyPixelBuffer, 0);
            if (ret != kCVReturnSuccess) {
                return -1;
            }
            
            if (!CVPixelBufferIsPlanar(buddyPixelBuffer)) {
                videoFrameInfo.planePtr[0] = CVPixelBufferGetBaseAddress(buddyPixelBuffer);
                videoFrameInfo.planeRowPitch[0] = (int)CVPixelBufferGetBytesPerRow(buddyPixelBuffer);
            } else {
                for (int p = 0; p < CVPixelBufferGetPlaneCount(inputImage); p++) {
                    videoFrameInfo.planePtr[p] = CVPixelBufferGetBaseAddressOfPlane(buddyPixelBuffer, p);
                    videoFrameInfo.planeRowPitch[p] = (int)CVPixelBufferGetBytesPerRowOfPlane(buddyPixelBuffer, p);
                }
            }
            
            NvsRenderFlag flags = NvsRenderFlag_NoFlag;
            if(isImageMode) {
                NvsARSceneManipulate* arSceneMainpulate = [effect getARSceneManipulate];
                [arSceneMainpulate setDetectionMode:NvsARSceneDetectionMode_Image];
            }
            
            //render arscene effect
            renderError = [m_renderCore renderEffect:effect inputTexId:inputTexture
                      inputBuddyBuffer:inputImage != nil?&videoFrameInfo:nil physicalOrientation: camerRotation
                     inputVideoResolution:&videoEditRes outputTexId:outputTexture timestamp:currentTimeStamp flags:flags];
            
            CVPixelBufferUnlockBaseAddress(buddyPixelBuffer, 0);
            
            if(isImageMode) {
                NvsARSceneManipulate* arSceneMainpulate = [effect getARSceneManipulate];
                [arSceneMainpulate setDetectionMode:NvsARSceneDetectionMode_Video];
            }
            
        } else {
            renderError = [m_renderCore renderEffect:effect inputTexId:inputTexture inputVideoResolution:&videoEditRes outputTexId:outputTexture timestamp:currentTimeStamp flags: NvsRenderFlag_NoFlag];
        }
        
        //change render texture
        inputTexture = outputTexture;
        if (outputTexture == m_outputTexture)
            outputTexture = m_tempTexture;
        else
            outputTexture = m_outputTexture;
        
        if (renderError != NvsEffectCoreError_NoError) {
            NSLog(@"Has error occured when render effect! %d",renderError);
            return -1;
        }
    }
    
    return 0;
}

+(GLuint)createTextureWithWidth:(int)width height:(int)height
{
    GLuint textureId = 0;
    glGenTextures(1, &textureId);
    glBindTexture(GL_TEXTURE_2D, textureId);
    [self glCheckError];
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MIN_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_MAG_FILTER, GL_NEAREST);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_S, GL_CLAMP_TO_EDGE);
    glTexParameteri(GL_TEXTURE_2D, GL_TEXTURE_WRAP_T, GL_CLAMP_TO_EDGE);
    glTexImage2D(GL_TEXTURE_2D, 0, GL_RGBA, width, height, 0, GL_BGRA, GL_UNSIGNED_BYTE, 0);
    
    return textureId;
}

- (void)fillVideoFrameInfoFromPixelBuffer:(CVPixelBufferRef)inputImage videoFrameInfo:(NvsEffectVideoFrameInfo*)frameInfo
{
    OSType pixelFormat = CVPixelBufferGetPixelFormatType(inputImage);
    unsigned int width = (unsigned int)CVPixelBufferGetWidth(inputImage);
    unsigned int height = (unsigned int)CVPixelBufferGetHeight(inputImage);
    frameInfo->frameWidth = width;
    frameInfo->frameHeight = height;
    frameInfo->flipHorizontally = false;
    
    if (pixelFormat == kCVPixelFormatType_32BGRA) {
        frameInfo->pixelFormat = NvsEffectPixelFormat_BGRA;
        frameInfo->isFullRangeYUV = true;
        frameInfo->isRec601 = NO;
        frameInfo->displayRotation = 0;
    } else if (pixelFormat == kCVPixelFormatType_420YpCbCr8BiPlanarVideoRange) {
        frameInfo->pixelFormat = NvsEffectPixelFormat_Nv12;
        frameInfo->isFullRangeYUV = false;
        frameInfo->isRec601 = NO;
        frameInfo->displayRotation = 0;
    }
}

@end
