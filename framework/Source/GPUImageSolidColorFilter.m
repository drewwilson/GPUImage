
#import "GPUImageSolidColorFilter.h"

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#define FTCColor UIColor
#else
#define FTCColor NSColor
#endif

#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
NSString *const kGPUImageSolidColorFilterFragmentShaderString = SHADER_STRING
(
 precision highp float;
 
 uniform vec4 color;
 
 void main()
 {
    gl_FragColor = color;
 }
 );
#else
NSString *const kGPUImageSolidColorFilterFragmentShaderString = SHADER_STRING
(
 uniform vec4 color;
 
 void main()
 {
    gl_FragColor = color;
 }
 );
#endif

@interface GPUImageSolidColorFilter() {
   GLint colorUniform;
}
@end

@implementation GPUImageSolidColorFilter

@synthesize color = _color;

- (id)init {
   self = [super initWithFragmentShaderFromString:kGPUImageSolidColorFilterFragmentShaderString];
   if (!self) {
      return nil;
   }
   
   colorUniform = [filterProgram uniformIndex:@"color"];
   
   self.color = [FTCColor redColor];
   
   return self;
}

#pragma mark - Accessors

- (void)setColor:(FTCColor *)color {
   _color = color;
   
   const CGFloat *colors = CGColorGetComponents(color.CGColor);
   CGFloat r, g, b, a;
   a = colors[3];
   //
   CGFloat components[3];
   [self getRGBComponents:components forColor:color];
   r = components[0];
   g = components[1];
   b = components[2];
   
   [self setVec4:(GPUVector4){r,g,b,a} forUniform:colorUniform program:filterProgram];
}

- (void)getRGBComponents:(CGFloat [3])components forColor:(FTCColor *)color {
   CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
   unsigned char resultingPixel[4];
   CGContextRef context = CGBitmapContextCreate(&resultingPixel,
                                                1,
                                                1,
                                                8,
                                                4,
                                                rgbColorSpace,
                                                kCGImageAlphaNoneSkipLast);
   CGContextSetFillColorWithColor(context, [color CGColor]);
   CGContextFillRect(context, CGRectMake(0, 0, 1, 1));
   CGContextRelease(context);
   CGColorSpaceRelease(rgbColorSpace);
   
   for (int component = 0; component < 3; component++) {
      components[component] = resultingPixel[component] / 255.0f;
   }
}

@end