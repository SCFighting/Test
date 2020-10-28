//
//  EFARSceneEffectModel.m
//  EffectSdkDemo
//
//  Created by 美摄 on 2020/4/27.
//  Copyright © 2020 美摄. All rights reserved.
//

#import "EFARSceneEffectModel.h"

@interface EFARSceneEffectModel ()

@property (nonatomic, strong) NSMutableArray<NvBeautyTypeModel*> *beautyFxArray;
@property (nonatomic, strong) NSMutableArray<NvBeautyTypeModel*> *beautyTypeFxArray;

@property (nonatomic, weak)   NvsEffectSdkContext                   *effectContext;

@end

@implementation EFARSceneEffectModel
@synthesize faceEffect;

-(instancetype)init{
    self = [super init];
    if (self) {
        [self initARSceneEffect];
        [self initializeData];
    }
    return self;
}

- (void)initARSceneEffect {
}

#pragma mark -- EFFaceEffectModel

-(NvsVideoEffect*)createVideoEffectWithContext:(NvsEffectSdkContext*)effectContext{
    if (self.faceEffect) {
        return self.faceEffect;
    }
    self.effectContext = effectContext;
    NvsEffectRational aspectRatio = {9, 16};
    NvsVideoEffect* videoEffect = [effectContext createVideoEffect:@"Beauty" aspectRatio:aspectRatio];
    self.faceEffect = videoEffect;
    return videoEffect;
}

-(void)willDisplayPixelBuffer:(CVPixelBufferRef)pixelBuffer
                         flip:(BOOL)flip
                 isUpsideDown:(BOOL)isUpsideDown
timestamp:(int64_t)timestamp{
    //
}


#pragma mark -- 美颜 美型

-(NSMutableArray<NvBeautyTypeModel*>*)modelArrayForBeauty{
    return self.beautyFxArray;
}
//美型
-(NSMutableArray<NvBeautyTypeModel*>*)modelArrayForBeautyType{
    return self.beautyTypeFxArray;
}

-(void)enableBeauty:(BOOL)enable{
//    [self.faceEffect setBooleanVal:@"Beauty Effect" val:enable];
}

-(void)enableBeautyType:(BOOL)enable{
//    [self.faceEffect setBooleanVal:@"Beauty Shape" val:enable];
}

-(void)effectModelChanged:(NvBeautyTypeModel *)model withState:(BOOL)state{
}

-(void)reloadModelArray:(NSMutableArray <NvBeautyTypeModel *>*)array{
    for (NvBeautyTypeModel *model in array) {
        [self.faceEffect setFloatVal:model.fxName val:model.value];
    }
}

#pragma mark -- 道具

-(void)applyStickerModel:(NvStickerModel*)item{
    if(self.faceEffect != nil) {
        [self.faceEffect setStringVal:@"Scene Id" val:item.sceneId];
    }
}

-(NSArray<NvStickerModel*>*)stickerArray{
    NSMutableArray* _stickerArray = [NSMutableArray array];
    return _stickerArray;
}

-(void)initializeData{
    //
    self.beautyFxArray = [NSMutableArray array];
    self.beautyTypeFxArray = [NSMutableArray array];
    
//    for (int i = 0; i < beautyByteArray_1.count; i++) {
//        NvBeautyTypeModel *beautyByteModel = [NvBeautyTypeModel new];
//        beautyByteModel.name = beautyByteArray_1[i];
//        beautyByteModel.coverImage = beautyByteArray_2[i];
//        beautyByteModel.selected = i == 0?YES:NO;
//        beautyByteModel.isOperation = NO;
//        beautyByteModel.isBeauty = NO;
//        beautyByteModel.fxName = beautyByteArray_3[i];
//        beautyByteModel.value = [self.faceEffect getFloatVal:beautyByteModel.fxName];//0;
//        [self.beautyTypeFxArray addObject:beautyByteModel];
//    }
}

- (NSString*)createStickerItem:(NSString*)itemPath {
    NSMutableString* sceneId = [[NSMutableString alloc] initWithString:@""];
    NvsAssetPackageManagerError error = [self.effectContext.assetPackageManager installAssetPackage:itemPath license:nil type:NvsAssetPackageType_ARScene sync:YES assetPackageId:sceneId];
    if (error != NvsAssetPackageManagerError_NoError && error != NvsAssetPackageManagerError_AlreadyInstalled) {
        NSLog(@"包裹安装失败");
        return nil;
    }else if(error == NvsAssetPackageManagerError_AlreadyInstalled){
        [self.effectContext.assetPackageManager upgradeAssetPackage:itemPath license:nil type:NvsAssetPackageType_ARScene sync:YES assetPackageId:sceneId];
    }
    return sceneId;
}

@end
