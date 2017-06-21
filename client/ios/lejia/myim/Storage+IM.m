//
//  Storage+IM.m
//  myim
//
//  Created by Sean Shi on 15/10/17.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "Storage+IM.h"
#import "AreaManager.h"

#define STORAGE_KEY_PHONE @"STORAGE_KEY_PHONE"
#define STORAGE_KEY_LOGININFO @"STORAGE_KEY_LOGININFO"
#define STORAGE_KEY_STUDENT @"STORAGE_KEY_STUDENT"
#define STORAGE_KEY_TEACHER @"STORAGE_KEY_TEACHER"
#define STORAGE_KEY_CUSTOMERSERVICE @"STORAGE_KEY_CUSTOMERSERVICE"
#define STORAGE_KEY_OPERATION @"STORAGE_KEY_OPERATION"


#define STORAGE_KEY_USERIMAGE @"STORAGE_KEY_USERIMAGE"
#define STORAGE_KEY_ACCESSTOKEN @"STORAGE_KEY_ACCESSTOKEN"
#define STORAGE_KEY_ACCESSTOKEN_EXPIRETIME @"STORAGE_KEY_ACCESSTOKEN_EXPIRETIME"
#define STORAGE_KEY_RCUSERTOKEN @"STORAGE_KEY_RCUSERTOKEN"
#define STORAGE_KEY_AREA_VERSION @"STORAGE_KEY_AREA_VERSION"

#define STORAGE_KEY_TEACHERSKILLDICT @"STORAGE_KEY_TEACHERSKILLDICT"

#define STORAGE_KEY_REMOTEURL @"BaseUrlList"

@implementation Storage (IM)


static NSString* FastestRemoteUrl;
+(NSString*)getBaseUrl{
    NSString* ret=[[[NSBundle mainBundle] infoDictionary] objectForKey:BASE_URL_KEY];
    if(FastestRemoteUrl!=nil){
        ret=FastestRemoteUrl;
    }else{
        [Storage checkFastestRemoteUrl];
    }
    return ret;
}

#pragma mark 检测有效的Remote Url
+(void)checkFastestRemoteUrl{
    NSArray<NSString*>* urls=[[[NSBundle mainBundle] infoDictionary] objectForKey:STORAGE_KEY_REMOTEURL];
    NSString *appVersion = [[[NSBundle mainBundle] infoDictionary] objectForKey:@"CFBundleVersion"];
    debugLog(@"%@",appVersion);
    for(NSString* url in urls){
        [Remote serverVersion:url callback:^(StorageCallbackData *callback_data) {
            if(callback_data.code==0){
                NSString* serverVersion=callback_data.data;
                if(([serverVersion compare:appVersion]==NSOrderedAscending) || ([serverVersion compare:appVersion]==NSOrderedSame)){
                    if(FastestRemoteUrl==nil){
                        FastestRemoteUrl=url;

                        //更新地区数据
                        [Remote updateAreaData:nil];
                        //更新字典数据
                        [Storage initDictData];
                        //更新用户信息
                        [Storage updateLoginInfo];
                    }
                }
            }
        }];
    }
}

#pragma mark 获取本地登录信息
static Person* global_loginfo;
+(Person*) getLoginInfo{
    if(global_loginfo==nil){
        NSData* data=[[NSUserDefaults standardUserDefaults] dataForKey:STORAGE_KEY_LOGININFO];
        if(data!=nil){
            global_loginfo=[NSKeyedUnarchiver unarchiveObjectWithData:data];
        }
    }
    return global_loginfo;
}
+(void) setLoginInfo:(Person*)obj{
    if(obj!=nil){
        NSData* data=[NSKeyedArchiver archivedDataWithRootObject:obj];
        [[NSUserDefaults standardUserDefaults]setObject:data forKey:STORAGE_KEY_LOGININFO];
    }else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:STORAGE_KEY_LOGININFO];
    }
    global_loginfo=obj;
}

#pragma mark 更新地区数据
+(NSArray<Area*>*) getAllArea{
    return [AreaManager getSubArea:nil];
}
+(void) setAllArea:(NSArray<Area*>*)allArea{
    [AreaManager clearArea];
    if(allArea!=nil){
        [AreaManager insertArea:allArea parent:nil];
    }
}
#pragma mark 地区数据版本
+(float) getAreaVersion{
    return [[NSUserDefaults standardUserDefaults] floatForKey:STORAGE_KEY_AREA_VERSION];
}
+(void) setAreaVersion:(float)areaVersion{
    [[NSUserDefaults standardUserDefaults] setFloat:areaVersion forKey:STORAGE_KEY_AREA_VERSION];
}


#pragma mark 获取用户头像
+(UIImage*) getUserImage{
    UIImage* ret=nil;
    Person* person=[Storage getLoginInfo];
    if(person!=nil){
        NSData* data=[[NSUserDefaults standardUserDefaults] objectForKey:STORAGE_KEY_USERIMAGE];
        if([data isKindOfClass:[NSData class]]){
            @try{
                ret=[UIImage imageWithData:data];
            }@catch(NSException* e){}
        }
        if(ret==nil){
            if([person isMale]){
                ret=[UIImage imageNamed:@"缺省头像"];
            }else{
                ret=[UIImage imageNamed:@"缺省头像"];
            }
        }
    }
    return ret;
}
+(void) setUserImage:(UIImage*)image{
    if(image==nil){
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:STORAGE_KEY_USERIMAGE];
    }else{
        NSData* data=UIImageJPEGRepresentation(image, 1.0);
        [[NSUserDefaults standardUserDefaults] setObject:data forKey:STORAGE_KEY_USERIMAGE];
    }
}

#pragma mark 获取用户二维码
+(UIImage*) getQRCodeImage{
    return nil;
}

#pragma mark 保存通过手机验证码验证的手机号
+(void) setPhone:(NSString*)phone{
    [[NSUserDefaults standardUserDefaults]setObject:phone forKey:STORAGE_KEY_PHONE];
}
+(NSString*) getPhone{
    return [[NSUserDefaults standardUserDefaults] stringForKey:STORAGE_KEY_PHONE];
}

#pragma mark 获取融云UserToken
+(NSString*) getRCUserToken{
    return [[NSUserDefaults standardUserDefaults] stringForKey:STORAGE_KEY_RCUSERTOKEN];
}
+(void) setRCUserToken:(NSString*)obj{
    [[NSUserDefaults standardUserDefaults]setObject:obj forKey:STORAGE_KEY_RCUSERTOKEN];
}

#pragma mark 服务器access_token
+(NSString*) getAccessToken{
    return [[NSUserDefaults standardUserDefaults] stringForKey:STORAGE_KEY_ACCESSTOKEN];
}
+(void) setAccessToken:(NSString*)obj{
    [[NSUserDefaults standardUserDefaults]setObject:obj forKey:STORAGE_KEY_ACCESSTOKEN];
}
+(NSDate*) getAccessTokenExpireTime{
    return [[NSUserDefaults standardUserDefaults] objectForKey:STORAGE_KEY_ACCESSTOKEN_EXPIRETIME];
}
+(void) setAccessTokenExpireTime:(NSDate*)obj{
    [[NSUserDefaults standardUserDefaults]setObject:obj forKey:STORAGE_KEY_ACCESSTOKEN_EXPIRETIME];
}


#pragma mark 保存教练身份
+(Teacher*) getTeacher{
    Teacher* ret=nil;
    NSData* data=[[NSUserDefaults standardUserDefaults] dataForKey:STORAGE_KEY_TEACHER];
    if(data!=nil){
        ret=[NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return ret;
}
+(void) setTeacher:(Teacher*)obj{
    if(obj!=nil){
        [Storage setStudent:nil];
        [Storage setCustomerService:nil];
        [Storage setOperation:nil];
        NSData* data=[NSKeyedArchiver archivedDataWithRootObject:obj];
        [[NSUserDefaults standardUserDefaults]setObject:data forKey:STORAGE_KEY_TEACHER];
        @try{
            [Remote setAvailableCharacter:[Storage getLoginInfo].id character:obj callback:nil];
        }@catch(NSException* exception){
            debugLog(@"%@",exception.description);
        }
        
    }else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:STORAGE_KEY_TEACHER];
    }
}

#pragma mark 保存学员身份
+(Student*) getStudent{
    Student* ret=nil;
    NSData* data=[[NSUserDefaults standardUserDefaults] dataForKey:STORAGE_KEY_STUDENT];
    if(data!=nil){
        ret=[NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return ret;
}

+(void) setStudent:(Student*)obj{
    if(obj!=nil){
        [Storage setTeacher:nil];
        [Storage setCustomerService:nil];
        [Storage setOperation:nil];
        NSData* data=[NSKeyedArchiver archivedDataWithRootObject:obj];
        [[NSUserDefaults standardUserDefaults]setObject:data forKey:STORAGE_KEY_STUDENT];
        @try{
            [Remote setAvailableCharacter:[Storage getLoginInfo].id character:obj callback:nil];
        }@catch(NSException* exception){
            debugLog(@"%@",exception.description);
        }
    }else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:STORAGE_KEY_STUDENT];
    }
}

#pragma mark 保存客服身份
+(CustomerService*) getCustomerService{
    CustomerService* ret=nil;
    NSData* data=[[NSUserDefaults standardUserDefaults] dataForKey:STORAGE_KEY_CUSTOMERSERVICE];
    if(data!=nil){
        ret=[NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return ret;
}
+(void) setCustomerService:(CustomerService*)obj{
    if(obj!=nil){
        [Storage setStudent:nil];
        [Storage setTeacher:nil];
        [Storage setOperation:nil];
        NSData* data=[NSKeyedArchiver archivedDataWithRootObject:obj];
        [[NSUserDefaults standardUserDefaults]setObject:data forKey:STORAGE_KEY_CUSTOMERSERVICE];
        @try{
            [Remote setAvailableCharacter:[Storage getLoginInfo].id character:obj callback:nil];
        }@catch(NSException* exception){
            debugLog(@"%@",exception.description);
        }
        
    }else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:STORAGE_KEY_CUSTOMERSERVICE];
    }
}

#pragma mark 保存运营身份
+(Operation*) getOperation{
    Operation* ret=nil;
    NSData* data=[[NSUserDefaults standardUserDefaults] dataForKey:STORAGE_KEY_OPERATION];
    if(data!=nil){
        ret=[NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return ret;
}
+(void) setOperation:(Operation*)obj{
    if(obj!=nil){
        [Storage setStudent:nil];
        [Storage setTeacher:nil];
        [Storage setCustomerService:nil];
        NSData* data=[NSKeyedArchiver archivedDataWithRootObject:obj];
        [[NSUserDefaults standardUserDefaults]setObject:data forKey:STORAGE_KEY_OPERATION];
        @try{
            [Remote setAvailableCharacter:[Storage getLoginInfo].id character:obj callback:nil];
        }@catch(NSException* exception){
            debugLog(@"%@",exception.description);
        }
        
    }else{
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:STORAGE_KEY_OPERATION];
    }
}


#pragma mark 更新当期用户信息并保存到本地
+(void)updateLoginInfo{
    if([Storage getLoginInfo]!=nil){
        [Remote getPersonWithId:[Storage getLoginInfo].id callback:^(StorageCallbackData *callback_data) {
            if(callback_data.code==0){
                Person* person=callback_data.data;
                [Remote headImageWithURL:person.imageurl callback:^(StorageCallbackData *callback_data) {
                    if(callback_data.code==0){
                        UIImage* headImage=(UIImage*)callback_data.data;
                        [Storage setLoginInfo:person];
                        [Storage setUserImage:headImage];
                        [Storage updateCharacter];
                    }
                }];
            }
        }];
    }
}


#pragma mark 获取当前有效身份并保存到本地
+(void)updateCharacter{
    if([Storage getLoginInfo]!=nil){
        [Remote availableCharacter:[Storage getLoginInfo].id callback:^(StorageCallbackData *callback_data) {
            if(callback_data.code==0){
                NSDictionary* result=callback_data.data;
                if([@"" isEqualToString:result[@"character_type"]]){
                    [Storage setStudent:nil];
                    [Storage setTeacher:nil];
                    [Storage setCustomerService:nil];
                    [Storage setOperation:nil];
                }else if([@"teacher" isEqualToString:result[@"character_type"]]){
                    [Storage setTeacher:result[@"obj"]];
                }else if([@"student" isEqualToString:result[@"character_type"]]){
                    [Storage setStudent:result[@"obj"]];
                }else if([@"customerservice" isEqualToString:result[@"character_type"]]){
                    [Storage setCustomerService:result[@"obj"]];
                }else if([@"operation" isEqualToString:result[@"character_type"]]){
                    [Storage setOperation:result[@"obj"]];
                }
            }
        }];
    }
}


#pragma mark 获取系统配置的字符串
static NSDictionary* appText;
+(nullable NSString*)getAppTextWithKey:(nonnull NSString*)key{
    if(appText==nil){
        appText=[Utility loadPlistAsDictionary:@"a"];
    }
    if(appText!=nil){
        return (NSString*)appText[key];
    }else{
        return nil;
    }
}


#pragma mark 取得教学科目字典数据
+(NSArray<Dict*>*)teacherSkillDict{
    NSArray<Dict*>* ret=[Utility initArray:nil];
    NSData* data=[[NSUserDefaults standardUserDefaults] dataForKey:STORAGE_KEY_TEACHERSKILLDICT];
    if(data!=nil){
        ret=[NSKeyedUnarchiver unarchiveObjectWithData:data];
    }
    return ret;
}
#pragma mark 初始化字典数据
+(void)initDictData{
    [Remote dictWithName:@"teacher_skill" callback:^(StorageCallbackData *callback_data) {
        if(callback_data.code==0){
            NSData* data=[NSKeyedArchiver archivedDataWithRootObject:callback_data.data];
            [[NSUserDefaults standardUserDefaults] setObject:data forKey:STORAGE_KEY_TEACHERSKILLDICT];
        }else{
            [Utility showError:callback_data.message type:ErrorType_Network];
        }
    }];
}
@end
