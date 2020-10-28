//
//  EFARSceneFaceEffectModel.m
//  EffectSdkDemo
//
//  Created by 美摄 on 2019/12/12.
//  Copyright © 2019 美摄. All rights reserved.
//

#import "EFARSceneFaceEffectModel.h"

@interface EFARSceneFaceEffectModel ()

@property (nonatomic, strong) NSMutableArray<NvBeautyTypeModel*> *beautyFxArray;
@property (nonatomic, strong) NSMutableArray<NvBeautyTypeModel*> *beautyTypeFxArray;

@property (nonatomic, weak)   NvsEffectSdkContext                   *effectContext;

@end

@implementation EFARSceneFaceEffectModel
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
    NSString *arsceneModel = [[NSBundle mainBundle] pathForResource:@"ms_face_v1.0.1" ofType:@"model"];
    
    BOOL result = [NvsEffectSdkContext initHumanDetection:arsceneModel licenseFilePath:nil features:NvsEffectSdkHumanDetectionFeature_FaceLandmark|NvsEffectSdkHumanDetectionFeature_FaceAction |NvsEffectSdkHumanDetectionFeature_VideoMode |NvsEffectSdkHumanDetectionFeature_ImageMode];
    if (!result) {
        NSLog(@"initHumanDetection error");
    }
}

#pragma mark -- EFFaceEffectModel

-(NvsVideoEffect*)createVideoEffectWithContext:(NvsEffectSdkContext*)effectContext{
    if (self.faceEffect) {
        return self.faceEffect;
    }
    self.effectContext = effectContext;
    NvsEffectRational aspectRatio = {9, 16};
    NvsVideoEffect* videoEffect = [effectContext createVideoEffect:@"AR Scene" aspectRatio:aspectRatio realTime:false];
    NvsARSceneManipulate* arSceneMainpulate = [videoEffect getARSceneManipulate];
//    arSceneMainpulate.delegate = self;
    self.faceEffect = videoEffect;
    return videoEffect;
}

#pragma mark NvsARSceneManipulateDelegate
- (void)notifyFaceBoundingRectWithId:(int*)faceIds boundingRect:(NvsRect*)boundingRects faceCount:(int)count{
    if (faceIds == 0 && count == 0) {
        if (self.delegate && [self.delegate respondsToSelector:@selector(notifyFace)]) {
            [self.delegate notifyFace];
        }
    }
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
    [self.faceEffect setBooleanVal:@"Beauty Effect" val:enable];
    if (enable) {
        [self applyBeautyEffectInCondition];
    }
}

-(void)enableBeautyType:(BOOL)enable{
    [self.faceEffect setBooleanVal:@"Beauty Shape" val:enable];
    if (enable) {
        [self applyBeautyTypeEffectInCondition];
    }
}

#pragma mark 应用美颜数组中的效果
- (void)applyBeautyEffectInCondition {
    for (NvBeautyTypeModel *model in self.beautyFxArray) {
        if ([model.fxName isEqualToString:@"Default Beauty Enabled"]) {
            [self.faceEffect setBooleanVal:model.fxName val:model.switchSelected];
            [self.faceEffect setFloatVal:@"Default Intensity" val:model.value];
        }else if ([model.fxName isEqualToString:@"Default Sharpen Enabled"]){
            [self.faceEffect setBooleanVal:model.fxName val:model.switchSelected];
        }else{
            [self.faceEffect setFloatVal:model.fxName val:model.value];
        }
    }
}

#pragma mark 应用美型数组中的效果
- (void)applyBeautyTypeEffectInCondition {
    for (NvBeautyTypeModel *model in self.beautyTypeFxArray) {
        if ([model.fxName isEqualToString:@"Face Size Warp Degree"] || [model.fxName isEqualToString:@"Nose Width Warp Degree"] || [model.fxName isEqualToString:@"Face Length Warp Degree"] || [model.fxName isEqualToString:@"Face Width Warp Degree"]) {
            [self.faceEffect setFloatVal:model.fxName val:-model.value];
        }else{
            [self.faceEffect setFloatVal:model.fxName val:model.value];
        }
    }
}

-(void)effectModelChanged:(NvBeautyTypeModel *)model withState:(BOOL)state{
    if (state) {
        if (model.isBeauty) {
            //美颜
            if ([model.fxName isEqualToString:@"Default Beauty Enabled"]) {
                [self.faceEffect setBooleanVal:model.fxName val:model.switchSelected];
                [self.faceEffect setFloatVal:@"Default Intensity" val:model.value];
            }else if ([model.fxName isEqualToString:@"Default Sharpen Enabled"]){
                [self.faceEffect setBooleanVal:model.fxName val:model.switchSelected];
            }else{
                [self.faceEffect setFloatVal:model.fxName val:model.value];
            }
        }else{
            
        }
    }else{
        if (model.isBeauty) {
            if ([model.fxName isEqualToString:@"Default Beauty Enabled"]) {
                [self.faceEffect setBooleanVal:model.fxName val:model.switchSelected];
                [self.faceEffect setFloatVal:@"Default Intensity" val:1];
            }else if ([model.fxName isEqualToString:@"Default Sharpen Enabled"]){
                [self.faceEffect setBooleanVal:model.fxName val:model.switchSelected];
            }else{
                [self.faceEffect setFloatVal:model.fxName val:model.value];
            }
        }else{
            if ([model.fxName isEqualToString:@"Face Size Warp Degree"] || [model.fxName isEqualToString:@"Nose Width Warp Degree"] || [model.fxName isEqualToString:@"Face Length Warp Degree"] || [model.fxName isEqualToString:@"Face Width Warp Degree"]) {
                [self.faceEffect setFloatVal:model.fxName val:-model.value];
            }else{
                [self.faceEffect setFloatVal:model.fxName val:model.value];
            }
        }
    }
}

-(void)reloadModelArray:(NSMutableArray <NvBeautyTypeModel *>*)array{
    for (NvBeautyTypeModel *model in array) {
        [self.faceEffect setFloatVal:model.fxName val:model.value];
    }
}

-(void)useLutWhiten:(BOOL)lutWhiten{
    NSString *lutPath = @"";
    NSString *imagePath = @"";
    if (lutWhiten) {
        //轻言美白(模式B)
        NSString *path = [[[NSBundle bundleForClass:[self class]] bundlePath] stringByAppendingPathComponent:@"whitenLut"] ;
        lutPath = [path stringByAppendingPathComponent:@"preset.mslut"];
        imagePath = [path stringByAppendingPathComponent:@"filter.png"];
    }else{
        //美白(模式A)
//        lutPath = @"";
//        imagePath = @"";
    }
    [self.faceEffect setStringVal:@"Default Beauty Lut File" val:lutPath];
    [self.faceEffect setStringVal:@"Whitening Lut File" val:imagePath];
    [self.faceEffect setBooleanVal:@"Whitening Lut Enabled" val:lutWhiten];
}

#pragma mark -- 道具

-(void)applyStickerModel:(NvStickerModel*)item{
    if(self.faceEffect != nil) {
        [self.faceEffect setStringVal:@"Scene Id" val:item.sceneId];
    }
}

-(NSArray<NvStickerModel*>*)stickerArray{
    NSMutableArray* _stickerArray = [NSMutableArray array];
    NSArray *stickerPathArray = @[@"6F8624EC-6B19-4AFA-8C57-7F32DCFD9E41.arscene",
                                  @"049ED95F-C80F-483D-B739-C76FD706485A.arscene",
                                  @"BED6B75B-3DAE-4F6B-A859-9318288F4706.arscene",
                                  @"25C78DC6-823C-4103-9E8A-D84350362F16.arscene",
                                  @"D3F9A1A9-CFD8-46B6-8E9C-DC3E87A9A687.2.arscene",
                                  @"D18BD048-4176-4E14-B705-7E2A4DF08274.arscene",
                                  @"9C917EE3-A1B0-4B5D-B50F-9624A6824A6B.arscene",
                                  @"827EB8A5-1804-45CE-B054-4BA640E566A9.arscene",
                                  @"AA219FDE-AF03-4CD7-87A9-28D7CF930DB0.arscene",
                                  @"EA962143-6CCA-42E4-B7FC-9615B9EEA231.arscene",
                                  @"E8E908B6-215B-4EF7-B1CD-C2832FFB9CF3.arscene"];
    NSArray *stickerNameArray = @[@"高达", @"狗头", @"僵尸帽子", @"pick you", @"冒心", @"钢铁侠", @"小鹿", @"眼镜", @"面具", @"骷髅墨镜", @"2019"];
    NSArray *stickerImageArray = @[@"gaoda", @"goutou", @"jiangshimaozi", @"pickyou", @"maoxin", @"gangtiexia", @"xiaolu", @"yanjing", @"mianju", @"kuloumojing", @"2019"];
    
    NSString *resourceBundlePath = [[NSBundle mainBundle] pathForResource:@"StickerResource" ofType:@"bundle"];
    NSString *arscenePath = [resourceBundlePath stringByAppendingPathComponent:@"arscene"];
    for (int i = 0; i < stickerNameArray.count; i++) {
        NSString *fileName = stickerPathArray[i];
        NSString *filePath = [arscenePath stringByAppendingPathComponent:fileName];
        NSString* sceneId = [self createStickerItem:filePath];
        if(sceneId.length > 0) {
            NvStickerModel *model = [NvStickerModel new];
            model.sceneId = sceneId;
            model.coverImage = stickerImageArray[i];
            model.name = stickerNameArray[i];
            model.selected = NO;
            [_stickerArray addObject:model];
        }
    }
    return _stickerArray;
}

-(void)initializeData{
    //
    self.beautyFxArray = [NSMutableArray array];
    NSArray *titleArray = @[NSLocalizedString(@"Strength", @"磨皮"), NSLocalizedString(@"Whiten mode B", @"美白B"), NSLocalizedString(@"Rosy", @"红润"), NSLocalizedString(@"Color correction", @"校色"), NSLocalizedString(@"Amount", @"锐度")];
    NSArray *imageArray = @[@"NvCaptureBeautyStrength",@"NvCaptureBeautyWhitening",@"NvCaptureBeautyReddening",@"NvCaptureBeautyFilter",@"NvCaptureBeautySharpen"];
    NSArray *fxParameter = @[@"Beauty Strength", @"Beauty Whitening", @"Beauty Reddening",@"Default Beauty Enabled",@"Default Sharpen Enabled"];
    
    for (int i = 0; i < titleArray.count; i++) {
        NvBeautyTypeModel *beautyModel = [NvBeautyTypeModel new];
        beautyModel.name = titleArray[i];
        beautyModel.coverImage = imageArray[i];
        if(i == 3 || i == 4){
            if (i == 3) {
                beautyModel.value = 1.0;
            }
            beautyModel.switchSelected = YES;
        }else{
            beautyModel.value = 0.5;
        }
        beautyModel.selected = NO;
        beautyModel.isOperation = NO;
        beautyModel.isBeauty = YES;
        beautyModel.fxName = fxParameter[i];
        [self.beautyFxArray addObject:beautyModel];
    }
    
    self.beautyTypeFxArray = [NSMutableArray array];
    NSArray *beautyByteArray_1 = @[NSLocalizedString(@"Face", @"瘦脸"), NSLocalizedString(@"Eye", @"大眼"), NSLocalizedString(@"Chin", @"下巴"), NSLocalizedString(@"Forhead", @"额头"), NSLocalizedString(@"Nose", @"瘦鼻"), NSLocalizedString(@"Mouth", @"嘴型"), NSLocalizedString(@"SmallFace", @"小脸"), NSLocalizedString(@"Canthus", @"眼角"), NSLocalizedString(@"NarrowFace", @"窄脸"), NSLocalizedString(@"Proboscis", @"长鼻"), NSLocalizedString(@"MouthCorner", @"嘴角")];
    NSArray *beautyByteArray_2 = @[@"NvCaptureBeautyTypeFace", @"NvCaptureBeautyTypeEye", @"NvCaptureBeautyTypeChin", @"NvCaptureBeautyTypeForehead", @"NvCaptureBeautyTypeNose", @"NvCaptureBeautyTypeMouth", @"NvCaptureBeautyTypeSmallFace", @"NvCaptureBeautyTypeCanthus", @"NvCaptureBeautyTypeNarrowFace", @"NvCaptureBeautyTypeProboscis", @"NvCaptureBeautyTypeMouthCorner"];
    NSArray *beautyByteArray_3 = @[@"Face Size Warp Degree", @"Eye Size Warp Degree", @"Chin Length Warp Degree", @"Forehead Height Warp Degree", @"Nose Width Warp Degree", @"Mouth Size Warp Degree", @"Face Length Warp Degree", @"Eye Corner Stretch Degree", @"Face Width Warp Degree", @"Nose Length Warp Degree", @"Mouth Corner Lift Degree"];
    
    for (int i = 0; i < beautyByteArray_1.count; i++) {
        NvBeautyTypeModel *beautyByteModel = [NvBeautyTypeModel new];
        beautyByteModel.name = beautyByteArray_1[i];
        beautyByteModel.coverImage = beautyByteArray_2[i];
        beautyByteModel.selected = i == 0?YES:NO;
        beautyByteModel.isOperation = NO;
        beautyByteModel.isBeauty = NO;
        beautyByteModel.fxName = beautyByteArray_3[i];
        if (i==0) {
            beautyByteModel.value = 0.6;
        }
        else if (i==1) {
            beautyByteModel.value = 0.7;
        }
        else if (i==4) {
            beautyByteModel.value = 0.5;
        }else{
            beautyByteModel.value = 0;
        }
        
        [self.beautyTypeFxArray addObject:beautyByteModel];
    }
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
