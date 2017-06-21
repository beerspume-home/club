//
//  Storage.h
//  xcbteacher
//
//  Created by Sean Shi on 15/8/9.
//  Copyright (c) 2015年 车友会. All rights reserved.
//

#ifndef BaseLib_Storage_h
#define BaseLib_Storage_h

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>
#import "BaseModels.h"

#define BASE_STORAGE_DEVICE_TOKEN @"BASE_STORAGE_DEVICE_TOKEN"
#define BASE_STORAGE_GETUI_CLIENTID @"BASE_STORAGE_GETUI_CLIENTID"
#define BASE_URL_KEY @"BaseUrl"

@interface Storage : NSObject

+(NSString*)getDeviceid;
+(NSString*)getBaseUrl;
+(void)setDeviceToken:(NSString*)token;
+(NSString*)getDeviceToken;
+(void)setGeTuiClientId:(NSString*)clientId;
+(NSString*)getGeTuiClientId;
@end

@interface Network : NSObject
+(NSData*) requestUrlAsData:(NSString*)urlString;
+(NSString*) requestUrlAsText:(NSString*)urlString;
+(StorageCallbackData*) requestUrlAsJson:(NSString*)urlString;

+(NSData*) requestUrlAsData:(NSString*)urlString parameters:(NSDictionary*)data;
+(NSString*) requestUrlAsText:(NSString*)urlString parameters:(NSDictionary*)data;
+(StorageCallbackData*) requestUrlAsJson:(NSString*)urlString parameters:(NSDictionary*)data;
+(NSString*)getUrlWithCommand:(NSString*)command;
+(NSString*)getUrlWithParameters:(NSString*)command parameters:(NSString*)obj, ...NS_REQUIRES_NIL_TERMINATION;

+(void) registPushTokenForUser:(NSString*)userid url:(NSString*)url callback:(void (^)(StorageCallbackData* callback_data))callback;

+(void) addRequestPreHandler:(void (^)(NSMutableURLRequest* request))handler;
+(void) addRequestPostHandler:(void (^)(NSMutableURLRequest* request,NSHTTPURLResponse* response))handler;
+(void) processRequestPreHandler:(NSMutableURLRequest*) request;
+(void) processRequestPostHandler:(NSMutableURLRequest*) request response:(NSHTTPURLResponse*) response;

@end


#endif