//
//  Utility.m
//  xcbteacher
//
//  Created by Sean Shi on 15/8/7.
//  Copyright (c) 2015年 车友会. All rights reserved.
//

#import "Utility.h"
#import "BaseModels.h"
#import <objc/runtime.h>
#import<CoreText/CoreText.h>
#import "Debug.h"

@implementation Utility

#pragma mark 获得中文拼音首字符
+(NSString*) firstLatinLetter:(NSString*) nameStr{
    NSString* ret=@"";
    if(![Utility isEmptyString:nameStr]){
        NSMutableString* py= [[NSMutableString alloc]initWithString:nameStr];
        if(CFStringTransform((__bridge CFMutableStringRef)py, 0, kCFStringTransformToLatin, false)){
            if(CFStringTransform((__bridge CFMutableStringRef)py, 0, kCFStringTransformStripDiacritics, false)){
                ret=[[py uppercaseString]substringToIndex:1];
            }
        }
            
    }
    return ret;
}

#pragma mark 加载PList文件
+(NSMutableDictionary*) loadPlistAsDictionary:(NSString*)name{
    NSBundle* mainBundle=[NSBundle mainBundle];
    NSURL* plistUrl=[mainBundle URLForResource:name withExtension:@"plist"];
    return  [NSMutableDictionary dictionaryWithContentsOfURL:plistUrl];
}

+(NSMutableArray*) loadPlistAsArray:(NSString*)name{
    NSBundle* mainBundle=[NSBundle mainBundle];
    NSURL* plistUrl=[mainBundle URLForResource:name withExtension:@"plist"];
    return  [NSMutableArray arrayWithContentsOfURL:plistUrl];
}

#pragma mark 初始化空数组
+(NSMutableArray*) initArray:(NSMutableArray*)array{
    if(array==nil){
        array=[NSMutableArray array];
    }else{
        [array removeAllObjects];
    }
    return array;
}

#pragma mark 初始化空字典
+(NSMutableDictionary*) initDictionary:(NSMutableDictionary*)dict{
    if(dict==nil){
        dict=[NSMutableDictionary dictionary];
    }else{
        [dict removeAllObjects];
    }
    return dict;
}

#pragma mark 取得屏幕截图
+(UIImage*) getScreenImage:(UIView*)view{
    UIGraphicsBeginImageContextWithOptions(view.frame.size, true, 0);
//    UIGraphicsBeginImageContext(view.frame.size);
    [view.layer renderInContext:UIGraphicsGetCurrentContext()];
    UIImage* screenImage=UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    return screenImage;
}

#pragma mark 取得当前的ViewController对象
+(UIViewController *)getCurrentVC{
    UIViewController *result = nil;
    
    UIWindow * window = [[UIApplication sharedApplication] keyWindow];
    if (window.windowLevel != UIWindowLevelNormal)
    {
        NSArray *windows = [[UIApplication sharedApplication] windows];
        for(UIWindow * tmpWin in windows)
        {
            if (tmpWin.windowLevel == UIWindowLevelNormal)
            {
                window = tmpWin;
                break;
            }
        }
    }
    
    UIView *frontView = [[window subviews] objectAtIndex:0];
    id nextResponder = [frontView nextResponder];
    
    if ([nextResponder isKindOfClass:[UIViewController class]])
        result = nextResponder;
    else
        result = window.rootViewController;
    
    return result;
}

#pragma mark 字符串RGB颜色转数字值
+(NSUInteger)colorStringToInt:(NSString *)colorStrig{
    const char *cstr;
    int startPosition = 0;
    NSUInteger nColor = 0;
    if(colorStrig!=nil){
        colorStrig=[colorStrig uppercaseString];
    }
    cstr = [colorStrig UTF8String];
    
    //判断是否有#号
    if (cstr[0] == '#') startPosition = 1;//有#号，则从第1位开始是颜色值，否则认为第一位就是颜色值
    else startPosition = 0;
    
    NSUInteger ret=0;
    for(int i=0;i<3;i++){
        //第1位颜色值
        int iPosition = startPosition + i*2;
        if (cstr[iPosition] >= '0' && cstr[iPosition] <='9') nColor = (cstr[iPosition] - '0') * 16;
        else  nColor = (cstr[iPosition] - 'A' + 10) * 16;
        
        //第2位颜色值
        iPosition++;
        if (cstr[iPosition] >= '0' && cstr[iPosition] <='9') nColor = nColor + (cstr[iPosition] - '0');
        else nColor = nColor + (cstr[iPosition] - 'A' + 10);
        ret|=(nColor<<((2-i)*8));
    }
    return ret;
}

#pragma mark 检查身份证格式
+(BOOL) checkIDCardFormat:(NSString*)idcard{
    idcard=[idcard stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(idcard==nil || (idcard.length!=15 && idcard.length!=18)){
        return false;
    }else{
        for(int i=0;i<idcard.length;i++){
            unichar c=[idcard characterAtIndex:i];
            if((c<'0' || c>'9') && c!='x' && c!='X'){
                return false;
            }
        }
    }
    return true;
}

#pragma mark 检查手机号格式
+(BOOL) checkPhoneFormat:(NSString*)phone{
    phone=[phone stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(phone==nil || phone.length!=11 || ![@"1" isEqualToString:[phone substringToIndex:1]]){
        return false;
    }else{
        for(int i=0;i<phone.length;i++){
            unichar c=[phone characterAtIndex:i];
            if(c<'0' || c>'9'){
                return false;
            }
        }
    }
    return true;
}
#pragma mark 检查验证码格式
+(BOOL) checkVerifyCodeFormat:(NSString*)code{
    code=[code stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    return code.length>0;
}
#pragma mark Trim
+(NSString*) trim:(NSString*)str{
    NSString* ret=[str stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    if(ret==nil)ret=@"";
    return ret;
}

#pragma mark 输出为字符串
+(NSString*) convertIntToString:(int) obj{
    return [NSString stringWithFormat:@"%d",obj];
}
+(NSString*) convertFloatToString:(float) obj{
    return [NSString stringWithFormat:@"%f",obj];
}
+(NSString*) convertDoubleToString:(double) obj{
    return [NSString stringWithFormat:@"%f",obj];
}
+(NSString*) convertToString:(id)obj{
    if([obj isKindOfClass:[NSNumber class]]){
        return [((NSNumber*)obj) stringValue];
    }
    return nil;
}

#pragma mark 设置元素位置及大小
+(void) setX:(CGFloat)x ofView:(UIView*)v{
    if(v!=nil){
        CGRect frame=v.frame;
        frame.origin.x=x;
        [v setFrame:frame];
    }
}
+(void) setY:(CGFloat)y ofView:(UIView*)v{
    if(v!=nil){
        CGRect frame=v.frame;
        frame.origin.y=y;
        [v setFrame:frame];
    }
}
+(void) setWidth:(CGFloat)w ofView:(UIView*)v{
    if(v!=nil){
        CGRect frame=v.frame;
        frame.size.width=w;
        [v setFrame:frame];
    }
}
+(void) setHeight:(CGFloat)h ofView:(UIView*)v{
    if(v!=nil){
        CGRect frame=v.frame;
        frame.size.height=h;
        [v setFrame:frame];
    }
    
}
+(void) setSize:(CGSize)size ofView:(UIView*)v{
    if(v!=nil){
        CGRect frame=v.frame;
        frame.size=size;
        [v setFrame:frame];
    }
    
}
+(void) setOrigin:(CGPoint)origin ofView:(UIView*)v{
    if(v!=nil){
        CGRect frame=v.frame;
        frame.origin=origin;
        [v setFrame:frame];
    }
}
+(void) setCenterX:(CGFloat)x ofView:(UIView*)v{
    if(v!=nil){
        CGPoint center=v.center;
        center.x=x;
        [v setCenter:center];
    }
}
+(void) setCenterY:(CGFloat)y ofView:(UIView*)v{
    if(v!=nil){
        CGPoint center=v.center;
        center.y=y;
        [v setCenter:center];
    }
}
+(void) setCenter:(CGPoint)point ofView:(UIView*)v{
    if(v!=nil){
        [v setCenter:point];
    }
}

#pragma mark 判断设备是否为iPhone
+(BOOL) deviceIsIPhone{
    return UI_USER_INTERFACE_IDIOM()==UIUserInterfaceIdiomPhone;
}

#pragma mark 判断一个UIView是否是输入框
+(BOOL) isInputView:(UIView*)v{
    return ([v isKindOfClass:[UITextField class]] || [v isKindOfClass:[UITextView class]]);
}

#pragma mark 使UILable适合其中的文字大小
+(void) fitLabel:(UILabel*)label{
    [Utility fitLabel:label usePadding:false];
}

+(void) fitLabel:(UILabel*)label usePadding:(BOOL)usePadding{
    CGFloat widthPadding=0;
    CGFloat heightPadding=0;
    if(usePadding){
        widthPadding=heightPadding=5;
    }
    [Utility fitLabel:label  WithWidthPadding:widthPadding WithHeightPadding:heightPadding];
}
+(void) fitLabel:(UILabel*)label WithWidthPadding:(CGFloat)widthPadding WithHeightPadding:(CGFloat)heightPadding{
    if(label!=nil){
        CGSize size=getStringSize(label.text,label.font);
        size.width+=widthPadding*2;
        size.height+=heightPadding*2;
        [label setFrame:CGRectMake(
                                  label.frame.origin.x,
                                  label.frame.origin.y,
                                  size.width,
                                  size.height)
         ];
    }
}



#pragma mark HighLight关键字
+(NSAttributedString*)highLightString:(nonnull NSString*)content withKeyword:(nonnull NSString*)keyword highLightColor:(nonnull UIColor*)color{
    NSMutableAttributedString* ret=[[NSMutableAttributedString alloc]initWithString:content];
    if(keyword.length>0){
        NSRange range=[content rangeOfString:keyword];
        while(range.location!=NSNotFound){
            [ret addAttribute:NSForegroundColorAttributeName
                        value:(id)color
                        range:range];
            NSRange r0;
            r0.location=range.location+range.length;
            r0.length=content.length-r0.location;
            range=[content rangeOfString:keyword options:NSCaseInsensitiveSearch range:r0];
        }
    }
    return ret;
}

#pragma mark 转换为金额字符串
+(NSAttributedString*)convertToStringFromMoney:(float)amount font:(nullable UIFont*)font{
    if(font==nil){
        font=[UIFont systemFontOfSize:30.0];
    }
    int number=(int)amount;
    int decimal=(int)((amount-number)*100);
    
    NSString* content=[NSString stringWithFormat:@"￥ %d.%02d",number,decimal];
    NSMutableAttributedString* ret=[[NSMutableAttributedString alloc]initWithString:content];
    NSRange range=[content rangeOfString:@"."];
    [ret addAttribute:NSFontAttributeName
                value:font
                range:NSMakeRange(0,range.location+range.length)];
    [ret addAttribute:NSFontAttributeName
                value:[UIFont fontWithName:font.fontName size:font.pointSize*0.8]
                range:NSMakeRange(range.location+range.length, 2)];
    return ret;
}

#pragma mark 判断字符串是否为空内容
+(BOOL)isEmptyString:(NSString*)s;{
    return (s==nil || ![s isKindOfClass:[NSString class]] || [Utility trim:s].length==0);
}



#pragma mark 获取一个类的所有属性
+(NSArray<NSDictionary<NSString*,NSString*>*>*)allPropertiesInClass:(Class)class WithSuperclass:(Class)superclass{
    NSMutableArray<NSDictionary<NSString*,NSString*>*>* ret=[Utility initArray:nil];
    u_int count;
    while((superclass==nil || [class isSubclassOfClass:superclass]) && class!=nil){
        objc_property_t *properties  =class_copyPropertyList(class, &count);
//        NSMutableArray *propertiesArray = [NSMutableArray arrayWithCapacity:count];
        for (int i = 0; i<count; i++)
        {
            const char* propertyName =property_getName(properties[i]);
            const char* propertyAttributes=property_getAttributes(properties[i]);
            
            NSString* attributes=[NSString stringWithCString:propertyAttributes encoding:NSASCIIStringEncoding];
            NSArray<NSString *>* attr=[attributes componentsSeparatedByString:@","];
            if(attr.count>1){
                [ret addObject:@{
                             @"name":[NSString stringWithCString:propertyName encoding:NSASCIIStringEncoding],
                             @"returntype":attr[0],
                             @"readonly":[NSNumber numberWithBool:[@"R" isEqualToString:attr[1]]],
                             }];
            }
        }
        free(properties);
        class =class_getSuperclass(class);
    }
    return ret;
}
#pragma mark 获取一个类的所有属性和值
+(NSDictionary<NSString*,id>*)allPropertiesAndValueInObject:(id)object WithSuperclass:(Class)superclass{
    NSMutableDictionary<NSString*,id>* ret=[Utility initDictionary:nil];

    NSArray<NSDictionary<NSString*,NSString*>*>* ps=[Utility allPropertiesInClass:[object class] WithSuperclass:superclass];
    for(NSDictionary<NSString*,NSString*>* p in ps){
        NSString* p_name=p[@"name"];
        id p_value=[object valueForKey:p_name];
        [ret setObject:p_value forKey:p_name];
    }
    return ret;
}


#pragma mark 向Array中添加[NSNull null]直到指定的index
+(NSMutableArray*)appendNullToArray:(NSMutableArray*)array untilIndex:(int)index{
    if(array==nil){
        array=[Utility initArray:nil];
    }
    for(NSUInteger i=array.count;i<=index;i++){
        [array addObject:[NSNull null]];
    }
    return array;
}


#pragma mark 清空一个View的所有子View
+(void)cleanView:(UIView*)view{
    if(view!=nil){
        for(UIView* v in view.subviews){
            [v removeFromSuperview];
        }
    }
}


#pragma mark 计算一个View中所有子View的最底部位置
+(CGFloat)calcBottomOfSubviewsInView:(UIView*)view{
    CGFloat maxBottom = 0.0;
    if(view!=nil){
        for(UIView* v in view.subviews){
            if((v.frame.origin.y+v.frame.size.height)>maxBottom){
                maxBottom=v.frame.origin.y+v.frame.size.height;
            }
        }
    }
    return maxBottom;
}

@end

#pragma mark 封装GCD
void runInBackground(dispatch_block_t block){
    if(block){
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0),block);
    }
}
void runDelayInBackground(dispatch_block_t block,double delayInSeconds){
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block);
    
}
void runInMain(dispatch_block_t block){
    if(block){
        dispatch_async(dispatch_get_main_queue(),block);
    }
}
void runDelayInMain(dispatch_block_t block,double delayInSeconds){
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, dispatch_get_main_queue(), block);
}
void runInQueue(NSString* queueName,dispatch_block_t block){
    dispatch_async(getGCDQueue(queueName),block);
}
void runDelayInQueue(NSString* queueName,dispatch_block_t block,double delayInSeconds){
    dispatch_time_t popTime = dispatch_time(DISPATCH_TIME_NOW, delayInSeconds * NSEC_PER_SEC);
    dispatch_after(popTime, getGCDQueue(queueName), block);
}
dispatch_queue_t getGCDQueue(NSString* queueName){
    if(GCD_QUEUE==nil){
        GCD_QUEUE=[Utility initDictionary:GCD_QUEUE];
    }
    if([GCD_QUEUE objectForKey:queueName]==nil){
        dispatch_queue_t queue=dispatch_queue_create([queueName cStringUsingEncoding:NSUTF8StringEncoding], DISPATCH_QUEUE_SERIAL);

//        void* a=(__bridge void *)(queue);
//        id b=(__bridge id)(a);
        [GCD_QUEUE setObject:queue forKey:queueName];
        return queue;
    }else{
        return (dispatch_queue_t)[GCD_QUEUE objectForKey:queueName];
    }
}

#pragma mark 将Key,Value对组成URL参数
NSString* parseUrlParameter(NSString* obj, ...){
    va_list params;
    va_start(params, obj);
    NSString* ret=parseUrlParameter_v(obj,params);
    va_end(params);
    return ret;
}

NSString* parseUrlParameter_v(NSString* obj, va_list args){
    NSMutableString* ret=[NSMutableString string];
    NSArray* formats=[NSArray arrayWithObjects:@"%@=",@"%@&", nil];
    int index=0;
    [ret appendFormat:[formats objectAtIndex:index],obj];
    index=index==0?1:0;
    id arg;
    while((arg = va_arg(args,id))){
        if (arg){
            [ret appendFormat:[formats objectAtIndex:index],arg];
            index=index==0?1:0;
        }
        
    }
    return ret;
}
NSString* parseUrlParameter_a(NSString* prefixname,NSArray* data){
    NSMutableString* ret=[NSMutableString string];
    if(prefixname==nil)prefixname=@"";
    for(int i=0;i<data.count;i++){
        NSString* p=nil;
        NSString* p_name=[prefixname stringByAppendingFormat:@"[%d]",i];
        id obj=[data objectAtIndex:i];
        if([obj isKindOfClass:[NSArray class]]){
            p=parseUrlParameter_a([p_name stringByAppendingString:@"_a"], obj);
        }else if([obj isKindOfClass:[NSDictionary class]]){
            p=parseUrlParameter_d([p_name stringByAppendingString:@"_d_"], obj);
        }else if([obj isKindOfClass:[NSString class]]){
            p=[NSString stringWithFormat:@"&%@=%@",p_name,obj];
        }else{
            p=@"";
        }
        [ret appendString:p];
    }
    
    return ret;
}

NSString* parseUrlParameter_d(NSString* prefixname,NSDictionary* data){
    NSMutableString* ret=[NSMutableString string];
    if(prefixname==nil)prefixname=@"";
    for(id obj in data){
        if([obj isKindOfClass:[NSString class]]){
            NSString* p=nil;
            NSString* p_name;
            p_name=[prefixname stringByAppendingString:obj];
            id value=[data objectForKey:obj];
            if([value isKindOfClass:[NSDictionary class]]){
                p=parseUrlParameter_d([p_name stringByAppendingString:@"_"], value);
            }else if([value isKindOfClass:[NSArray class]]){
                p=parseUrlParameter_a(p_name, value);
            }else{
                p=[NSString stringWithFormat:@"&%@=%@",p_name,value];
            }
            [ret appendString:p];
        }
    }
    return ret;
}

#pragma mark 自动填充值对象(VO)
id autoFillObjFromDictionary(id obj,NSDictionary* data){
    if(data==nil)return obj;
    Class cls = [obj class];
    while (cls != [NSObject class] && [cls isSubclassOfClass:[BaseObject class]])
    {
        unsigned int numberOfIvars = 0;
        Ivar* ivars = class_copyIvarList(cls, &numberOfIvars);//获取cls 类成员变量列表
        for(const Ivar* p = ivars; p < ivars+numberOfIvars; p++)//采用指针+1 来获取下一个变量
        {
            Ivar const ivar = *p;//取得这个变量
//            const char *type = ivar_getTypeEncoding(ivar); //取得这个变量的类型
            NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];//取得这个变量的名称
            
            NSString* keyInData=[key substringFromIndex:1];
            id valueInData=[data objectForKey:keyInData];
            @try{
                if([valueInData isKindOfClass:[NSNull class]]){
                    [obj setValue:nil forKey:key];
                }else{
                    [obj setValue:valueInData forKey:key];
                }
            }@catch(NSException* e){
                debugLog(@"autoFillObjFromDictionary:%@",e);
            }
            
        }
        cls = class_getSuperclass(cls);
    }
    return obj;
}

NSDictionary* convertObjToDictionary(id obj){
    NSMutableDictionary* ret=[NSMutableDictionary dictionary];
    
    if(obj!=nil){
        Class cls = [obj class];
        while (cls != [NSObject class] && [cls isSubclassOfClass:[BaseObject class]])
        {
            unsigned int numberOfIvars = 0;
            Ivar* ivars = class_copyIvarList(cls, &numberOfIvars);//获取cls 类成员变量列表
            for(const Ivar* p = ivars; p < ivars+numberOfIvars; p++)//采用指针+1 来获取下一个变量
            {
                Ivar const ivar = *p;//取得这个变量
                //            const char *type = ivar_getTypeEncoding(ivar); //取得这个变量的类型
                NSString *key = [NSString stringWithUTF8String:ivar_getName(ivar)];//取得这个变量的名称
                
                NSString* keyInData=[key substringFromIndex:1];
                id value=[obj valueForKey:key];
                if([value isKindOfClass:[BaseObject class]]){
                    value=convertObjToDictionary(value);
                }
                //NSNumber（Integer、Float、Double），NSString，NSDate，NSArray，NSDictionary，BOOL类型
                if([value isKindOfClass:[NSNumber class]]
                   || [value isKindOfClass:[NSString class]]
                   || [value isKindOfClass:[NSDate class]]
                   || [value isKindOfClass:[NSArray class]]
                   || [value isKindOfClass:[NSDictionary class]]
                   ){
                    [ret setObject:value forKey:keyInData];
                }
            }
            cls = class_getSuperclass(cls);
        }
    }
    
    return ret;
}



#pragma mark 获得文字的像素大小
CGSize getStringSize(NSString* string,UIFont* font){
    return [string boundingRectWithSize:CGSizeMake(MAXFLOAT, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
    
}
CGSize getStringSizeLimitWithWidth(NSString* string,UIFont* font,CGFloat widthLimit){
    return [string boundingRectWithSize:CGSizeMake(widthLimit, MAXFLOAT) options:NSStringDrawingUsesLineFragmentOrigin attributes:@{NSFontAttributeName:font} context:nil].size;
    
}


#pragma mark 取得系统版本号
float getSystemVersion(){
    return [[[UIDevice currentDevice]systemVersion] floatValue];
}

#pragma mark 取得当前屏幕大小
CGSize getScreenSize(){
    UIInterfaceOrientation interfaceOrientation=[UIApplication sharedApplication].statusBarOrientation;
    CGSize size=[[UIScreen mainScreen] bounds].size;
    if(getSystemVersion()<8.0){
        if(interfaceOrientation==UIInterfaceOrientationLandscapeLeft || interfaceOrientation==UIInterfaceOrientationLandscapeRight){
            size=CGSizeMake(size.height, size.width);
        }
    }

    return size;
}


#pragma mark 读取通讯录
void systemAddressBook(void(^handler)(NSDictionary<NSString*,NSString*>* addressBook)){
    systemAddressBookMobileOnly(handler,false);
}
void systemAddressBookMobileOnly(void(^handler)(NSDictionary<NSString*,NSString*>* addressBook), BOOL onlyMobile){
    debugLog(@"检测系统版本");
    if(getSystemVersion()>=6.0){
        debugLog(@"系统版本%f,申请获取通讯录权限",getSystemVersion());
        __block ABAddressBookRef addressBook=ABAddressBookCreate();
        ABAddressBookRequestAccessWithCompletion(addressBook, ^(bool granted, CFErrorRef error) {
            NSMutableDictionary* ret=[Utility initDictionary:nil];
            if(granted){
                debugLog(@"获取通讯录授权成功");
                @try {
                    CFArrayRef results = ABAddressBookCopyArrayOfAllPeople(addressBook);
                    NSArray<NSString*>* replaceString=@[@"*86",@"-",@" ",@"(",@")",@"+",@";"];
                    for(int i=0;i<CFArrayGetCount(results);i++){
                        ABRecordRef person=CFArrayGetValueAtIndex(results, i);
                        NSString* firstName=(__bridge NSString*)ABRecordCopyValue(person, kABPersonFirstNameProperty);
                        NSString* middleName=(__bridge NSString*)ABRecordCopyValue(person, kABPersonMiddleNameProperty);
                        NSString* lastName=(__bridge NSString*)ABRecordCopyValue(person, kABPersonLastNameProperty);
                        NSString* name=[NSString stringWithFormat:@"%@%@%@",
                                        firstName==nil?@"":firstName,
                                        middleName==nil?@"":[NSString stringWithFormat:@" %@",middleName],
                                        lastName==nil?@"":[NSString stringWithFormat:@" %@",lastName]
                                        ];
                        
                        ABMultiValueRef phones = ABRecordCopyValue(person, kABPersonPhoneProperty);
                        for (int k = 0; k<ABMultiValueGetCount(phones); k++){
                            //获取电话Label
//                            NSString * phoneLabel = (__bridge NSString*)ABAddressBookCopyLocalizedLabel(ABMultiValueCopyLabelAtIndex(phones, k));
                            //获取該Label下的电话值
                            NSString * phone = (__bridge NSString*)ABMultiValueCopyValueAtIndex(phones, k);
                            NSMutableString* a=[NSMutableString stringWithString:phone];
                            for(int i=0;i<replaceString.count;i++){
                                NSString* ch=replaceString[i];
                                [a replaceOccurrencesOfString:ch
                                                   withString:@""
                                                      options:NSCaseInsensitiveSearch
                                                        range:NSMakeRange(0, a.length)
                                 ];
                            }
                            phone=[NSString stringWithString:a];
                            if(!onlyMobile || [Utility checkPhoneFormat:phone]){
                                if(ret[phone]==nil){
                                    ret[phone]=name;
                                }else{
                                    ret[phone]=[ret[phone] stringByAppendingFormat:@",%@",name];
                                }
                            }
                        }
                    }
                }
                @catch (NSException *exception) {
                    debugLog(@"%@",exception.description);
                }
                @finally {
                    ABAddressBookRevert(addressBook);
                }
            }else{
                debugLog(@"获取通讯录录授权失败");
            }
            handler(ret);
        });
        
    }
}

