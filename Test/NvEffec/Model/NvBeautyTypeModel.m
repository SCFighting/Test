//
//  NvBeautyTypeModel.m
//  EffectSdkDemo
//
//  Created by 美摄 on 2020/4/27.
//  Copyright © 2020 美摄. All rights reserved.
//

#import "NvBeautyTypeModel.h"

@implementation NvBeautyTypeModel
- (instancetype)init {
    self = [super init];
    return self;
}

- (id)copyWithZone:(nullable NSZone *)zone {
    NvBeautyTypeModel *model = [NvBeautyTypeModel new];
    model.isBeauty = self.isBeauty;
    model.name = self.name;
    model.selected = self.selected;
    model.value = self.value;
    model.coverImage = self.coverImage;
    model.isOperation = self.isOperation;
    model.fxName = self.fxName;
    model.switchSelected = self.switchSelected;
    return model;
}
@end
