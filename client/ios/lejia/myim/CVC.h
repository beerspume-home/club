//
//  CVC.h
//  myim
//
//  Created by Sean Shi on 15/10/14.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <RongIMKit/RongIMKit.h>
#import "AController+IM.h"

@interface CVC : AController

@property(nonatomic,assign) RCConversationType conversationType;
@property(nonatomic,retain) NSString* targetId;
@property(nonatomic,retain) NSString* ctitle;

-(instancetype) initWithConversationType:(RCConversationType)conversationType targetId:(NSString*)targetId title:(NSString*)title;

@end
