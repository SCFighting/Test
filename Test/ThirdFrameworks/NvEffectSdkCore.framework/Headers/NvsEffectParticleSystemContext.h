//================================================================================
//
// (c) Copyright China Digital Video (Beijing) Limited, 2016. All rights reserved.
//
// This code and information is provided "as is" without warranty of any kind,
// either expressed or implied, including but not limited to the implied
// warranties of merchantability and/or fitness for a particular purpose.
//
//--------------------------------------------------------------------------------
//   Birth Date:    Dec 29. 2016
//   Author:        NewAuto video team
//================================================================================
#pragma once

#import <Foundation/Foundation.h>
#import "NvsParticleSystemContext.h"


/*! \if ENGLISH
 *  \brief Particle effect context
 *
 *  The particle effect context class can be Regarded as the entry point for adjusting particle effects. Users can adjust the position, size, emission rate, etc. of the particle emitter.
 *  \warning In the NvsEffectParticleSystemContext class, all public APIs are used in the UI thread! ! !
 *  \else
 *  \brief 粒子特效上下文
 *
 *  粒子特效上下文类可视作调整粒子效果的入口。可以调整粒子发射器的位置，大小，发射速率等
 *  \warning NvsEffectParticleSystemContext类中，所有public API都在UI线程使用！！！
 *  \endif
*/
NVS_EXPORT @interface NvsEffectParticleSystemContext : NvsParticleSystemContext

@end

