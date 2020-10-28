//================================================================================
//
// (c) Copyright China Digital Video (Beijing) Limited, 2017. All rights reserved.
//
// This code and information is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the implied
// warranties of merchantability and/or fitness for a particular purpose.
//
//--------------------------------------------------------------------------------
//   Birth Date:    Jan 23. 2017
//   Author:        NewAuto video team
//================================================================================
#pragma once

#import "NvsEffectCommonDef.h"

#import <Foundation/Foundation.h>
#import "NvsAssetPackageManager.h"


#define NvsEffectAssetPackageType NvsAssetPackageType
#define NvsEffectAssetPackageType_VideoFx NvsAssetPackageType_VideoFx
#define NvsEffectAssetPackageType_VideoTransition NvsAssetPackageType_VideoTransition
#define NvsEffectAssetPackageType_CaptionStyle NvsAssetPackageType_CaptionStyle
#define NvsEffectAssetPackageType_AnimatedSticker NvsAssetPackageType_AnimatedSticker
#define NvsEffectAssetPackageType_Theme NvsAssetPackageType_Theme
#define NvsEffectAssetPackageType_CaptureScene NvsAssetPackageType_CaptureScene
#define NvsEffectAssetPackageType_ARScene NvsAssetPackageType_ARScene
#define NvsEffectAssetPackageType_CompoundCaption NvsAssetPackageType_CompoundCaption

#define NvsEffectAssetPackageStatus NvsAssetPackageStatus
#define NvsEffectAssetPackageStatus_NotInstalled NvsAssetPackageStatus_NotInstalled
#define NvsEffectAssetPackageStatus_Installing NvsAssetPackageStatus_Installing
#define NvsEffectAssetPackageStatus_Ready NvsAssetPackageStatus_Ready
#define NvsEffectAssetPackageStatus_Upgrading NvsAssetPackageStatus_Upgrading

#define NvsEffectAssetPackageManagerError NvsAssetPackageManagerError
#define NvsEffectAssetPackageManagerError_NoError NvsAssetPackageManagerError_NoError
#define NvsEffectAssetPackageManagerError_Name NvsAssetPackageManagerError_Name
#define NvsEffectAssetPackageManagerError_AlreadyInstalled NvsAssetPackageManagerError_AlreadyInstalled
#define NvsEffectAssetPackageManagerError_WorkingInProgress NvsAssetPackageManagerError_WorkingInProgress
#define NvsEffectAssetPackageManagerError_NotInstalled NvsAssetPackageManagerError_NotInstalled
#define NvsEffectAssetPackageManagerError_ImproperStatus NvsAssetPackageManagerError_ImproperStatus
#define NvsEffectAssetPackageManagerError_Decompression NvsAssetPackageManagerError_Decompression
#define NvsEffectAssetPackageManagerError_InvalidPackage NvsAssetPackageManagerError_InvalidPackage
#define NvsEffectAssetPackageManagerError_AssetType NvsAssetPackageManagerError_AssetType
#define NvsEffectAssetPackageManagerError_Permission NvsAssetPackageManagerError_Permission
#define NvsEffectAssetPackageManagerError_MetaContent NvsAssetPackageManagerError_MetaContent
#define NvsEffectAssetPackageManagerError_SdkVersion NvsAssetPackageManagerError_SdkVersion
#define NvsEffectAssetPackageManagerError_UpgradeVersion NvsAssetPackageManagerError_UpgradeVersion
#define NvsEffectAssetPackageManagerError_IO NvsAssetPackageManagerError_IO
#define NvsEffectAssetPackageManagerError_Resource NvsAssetPackageManagerError_Resource

#define NvsEffectAssetPackageAspectRatio NvsAssetPackageAspectRatio
#define NvsEffectAssetPackageAspectRatio_16v9 NvsAssetPackageAspectRatio_16v9
#define NvsEffectAssetPackageAspectRatio_1v1 NvsAssetPackageAspectRatio_1v1
#define NvsEffectAssetPackageAspectRatio_9v16 NvsAssetPackageAspectRatio_9v16
#define NvsEffectAssetPackageAspectRatio_4v3 NvsAssetPackageAspectRatio_4v3
#define NvsEffectAssetPackageAspectRatio_3v4 NvsAssetPackageAspectRatio_3v4
#define NvsEffectAssetPackageAspectRatio_18v9 NvsAssetPackageAspectRatio_18v9
#define NvsEffectAssetPackageAspectRatio_9v18 NvsAssetPackageAspectRatio_9v18

@protocol NvsEffectAssetPackageManagerDelegate <NvsAssetPackageManagerDelegate>

@end

/*! \if ENGLISH
 *  \brief Asset package manager for managing assets in video.
 *
 *   In the development of the SDK, the asset package manager unifies the various special asset packages including subtitles, themes, animation stickers, etc. for installation, upgrading, and uninstallation. When it is installing, upgrading, and uninstalling, there will be a corresponding error type for errors to be quickly located and resolved.
 *  \warning NvsEffectAssetPackageManager类中，所有public API都在UI线程使用！！！
 *  \else
 *  \brief 资源包管理器，管理视频场景中的资源包
 *
 *   在SDK开发过中，资源包管理器统一对需要的各种特技资源包包括字幕，主题，动画贴纸等进行相应的安装，升级，卸载等操作。在安装，升级，卸载时，出现差错都会有相应的错误提示类型，以便快速定位和解决错误。
 *  \warning NvsEffectAssetPackageManager类中，所有public API都在UI线程使用！！！
 *  \endif
*/
NVS_EXPORT @interface NvsEffectAssetPackageManager : NvsAssetPackageManager

@end

