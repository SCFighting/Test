//================================================================================
//
// (c) Copyright China Digital Video (Beijing) Limited, 2016. All rights reserved.
//
// This code and information is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the implied
// warranties of merchantability and/or fitness for a particular purpose.
//
//--------------------------------------------------------------------------------
//   Birth Date:    Mar 9. 2020
//   Author:        NewAuto video team
//================================================================================

#pragma once

#import <Foundation/Foundation.h>
#import "NvsCommonDef.h"
#import "NvsArbitraryData.h"

/*! \if ENGLISH
*  \brief Makeup effect layer type
*  \else
*  \brief 美妆特效渲染层类型
*  \endif
*/
typedef enum {
    NvsMakeupEffectLayerType_3D = 0,    //!< \if ENGLISH Makeup 3d layer type \else 美妆三维层 \endif
    NvsMakeupEffectLayerType_Lut = 1    //!< \if ENGLISH Makeup lut layer type \else 美妆LUT校色层 \endif
} NvsMakeupEffectLayerType;

/*! \if ENGLISH
*  \brief Makeup effect blending mode of layers
*  \else
*  \brief 美妆特效渲染层叠加方式
*  \endif
*/
typedef enum {
    NvsMakeupEffectBlendingMode_Unknown = -1,   //!< \if ENGLISH Unknown blending mode \else 无效叠加方式 \endif
    NvsMakeupEffectBlendingMode_Normal = 0,     //!< \if ENGLISH Normal blending mode \else Normal 叠加方式 \endif
    NvsMakeupEffectBlendingMode_Multiply,       //!< \if ENGLISH Multiply blending mode \else Multiply 叠加方式 \endif
    NvsMakeupEffectBlendingMode_Subtract,       //!< \if ENGLISH Subtract blending mode \else Subtract 叠加方式 \endif
    NvsMakeupEffectBlendingMode_Screen,         //!< \if ENGLISH Screen blending mode \else Screen 叠加方式 \endif
    NvsMakeupEffectBlendingMode_Add,            //!< \if ENGLISH Add blending mode \else Add 叠加方式 \endif
    NvsMakeupEffectBlendingMode_Exclusion       //!< \if ENGLISH Exclusion blending mode \else Exclusion 叠加方式 \endif
} NvsMakeupEffectBlendingMode;

/*! \if ENGLISH
*  \brief Flags which indicate which parts of makeup are under the control of customers
*  \else
*  \brief 用户可以自定义的美妆特效标志位
*  \endif
*/
typedef enum {
    NvsMakeupEffectCustomEnabledFlag_None = 0x00,       //!< \if ENGLISH No custom item \else 无自定义项 \endif
    NvsMakeupEffectCustomEnabledFlag_Lip = 0x01,        //!< \if ENGLISH Enable custom lip \else 自定义嘴唇 \endif
    NvsMakeupEffectCustomEnabledFlag_Eyebrow = 0x02,    //!< \if ENGLISH Enable custom eyebrow \else 自定义眉毛 \endif
    NvsMakeupEffectCustomEnabledFlag_Eyeshadow = 0x04,  //!< \if ENGLISH Enable custom eyeshadow \else 自定义眼影 \endif
    NvsMakeupEffectCustomEnabledFlag_Eyelash = 0x08,    //!< \if ENGLISH Enable custom eyelash \else 自定义睫毛 \endif
    NvsMakeupEffectCustomEnabledFlag_Eyeliner = 0x10,   //!< \if ENGLISH Enable custom eyeliner \else 自定义眼线 \endif
    NvsMakeupEffectCustomEnabledFlag_Blusher = 0x20,    //!< \if ENGLISH Enable custom blusher \else 自定义腮红 \endif
    NvsMakeupEffectCustomEnabledFlag_Shadow = 0x40,     //!< \if ENGLISH Enable custom shadow \else 自定义阴影 \endif
    NvsMakeupEffectCustomEnabledFlag_Highlight = 0x80,  //!< \if ENGLISH Enable custom brighten \else 自定义提亮 \endif
    NvsMakeupEffectCustomEnabledFlag_All = 0xFF         //!< \if ENGLISH Enable all custom makeup \else 自定义所有美妆效果 \endif
} NvsMakeupEffectCustomEnabledFlag;

/*! \if ENGLISH
 *  \brief Makeup effect layer information
 *  \else
 *  \brief 美妆特效渲染层数据
 *  \endif
 */
NVS_EXPORT @interface NvsMakeupEffectLayer : NSObject

@property (nonatomic, copy) NSString *layerId;
@property (nonatomic, assign) float intensity;
@property (nonatomic, assign) NvsMakeupEffectLayerType type;

@end

/*! \if ENGLISH
 *  \brief Makeup effect 3d layer information
 *  \else
 *  \brief 美妆特效三维渲染层数据
 *  \endif
 */
NVS_EXPORT @interface NvsMakeupEffectLayer3D : NvsMakeupEffectLayer

@property (nonatomic, copy) NSString *texFilePath;
@property (nonatomic, assign) NvsColor texColor;
@property (nonatomic, assign) NvsMakeupEffectBlendingMode blendingMode;

@end

/*! \if ENGLISH
 *  \brief Makeup effect lut layer information
 *  \else
 *  \brief 美妆特效Lut校色渲染层数据
 *  \endif
 */
NVS_EXPORT @interface NvsMakeupEffectLayerLut : NvsMakeupEffectLayer
@property (nonatomic, copy) NSString *lutFilePath;
@end

/*! \if ENGLISH
 *  \brief Makeup effect information for each part, say eyelash, eyebrow, lips, etc.
 *  \else
 *  \brief 局部美妆特效数据，例如睫毛，眉毛，嘴唇等
 *  \endif
 */
NVS_EXPORT @interface NvsMakeupEffect : NSObject
@property (nonatomic, copy) NSString *effectId;
@property (nonatomic, assign) NvsColor color;
@property (nonatomic, assign) float intensity;
@property (nonatomic, strong) NSMutableArray<NvsMakeupEffectLayer *> *makeupEffectLayerArray;
@end

/*! \if ENGLISH
*  \brief Makeup effect control information
*  \else
*  \brief 美妆特效控制信息
*  \endif
*/
NVS_EXPORT @interface NvsMakeupEffectInfo : NvsArbitraryData
@property (nonatomic, strong) NSMutableArray<NvsMakeupEffect *> *makeupEffectArray;
@end


