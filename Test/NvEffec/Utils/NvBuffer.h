//
//  NvBuffer.h
//  EffectSdkDemo
//
//  Created by ms20180425 on 2020/5/12.
//  Copyright © 2020 美摄. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CoreMotion/CoreMotion.h>
#import <AVFoundation/AVFoundation.h>

NS_ASSUME_NONNULL_BEGIN

/// buffer操作类
@interface NvBuffer : NSObject

/// 根据传入比例裁剪buffer
/// @param sampleBuffer 传入的原始sampleBuffer
/// @param proportion 传入的裁剪比例
+ (CVPixelBufferRef)modifyImage:(CMSampleBufferRef)sampleBuffer withProportion:(CGFloat)proportion;

/// 根据传入的图片，输出对应的buffer
/// @param image 图片
+ (CVPixelBufferRef)pixelBufferFromCGImage:(CGImageRef)image;

/// 根据传入的buffer，输出图片
/// @param buffer buffer
+ (UIImage*)uiImageFromPixelBuffer:(CVPixelBufferRef)buffer;

/// 根据传入的buffer，输出图片
/// @param pixelBufferRef buffer
+ (UIImage *)imageFromPixelBuffer:(CVPixelBufferRef)pixelBufferRef;

@end

NS_ASSUME_NONNULL_END
