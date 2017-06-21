//
//  Models.h
//  xcbteacher
//
//  Created by Sean Shi on 15/8/15.
//  Copyright (c) 2015年 车友会. All rights reserved.
//
#ifndef BaseLib_Models_h
#define BaseLib_Models_h


#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface BaseObject : NSObject<NSCoding>
@property (nonatomic,retain)NSString* id;

+(instancetype) initWithDictionary:(NSDictionary*)data;
+(NSString*)genIdentifier:(Class)class id:(NSString*)objId;
-(NSDictionary*) convertToDictionary;
-(NSString*)getIdentifier;

@end

@interface StorageCallbackData : NSObject
@property (nonatomic) NSInteger code;
@property (nonatomic,retain) NSString* message;
@property (nonatomic,retain) id data;

-(StorageCallbackData*) mutableDeepCopy;
@end

#endif
