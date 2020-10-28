//
//  EFARSceneFaceEffectModel.h
//  EffectSdkDemo
//
//  Created by 美摄 on 2019/12/12.
//  Copyright © 2019 美摄. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "EFFaceEffectModel.h"

NS_ASSUME_NONNULL_BEGIN

@protocol EFARSceneFaceEffectModelDelegate <NSObject>

@optional

/// 如果没有检测到人脸会走这个回调
- (void)notifyFace;

@end

@interface EFARSceneFaceEffectModel : NSObject <EFFaceEffectModel>

@property (nonatomic, weak) id<EFARSceneFaceEffectModelDelegate> delegate;

-(void)useLutWhiten:(BOOL)lutWhiten;

@end

NS_ASSUME_NONNULL_END
