//
//  Utility+IM.m
//  myim
//
//  Created by Sean Shi on 15/10/20.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "Utility+IM.h"
#import "RCIMDelegate.h"
#import <CommonCrypto/CommonDigest.h>

#define ANIMATE_DURATION 1
#define ANIMATE_DELAY 2


@interface ErrorAnimate : NSObject{
    UIView* _rootView;
    NSMutableArray<UILabel*>* _pool;
}
+(instancetype)shareErrorAnimate;
-(void)show:(NSString*)msg type:(ErrorType)type;
-(void)errorLabelDidShow:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
-(void)errorLabelDidHide:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context;
@end

static ErrorAnimate* global_errorAnimate;

@implementation ErrorAnimate

+(instancetype)shareErrorAnimate{
    if(global_errorAnimate==nil){
        global_errorAnimate=[[ErrorAnimate alloc]init];
    }
    return global_errorAnimate;
}

-(void)show:(NSString*)msg type:(ErrorType)type{
    if(_rootView==nil){
        _rootView=[UIApplication sharedApplication].keyWindow;
    }
    if(_rootView!=nil){
        UILabel* msgLabel=[[UILabel alloc]init];
        [_rootView addSubview:msgLabel];
        msgLabel.font=FONT_TEXT_NORMAL;
        msgLabel.text=msg;
        if(type==ErrorType_Network){
            msgLabel.textColor=COLOR_MESSAGE_ERROR_TEXT;
            msgLabel.backgroundColor=COLOR_MESSAGE_ERROR_BG;
        }else{
            msgLabel.textColor=COLOR_MESSAGE_TEXT;
            msgLabel.backgroundColor=COLOR_MESSAGE_BG;
        }
        [Utility fitLabel:msgLabel];
        msgLabel.textAlignment=NSTextAlignmentCenter;
        msgLabel.width=_rootView.width;
        msgLabel.height+=10;
        msgLabel.bottom=msgLabel.superview.height;
        
        msgLabel.alpha=0;
        
        if(_pool==nil){
            _pool=[Utility initArray:nil];
        }
        [_pool addObject:msgLabel];
        [self arrangeLabel];

        [UIView beginAnimations:nil context:(__bridge void * _Nullable)(msgLabel)];
        [UIView setAnimationDuration:ANIMATE_DURATION];
        [UIView setAnimationDelegate:self];
        [UIView setAnimationDidStopSelector:@selector(errorLabelDidShow:finished:context:)];
        msgLabel.alpha=1;
        [UIView commitAnimations];
    }
}
-(void)hide:(nonnull UILabel*)msgLabel{
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:ANIMATE_DURATION];
    [UIView setAnimationDelegate:self];
    [UIView setAnimationDidStopSelector:@selector(errorLabelDidHide:finished:context:)];
    msgLabel.alpha=0;
    [UIView commitAnimations];
}
-(void)errorLabelDidShow:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context{
    UILabel* msgLabel=(__bridge UILabel *)(context);
    runDelayInMain(^{
        [self hide:msgLabel];
    }, ANIMATE_DELAY);
    
}
-(void)errorLabelDidHide:(NSString *)animationID finished:(NSNumber *)finished context:(void *)context{
    UILabel* msgLabel=(__bridge UILabel *)(context);
    [msgLabel removeFromSuperview];
    if(_pool!=nil){
        [_pool removeObject:msgLabel];
    }
}

-(void)arrangeLabel{
    if(_pool!=nil && _pool.count>1){
        [UIView beginAnimations:nil context:nil];
        [UIView setAnimationDuration:0.2];
        for(int i=0;i<_pool.count-1;i++){
            @try {
                _pool[i].top-=_pool[_pool.count-1].height-1;
            }
            @catch (NSException *exception) {
                debugLog(@"%@",exception.description);
            }
        }
        [UIView commitAnimations];
    }
}

@end

@implementation Utility (IM)
//生成UILable，自动根据文字和字体修改size
+(UILabel* _Nonnull)genLabelWithText:(nullable NSString*)text bgcolor:(nullable UIColor*)bgcolor textcolor:(nullable UIColor*)textcolor font:(nullable UIFont*)font{
    UILabel* ret=[[UILabel alloc]init];
    ret.numberOfLines=0;
    if(text!=nil){
        ret.text=text;
    }
    if(bgcolor!=nil){
        ret.backgroundColor=bgcolor;
    }
    if(textcolor!=nil){
        ret.textColor=textcolor;
    }
    if(font!=nil){
        ret.font=font;
    }
    [Utility fitLabel:ret];
    return ret;
}

//连接融云服务
+(void)connectRongCloud{
    // 快速集成第二步，连接融云服务器
    NSString* rc_user_token=[Storage getRCUserToken];
    [[RCIM sharedRCIM] connectWithToken:rc_user_token success:^(NSString *userId) {
        // Connect 成功
        debugLog(@"Connect 成功,UserId:%@",userId);
    }
                                  error:^(RCConnectErrorCode status) {
                                      // Connect 失败
                                      debugLog(@"Connect 失败");
                                  }
                         tokenIncorrect:^() {
                             // Token 失效的状态处理
                             debugLog(@"失效的状态处理");
                         }];
    
    [[RCIM sharedRCIM]setUserInfoDataSource:[RCIMDelegate sharedDelegate]];
    [[RCIM sharedRCIM]setGroupInfoDataSource:[RCIMDelegate sharedDelegate]];
    [[RCIM sharedRCIM]setReceiveMessageDelegate:[RCIMDelegate sharedDelegate]];
    
}

//为身份证号加星号
+(nonnull NSString*)maskIDCard:(nonnull NSString*)idcard{
    return [[idcard substringToIndex:idcard.length>=10?10:idcard.length] stringByAppendingFormat:@"****%@",([idcard substringFromIndex:idcard.length>=14?14:idcard.length ])];
}

//判断性别数据是否为男
+(BOOL)isMale:(nonnull NSString*)gender{
    return ([gender isEqualToString:@"1"]
            ||[gender isEqualToString:@"男"]
            ||[gender isEqualToString:@"male"]
            );
}

//打开聊天界面
+(void)openConversationType:(RCConversationType)conversationType target:(nonnull NSString*)targetId title:(nonnull NSString*)title byViewController:(nonnull UIViewController*)viewController{
    CVC* conversationVC=[[CVC alloc]
                         initWithConversationType:conversationType
                         targetId:targetId
                         title:title
                         ];
    [viewController.navigationController pushViewController:conversationVC animated:true];
}
//打开单聊界面
+(void)openChatPersonTarget:(nonnull NSString*)targetId title:(nonnull NSString*)title  byViewController:(nonnull UIViewController*)viewController{
    [Utility openConversationType:ConversationType_PRIVATE target:targetId title:title byViewController:viewController];
}
//打开群聊界面
+(void)openChatGroupTarget:(nonnull NSString*)targetId title:(nonnull NSString*)title  byViewController:(nonnull UIViewController*)viewController{
    [Utility openConversationType:ConversationType_GROUP target:targetId title:title byViewController:viewController];
}

//通知有消息更新
+(void)notifyUpdateMessage{
    //发送系统消息通知更新
    [[NSNotificationCenter defaultCenter] postNotificationName:NSNOTIFICATIONCENTER_KEY_UNREADMESSAGE object:nil userInfo:nil];
}

//显示错误信息
+(void)showError:(nonnull NSString *)errorMsg type:(ErrorType)type{
    [[ErrorAnimate shareErrorAnimate] show:errorMsg type:type];
}
+(void)showError:(nonnull NSString *)errorMsg{
    [[ErrorAnimate shareErrorAnimate] show:errorMsg type:ErrorType_Network];
}
+(void)showMessage:(nonnull NSString*)msg{
    [Utility showError:msg type:ErrorType_Business];
}

//将时间字符串转换为一半小时为间隔的时间序号
+(NSInteger)parseIndexFromTime:(NSString*)time{
    NSInteger ret=-1;
    NSArray<NSString*>* a=[time componentsSeparatedByString:@":"];
    if(a.count>1){
        @try {
            ret=a[0].integerValue*2+(a[1].integerValue<30?0:1);
        }
        @catch (NSException *exception) {
            debugLog(@"%@",exception);
        }
        @finally {
        }
    }
    return ret;
}
+(NSString*)formatTimeFronIndex:(NSInteger)index{
    return [NSString stringWithFormat:@"%02d:%@",index/2,(index%2==0?@"00":@"30")];
}
#pragma mark 将字典值转为字典显示内容
+(NSString*)descInDict:(NSArray<Dict*>*)dict fromValue:(NSString*)value {
    NSString* ret=@"";
    if(dict!=nil){
        NSArray* valueArray=[value componentsSeparatedByString:@","];
        
        for(Dict* d in dict){
            if([valueArray containsObject:d.value]){
                ret=[ret stringByAppendingFormat:([Utility isEmptyString:ret]?@"%@":@",%@"),d.desc];
            }
        }
    }
    return ret;
}



+(NSString*) sha1:(NSString*)s{
    const char *cstr = [s cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:s.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}

+ (NSString *) sha1_base64:(NSString*)s{
    const char *cstr = [s cStringUsingEncoding:NSUTF8StringEncoding];
    NSData *data = [NSData dataWithBytes:cstr length:s.length];
    
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSData * base64 = [[NSData alloc]initWithBytes:digest length:CC_SHA1_DIGEST_LENGTH];
    
    
    
    NSString * output =[base64 base64EncodedStringWithOptions:0];
    return output;
}

@end

