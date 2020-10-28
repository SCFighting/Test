//
//  EFFaceEffectModel.h
//  EffectSdkDemo
//
//  美颜 美型 人脸贴纸
//
//  Created by 美摄 on 2019/12/12.
//  Copyright © 2019 美摄. All rights reserved.
//

#ifndef EFFaceEffectModel_h
#define EFFaceEffectModel_h

#import <Foundation/Foundation.h>

#import <NvEffectSdkCore/NvsEffectSdkContext.h>
#import <NvEffectSdkCore/NvsEffectAssetPackageManager.h>

#import "NvBeautyTypeModel.h"
#import "NvStickerModel.h"
//#import "NvStickerCollectionViewCell.h"

@protocol EFFaceEffectModel <NSObject>

@property(nonatomic,strong)NvsVideoEffect* faceEffect;

-(void)willDisplayPixelBuffer:(CVPixelBufferRef)pixelBuffer
                         flip:(BOOL)flip
                 isUpsideDown:(BOOL)isUpsideDown
                    timestamp:(int64_t)timestamp;

-(NvsVideoEffect*)createVideoEffectWithContext:(NvsEffectSdkContext*)effectContext;

//美颜
-(NSMutableArray<NvBeautyTypeModel*>*)modelArrayForBeauty;
//美型
-(NSMutableArray<NvBeautyTypeModel*>*)modelArrayForBeautyType;

-(void)enableBeauty:(BOOL)enable;

-(void)enableBeautyType:(BOOL)enable;

#pragma mark -- 道具
-(NSArray<NvStickerModel*>*)stickerArray;

-(void)applyStickerModel:(NvStickerModel*)item;

-(void)effectModelChanged:(NvBeautyTypeModel *)model withState:(BOOL)state;

-(void)reloadModelArray:(NSMutableArray <NvBeautyTypeModel *>*)array;

@end

#endif /* EFFaceEffectModel_h */
