//
//  Cache.h
//  myim
//
//  Created by Sean Shi on 15/10/21.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Cache : NSObject
+(void)putInCache:(NSArray<__kindof BaseObject*> *) objs;
+(Person*)getPerson:(NSString*)personid;
+(ChatGroup*)getChatGroup:(NSString*)id;

//缓存通讯录
+(void)resetContacts:(NSArray<Person*>*)persons;
+(void)addContacts:(NSArray<Person*>*)persons;
+(Person*)getPersonFromContacts:(NSString*)personid;
@end
