//
//  AppDelegate.m
//  myim
//
//  Created by Sean Shi on 15/10/12.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "AppDelegate.h"
#import <RongIMKit/RongIMKit.h>
#import "ViewController.h"

#import "JEAppointmentMessage.h"

@interface AppDelegate()

@end

@implementation AppDelegate

- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions {
    [Network addRequestPreHandler:^(NSMutableURLRequest *request) {
        NSMutableArray<NSString*>* sign_array=[Utility initArray:nil];
        Person* person=[Storage getLoginInfo];
        NSString* access_token=[Storage getAccessToken];
        NSString* deviceid=[Storage getDeviceid];
        NSString* datetime=[NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970]];
        [request setValue:deviceid forHTTPHeaderField:@"deviceid"];
        if(person!=nil){
            [sign_array addObject:person.id];
            [sign_array addObject:deviceid];
            [sign_array addObject:datetime];
            [sign_array addObject:access_token==nil?@"":access_token];
            [sign_array sortUsingComparator:^NSComparisonResult(NSString*  _Nonnull obj1, NSString*  _Nonnull obj2) {
                return [obj1 compare:obj2];
            }];
            NSString* sign=[NSString stringWithFormat:@"%@%@%@%@",sign_array[0],sign_array[1],sign_array[2],sign_array[3]];
            sign=[Utility sha1:sign];
            [request setValue:person.id forHTTPHeaderField:@"personid"];
            [request setValue:datetime forHTTPHeaderField:@"datetime"];
            [request setValue:sign forHTTPHeaderField:@"sign"];
            
            debugLog(@"%@ %@ %@ %@",person.id,deviceid,datetime,sign);
        }
    }];

    [Storage checkFastestRemoteUrl];
    
    if(getSystemVersion()>=7){
        [[UIApplication sharedApplication] setStatusBarStyle:UIStatusBarStyleLightContent];
    }
    //初始化融云SDK
    [[RCIM sharedRCIM]initWithAppKey:@"p5tvi9dst1414"];
    [[RCIM sharedRCIM]registerMessageType:[JEAppointmentMessage class]];
    
    
    /**
     * 融云消息推送处理1
     */
    if ([application
         respondsToSelector:@selector(registerUserNotificationSettings:)]) {
        UIUserNotificationSettings *settings = [UIUserNotificationSettings
                                                settingsForTypes:(UIUserNotificationTypeBadge |
                                                                  UIUserNotificationTypeSound |
                                                                  UIUserNotificationTypeAlert)
                                                categories:nil];
        [application registerUserNotificationSettings:settings];
    } else {
//        UIRemoteNotificationType myTypes = UIRemoteNotificationTypeBadge |
//        UIRemoteNotificationTypeAlert |
//        UIRemoteNotificationTypeSound;
//        [application registerForRemoteNotificationTypes:myTypes];
//        
        
        [application registerUserNotificationSettings:[UIUserNotificationSettings
                                                                             settingsForTypes:(UIUserNotificationTypeSound | UIUserNotificationTypeAlert | UIUserNotificationTypeBadge)
                                                                             categories:nil]];
        
        
        [[UIApplication sharedApplication] registerForRemoteNotifications];

    }
    
//    // 快速集成第二步，连接融云服务器
//    [[RCIM sharedRCIM] connectWithToken:@"Z8e1gdVRmVfTxlCYb0fAs/iHND4+fMmMz/dFY8ga0Bd7GiQmE++ZWS67/dM2fdp6w7SUEGEhX5FhfzYILsZoXA==" success:^(NSString *userId) {
//        // Connect 成功
//        NSLog(@"Connect 成功,UserId:%@",userId);
//    }
//    error:^(RCConnectErrorCode status) {
//        // Connect 失败
//        NSLog(@"Connect 失败");
//    }
//    tokenIncorrect:^() {
//        // Token 失效的状态处理
//        NSLog(@"失效的状态处理");
//    }];
    
    
    self.window=[[UIWindow alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
    self.window.rootViewController=[[UINavigationController alloc] initWithRootViewController:[ViewController new]];
    
    [self.window makeKeyAndVisible];
    
    return YES;
}

/**
 * 融云消息推送处理2
 */
//注册用户通知设置
- (void)application:(UIApplication *)application
didRegisterUserNotificationSettings:
(UIUserNotificationSettings *)notificationSettings {
    // register to receive notifications
    [application registerForRemoteNotifications];
}

/**
 * 融云消息推送处理3
 */
- (void)application:(UIApplication *)application
didRegisterForRemoteNotificationsWithDeviceToken:(NSData *)deviceToken {
    NSString *token =
    [[[[deviceToken description] stringByReplacingOccurrencesOfString:@"<"
                                                           withString:@""]
      stringByReplacingOccurrencesOfString:@">"
      withString:@""]
     stringByReplacingOccurrencesOfString:@" "
     withString:@""];
    
    [[RCIMClient sharedRCIMClient] setDeviceToken:token];
}

- (void)applicationWillResignActive:(UIApplication *)application {
    // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
    // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
}

- (void)applicationDidEnterBackground:(UIApplication *)application {
    // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
    // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
}

- (void)applicationWillEnterForeground:(UIApplication *)application {
    // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
}

- (void)applicationDidBecomeActive:(UIApplication *)application {
    // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
}

- (void)applicationWillTerminate:(UIApplication *)application {
    // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
}

@end
