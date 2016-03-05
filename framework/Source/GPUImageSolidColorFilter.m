
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
   
   const CGFloat *comps = CGColorGetComponents(color.CGColor);
#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
#else
   NSColorSpace *colorSpace = [NSColorSpace sRGBColorSpace];
   color = [NSColor colorWithColorSpace:colorSpace components:comps count:4];
#endif
   
   CGFloat r, g, b, a;
   a = comps[3];
   
   CGFloat rgb[3];
   [self getRGBComponents:rgb forColor:color];
   r = rgb[0];
   g = rgb[1];
   b = rgb[2];
   
   [self setVec4:(GPUVector4){r,g,b,a} forUniform:colorUniform program:filterProgram];
}

- (void)getRGBComponents:(CGFloat [3])components forColor:(FTCColor *)color {
   CGColorSpaceRef rgbColorSpace = CGColorSpaceCreateDeviceRGB();
   unsigned char buffer[4];
   CGContextRef context = CGBitmapContextCreate(&buffer,
                                                1,
                                                1,
                                                8,
                                                4,
                                                rgbColorSpace,
                                                kCGImageAlphaNoneSkipLast);
   CGContextSetFillColorWithColor(context, [color CGColor]);
   CGContextFillRect(context, CGRectMake(0.0, 0.0, 1.0, 1.0));
   CGContextRelease(context);
   CGColorSpaceRelease(rgbColorSpace);
   
   for (int i = 0; i < 3; i++) {
      components[i] = buffer[i] / 255.0f;
   }
}

@end
