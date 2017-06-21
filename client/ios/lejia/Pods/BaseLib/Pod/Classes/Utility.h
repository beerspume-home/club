//
//  Utility.h
//  xcbteacher
//
//  Created by Sean Shi on 15/8/7.
//  Copyright (c) 2015年 车友会. All rights reserved.
//
#ifndef BaseLib_Utility_h
#define BaseLib_Utility_h

#if TARGET_IPHONE_SIMULATOR
#define SIMULATOR 1
#elif TARGET_OS_IPHONE
#define SIMULATOR 0
#endif

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import <AddressBook/AddressBook.h>


#define UIColorFromRGB(rgbValue) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

//RGB color macro with alpha
#define UIColorFromRGBWithAlpha(rgbValue,a) [UIColor \
colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 \
green:((float)((rgbValue & 0xFF00) >> 8))/255.0 \
blue:((float)(rgbValue & 0xFF))/255.0 alpha:a]


typedef NS_ENUM(NSInteger, ErrorType) {
    ErrorType_UnKnow      = 0,
    ErrorType_Network,
    ErrorType_Business,
};


@interface Utility : NSObject

#pragma mark 获得中文拼音首字符
+(nullable NSString*) firstLatinLetter:(nullable NSString*) nameStr;

#pragma mark 加载PList文件
+(nullable NSMutableDictionary*) loadPlistAsDictionary:(nullable NSString*)name;
+(nullable NSMutableArray*) loadPlistAsArray:(nullable NSString*)name;

#pragma mark 初始化空数组
+(nonnull NSMutableArray*) initArray:(nullable NSMutableArray*)array;
#pragma mark 初始化空字典
+(nonnull NSMutableDictionary*) initDictionary:(nullable NSMutableDictionary*)dict;

#pragma mark 取得屏幕截图
+(nullable UIImage*) getScreenImage:(nullable UIView*)view;

#pragma mark 取得当前的ViewController对象
+(nullable UIViewController *)getCurrentVC;

#pragma mark 字符串RGB颜色转数字值
+(NSUInteger)colorStringToInt:(nullable NSString *)colorStrig;

#pragma mark 检查身份证格式
+(BOOL) checkIDCardFormat:(nullable NSString*)idcard;
#pragma mark 检查手机号格式
+(BOOL) checkPhoneFormat:(nullable NSString*)phone;
#pragma mark 检查验证码格式
+(BOOL) checkVerifyCodeFormat:(nullable NSString*)code;

#pragma mark Trim
+(nullable NSString*) trim:(nullable NSString*)str;

#pragma mark 输出为字符串
+(nonnull NSString*) convertIntToString:(int) obj;
+(nonnull NSString*) convertFloatToString:(float) obj;
+(nonnull NSString*) convertDoubleToString:(double) obj;

#pragma mark 设置元素位置及大小
+(void) setX:(CGFloat)x ofView:(nullable UIView*)v;
+(void) setY:(CGFloat)y ofView:(nullable UIView*)v;
+(void) setWidth:(CGFloat)w ofView:(nullable UIView*)v;
+(void) setHeight:(CGFloat)h ofView:(nullable UIView*)v;
+(void) setSize:(CGSize)size ofView:(nullable UIView*)v;
+(void) setOrigin:(CGPoint)origin ofView:(nullable UIView*)v;
+(void) setCenterX:(CGFloat)x ofView:(nullable UIView*)v;
+(void) setCenterY:(CGFloat)y ofView:(nullable UIView*)v;
+(void) setCenter:(CGPoint)point ofView:(nullable UIView*)v;

#pragma mark 判断设备是否为iPhone
+(BOOL) deviceIsIPhone;

#pragma mark 判断一个UIView是否是输入框
+(BOOL) isInputView:(nonnull UIView*)v;

#pragma mark 使UILable适合其中的文字大小
+(void) fitLabel:(nonnull UILabel*)label;
+(void) fitLabel:(nonnull UILabel*)label usePadding:(BOOL)usePadding;
+(void) fitLabel:(nonnull UILabel*)label WithWidthPadding:(CGFloat)widthPadding WithHeightPadding:(CGFloat)heightPadding;

#pragma mark 转换一个类型为字符串
+(nonnull NSString*)convertToString:(nonnull id)obj;

#pragma mark HighLight关键字
+(nonnull NSAttributedString*)highLightString:(nonnull NSString*)content withKeyword:(nonnull NSString*)keyword highLightColor:(nonnull UIColor*)color;

#pragma mark 转换为金额字符串
+(nonnull NSAttributedString*)convertToStringFromMoney:(float)amount font:(nullable UIFont*)font;

#pragma mark 判断字符串是否为空内容
+(BOOL)isEmptyString:(nullable NSString*)s;

#pragma mark 获取一个类的所有属性
+(nonnull NSArray<NSDictionary<NSString*,NSString*>*>*)allPropertiesInClass:(nonnull Class)class WithSuperclass:(nullable Class)superclass;

#pragma mark 获取一个类的所有属性和值
+(nonnull NSDictionary<NSString*,id>*)allPropertiesAndValueInObject:(nonnull id)object WithSuperclass:(nullable Class)superclass;

#pragma mark 向Array中添加[NSNull null]直到指定的index
+(nonnull NSMutableArray*)appendNullToArray:(nullable NSMutableArray*)array untilIndex:(int)index;

#pragma mark 清空一个View的所有子View
+(void)cleanView:(nonnull UIView*)view;

#pragma mark 计算一个View中所有子View的最底部位置
+(CGFloat)calcBottomOfSubviewsInView:(nonnull UIView*)view;

@end

#pragma mark 封装GCD
static NSMutableDictionary* _Nullable GCD_QUEUE;
void runInBackground(_Nonnull dispatch_block_t block);
void runDelayInBackground(_Nonnull dispatch_block_t block,double delayInSeconds);
void runInMain(_Nonnull dispatch_block_t block);
void runDelayInMain(_Nonnull dispatch_block_t block,double delayInSeconds);
void runInQueue(NSString* _Nonnull queueName,_Nonnull  dispatch_block_t block);
void runDelayInQueue(NSString* _Nonnull queueName,_Nonnull dispatch_block_t block,double delayInSeconds);
_Nullable dispatch_queue_t getGCDQueue(NSString* _Nonnull queueName);


#pragma mark 将Key,Value对组成URL参数
NSString* _Nullable parseUrlParameter(NSString* _Nullable obj, ...);

#pragma clang diagnostic push
#pragma clang diagnostic ignored "-Wnullability-completeness"
NSString* _Nullable parseUrlParameter_v(NSString* _Nullable obj, va_list args);
#pragma clang diagnostic pop

NSString* _Nullable parseUrlParameter_d(NSString* _Nullable prefixname,NSDictionary* _Nullable data);
NSString* _Nullable parseUrlParameter_a(NSString* _Nullable prefixname,NSArray* _Nullable data);

#pragma mark 自动填充值对象(VO)
id _Nullable autoFillObjFromDictionary(id _Nullable obj,NSDictionary* _Nullable data);
NSDictionary* _Nullable convertObjToDictionary(id _Nullable obj);

#pragma mark 获得文字的像素大小
CGSize getStringSize(NSString* _Nonnull string,UIFont* _Nonnull font);
CGSize getStringSizeLimitWithWidth(NSString* _Nonnull string,UIFont* _Nonnull font,CGFloat widthLimit);

#pragma mark 取得系统版本号
float getSystemVersion();

#pragma mark 取得当前屏幕大小
CGSize getScreenSize();


#pragma mark 读取通讯录
void addressBookChanged(ABAddressBookRef _Nullable addressBook,CFDictionaryRef _Nullable info,void* _Nullable context);
void systemAddressBook(void(^ _Nullable handler)(NSDictionary<NSString*,NSString*>* _Nullable addressBook));
void systemAddressBookMobileOnly(void(^ _Nullable handler)(NSDictionary<NSString*,NSString*>*  _Nullable addressBook), BOOL onlyMobile);
#endif