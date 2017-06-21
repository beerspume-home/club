//
//  Utility+IM.h
//  myim
//
//  Created by Sean Shi on 15/10/20.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "Utility.h"
#import <RongIMKit/RongIMKit.h>
#import "Models.h"

@interface Utility (IM)
//生成UILable，自动根据文字和字体修改size
+(UILabel* _Nonnull )genLabelWithText:(nullable NSString*)text bgcolor:(nullable UIColor*)bgcolor textcolor:(nullable UIColor*)textcolor font:(nullable UIFont*)font;

//连接融云服务
+(void)connectRongCloud;

//为身份证号加星号
+(nonnull NSString*)maskIDCard:(nonnull NSString*)idcard;


//判断性别数据是否为男
+(BOOL)isMale:(nonnull NSString*)gender;

//打开聊天假面
+(void)openConversationType:(RCConversationType)conversationType target:(nonnull NSString*)targetId title:(nonnull NSString*)title byViewController:(nonnull UIViewController*)viewController;
//打开单聊界面
+(void)openChatPersonTarget:(nonnull NSString*)targetId title:(nonnull NSString*)title  byViewController:(nonnull UIViewController*)viewController;
//打开群聊界面
+(void)openChatGroupTarget:(nonnull NSString*)targetId title:(nonnull NSString*)title  byViewController:(nonnull UIViewController*)viewController;

//通知有消息更新
+(void)notifyUpdateMessage;

//显示错误提示
+(void)showError:(nonnull NSString*)errorMsg type:(ErrorType)type;
+(void)showError:(nonnull NSString *)errorMsg;
+(void)showMessage:(nonnull NSString*)msg;



//将时间字符串转换为一半小时为间隔的时间序号
+(NSInteger)parseIndexFromTime:(NSString*)time;
+(NSString*)formatTimeFronIndex:(NSInteger)index;


#pragma mark 将字典值转为字典显示内容
+(NSString*)descInDict:(NSArray<Dict*>*)dict fromValue:(NSString*)value;

+(NSString*) sha1:(NSString*)s;
+(NSString *) sha1_base64:(NSString*)s;
@end
