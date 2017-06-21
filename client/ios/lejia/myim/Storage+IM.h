//
//  Storage+IM.h
//  myim
//
//  Created by Sean Shi on 15/10/17.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "Storage.h"

@interface Storage (IM)
#pragma mark 检测有效的Remote Url
+(void)checkFastestRemoteUrl;

#pragma mark 获取本地登录信息
+(Person*) getLoginInfo;
+(void) setLoginInfo:(Person*)obj;

#pragma mark 获取用户头像
+(UIImage*) getUserImage;
+(void) setUserImage:(UIImage*)image;

#pragma mark 获取用户二维码
+(UIImage*) getQRCodeImage;

#pragma mark 保存通过手机验证码验证的手机号
+(void) setPhone:(NSString*)phone;
+(NSString*) getPhone;


#pragma mark 获取融云UserToken
+(NSString*) getRCUserToken;
+(void) setRCUserToken:(NSString*)obj;

#pragma mark 服务器access_token
+(NSString*) getAccessToken;
+(void) setAccessToken:(NSString*)obj;
+(NSDate*) getAccessTokenExpireTime;
+(void) setAccessTokenExpireTime:(NSDate*)obj;


#pragma mark 更新地区数据
+(NSArray<Area*>*) getAllArea;
+(void) setAllArea:(NSArray<Area*>*)allArea;

#pragma mark 地区数据版本
+(float) getAreaVersion;
+(void) setAreaVersion:(float)areaVersion;

#pragma mark 保存学员身份
+(Student*) getStudent;
+(void) setStudent:(Student*)obj;

#pragma mark 保存教练身份
+(Teacher*) getTeacher;
+(void) setTeacher:(Teacher*)obj;

#pragma mark 保存客服身份
+(CustomerService*) getCustomerService;
+(void) setCustomerService:(CustomerService*)obj;

#pragma mark 保存运营身份
+(Operation*) getOperation;+(void) setOperation:(Operation*)obj;

#pragma mark 获取当前有效身份并保存到本地
+(void)updateCharacter;

#pragma mark 更新当期用户信息并保存到本地
+(void)updateLoginInfo;

#pragma mark 获取系统配置的字符串
+(nullable NSString*)getAppTextWithKey:(nonnull NSString*)key;


#pragma mark 取得教学科目字典数据
+(NSArray<Dict*>*)teacherSkillDict;
#pragma mark 初始化字典数据
+(void)initDictData;
@end
