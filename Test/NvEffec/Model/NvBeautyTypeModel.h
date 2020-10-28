//
//  NvBeautyTypeModel.h
//  EffectSdkDemo
//
//  Created by 美摄 on 2020/4/27.
//  Copyright © 2020 美摄. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

//美颜、美型 model
@interface NvBeautyTypeModel : NSObject<NSCopying>

@property (nonatomic, assign) BOOL isBeauty;          //判断这个model是否是美颜
@property (nonatomic, strong) NSString *name;         //外部显示文字
@property (nonatomic, assign) BOOL selected;          //是否选中
@property (nonatomic, assign) float value;            //效果程度
@property (nonatomic, strong) NSString *coverImage;   //封面图片
@property (nonatomic, assign) BOOL isOperation;       //是否是开启了美型、美颜
@property (nonatomic, strong) NSString *fxName;       //特效参数名
@property (nonatomic, assign) BOOL switchSelected;    //锐度、校色开关

@end

NS_ASSUME_NONNULL_END
