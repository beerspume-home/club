//
//  RCIMUserInfoDataSource.m
//  myim
//
//  Created by Sean Shi on 15/10/22.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "RCIMDelegate.h"
#import "Cache.h"

static RCIMDelegate* RCIMDelegate_sharedInstance;

@implementation RCIMDelegate
+(nonnull instancetype)sharedDelegate{
    if(RCIMDelegate_sharedInstance==nil){
        RCIMDelegate_sharedInstance=[[RCIMDelegate alloc]init];
    }
    return RCIMDelegate_sharedInstance;
}

/**
 *  获取用户信息。
 *  @param userId     用户 Id。
 *  @param completion 用户信息
 */
- (void)getUserInfoWithUserId:(NSString *)userId
                   completion:(void (^)(RCUserInfo *userInfo))completion{
    Person* person=[Cache getPerson:userId];
    if(person!=nil){
        RCUserInfo* userInfo=[[RCUserInfo alloc]initWithUserId:userId
                                                          name:person.socialname
                                                      portrait:person.imageurl
                              ];
        completion(userInfo);
    }
}


/**
 *  获取群组信息。
 *  @param groupId  群组ID.
 *  @param completion 获取完成调用的BLOCK.
 */

- (void)getGroupInfoWithGroupId:(NSString *)groupId
                     completion:(void (^)(RCGroup *groupInfo))completion{
    
    ChatGroup* obj=[Cache getChatGroup:groupId];
    if(obj!=nil){
        RCGroup* info=[[RCGroup alloc]initWithGroupId:groupId
                                            groupName:obj.name
                                          portraitUri:obj.imageurl
                              ];
        completion(info);
    }
}



/**
 接收消息到消息后执行。
 
 @param message 接收到的消息。
 @param left    剩余消息数.
 */
- (void)onRCIMReceiveMessage:(RCMessage *)message left:(int)left{
}


///**
// *  收到消息Notifiction处理。用户可以自定义通知，不实现SDK会处理。
// *
// *  @param message    收到的消息实体。
// *  @param senderName 发送者的名字
// *
// *  @return 返回NO，SDK处理通知；返回YES，App自定义通知栏，SDK不再展现通知。
// */
//-(BOOL)onRCIMCustomLocalNotification:(RCMessage*)message withSenderName:(NSString *)senderName;
//
///**
// *  收到消息铃声处理。用户可以自定义新消息铃声，不实现SDK会处理。
// *
// *  @param message 收到的消息实体。
// *
// *  @return 返回NO，SDK处理铃声；返回YES，App自定义通知音，SDK不再播放铃音。
// */
//-(BOOL)onRCIMCustomAlertSound:(RCMessage*)message;

+(nonnull RCGroup*)genRCGroupWithChatGroup:(nonnull ChatGroup*)group{
    RCGroup* ret=[[RCGroup alloc]init];
    ret.groupId=group.id;
    ret.groupName=group.name;
    ret.portraitUri=group.imageurl;
    return ret;
}
+(nonnull RCUserInfo*)genRCUserWithPerson:(nonnull Person*)person{
    RCUserInfo* ret=[[RCUserInfo alloc]init];
    ret.userId =person.id;
    ret.name=person.socialname;
    ret.portraitUri=person.imageurl;
    return ret;
}
+(void)refreshGroupInCache:(nonnull ChatGroup*)group{
    [[RCIM sharedRCIM]refreshGroupInfoCache:[RCIMDelegate genRCGroupWithChatGroup:group] withGroupId:group.id];
}

+(void)refreshPersonInCache:(nonnull Person*)person{
    [[RCIM sharedRCIM]refreshUserInfoCache:[RCIMDelegate genRCUserWithPerson:person] withUserId:person.id];
}
@end
