//
//  RCIMUserInfoDataSource.h
//  myim
//
//  Created by Sean Shi on 15/10/22.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface RCIMDelegate : NSObject<RCIMUserInfoDataSource,RCIMGroupInfoDataSource,RCIMReceiveMessageDelegate>
+(nonnull instancetype)sharedDelegate;

+(nonnull RCGroup*)genRCGroupWithChatGroup:(nonnull ChatGroup*)group;
+(nonnull RCUserInfo*)genRCUserWithPerson:(nonnull Person*)person;
+(void)refreshGroupInCache:(nonnull ChatGroup*)group;
+(void)refreshPersonInCache:(nonnull Person*)person;

@end
