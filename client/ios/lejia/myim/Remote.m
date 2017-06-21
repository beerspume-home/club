//
//  Remote.m
//  myim
//
//  Created by Sean Shi on 15/10/17.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Remote.h"
#import "AreaManager.h"
#import "TempStorage.h"

@implementation Remote


#pragma mark 获取有效的Rremote Url
+(void) serverVersion:(NSString*)url callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        StorageCallbackData* callback_data=nil;
        if(url!=nil){
            NSMutableDictionary* param=[NSMutableDictionary dictionaryWithDictionary:
                                        @{@"deviceid":[Storage getDeviceid],
                                          }];
            NSString* urlString=[url stringByAppendingPathComponent:@"app/version"];
            callback_data=[Network requestUrlAsJson:urlString parameters:param];
        }else{
            callback_data=[[StorageCallbackData alloc]init];
            callback_data.code=99;
            callback_data.message=@"nil url";
        }
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
        
    });
}

#pragma mark 记录日志
+(void) log:(NSString*)name ext:(NSArray<NSString*>*)ext callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        NSString* operatorid=[Storage getLoginInfo].id;
        StorageCallbackData* callback_data=nil;
        NSMutableDictionary* param=[NSMutableDictionary dictionaryWithDictionary:
  @{@"deviceid":[Storage getDeviceid],
    @"operatorid":operatorid==nil?@"":operatorid,
    @"name":name==nil?@"":name,
    }];
        if(ext!=nil){
            for(int i=0;i<ext.count;i++){
                if(i<9){
                    [param setObject:ext[i] forKey:[NSString stringWithFormat:@"ext%d",(i+1)]];
                }
            }
        }
        NSString* urlString=[Network getUrlWithCommand:@"app/log/"];
        callback_data=[Network requestUrlAsJson:urlString parameters:param];
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
        
    });
}


#pragma mark 登录
+(void) loginWithUsername:(NSString*)username password:(NSString*)password callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"username":username,
                              @"password":password,
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/userLogin/"];
        StorageCallbackData* callback_data=[Network requestUrlAsJson:urlString parameters:param];
        if(callback_data.code==0){
            NSMutableDictionary* data=(NSMutableDictionary*)callback_data.data;
            Person* person=[Person initWithDictionary:data[@"person"]];
            NSString* rc_user_token=data[@"rc_user_token"];
            [Storage setRCUserToken:rc_user_token];

            NSDictionary* accessTokenObj=data[@"access_token"];
            if(accessTokenObj!=nil){
                NSString* accesstoken=accessTokenObj[@"accesstoken"];
                NSNumber* expire_in=accessTokenObj[@"expire_in"];
                [Storage setAccessToken:accesstoken];
                if(accesstoken!=nil){
                    int int_expire_in=7200;
                    if([expire_in isKindOfClass:[NSNumber class]]){
                        int_expire_in=expire_in.intValue;
                    }
                }
            }
            callback_data.data=person;

        }
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
    });
}

#pragma mark 取得用户头像
+(void) headImageWithPerson:(NSString*)personid callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"personid":personid,
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/headImage/"];
        NSData* data=[Network requestUrlAsData:urlString parameters:param];
        UIImage* headImage=nil;
        @try {
            if(data!=nil){
                headImage=[UIImage imageWithData:data];
            }
        }
        @catch (NSException *exception) {
            debugLog(@"%@",exception.reason);
        }
        if(headImage==nil){
            headImage=[UIImage imageNamed:@"缺省头像"];
        }
        StorageCallbackData* callback_data=[[StorageCallbackData alloc]init];
        callback_data.code=0;
        callback_data.data=headImage;
        
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
    });
}

#pragma mark 取得用户头像(url)
+(void) headImageWithURL:(NSString*)url callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        NSData* data=[Network requestUrlAsData:url];
        UIImage* headImage=nil;
        @try {
            if(data!=nil){
                headImage=[UIImage imageWithData:data];
            }
        }
        @catch (NSException *exception) {
            debugLog(@"%@",exception.reason);
        }
        if(headImage==nil){
            headImage=[UIImage imageNamed:@"缺省头像"];
        }
        StorageCallbackData* callback_data=[[StorageCallbackData alloc]init];
        callback_data.code=0;
        callback_data.data=headImage;
        
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
    });
}

#pragma mark 发送手机验证码
+(void) sendSMSCodeWithPhone:(NSString*)phone callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"phone":phone,
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/sendSMSCode/"];
        StorageCallbackData* callback_data=[Network requestUrlAsJson:urlString parameters:param];
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
    });
}

#pragma mark 注册
+(void) regWithPhone:(NSString*)phone smscode:(NSString*)smscode password:(NSString*)password callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"phone":phone,
                              @"smscode":smscode,
                              @"password":password,
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/userReg/"];
        StorageCallbackData* callback_data=[Network requestUrlAsJson:urlString parameters:param];
        if(callback_data.code==0){
            NSMutableDictionary* data=(NSMutableDictionary*)callback_data.data;
            Person* person=[Person initWithDictionary:data[@"person"]];
            NSString* rc_user_token=data[@"rc_user_token"];
            [Storage setRCUserToken:rc_user_token];
            callback_data.data=person;
        }
        
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
    });
}

#pragma mark 重设密码
+(void) resetPasswordWithPhone:(NSString*)phone smscode:(NSString*)smscode password:(NSString*)password callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"phone":phone,
                              @"smscode":smscode,
                              @"password":password,
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/resetPassword/"];
        StorageCallbackData* callback_data=[Network requestUrlAsJson:urlString parameters:param];
        if(callback_data.code==0){
            NSMutableDictionary* data=(NSMutableDictionary*)callback_data.data;
            callback_data.data=[Person initWithDictionary:data];
        }
        
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
    });
}

#pragma mark 修改用户信息
+(void) updatePerson:(Person*)person callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"personid":person.id,
                              @"username":person.username,
                              @"email":person.email,
                              @"name":person.name,
                              @"idcard":person.idcard,
                              @"gender":person.gender,
                              @"nickname":person.social.nickname,
                              @"introduction":person.social.introduction,
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/updatePerson/"];
        StorageCallbackData* callback_data=[Network requestUrlAsJson:urlString parameters:param];
        if(callback_data.code==0){
            NSMutableDictionary* data=(NSMutableDictionary*)callback_data.data;
            callback_data.data=[Person initWithDictionary:data];
        }
        
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
    });
}

#pragma mark 修改用户名
+(void) updatePersonUsername:(NSString*)username callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        Person* person=[Storage getLoginInfo];
        StorageCallbackData* callback_data=nil;
        if(person!=nil){
            NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                                  @"personid":person.id,
                                  @"username":username,
                                  };
            NSString* urlString=[Network getUrlWithCommand:@"app/updatePersonUsername/"];
            callback_data=[Network requestUrlAsJson:urlString parameters:param];
            if(callback_data.code==0){
                NSDictionary* data=(NSDictionary*)callback_data.data;
                Person* person=[Person initWithDictionary:data];
                callback_data.data=person;
            }
        }else{
            callback_data=[[StorageCallbackData alloc]init];
            callback_data.code=99;
            callback_data.message=@"需要登录";
        }
        
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
    });
}

#pragma mark 修改用户地区信息
+(void) updatePersonArea:(NSString*)areaid callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        Person* person=[Storage getLoginInfo];
        StorageCallbackData* callback_data=nil;
        if(person!=nil){
            NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                                  @"personid":person.id,
                                  @"areaid":areaid,
                                  };
            NSString* urlString=[Network getUrlWithCommand:@"app/updatePersonArea/"];
            callback_data=[Network requestUrlAsJson:urlString parameters:param];
            if(callback_data.code==0){
                NSDictionary* data=(NSDictionary*)callback_data.data;
                Person* person=[Person initWithDictionary:data];
                callback_data.data=person;
            }
        }else{
            callback_data=[[StorageCallbackData alloc]init];
            callback_data.code=99;
            callback_data.message=@"需要登录";
        }
        
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
    });
}
#pragma mark 获取通讯录
+(void) contactsWithCallbak:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        Person* person=[Storage getLoginInfo];
        StorageCallbackData* callback_data=nil;
        if(person!=nil){
            NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                                  @"personid":person.id,
                                  };
            NSString* urlString=[Network getUrlWithCommand:@"app/contacts/"];
            callback_data=[Network requestUrlAsJson:urlString parameters:param];
            if(callback_data.code==0){
                NSArray* data=(NSArray*)callback_data.data;
                NSMutableArray* contacts=[Utility initArray:nil];
                for(int i=0;i<data.count;i++){
                    Person* person=[Person initWithDictionary:data[i]];
                    [contacts addObject:person];
                }
                callback_data.data=contacts;
                [Cache resetContacts:contacts];
            }
        }else{
            callback_data=[[StorageCallbackData alloc]init];
            callback_data.code=99;
            callback_data.message=@"需要登录";
        }
        
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
    });
}

#pragma mark 更新用户头像
+(void) updateHeadImageWithImage:(UIImage*)image callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        Person* person=[Storage getLoginInfo];
        StorageCallbackData* callback_data=nil;
        if(person!=nil){
            NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                                  @"personid":person.id,
                                  @"headimage":UIImagePNGRepresentation(image),
                                  };
            NSString* urlString=[Network getUrlWithCommand:@"app/updateHeadImage/"];
            callback_data=[Network requestUrlAsJson:urlString parameters:param];
        }else{
            callback_data=[[StorageCallbackData alloc]init];
            callback_data.code=99;
            callback_data.message=@"需要登录";
        }
        
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
    });
}

#pragma mark 查找新好友
+(void) searchPersonWithUsername:(NSString*)username callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"username":username,
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/searchPerson/"];
        StorageCallbackData* callback_data=[Network requestUrlAsJson:urlString parameters:param];
        if(callback_data.code==0){
            NSDictionary* data=(NSDictionary*)callback_data.data;
            Person* person=[Person initWithDictionary:data];
            callback_data.data=person;
        }

        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
    });
}

#pragma mark 判断两人关系是否为好友
+(void) isFriendBetweenMe:(NSString*)myid andOther:(NSString*)otherid callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"myid":myid,
                              @"otherid":otherid,
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/isFriend/"];
        StorageCallbackData* callback_data=[Network requestUrlAsJson:urlString parameters:param];
        if(callback_data.code==0){
            NSDictionary* data=(NSDictionary*)callback_data.data;
            callback_data.data=data[@"isfriend"];
        }
        
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
    });
}

#pragma mark 添加到通讯录
+(void) addContacts:(NSString*)friendid callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        Person* person=[Storage getLoginInfo];
        StorageCallbackData* callback_data=nil;
        if(person!=nil){
            NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                                  @"personid":person.id,
                                  @"friendid":friendid,
                                  };
            NSString* urlString=[Network getUrlWithCommand:@"app/addContacts/"];
            callback_data=[Network requestUrlAsJson:urlString parameters:param];
        }else{
            callback_data=[[StorageCallbackData alloc]init];
            callback_data.code=99;
            callback_data.message=@"需要登录";
        }
        
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
    });
}

#pragma mark 获取指定用户信息
+(void) getPersonWithId:(NSString*)personid callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"id":personid,
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/person/"];
        StorageCallbackData* callback_data=[Network requestUrlAsJson:urlString parameters:param];
        if(callback_data.code==0){
            NSDictionary* data=callback_data.data;
            Person* person=[Person initWithDictionary:data];
            callback_data.data=person;
        }
        
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
    });
}

#pragma mark 发起群聊
+(void) createChatGroup:(NSString*)ownerid persons:(NSArray<NSString*>*)persons callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        StorageCallbackData* callback_data=nil;
        if(persons==nil || persons.count<2){
            callback_data=[[StorageCallbackData alloc]init];
            callback_data.code=10;
            callback_data.message=@"创建群聊，成员需达到3人以上";
        }else{
            NSString* str_persons=@"";
            for(int i=0;i<persons.count;i++){
                str_persons=[str_persons stringByAppendingFormat:(i==0?@"%@":@",%@"),persons[i]];
            }
            NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                                  @"ownerid":ownerid,
                                  @"persons":str_persons,
                                  };
            NSString* urlString=[Network getUrlWithCommand:@"app/createChatGroup/"];
            callback_data=[Network requestUrlAsJson:urlString parameters:param];
            if(callback_data.code==0){
                NSDictionary* data=callback_data.data;
                ChatGroup* chatGroup=[ChatGroup initWithDictionary:data];
                callback_data.data=chatGroup;
            }
        }
        
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
    });
}


#pragma mark 查找当前用户所属的群组
+(void) searchChatGroup:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        Person* person=[Storage getLoginInfo];
        StorageCallbackData* callback_data=nil;
        if(person!=nil){
            NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                                  @"personid":person.id,
                                  };
            NSString* urlString=[Network getUrlWithCommand:@"app/searchChatGroup/"];
            callback_data=[Network requestUrlAsJson:urlString parameters:param];
            if(callback_data.code==0){
                NSArray* data=callback_data.data;
                NSMutableArray* chatGroups=[Utility initArray:nil];
                for(int i=0;i<data.count;i++){
                    ChatGroup* chatGroup=[ChatGroup initWithDictionary:data[i]];
                    [chatGroups addObject:chatGroup];
                }
                callback_data.data=chatGroups;
            }
        }else{
            callback_data=[[StorageCallbackData alloc]init];
            callback_data.code=99;
            callback_data.message=@"需要用户登录";
        }
        
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
    });
}

#pragma mark 获取指定群
+(void) getChatGroupWithId:(NSString*)groupid callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        StorageCallbackData* callback_data=nil;
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"groupid":groupid,
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/chatGroup/"];
        callback_data=[Network requestUrlAsJson:urlString parameters:param];
        if(callback_data.code==0){
            NSDictionary* data=callback_data.data;
            ChatGroup* chatGroup=[ChatGroup initWithDictionary:data];
            callback_data.data=chatGroup;
        }
        
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
    });
}

#pragma mark 从群中删除成员
+(void) removeMember:(NSString*)personid fromChatGroup:(NSString*)groupid callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        StorageCallbackData* callback_data=nil;
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"personid":personid,
                              @"groupid":groupid,
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/removePersonFromChatGroup/"];
        callback_data=[Network requestUrlAsJson:urlString parameters:param];
        
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
    });
}

#pragma mark 添加成员到群组
+(void) addMembers:(NSArray<NSString*>*)persons toChatGroup:(NSString*)groupid callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        Person* person=[Storage getLoginInfo];
        NSString* str_persons=@"";
        for(int i=0;i<persons.count;i++){
            str_persons=[str_persons stringByAppendingFormat:(i==0?@"%@":@",%@"),persons[i]];
        }
        
        StorageCallbackData* callback_data=nil;
        if(person!=nil){
            NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                                  @"persons":str_persons,
                                  @"groupid":groupid,
                                  @"operatorid":person.id,
                                  };
            NSString* urlString=[Network getUrlWithCommand:@"app/addPersonToChatGroup/"];
            callback_data=[Network requestUrlAsJson:urlString parameters:param];
        }else{
            callback_data=[[StorageCallbackData alloc]init];
            callback_data.code=99;
            callback_data.message=@"需要登录";
        }
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
    });
}

#pragma mark 更新群组名称
+(void) updateGroup:(NSString*)groupid name:(NSString*)groupname callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        StorageCallbackData* callback_data=nil;
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"groupid":groupid,
                              @"groupname":groupname,
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/updateChatGroupName/"];
        callback_data=[Network requestUrlAsJson:urlString parameters:param];
        if(callback_data.code==0){
            NSDictionary* data=callback_data.data;
            ChatGroup* group=[ChatGroup initWithDictionary:data];
            callback_data.data=group;
        }
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
    });
}

#pragma mark 获取图片
+(void) imageWithUrl:(NSString*)urlString calback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        StorageCallbackData* callback_data=nil;
        NSData* data=[Network  requestUrlAsData:urlString];
        if(data!=nil){
            callback_data=[[StorageCallbackData alloc]init];
            callback_data.code=0;
            callback_data.message=@"";
            callback_data.data=[UIImage imageWithData:data];
        }
        
        if(callback_data==nil){
            callback_data=[[StorageCallbackData alloc]init];
            callback_data.code=99;
            callback_data.message=@"需要用户登录";
        }
        
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
    });
}

#pragma mark 更新地区数据
+(void) updateAreaData:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        StorageCallbackData* callback_data=nil;
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/areaVersion/"];
        callback_data=[Network requestUrlAsJson:urlString parameters:param];
        if(callback_data.code==0){
            NSNumber* areaVersion=callback_data.data;
            float currentAreaVersion=[Storage getAreaVersion];
            if(true || areaVersion.floatValue>currentAreaVersion){
                urlString=[Network getUrlWithCommand:@"app/area/"];
                callback_data=[Network requestUrlAsJson:urlString parameters:param];
                NSArray* data=callback_data.data;
                NSMutableArray* areas=[Utility initArray:nil];
                if(data!=nil){
                    for(int i=0;i<data.count;i++){
                        [areas addObject:[Area initWithDictionary:data[i]]];
                    }
                }
                callback_data.data=areas;
                [Storage setAllArea:areas];
                [Storage setAreaVersion:areaVersion.floatValue];
                
            }else{
                callback_data.data=nil;
            }
        }
        
        
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
    });
}


#pragma mark 查找驾校
+(void) searchSchool:(NSString*)searchkey fuzzy:(BOOL)fuzzy start:(NSInteger)start offset:(NSInteger)offset callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        StorageCallbackData* callback_data=nil;
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"searchkey":searchkey,
                              @"start":[Utility convertIntToString:start],
                              @"offset":[Utility convertIntToString:offset],
                              @"fuzzy":fuzzy?@"1":@"0",
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/searchSchool/"];
        callback_data=[Network requestUrlAsJson:urlString parameters:param];
        if(callback_data.code==0){
            NSArray* data=callback_data.data;
            NSMutableArray<School*>* schools=[Utility initArray:nil];
            for(int i=0;i<data.count;i++){
                School* school=[School initWithDictionary:data[i]];
                [schools addObject:school];
            }
            callback_data.data=schools;
        }
        
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
    });
}

#pragma mark 创建驾校
+(void) createSchool:(NSString*)schoolname areaid:(NSString*)areaid callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        StorageCallbackData* callback_data=nil;
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"schoolname":schoolname,
                              @"areaid":areaid,
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/createSchool/"];
        callback_data=[Network requestUrlAsJson:urlString parameters:param];
        if(callback_data.code==0){
            NSDictionary* data=callback_data.data;
            School* school=[School initWithDictionary:data];
            callback_data.data=school;
        }
        
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
    });
}

#pragma mark 字典数据
+(void) dictWithName:(NSString*)dictname callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        StorageCallbackData* callback_data=nil;
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"dictname":dictname,
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/dictdata/"];
        callback_data=[Network requestUrlAsJson:urlString parameters:param];
        if(callback_data.code==0){
            NSArray* data=callback_data.data;
            NSMutableArray<Dict*>* skills=[Utility initArray:nil];
            for(int i=0;i<data.count;i++){
                [skills addObject:[Dict initWithDictionary:data[i]]];
            }
            callback_data.data=skills;
        }
        
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
    });
}

#pragma mark 创建学员身份
+(void) createStudent:(NSString*)personid schoolid:(NSString*)schoolid status:(NSString*)status  signupdate:(NSString*)signupdate km1score:(NSString*)km1score km2score:(NSString*)km2score km3ascore:(NSString*)km3ascore km3bscore:(NSString*)km3bscore licencedate:(NSString*)licencedate callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        StorageCallbackData* callback_data=nil;
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"personid":personid,
                              @"schoolid":schoolid,
                              @"status":status,
                              @"signupdate":signupdate,
                              @"km1score":km1score,
                              @"km2score":km2score,
                              @"km3ascore":km3ascore,
                              @"km3bscore":km3bscore,
                              @"licencedate":licencedate,
                              @"available":@"1",
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/createStudent/"];
        callback_data=[Network requestUrlAsJson:urlString parameters:param];
        if(callback_data.code==0){
            NSDictionary* data=callback_data.data;
            Student* obj=[Student initWithDictionary:data];
            callback_data.data=obj;
        }
        
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
    });
}

/**删除学员身份*/
+(void)deleteStudent:(NSString *)studentid callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        StorageCallbackData* callback_data=nil;
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"studentid":studentid==nil?@"":studentid,
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/deleteStudent/"];
        callback_data=[Network requestUrlAsJson:urlString parameters:param];
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
    });
}


#pragma mark 取得学员身份
+(void) student:(NSString*)studentid callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        StorageCallbackData* callback_data=nil;
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"studentid":studentid==nil?@"":studentid,
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/student/"];
        callback_data=[Network requestUrlAsJson:urlString parameters:param];
        if(callback_data.code==0){
            callback_data.data=[Student initWithDictionary:callback_data.data];
        }
        
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
    });
}

#pragma mark 创建教练身份
+(void) createTeacher:(NSString*)personid schoolid:(NSString*)schoolid skills:(NSString*)skills callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        StorageCallbackData* callback_data=nil;
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"personid":personid,
                              @"schoolid":schoolid,
                              @"skills":skills,
                              @"available":@"1",
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/createTeacher/"];
        callback_data=[Network requestUrlAsJson:urlString parameters:param];
        if(callback_data.code==0){
            NSDictionary* data=callback_data.data;
            Teacher* teacher=[Teacher initWithDictionary:data];
            callback_data.data=teacher;
        }
        
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
    });
}

#pragma mark 取得教练对象
+(void) teacher:(NSString*)teacherid callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        StorageCallbackData* callback_data=nil;
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"teacherid":teacherid==nil?@"":teacherid,
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/teacher/"];
        callback_data=[Network requestUrlAsJson:urlString parameters:param];
        if(callback_data.code==0){
            NSDictionary* data=callback_data.data;
            Teacher* teacher=[Teacher initWithDictionary:data];
            callback_data.data=teacher;
        }
        
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
    });
}
/**删除教练身份*/
+(void)deleteTeacher:(NSString *)teacherid callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        StorageCallbackData* callback_data=nil;
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"teacherid":teacherid==nil?@"":teacherid,
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/deleteTeacher/"];
        callback_data=[Network requestUrlAsJson:urlString parameters:param];
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
    });
}
#pragma mark 我的所有教练身份
+(void) allTeacherCharacter:(NSString*)personid callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        StorageCallbackData* callback_data=nil;
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"personid":personid,
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/allTeacherCharacter/"];
        callback_data=[Network requestUrlAsJson:urlString parameters:param];
        if(callback_data.code==0){
            NSArray* data=callback_data.data;
            NSMutableArray<Teacher*>* teachers=[Utility initArray:nil];
            for(int i=0;i<data.count;i++){
                Teacher* teacher=[Teacher initWithDictionary:data[i]];
                [teachers addObject:teacher];
            }
            callback_data.data=teachers;
        }
        
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
    });
}
#pragma mark 创建客服身份
+(void) createCustomerService:(NSString*)personid schoolid:(NSString*)schoolid callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        StorageCallbackData* callback_data=nil;
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"personid":personid,
                              @"schoolid":schoolid,
                              @"available":@"1",
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/createCustomerService/"];
        callback_data=[Network requestUrlAsJson:urlString parameters:param];
        if(callback_data.code==0){
            NSDictionary* data=callback_data.data;
            CustomerService* obj=[CustomerService initWithDictionary:data];
            callback_data.data=obj;
        }
        
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
    });
}
/**删除客服身份*/
+(void)deleteCustomerService:(NSString *)CustomerServiceid callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        StorageCallbackData* callback_data=nil;
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"customerserviceid":CustomerServiceid==nil?@"":CustomerServiceid,
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/deleteCustomerService/"];
        callback_data=[Network requestUrlAsJson:urlString parameters:param];
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
    });
}
#pragma mark 我的所有客服身份
+(void) allCustomerCharacter:(NSString*)personid callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        StorageCallbackData* callback_data=nil;
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"personid":personid,
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/allCustomerServiceCharacter/"];
        callback_data=[Network requestUrlAsJson:urlString parameters:param];
        if(callback_data.code==0){
            NSArray* data=callback_data.data;
            NSMutableArray<CustomerService*>* objs=[Utility initArray:nil];
            for(int i=0;i<data.count;i++){
                CustomerService* obj=[CustomerService initWithDictionary:data[i]];
                [objs addObject:obj];
            }
            callback_data.data=objs;
        }
        
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
    });
}


#pragma mark 创建运营身份
+(void) createOperation:(NSString*)personid schoolid:(NSString*)schoolid callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        StorageCallbackData* callback_data=nil;
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"personid":personid,
                              @"schoolid":schoolid,
                              @"available":@"1",
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/createOperation/"];
        callback_data=[Network requestUrlAsJson:urlString parameters:param];
        if(callback_data.code==0){
            NSDictionary* data=callback_data.data;
            Operation* obj=[Operation initWithDictionary:data];
            callback_data.data=obj;
        }
        
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
    });
}
/**删除运营身份*/
+(void)deleteOperation:(NSString *)operationid callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        StorageCallbackData* callback_data=nil;
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"operationid":operationid==nil?@"":operationid,
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/deleteOperation/"];
        callback_data=[Network requestUrlAsJson:urlString parameters:param];
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
    });
}
#pragma mark 我的所有运营身份
+(void) allOperation:(NSString*)personid callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        StorageCallbackData* callback_data=nil;
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"personid":personid,
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/allOperationCharacter/"];
        callback_data=[Network requestUrlAsJson:urlString parameters:param];
        if(callback_data.code==0){
            NSArray* data=callback_data.data;
            NSMutableArray<Operation*>* objs=[Utility initArray:nil];
            for(int i=0;i<data.count;i++){
                Operation* obj=[Operation initWithDictionary:data[i]];
                [objs addObject:obj];
            }
            callback_data.data=objs;
        }
        
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
    });
}


#pragma mark 我的所有身份
+(void) allCharacter:(NSString*)personid callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        StorageCallbackData* callback_data=nil;
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"personid":personid,
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/allCharacter/"];
        callback_data=[Network requestUrlAsJson:urlString parameters:param];
        if(callback_data.code==0){
            NSArray* data=callback_data.data;
            NSMutableArray* objs=[Utility initArray:nil];
            for(int i=0;i<data.count;i++){
                NSDictionary* d=data[i];
                if([@"student" isEqualToString:d[@"character_type"]]){
                    [objs addObject:[Student initWithDictionary:d[@"obj"]]];
                }else if([@"teacher" isEqualToString:d[@"character_type"]]){
                    [objs addObject:[Teacher initWithDictionary:d[@"obj"]]];
                }else if([@"customerservice" isEqualToString:d[@"character_type"]]){
                    [objs addObject:[CustomerService initWithDictionary:d[@"obj"]]];
                }else if([@"operation" isEqualToString:d[@"character_type"]]){
                    [objs addObject:[Operation initWithDictionary:d[@"obj"]]];
                }
            }
            callback_data.data=objs;
        }
        
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
    });
}


#pragma mark 取得当前有效身份
+(void) availableCharacter:(NSString*)personid callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        StorageCallbackData* callback_data=nil;
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"personid":personid,
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/availableCharacter/"];
        callback_data=[Network requestUrlAsJson:urlString parameters:param];
        if(callback_data.code==0){
            NSDictionary* data=callback_data.data;
            NSString* characterType=data[@"character_type"];
            id obj=data[@"obj"];
            if([@"teacher" isEqualToString:characterType]){
                obj=[Teacher initWithDictionary:obj];
            }else if([@"student" isEqualToString:characterType]){
                obj=[Student initWithDictionary:obj];
            }else if([@"customerservice" isEqualToString:characterType]){
                obj=[CustomerService initWithDictionary:obj];
            }else if([@"operation" isEqualToString:characterType]){
                obj=[Operation initWithDictionary:obj];
            }
            
            callback_data.data=@{
                                 @"character_type":characterType,
                                 @"obj":obj,
                                 };
        }
        
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
    });
}

#pragma mark 设置当前有效身份
+(void) setAvailableCharacter:(NSString*)personid character:(BaseObject*)character callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        NSString* charactertype=nil;
        if([character isKindOfClass:[Student class]]){
            charactertype=@"student";
        }else if([character isKindOfClass:[Teacher class]]){
            charactertype=@"teacher";
        }else if([character isKindOfClass:[CustomerService class]]){
            charactertype=@"customerservice";
        }else if([character isKindOfClass:[Operation class]]){
            charactertype=@"operation";
        }
        
        
        StorageCallbackData* callback_data=nil;
        if(charactertype!=nil){
            NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                                  @"personid":personid,
                                  @"character_type":charactertype,
                                  @"characterid":character.id,
                                  };
            NSString* urlString=[Network getUrlWithCommand:@"app/setAvailableCharacter/"];
            callback_data=[Network requestUrlAsJson:urlString parameters:param];
        }else{
            callback_data=[[StorageCallbackData alloc]init];
            callback_data.code=99;
            callback_data.message=@"未知身份类型";
        }
        
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
    });
}


#pragma mark 关注驾校
+(void) interestSchool:(NSString*)schoolid callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        Person* person=[Storage getLoginInfo];
        StorageCallbackData* callback_data=nil;
        if(person!=nil){
            NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                                  @"personid":person.id,
                                  @"schoolid":schoolid,
                                  };
            NSString* urlString=[Network getUrlWithCommand:@"app/interestSchool/"];
            callback_data=[Network requestUrlAsJson:urlString parameters:param];
        }else{
            callback_data=[[StorageCallbackData alloc]init];
            callback_data.code=99;
            callback_data.message=@"需要登录";
        }
        
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });

    });
}


#pragma mark 取消关注驾校
+(void) uninterestSchool:(NSString*)schoolid callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        Person* person=[Storage getLoginInfo];
        StorageCallbackData* callback_data=nil;
        if(person!=nil){
            NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                                  @"personid":person.id,
                                  @"schoolid":schoolid,
                                  };
            NSString* urlString=[Network getUrlWithCommand:@"app/uninterestSchool/"];
            callback_data=[Network requestUrlAsJson:urlString parameters:param];
        }else{
            callback_data=[[StorageCallbackData alloc]init];
            callback_data.code=99;
            callback_data.message=@"需要登录";
        }
        
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
        
    });
}

#pragma mark 是否关注驾校
+(void) isInterestedSchool:(NSString*)schoolid callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        Person* person=[Storage getLoginInfo];
        StorageCallbackData* callback_data=nil;
        if(person!=nil){
            NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                                  @"personid":person.id,
                                  @"schoolid":schoolid,
                                  };
            NSString* urlString=[Network getUrlWithCommand:@"app/isInterestedSchool/"];
            callback_data=[Network requestUrlAsJson:urlString parameters:param];
            if(callback_data.code==0){
                NSString* ret=[NSString stringWithFormat:@"%@",callback_data.data];
                callback_data.data=ret;
            }
        }else{
            callback_data=[[StorageCallbackData alloc]init];
            callback_data.code=99;
            callback_data.message=@"需要登录";
        }
        
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
        
    });
}

#pragma mark 我关注的驾校
+(void) myInterestedSchool:(NSInteger)start offset:(NSInteger)offset callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        Person* person=[Storage getLoginInfo];
        StorageCallbackData* callback_data=nil;
        if(person!=nil){
            NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                                  @"personid":person.id,
                                  @"start":[Utility convertIntToString:start],
                                  @"offset":[Utility convertIntToString:offset],
                                  };
            NSString* urlString=[Network getUrlWithCommand:@"app/myInterestSchoolList/"];
            callback_data=[Network requestUrlAsJson:urlString parameters:param];
            if(callback_data.code==0){
                NSArray* data=callback_data.data;
                NSMutableArray<School*>* schools=[Utility initArray:nil];
                for(int i=0;i<data.count;i++){
                    School* school=[School initWithDictionary:data[i]];
                    [schools addObject:school];
                }
                callback_data.data=schools;
            }
        }else{
            callback_data=[[StorageCallbackData alloc]init];
            callback_data.code=99;
            callback_data.message=@"需要登录";
        }
        
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
        
    });
}

#pragma mark 取得驾校所有员工
+(void) allStaffOfSchool:(NSString*)schoolid charactertype:(NSString*)charactertype  callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        Person* person=[Storage getLoginInfo];
        StorageCallbackData* callback_data=nil;
        if(person!=nil){
            NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                                  @"schoolid":schoolid,
                                  @"character_type":charactertype==nil?@"":charactertype,
                                  };
            NSString* urlString=[Network getUrlWithCommand:@"app/schoolStaff/"];
            callback_data=[Network requestUrlAsJson:urlString parameters:param];
            if(callback_data.code==0){
                NSArray* data=callback_data.data;
                NSMutableArray<Person*>* persons=[Utility initArray:nil];
                for(int i=0;i<data.count;i++){
                    Person* person=[Person initWithDictionary:data[i]];
                    [persons addObject:person];
                }
                callback_data.data=persons;
            }
        }else{
            callback_data=[[StorageCallbackData alloc]init];
            callback_data.code=99;
            callback_data.message=@"需要登录";
        }
        
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
        
    });
}


#pragma mark 查询一组手机号是否存在
+(void) searchPhones:(nonnull NSArray<NSString*>*)phones callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        Person* person=[Storage getLoginInfo];
        StorageCallbackData* callback_data=nil;
        if(person!=nil){
            NSString* str_phones=@"";
            for(int i=0;i<phones.count;i++){
                str_phones=[str_phones stringByAppendingFormat:(i==0?@"%@":@",%@"),phones[i]];
            }
            NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                                  @"phones":str_phones,
                                  };
            NSString* urlString=[Network getUrlWithCommand:@"app/searchPhones/"];
            callback_data=[Network requestUrlAsJson:urlString parameters:param];
            if(callback_data.code==0){
                NSArray* data=callback_data.data;
                NSMutableArray<Person*>* persons=[Utility initArray:nil];
                for(int i=0;i<data.count;i++){
                    Person* person=[Person initWithDictionary:data[i]];
                    [persons addObject:person];
                }
                callback_data.data=persons;
            }
        }else{
            callback_data=[[StorageCallbackData alloc]init];
            callback_data.code=99;
            callback_data.message=@"需要登录";
        }
        
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
        
    });
}

#pragma mark 驾校报名
+(void) schoolSignup:(NSString*)personid school:(NSString*)schoolid classid:(NSString*)classid name:(NSString*)name phone:(NSString*)phone gender:(NSString*)gender age:(NSString*)age address:(NSString*)address remark:(NSString*)remark callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"personid":personid,
                              @"schoolid":schoolid,
                              @"classid":classid,
                              @"name":name,
                              @"phone":phone,
                              @"gender":gender,
                              @"age":age,
                              @"address":address,
                              @"remark":remark,
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/schoolSignup/"];
        StorageCallbackData* callback_data=[Network requestUrlAsJson:urlString parameters:param];
        
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
        
    });
}


#pragma mark 驾校报名列表
+(void) schoolSignupList:(NSString*)schoolid showtreated:(BOOL)showtreated start:(NSInteger)start offset:(NSInteger)offset callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"schoolid":schoolid,
                              @"start":[Utility convertIntToString:start],
                              @"offset":[Utility convertIntToString:offset],
                              @"showtreated":showtreated?@"1":@"0",
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/schoolSignupList/"];
        StorageCallbackData* callback_data=[Network requestUrlAsJson:urlString parameters:param];
        if(callback_data.code==0){
            NSMutableArray<SchoolSignup*>* signups=[Utility initArray:nil];
            for(NSDictionary* d in callback_data.data){
                [signups addObject:[SchoolSignup initWithDictionary:d]];
            }
            callback_data.data=signups;
        }
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
        
    });
}


#pragma mark 更新报名状态
+(void) updateSchoolSignupStatus:(NSString*)schoolsignupid status:(NSString*)status callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"schoolsignupid":schoolsignupid==nil?@"":schoolsignupid,
                              @"status":status==nil?@"":status,
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/updateSchoolSignupStatus/"];
        StorageCallbackData* callback_data=[Network requestUrlAsJson:urlString parameters:param];
        if(callback_data.code==0){
            callback_data.data=[SchoolSignup initWithDictionary:callback_data.data];
        }
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
        
    });
}

#pragma mark 驾校运营提交认证申请报名
+(void) submitOperationCertificate:(NSDictionary<NSString*,id>*)data callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        NSString* operationid=data[@"operationid"];
        NSString* summary=@"[";
        summary=[summary stringByAppendingString:@"{\"name\":\"name\",\"desc\":\"真实姓名\"}"];
        summary=[summary stringByAppendingString:@",{\"name\":\"phone\",\"desc\":\"手机号码\"}"];
        summary=[summary stringByAppendingString:@",{\"name\":\"idcard\",\"desc\":\"身份证号码\"}"];
        summary=[summary stringByAppendingString:@",{\"name\":\"schoolName\",\"desc\":\"驾校名称\"}"];
        summary=[summary stringByAppendingString:@",{\"name\":\"companyCode\",\"desc\":\"组织机构代码\"}"];
        summary=[summary stringByAppendingString:@",{\"name\":\"licenceCode\",\"desc\":\"工商执照注册号\"}"];
        summary=[summary stringByAppendingString:@",{\"name\":\"representative\",\"desc\":\"法人代表-企业负责人姓名\"}"];
        summary=[summary stringByAppendingString:@",{\"name\":\"idcardFrontPicture\",\"desc\":\"身份证正面照片\",\"type\":\"pic\",\"format\":\"jpg\"}"];
        summary=[summary stringByAppendingString:@",{\"name\":\"idcardBackPicture\",\"desc\":\"身份证反面照片\",\"type\":\"pic\",\"format\":\"jpg\"}"];
        summary=[summary stringByAppendingString:@",{\"name\":\"companyPicture\",\"desc\":\"组织机构证照片\",\"type\":\"pic\",\"format\":\"jpg\"}"];
        summary=[summary stringByAppendingString:@",{\"name\":\"licencePicture\",\"desc\":\"工商执照照片\",\"type\":\"pic\",\"format\":\"jpg\"}"];
        summary=[summary stringByAppendingString:@"]"];
        
        
        
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"operationid":operationid,
                              @"summary":summary,
                              @"name":data[@"name"],
                              @"phone":data[@"phone"],
                              @"idcard":data[@"idcard"],
                              @"schoolName":data[@"schoolName"],
                              @"companyCode":data[@"companyCode"],
                              @"licenceCode":data[@"licenceCode"],
                              @"representative":data[@"representative"],
                              @"idcardFrontPicture":data[@"idcardFrontPicture"],
                              @"idcardBackPicture":data[@"idcardBackPicture"],
                              @"companyPicture":data[@"companyPicture"],
                              @"licencePicture":data[@"licencePicture"],
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/submitOperationCertificate/"];
        StorageCallbackData* callback_data=[Network requestUrlAsJson:urlString parameters:param];
        
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
        
    });
}


#pragma mark 获取运营提交的认证申请
+(void) operationCertificate:(NSString*)operationid callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"operationid":operationid,
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/operationCertificate/"];
        StorageCallbackData* callback_data=[Network requestUrlAsJson:urlString parameters:param];
        if(callback_data.code==0){
            NSArray* data=callback_data.data;
            NSMutableArray* items=[Utility initArray:nil];
            for(NSDictionary* dataitem in data){
                OperationCertificateItem* item=[OperationCertificateItem initWithDictionary:dataitem];
                [items addObject:item];
            }
            callback_data.data=items;
        }
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
        
    });
}


#pragma mark 撤销运营提交的认证申请
+(void) revokeOperationCertificate:(NSString*)operationid callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"operationid":operationid,
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/revokeOperationCertificate/"];
        StorageCallbackData* callback_data=[Network requestUrlAsJson:urlString parameters:param];
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
        
    });
}


#pragma mark 认证员工
+(void) certify:(BaseObject*)character certify:(BOOL)certify callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        NSString* operationid=[Storage getOperation].id;
        NSString* charactertype=nil;
        if([character isKindOfClass:[Student class]]){
            charactertype=@"student";
        }else if([character isKindOfClass:[Teacher class]]){
            charactertype=@"teacher";
        }else if([character isKindOfClass:[CustomerService class]]){
            charactertype=@"customerservice";
        }else if([character isKindOfClass:[Operation class]]){
            charactertype=@"operation";
        }
        NSString* characterid=character.id;
        StorageCallbackData* callback_data=nil;
        if(operationid!=nil){
            NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                                  @"operationid":operationid==nil?@"":operationid,
                                  @"character_type":charactertype==nil?@"":charactertype,
                                  @"characterid":characterid==nil?@"":characterid,
                                  @"certify":certify?@"1":@"0",
                                  };
            NSString* urlString=[Network getUrlWithCommand:@"app/certify/"];
            callback_data=[Network requestUrlAsJson:urlString parameters:param];
        }else{
            callback_data=[[StorageCallbackData alloc]init];
            callback_data.code=99;
            callback_data.message=@"需要登录";
        }
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
        
    });
}


#pragma mark 获得驾校信息
+(void) school:(NSString*)schoolid callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        StorageCallbackData* callback_data=nil;
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"schoolid":schoolid==nil?@"":schoolid,
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/school/"];
        callback_data=[Network requestUrlAsJson:urlString parameters:param];
        if(callback_data.code==0){
            School* school=[School initWithDictionary:callback_data.data];
            callback_data.data=school;
        }
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
        
    });
}

#pragma mark 更新驾校介绍
+(void) updateSchoolIntroduce:(NSString*)schoolid introduction:(NSString*)introduction callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        StorageCallbackData* callback_data=nil;
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"schoolid":schoolid==nil?@"":schoolid,
                              @"introduction":introduction==nil?@"":introduction,
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/updateSchoolIntroduction/"];
        callback_data=[Network requestUrlAsJson:urlString parameters:param];
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
        
    });
}

#pragma mark 更新驾校一景
+(void) updateSchoolPictures:(NSString*)schoolid pics:(NSArray<UIImage*>*)pics callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        StorageCallbackData* callback_data=nil;
        NSMutableDictionary* param=[NSMutableDictionary
                                    dictionaryWithDictionary:
  @{
    @"deviceid":[Storage getDeviceid],
    @"schoolid":schoolid==nil?@"":schoolid,
    }];
        for(int i=0;i<pics.count;i++){
            NSString* image_key=[NSString stringWithFormat:@"pic%d",i];
            NSString* format_key=[NSString stringWithFormat:@"pic%d_format",i];
            UIImage* image=pics[i];
            NSData* image_data=UIImageJPEGRepresentation(image, 1);
            [param setObject:image_data forKey:image_key];
            [param setObject:@"jpg" forKey:format_key];
        }
                                    
        NSString* urlString=[Network getUrlWithCommand:@"app/updateSchoolPictures/"];
        callback_data=[Network requestUrlAsJson:urlString parameters:param];
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
        
    });
}


#pragma mark 添加驾校班级
+(void) addSchoolClass:(NSString*)operationid name:(NSString*)name cartype:(NSString*)cartype licensetype:(NSString*)licensetype trainingtime:(NSString*)trainingtime fee:(NSString*)fee realfee:(NSString*)realfee expiredate:(NSString*)expiredate remark:(NSString*)remark callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        StorageCallbackData* callback_data=nil;
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"operationid":operationid==nil?@"":operationid,
                              @"name":name==nil?@"":name,
                              @"cartype":cartype==nil?@"":cartype,
                              @"licensetype":licensetype==nil?@"":licensetype,
                              @"trainingtime":trainingtime==nil?@"":trainingtime,
                              @"fee":fee==nil?@"":fee,
                              @"realfee":realfee==nil?@"":realfee,
                              @"expiredate":expiredate==nil?@"":expiredate,
                              @"remark":remark==nil?@"":remark,
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/addSchoolClass/"];
        callback_data=[Network requestUrlAsJson:urlString parameters:param];
        if(callback_data.code==0){
            callback_data.data=[SchoolClass initWithDictionary:callback_data.data];
        }
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
        
    });
}


#pragma mark 驾校所有的课程
+(void) allSchoolClass:(NSString*)schoolid callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        StorageCallbackData* callback_data=nil;
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"schoolid":schoolid==nil?@"":schoolid,
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/allSchoolClass/"];
        callback_data=[Network requestUrlAsJson:urlString parameters:param];
        if(callback_data.code==0){
            NSMutableArray<SchoolClass*>* data=[Utility initArray:nil];
            for(NSDictionary* d in callback_data.data){
                [data addObject:[SchoolClass initWithDictionary:d]];
            }
            callback_data.data=data;
        }
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
        
    });
}


#pragma mark 更改课程状态
+(void) changeStatusSchoolClass:(NSString*)operationid schoolclassid:(NSString*)schoolclassid status:(NSString*)status callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        StorageCallbackData* callback_data=nil;
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"operationid":operationid==nil?@"":operationid,
                              @"schoolclassid":schoolclassid==nil?@"":schoolclassid,
                              @"status":status==nil?@"":status,
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/changeStatusSchoolClass/"];
        callback_data=[Network requestUrlAsJson:urlString parameters:param];
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
        
    });
}


#pragma mark 搜索学员
+(void) searchSchoolStudent:(NSString*)schoolid searchkey:(NSString*)searchkey callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        StorageCallbackData* callback_data=nil;
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"schoolid":schoolid==nil?@"":schoolid,
                              @"searchkey":searchkey==nil?@"":searchkey,
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/searchSchoolStudent/"];
        callback_data=[Network requestUrlAsJson:urlString parameters:param];
        if(callback_data.code==0){
            NSMutableArray<Student*>* objs=[Utility initArray:nil];
            for(NSDictionary* d in callback_data.data){
                [objs addObject:[Student initWithDictionary:d]];
            }
            callback_data.data=objs;
        }
        
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
        
    });
}



#pragma mark 获取教练课程
+(void) teacherTimeTable:(NSString*)timetableid callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        
        StorageCallbackData* callback_data=nil;
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"timetableid":timetableid==nil?@"":timetableid,
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/teacherTimeTable/"];
        callback_data=[Network requestUrlAsJson:urlString parameters:param];
        if(callback_data.code==0){
            callback_data.data=[CourseTimeTable initWithDictionary:callback_data.data];
        }
        
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
        

        
    });
}


#pragma mark 添加(/更新)教练课程
+(void) updateTeacherCourse:(NSString*)teacherid timetableid:(NSString*)timetableid courseList:(NSArray<Course*>*)courseList callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        
        StorageCallbackData* callback_data=nil;
        NSMutableDictionary* param=[NSMutableDictionary dictionaryWithDictionary:@{@"deviceid":[Storage getDeviceid],
                              @"teacherid":teacherid==nil?@"":teacherid,
                              }];
        if(timetableid!=nil){
            [param setObject:timetableid forKey:@"timetableid"];
        }
        
        int index=0;
        for(int i=0;i<courseList.count;i++){
            if(courseList[i].changed){
                NSString* key_courseid=[NSString stringWithFormat:@"courseid_%d",index];
                NSString* key_deleted=[NSString stringWithFormat:@"deleted_%d",index];
                NSString* key_weekday=[NSString stringWithFormat:@"weekday_%d",index];
                NSString* key_starttime=[NSString stringWithFormat:@"starttime_%d",index];
                NSString* key_endtime=[NSString stringWithFormat:@"endtime_%d",index];
                NSString* key_course=[NSString stringWithFormat:@"course_%d",index];
                NSString* key_studentnum=[NSString stringWithFormat:@"studentnum_%d",index];
                NSString* key_remark=[NSString stringWithFormat:@"remark_%d",index];
                if(![Utility isEmptyString:courseList[i].id]){
                    [param setObject:courseList[i].id forKey:key_courseid];
                }
                if(courseList[i].deleted){
                    [param setObject:@"1" forKey:key_deleted];
                }
                if(![Utility isEmptyString:courseList[i].weekday]){
                    [param setObject:courseList[i].weekday forKey:key_weekday];
                }
                if(![Utility isEmptyString:courseList[i].starttime]){
                    [param setObject:courseList[i].starttime forKey:key_starttime];
                }
                if(![Utility isEmptyString:courseList[i].endtime]){
                    [param setObject:courseList[i].endtime forKey:key_endtime];
                }
                if(![Utility isEmptyString:courseList[i].course]){
                    [param setObject:courseList[i].course forKey:key_course];
                }
                if(![Utility isEmptyString:courseList[i].studentnum]){
                    [param setObject:courseList[i].studentnum forKey:key_studentnum];
                }
                if(![Utility isEmptyString:courseList[i].remark]){
                    [param setObject:courseList[i].remark forKey:key_remark];
                }
                index++;
            }
            
        }
        NSString* urlString=[Network getUrlWithCommand:@"app/updateTeacherCourse/"];
        callback_data=[Network requestUrlAsJson:urlString parameters:param];
        if(callback_data.code==0){
            callback_data.data=[CourseTimeTable initWithDictionary:callback_data.data];
            for(int i=0;i<courseList.count;i++){
                courseList[i].changed=false;
            }
        }
        
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
        
        
        
    });
}


#pragma mark 取得可预约教练
+(void) appointmentTeacherList:(NSString*)studentid callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        
        StorageCallbackData* callback_data=nil;
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"studentid":studentid==nil?@"":studentid,
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/appointmentTeacherList/"];
        callback_data=[Network requestUrlAsJson:urlString parameters:param];
        if(callback_data.code==0){
            NSArray<NSDictionary*>* data=callback_data.data;
            NSMutableArray<Teacher*>* teachers=[Utility initArray:nil];
            for(int i=0;i<data.count;i++){
                [teachers addObject:[Teacher initWithDictionary:data[i]]];
            }
            callback_data.data=teachers;
                                  
        }
        
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
        
        
        
    });
}


#pragma mark 获取教练所有课表
+(void) teacherAllTimeTable:(NSString*)teacherid callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        
        StorageCallbackData* callback_data=nil;
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"teacherid":teacherid==nil?@"":teacherid,
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/teacherAllTimeTable/"];
        callback_data=[Network requestUrlAsJson:urlString parameters:param];
        if(callback_data.code==0){
            NSArray<NSDictionary*>* data=callback_data.data;
            NSMutableArray<CourseTimeTable*>* calendars=[Utility initArray:nil];
            for(int i=0;i<data.count;i++){
                [calendars addObject:[CourseTimeTable initWithDictionary:data[i]]];
            }
            callback_data.data=calendars;
            
        }
        
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
    });
}


#pragma mark 取得教练的预约日历
+(void) appointmentCalendar:(NSString*)teacherid studentid:(NSString*)studentid callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        
        StorageCallbackData* callback_data=nil;
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"teacherid":teacherid==nil?@"":teacherid,
                              @"studentid":studentid==nil?@"":studentid,
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/appointmentCalendar/"];
        callback_data=[Network requestUrlAsJson:urlString parameters:param];
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
        
        
        
    });
}

#pragma mark 预约
+(void) createAppointment:(NSString*)studentid date:(NSString*)dateString courseid:(NSString*)courseid remark:(NSString*)remark callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        
        StorageCallbackData* callback_data=nil;
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"studentid":studentid==nil?@"":studentid,
                              @"date":dateString==nil?@"":dateString,
                              @"courseid":dateString==nil?@"":courseid,
                              @"remark":remark==nil?@"":remark,
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/createAppointment/"];
        callback_data=[Network requestUrlAsJson:urlString parameters:param];
        if(callback_data.code==0){
            callback_data.data=[CourseAppointment initWithDictionary:callback_data.data];
        }
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
        
        
        
    });
}

#pragma mark 取消预约
+(void) cancelAppointment:(NSString*)studentid date:(NSString*)dateString courseid:(NSString*)courseid callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        
        StorageCallbackData* callback_data=nil;
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"studentid":studentid==nil?@"":studentid,
                              @"date":dateString==nil?@"":dateString,
                              @"courseid":courseid==nil?@"":courseid,
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/cancelAppointment/"];
        callback_data=[Network requestUrlAsJson:urlString parameters:param];
        if(callback_data.code==0){
            callback_data.data=[CourseAppointment initWithDictionary:callback_data.data];
        }
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
        
        
        
    });
}

#pragma mark 设置预约为缺勤
+(void) absentAppointment:(NSString*)appointmentid callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        
        StorageCallbackData* callback_data=nil;
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"appointmentid":appointmentid==nil?@"":appointmentid,
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/absentAppointment/"];
        callback_data=[Network requestUrlAsJson:urlString parameters:param];
        if(callback_data.code==0){
            callback_data.data=[CourseAppointment initWithDictionary:callback_data.data];
        }
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
        
        
        
    });
}


#pragma mark 获取教练课程
+(void) teacherCourse:(NSString*)courseid callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        
        StorageCallbackData* callback_data=nil;
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"courseid":courseid==nil?@"":courseid,
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/teacherCourse/"];
        callback_data=[Network requestUrlAsJson:urlString parameters:param];
        if(callback_data.code==0){
            callback_data.data=[Course initWithDictionary:callback_data.data];
        }
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
        
        
        
    });
}



#pragma mark 学员-取得约车记录
+(void) studentAppointmentList:(NSString*)studentid showexpired:(BOOL)showexpired start:(NSInteger)start offset:(NSInteger)offset callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        
        StorageCallbackData* callback_data=nil;
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"studentid":studentid==nil?@"":studentid,
                              @"showexpired":showexpired?@"1":@"0",
                              @"start":[Utility convertIntToString:start],
                              @"offset":[Utility convertIntToString:offset],
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/studentAppointmentList/"];
        callback_data=[Network requestUrlAsJson:urlString parameters:param];
        if(callback_data.code==0){
            NSMutableArray<CourseAppointment*>* appointments=[Utility initArray:nil];
            NSArray<NSDictionary*>* data=callback_data.data;
            for(int i=0;i<data.count;i++){
                [appointments addObject:[CourseAppointment initWithDictionary:data[i]]];
            }
            callback_data.data=appointments;
        }
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
        
        
        
    });
}


#pragma mark 教练-取得约车记录
+(void) teacherAppointmentList:(NSString*)teacherid showexpired:(BOOL)showexpired start:(NSInteger)start offset:(NSInteger)offset callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        
        StorageCallbackData* callback_data=nil;
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"teacherid":teacherid==nil?@"":teacherid,
                              @"showexpired":showexpired?@"1":@"0",
                              @"start":[Utility convertIntToString:start],
                              @"offset":[Utility convertIntToString:offset],
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/teacherAppointmentList/"];
        callback_data=[Network requestUrlAsJson:urlString parameters:param];
        if(callback_data.code==0){
            NSMutableArray<CourseAppointment*>* appointments=[Utility initArray:nil];
            NSArray<NSDictionary*>* data=callback_data.data;
            for(int i=0;i<data.count;i++){
                [appointments addObject:[CourseAppointment initWithDictionary:data[i]]];
            }
            callback_data.data=appointments;
        }
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
        
        
        
    });
}

#pragma mark 教练-取得某日约车记录
+(void) teacherAppointmentListOfOneDay:(NSString*)teacherid date:(NSDate*)date start:(NSInteger)start offset:(NSInteger)offset callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        
        StorageCallbackData* callback_data=nil;
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"teacherid":teacherid==nil?@"":teacherid,
                              @"date":date==nil?@"":[Utility formatStringFromDate:date withFormat:nil],
                              @"start":[Utility convertIntToString:start],
                              @"offset":[Utility convertIntToString:offset],
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/teacherAppointmentListOfOneDay/"];
        callback_data=[Network requestUrlAsJson:urlString parameters:param];
        if(callback_data.code==0){
            NSMutableArray<CourseAppointment*>* appointments=[Utility initArray:nil];
            NSArray<NSDictionary*>* data=callback_data.data;
            for(int i=0;i<data.count;i++){
                [appointments addObject:[CourseAppointment initWithDictionary:data[i]]];
            }
            callback_data.data=appointments;
        }
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
        
        
        
    });
}



#pragma mark 取得一个约车记录
+(void) appointment:(NSString*)appointmentid callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        
        StorageCallbackData* callback_data=nil;
        NSDictionary* param=@{@"deviceid":[Storage getDeviceid],
                              @"appointmentid":appointmentid==nil?@"":appointmentid,
                              };
        NSString* urlString=[Network getUrlWithCommand:@"app/appointment/"];
        callback_data=[Network requestUrlAsJson:urlString parameters:param];
        if(callback_data.code==0){
            callback_data.data=[CourseAppointment initWithDictionary:callback_data.data];
        }
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
        
        
        
    });
}


#pragma mark 新建(更新)评价
+(void) updateAppointmentEvaluation:(nonnull CourseAppointmentEvaluation*)evaluation who:(nonnull NSString*)who callback:(void (^)(StorageCallbackData* callback_data))callback{
    runInBackground(^{
        
        StorageCallbackData* callback_data=nil;
        NSMutableDictionary* param=[NSMutableDictionary dictionaryWithDictionary:
  @{@"deviceid":[Storage getDeviceid],
    @"appointmentid":evaluation.appointment==nil?@"":evaluation.appointment,
    @"evaluation":evaluation.evaluation==nil?@"":evaluation.evaluation,
    @"who":who,
                              }];
        if(![Utility isEmptyString:evaluation.id]){
            [param setObject:evaluation.id forKey:@"evaluationid"];
        }
        if(evaluation.star1!=nil){
            [param setObject:evaluation.star1 forKey:@"star1"];
        }
        if(evaluation.star2!=nil){
            [param setObject:evaluation.star2 forKey:@"star2"];
        }
        if(evaluation.star3!=nil){
            [param setObject:evaluation.star3 forKey:@"star3"];
        }
        if(evaluation.star4!=nil){
            [param setObject:evaluation.star4 forKey:@"star4"];
        }
        if(evaluation.star5!=nil){
            [param setObject:evaluation.star5 forKey:@"star5"];
        }
        if(evaluation.star6!=nil){
            [param setObject:evaluation.star6 forKey:@"star6"];
        }
        if(evaluation.star7!=nil){
            [param setObject:evaluation.star7 forKey:@"star7"];
        }
        if(evaluation.star8!=nil){
            [param setObject:evaluation.star8 forKey:@"star8"];
        }
        if(evaluation.star9!=nil){
            [param setObject:evaluation.star9 forKey:@"star9"];
        }
        
        
        NSString* urlString=[Network getUrlWithCommand:@"app/updateAppointmentEvaluation/"];
        callback_data=[Network requestUrlAsJson:urlString parameters:param];
        if(callback_data.code==0){
            callback_data.data=[CourseAppointment initWithDictionary:callback_data.data];
        }
        runInMain(^{
            if(callback!=nil){
                callback(callback_data);
            }
        });
        
        
        
    });
}
@end
