//
//  UILabel+JE.m
//
//  Created by Sean Shi on 15/9/3.
//  Copyright (c) 2015年 车友会. All rights reserved.
//

#import "UIView+JE.h"
#import "Utility.h"
#import "Utility+Date.h"
#import <objc/runtime.h>

@implementation UIView (JE)

#pragma mark 附加对象
-(void)setTagObject:(id)tagObject{
    objc_setAssociatedObject(self,@"tagObject",tagObject,OBJC_ASSOCIATION_RETAIN);
}
-(id)tagObject{
    return objc_getAssociatedObject(self, @"tagObject");
}

#pragma mark 定位元素
-(CGFloat)left{
    return self.frame.origin.x;
}
-(void)setLeft:(CGFloat)value{
    [Utility setX:value ofView:self];
}
-(CGFloat)top{
    return self.frame.origin.y;
}
-(void)setTop:(CGFloat)value{
    [Utility setY:value ofView:self];
}
-(CGPoint)origin{
    return self.frame.origin;
}
-(void)setOrigin:(CGPoint)value{
    [Utility setOrigin:value ofView:self];
}
-(CGFloat)width{
    return self.frame.size.width;
}
-(void)setWidth:(CGFloat)value{
    [Utility setWidth:value ofView:self];
}
-(CGFloat)height{
    return self.frame.size.height;
}
-(void)setHeight:(CGFloat)value{
    [Utility setHeight:value ofView:self];
}
-(CGSize)size{
    return self.frame.size;
}
-(void)setSize:(CGSize)value{
    [Utility setSize:value ofView:self];
}
-(CGFloat)centerX{
    return self.center.x;
}
-(void)setCenterX:(CGFloat)value{
    [Utility setCenterX:value ofView:self];
}
-(CGFloat)centerY{
    return self.center.y;
}
-(void)setCenterY:(CGFloat)value{
    [Utility setCenterY:value ofView:self];
}

-(CGFloat)bottom{
    return self.top+self.height;
}
-(void)setBottom:(CGFloat)value{
    [Utility setY:(value-self.height) ofView:self];
}
-(CGFloat)topOfScreen{
    CGFloat ret=self.top;
    UIView* superview=self.superview;
    if(superview!=nil){
        ret+=superview.topOfScreen;
    }
    return ret;
}
-(CGFloat)bottomOfScreen{
    UIView* superview=self.superview;
    if(superview!=nil){
        return superview.topOfScreen+self.bottom;
    }else{
        return self.bottomOfScreen;
    }
}
-(CGFloat)right{
    return self.left+self.width;
}
-(void)setRight:(CGFloat)value{
    [Utility setX:(value-self.width) ofView:self];
}

-(CGFloat)leftOfScreen{
    CGFloat ret=self.left;
    UIView* superview=self.superview;
    if(superview!=nil){
        ret+=superview.leftOfScreen;
    }
    return ret;
}
-(CGFloat)rightOfScreen{
    UIView* superview=self.superview;
    if(superview!=nil){
        return superview.leftOfScreen+self.right;
    }else{
        return self.right;
    }
}

-(CGPoint)innerCenterPoint{
    return CGPointMake(self.width/2, self.height/2);
}


#pragma mark 让一个View符合其内部元素的尺寸
-(void)fitSizeOfSubviews{
    CGFloat maxRight = 0.0;
    CGFloat maxBottom = 0.0;
    for(UIView* v in self.subviews){
        if((v.frame.origin.y+v.frame.size.height)>maxBottom){
            maxBottom=v.frame.origin.y+v.frame.size.height;
        }
        if((v.frame.origin.x+v.frame.size.width)>maxRight){
            maxRight=v.frame.origin.x+v.frame.size.width;
        }
    }
    
    self.size=CGSizeMake(maxRight, maxBottom);
}


-(void)fitWidthOfSubviews{
    CGFloat maxRight = 0.0;
    for(UIView* v in self.subviews){
        if((v.frame.origin.x+v.frame.size.width)>maxRight){
            maxRight=v.frame.origin.x+v.frame.size.width;
        }
    }
    
    self.size=CGSizeMake(maxRight, self.frame.size.height);
}
-(void)fitHeightOfSubviews{
    CGFloat maxBottom = 0.0;
    for(UIView* v in self.subviews){
        if((v.frame.origin.y+v.frame.size.height)>maxBottom){
            maxBottom=v.frame.origin.y+v.frame.size.height;
        }
    }
    
    self.size=CGSizeMake(self.frame.size.width, maxBottom);
}

-(void)fillSuperview:(UIView*)superview underOf:(UIView*)topview{
    [self fillSuperview:superview underOf:topview aboveOf:nil];
}
-(void)fillSuperview:(UIView*)superview aboveOf:(UIView*)bottomview{
    [self fillSuperview:superview underOf:nil aboveOf:bottomview];
}
-(void)fillSuperview:(UIView*)superview underOf:(UIView*)topview aboveOf:(UIView*)bottomview{
    [self fillSuperview:superview underOf:topview aboveOf:bottomview rightOf:nil leftOf:nil];
}
-(void)fillSuperview:(UIView*)superview rightOf:(UIView*)leftview{
    [self fillSuperview:superview rightOf:leftview leftOf:nil];
}
-(void)fillSuperview:(UIView*)superview leftOf:(UIView*)rightview{
    [self fillSuperview:superview rightOf:nil leftOf:rightview];
}
-(void)fillSuperview:(UIView*)superview rightOf:(UIView*)leftview leftOf:(UIView*)rightview{
    [self fillSuperview:superview underOf:nil aboveOf:nil rightOf:leftview leftOf:rightview];
}

-(void)fillSuperview:(UIView*)superview underOf:(UIView*)topview aboveOf:(UIView*)bottomview rightOf:(UIView*)leftview leftOf:(UIView*)rightview{
    if(superview!=nil){
        if(superview!=self.superview){
            if(self.superview!=nil){
                [self removeFromSuperview];
            }
            [superview addSubview:self];
        }
        self.top=0;
        if(topview!=nil){
            self.top=topview.bottom;
        }
        
        self.height=superview.height-self.top;
        if(bottomview!=nil){
            self.height-=bottomview.top;
        }
        
        self.left=0;
        if(leftview!=nil){
            self.left=leftview.right;
        }

        self.width=superview.width-self.left;
        if(rightview!=nil){
            self.width-=rightview.left;
        }
    }
}

#pragma mark 部分圆角
-(void)cornerRadius:(CGFloat)radius onCorner:(UIRectCorner)corner{
    UIBezierPath *maskPath = [UIBezierPath bezierPathWithRoundedRect:self.bounds byRoundingCorners:corner  cornerRadii:CGSizeMake(radius, radius)];
    CAShapeLayer *maskLayer = [[CAShapeLayer alloc] init];
    maskLayer.frame = self.bounds;
    maskLayer.path = maskPath.CGPath;
    self.layer.mask = maskLayer;
}

#pragma mark 清除所有手势
-(void)removeAllGestureRecognizer{
    for(UIGestureRecognizer* g in self.gestureRecognizers){
        [self removeGestureRecognizer:g];
    }
}
#pragma mark 设置手势（清除其他所有手势）
- (void)setGestureRecognizer:(nonnull UIGestureRecognizer*)g{
    [self removeAllGestureRecognizer];
    [self addGestureRecognizer:g];
}


@end


@implementation NSDictionary(JE)
-(NSMutableDictionary*) mutableDeepCopy{
    NSMutableDictionary *dict=[[NSMutableDictionary alloc] initWithCapacity:[self count]];
    //新建一个NSMutableDictionary对象，大小为原NSDictionary对象的大小
    NSArray *keys=[self allKeys];
    for(id key in keys)
    {//循环读取复制每一个元素
        id value=[self objectForKey:key];
        id copyValue;
        if ([value respondsToSelector:@selector(mutableDeepCopy)]) {
            //如果key对应的元素可以响应mutableDeepCopy方法(还是NSDictionary)，调用mutableDeepCopy方法复制
            copyValue=[value mutableDeepCopy];
        }else if([value respondsToSelector:@selector(mutableCopy)]){
            copyValue=[value mutableCopy];
        }else if([value respondsToSelector:@selector(copy)]){
            copyValue=[value copy];
        }else{
            copyValue=value;
        }
        [dict setObject:copyValue forKey:key];
        
    }
    return dict;
}

@end


@implementation NSArray(JE)
-(NSMutableArray*) mutableDeepCopy{
    NSMutableArray *arr=[[NSMutableArray alloc] initWithCapacity:[self count]];
    //新建一个NSMutableDictionary对象，大小为原NSDictionary对象的大小
    for(int i=0;i<self.count;i++){//循环读取复制每一个元素
        id value=self[i];
        id copyValue;
        if ([value respondsToSelector:@selector(mutableDeepCopy)]) {
            //如果key对应的元素可以响应mutableDeepCopy方法(还是NSDictionary)，调用mutableDeepCopy方法复制
            copyValue=[value mutableDeepCopy];
        }else if([value respondsToSelector:@selector(mutableCopy)]){
            copyValue=[value mutableCopy];
        }else if([value respondsToSelector:@selector(copy)]){
            copyValue=[value copy];
        }else{
            copyValue=value;
        }
        
        if(copyValue!=nil){
            [arr addObject:copyValue];
        }
        
    }
    return arr;
}

@end


@implementation UILabel (JE)
-(void)fit{
    [Utility fitLabel:self];
}
-(void)fitWithWidth:(CGFloat)width{
    CGSize size=getStringSizeLimitWithWidth(self.text, self.font, width);
    self.numberOfLines=0;
    self.lineBreakMode=NSLineBreakByWordWrapping;
    self.textAlignment=NSTextAlignmentLeft;
    CGRect frame=(CGRect){
        self.frame.origin.x,
        self.frame.origin.y,
        size.width,
        size.height};
    [self setFrame:frame];
}

@end



@implementation UIScrollView (JE)
-(void)fitContentHeightWithPadding:(CGFloat)padding{
    CGFloat maxBottom = 0.0;
    for(UIView* v in self.subviews){
        if((v.frame.origin.y+v.frame.size.height)>maxBottom){
            maxBottom=v.frame.origin.y+v.frame.size.height;
        }
    }
    
    [self setContentSize:CGSizeMake(self.frame.size.width, maxBottom+padding)];
}
-(void)fitContentWidthWithPadding:(CGFloat)padding{
    CGFloat maxRight = 0.0;
    for(UIView* v in self.subviews){
        if(v.right>maxRight){
            maxRight=v.right;
        }
    }
    
    [self setContentSize:CGSizeMake(maxRight+padding, self.frame.size.height)];
}
@end


@implementation UIImage (JE)

typedef enum {
    ALPHA = 0,
    BLUE = 1,
    GREEN = 2,
    RED = 3
} PIXELS;

- (UIImage *) greyImage {
    CGSize size = [self size];
    int width = size.width;
    int height = size.height;
    
    // the pixels will be painted to this array
    uint32_t *pixels = (uint32_t *) malloc(width * height * sizeof(uint32_t));
    
    // clear the pixels so any transparency is preserved
    memset(pixels, 0, width * height * sizeof(uint32_t));
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    
    // create a context with RGBA pixels
    CGContextRef context = CGBitmapContextCreate(pixels, width, height, 8, width * sizeof(uint32_t), colorSpace,
                                                 kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedLast);
    
    // paint the bitmap to our context which will fill in the pixels array
    CGContextDrawImage(context, CGRectMake(0, 0, width, height), [self CGImage]);
    
    for(int y = 0; y < height; y++) {
        for(int x = 0; x < width; x++) {
            uint8_t *rgbaPixel = (uint8_t *) &pixels[y * width + x];
            
            // convert to grayscale using recommended method: http://en.wikipedia./wiki/Grayscale#Converting_color_to_grayscale
            uint32_t gray = 0.3 * rgbaPixel[RED] + 0.59 * rgbaPixel[GREEN] + 0.11* rgbaPixel[BLUE];
            
            // set the pixels to gray
            rgbaPixel[RED] = gray;
            rgbaPixel[GREEN] = gray;
            rgbaPixel[BLUE] = gray;
        }
    }
    
    // create a new CGImageRef from our context with the modified pixels
    CGImageRef image = CGBitmapContextCreateImage(context);
    
    // we're done with the context, color space, and pixels
    CGContextRelease(context);
    CGColorSpaceRelease(colorSpace);
    free(pixels);
    
    // make a new UIImage to return
    UIImage *resultUIImage = [UIImage imageWithCGImage:image];
    
    // we're done with image now too
    CGImageRelease(image);
    
    return resultUIImage;
}

-(UIImage*)scaleToSize:(CGFloat)size{
    float scaleSize=size/(self.size.width>self.size.height?self.size.width:self.size.height);
    CGFloat width=self.size.width * scaleSize;
    CGFloat height=self.size.height * scaleSize;
    UIGraphicsBeginImageContext(CGSizeMake(width,height));
    [self drawInRect:CGRectMake(0, 0, width, height)];
    UIImage *scaledImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return scaledImage;
}

-(UIImage*)imageInRect:(CGRect)rect{
    
    //根据图片方向调整截取区域位置
    CGRect fixRect=CGRectMake(0, 0, 0, 0);
    if(self.imageOrientation==UIImageOrientationUp){
        fixRect.size.width=rect.size.width;
        fixRect.size.height=rect.size.height;
        fixRect.origin.x=rect.origin.x;
        fixRect.origin.y=rect.origin.y;
    }else if(self.imageOrientation==UIImageOrientationDown){
        fixRect.size.width=rect.size.width;
        fixRect.size.height=rect.size.height;
        rect.origin.x=self.size.width-rect.origin.x-rect.size.width;
        rect.origin.y=self.size.height-rect.origin.y-rect.size.height;
    }else if(self.imageOrientation==UIImageOrientationLeft){
        fixRect.size.width=rect.size.height;
        fixRect.size.height=rect.size.width;
        fixRect.origin.x=self.size.height-rect.origin.y-rect.size.height;
        fixRect.origin.y=rect.origin.x;
    }else if(self.imageOrientation==UIImageOrientationRight){
        fixRect.size.width=rect.size.height;
        fixRect.size.height=rect.size.width;
        fixRect.origin.x=rect.origin.y;
        fixRect.origin.y=self.size.width-rect.origin.x-rect.size.width;
    }else if(self.imageOrientation==UIImageOrientationUpMirrored){
        fixRect.size.width=rect.size.width;
        fixRect.size.height=rect.size.height;
        fixRect.origin.x=self.size.width-rect.origin.x-rect.size.width;
        fixRect.origin.y=rect.origin.y;
    }else if(self.imageOrientation==UIImageOrientationDownMirrored){
        fixRect.size.width=rect.size.width;
        fixRect.size.height=rect.size.height;
        fixRect.origin.x=rect.origin.x;
        fixRect.origin.y=self.size.height-rect.origin.y-rect.size.height;
    }else if(self.imageOrientation==UIImageOrientationLeftMirrored){
        fixRect.size.width=rect.size.height;
        fixRect.size.height=rect.size.width;
        fixRect.origin.x=rect.origin.y;
        fixRect.origin.y=rect.origin.x;
    }else if(self.imageOrientation==UIImageOrientationRightMirrored){
        fixRect.size.width=rect.size.height;
        fixRect.size.height=rect.size.width;
        fixRect.origin.x=self.size.height-rect.origin.y-rect.size.height;
        fixRect.origin.y=self.size.width-rect.origin.x-rect.size.width;
    }

    CGImageRef imageRef=CGImageCreateWithImageInRect(self.CGImage,fixRect);
    UIImage* retImage=[UIImage imageWithCGImage:imageRef scale:self.scale orientation:self.imageOrientation];
    CGImageRelease(imageRef);
    return retImage;
}

-(UIImage *)fixOrientation{
    CGImageRef imgRef = self.CGImage;
    CGFloat width = CGImageGetWidth(imgRef);
    CGFloat height = CGImageGetHeight(imgRef);
    
    CGAffineTransform transform = CGAffineTransformIdentity;
    CGRect bounds = CGRectMake(0, 0, width, height);
    
    CGFloat scaleRatio = 1;
    
    CGFloat boundHeight;
    UIImageOrientation orient = self.imageOrientation;
    switch(orient)
    {
        case UIImageOrientationUp: //EXIF = 1
            transform = CGAffineTransformIdentity;
            break;
            
        case UIImageOrientationUpMirrored: //EXIF = 2
            transform = CGAffineTransformMakeTranslation(width, 0.0);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            break;
            
        case UIImageOrientationDown: //EXIF = 3
            transform = CGAffineTransformMakeTranslation(width, height);
            transform = CGAffineTransformRotate(transform, M_PI);
            break;
            
        case UIImageOrientationDownMirrored: //EXIF = 4
            transform = CGAffineTransformMakeTranslation(0.0, height);
            transform = CGAffineTransformScale(transform, 1.0, -1.0);
            break;
            
        case UIImageOrientationLeftMirrored: //EXIF = 5
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(height, width);
            transform = CGAffineTransformScale(transform, -1.0, 1.0);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationLeft: //EXIF = 6
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(0.0, width);
            transform = CGAffineTransformRotate(transform, 3.0 * M_PI / 2.0);
            break;
            
        case UIImageOrientationRightMirrored: //EXIF = 7
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeScale(-1.0, 1.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        case UIImageOrientationRight: //EXIF = 8
            boundHeight = bounds.size.height;
            bounds.size.height = bounds.size.width;
            bounds.size.width = boundHeight;
            transform = CGAffineTransformMakeTranslation(height, 0.0);
            transform = CGAffineTransformRotate(transform, M_PI / 2.0);
            break;
            
        default:
            [NSException raise:NSInternalInconsistencyException format:@"Invalid image orientation"];
    }
    
    UIGraphicsBeginImageContext(bounds.size);
    
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    if (orient == UIImageOrientationRight || orient == UIImageOrientationLeft) {
        CGContextScaleCTM(context, -scaleRatio, scaleRatio);
        CGContextTranslateCTM(context, -height, 0);
    }
    else {
        CGContextScaleCTM(context, scaleRatio, -scaleRatio);
        CGContextTranslateCTM(context, 0, -height);
    }
    
    CGContextConcatCTM(context, transform);
    
    CGContextDrawImage(UIGraphicsGetCurrentContext(), CGRectMake(0, 0, width, height), imgRef);
    UIImage *imageCopy = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return imageCopy;
}
@end



@implementation NSDate(JE)

-(NSString*)formatedString{
    return [Utility formatStringFromDate:self withFormat: @"yyyy-M-d"];
}

-(NSString*)formatedStringWithFormat:(NSString*)format{
    return [Utility formatStringFromDate:self withFormat: format];
}

@end

@implementation NSObject(JE)


-(NSDictionary*)propertiesToDictionaryWithSuperclass:(Class)superclass{
    NSDictionary* ret=[Utility allPropertiesAndValueInObject:self WithSuperclass:superclass];
    return ret;
}
-(NSDictionary*)propertiesToDictionary{
    return [self propertiesToDictionaryWithSuperclass:[self class]];
}

-(void)fillPropertiesWithDictionary:(NSDictionary*)dataDict{
    if(dataDict!=nil){
        NSArray<NSDictionary<NSString*,NSString*>*>* ps=[Utility allPropertiesInClass:[self class] WithSuperclass:nil];
        for(NSDictionary<NSString*,NSString*>* p in ps){
            NSString* p_name=p[@"name"];
            @try {
                id p_value=dataDict[p_name];
                [self setValue:p_value forKey:p_name];
            }
            @catch (NSException *exception) {
            }
            @finally {
            }
        }
    }
}

@end
