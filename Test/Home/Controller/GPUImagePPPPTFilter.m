#import "GPUImagePPPPTFilter.h"

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
NSString *const kGPUImagePPPPTShaderString = SHADER_STRING
(
 varying highp vec2 textureCoordinate;
 varying highp vec2 textureCoordinate2;
 varying highp vec2 textureCoordinate3;

 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 uniform sampler2D inputImageTexture3;
 
 void main()
 {
	 lowp vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
	 lowp vec4 textureColor2 = texture2D(inputImageTexture2, textureCoordinate2);
     lowp vec4 textureColor3 = texture2D(inputImageTexture3, textureCoordinate3);
     lowp vec4 tempColor = vec4(mix(textureColor, textureColor2, textureColor2.a));
     gl_FragColor = vec4(mix(tempColor, textureColor3, 0.0));
 }
);
#else
NSString *const kGPUImagePPPPTShaderString = SHADER_STRING
(
 varying vec2 textureCoordinate;
 varying vec2 textureCoordinate2;
 varying vec2 textureCoordinate3;

 uniform sampler2D inputImageTexture;
 uniform sampler2D inputImageTexture2;
 uniform sampler2D inputImageTexture3;

 void main()
 {
	 vec4 textureColor = texture2D(inputImageTexture, textureCoordinate);
	 vec4 textureColor2 = texture2D(inputImageTexture2, textureCoordinate2);
     vec4 textureColor3 = texture2D(inputImageTexture3, textureCoordinate3);
     vec4 tempColor = vec4(mix(textureColor, textureColor2, textureColor2.a));
     gl_FragColor = vec4(mix(tempColor, textureColor3, 0.0));
 }
);
#endif

@implementation GPUImagePPPPTFilter

- (id)init;
{
    if (!(self = [super initWithFragmentShaderFromString:kGPUImagePPPPTShaderString]))
    {
		return nil;
    }
    return self;
}

@end
