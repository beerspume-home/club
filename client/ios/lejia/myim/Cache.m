//
//  Cache.m
//  myim
//
//  Created by Sean Shi on 15/10/21.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "Cache.h"
#import <FMDatabase.h>
#import <FMDatabaseQueue.h>

#define CACHE_DB_FILENAME @"cache_db"
#define CACHE_TABLENAME @"cache"

#define NAMESPACE_DEFAULT @"default"
#define NAMESPACE_CONTACTS @"contacts"

static FMDatabaseQueue* _cache_database_q;
static NSString* _cache_db_filename;
static BOOL _cache_inited;

@implementation Cache
+(void)initCacheDB{
    if(!_cache_inited){
        if(_cache_db_filename==nil){
            _cache_db_filename=[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:CACHE_DB_FILENAME];
        }
        _cache_database_q = [FMDatabaseQueue databaseQueueWithPath:_cache_db_filename];
        NSString* sql=[NSString stringWithFormat:@"create table if not exists %@ (id text , namespace text,data blob);",CACHE_TABLENAME];
        NSString* sqlindex=[NSString stringWithFormat:@"create index if not exists idx_1 on %@ (id , namespace);",CACHE_TABLENAME];
        [_cache_database_q inDatabase:^(FMDatabase *db) {
            if([db open]){
                [db executeUpdate:sql];
                [db executeUpdate:sqlindex];
            }
            [db close];
        }];
        _cache_inited=true;
    }
}

+(void)putInCache:(NSArray<__kindof BaseObject*> *) objs{
    [Cache putInCache:objs namespace:NAMESPACE_DEFAULT];
}
+(void)putInCache:(NSArray<__kindof BaseObject*> *) objs namespace:(NSString*)namespace{
    [Cache initCacheDB];
    for(BaseObject* obj in objs){
        NSString* objId=[obj getIdentifier];
        if(objId!=nil){
            NSData* data=[NSKeyedArchiver archivedDataWithRootObject:obj];
            NSString* sql1=[NSString stringWithFormat:@"select count(1) from %@ where id=? and namespace=?",CACHE_TABLENAME];
            NSString *sql2=[NSString stringWithFormat:@"update %@ set data=? where id=? and namespace=?",CACHE_TABLENAME];
            NSString *sql3=[NSString stringWithFormat:@"insert into %@ (id,namespace,data) values (?,?,?)",CACHE_TABLENAME];
            [_cache_database_q inDatabase:^(FMDatabase *db) {
                if([db open]){
                    FMResultSet* rs=[db executeQuery:sql1,objId,namespace];
                    BOOL found=false;
                    while([rs next]){
                        NSInteger count=[rs intForColumnIndex:0];
                        if(count>0){
                            found=true;
                            [db executeUpdate:sql2,data,objId,namespace];
                        }
                    }
                    if(!found){
                        [db executeUpdate:sql3,objId,namespace,data];
                    }
                }
                [db close];
            }];
        }
        if([obj isKindOfClass:[ChatGroup class]]){
            [RCIMDelegate refreshGroupInCache:(ChatGroup*)obj];
        }else if([obj isKindOfClass:[Person class]]){
            [RCIMDelegate refreshPersonInCache:(Person*)obj];
        }
    }
}
+(BaseObject*) get:(NSString*)objId{
    return [Cache get:objId namespace:NAMESPACE_DEFAULT];
}
+(BaseObject*) get:(NSString*)objId namespace:(NSString*)namespace{
    [Cache initCacheDB];
    __block BaseObject* ret=nil;
    NSString* sql1=[NSString stringWithFormat:@"select data from %@ where id=? and namespace=?",CACHE_TABLENAME];
    [_cache_database_q inDatabase:^(FMDatabase *db) {
        if([db open]){
            FMResultSet* rs=[db executeQuery:sql1,objId,namespace];
            while ([rs next]) {
                NSData* data=[rs dataForColumnIndex:0];
                if(data!=nil){
                    ret=[NSKeyedUnarchiver unarchiveObjectWithData:data];
                    break;
                }
            }
            [db close];
        }
    }];
    return ret;
}

+(Person*)getPerson:(NSString*)id{
    NSString* objId=[BaseObject genIdentifier:[Person class] id:id];
    Person* ret=(Person*)[Cache get:objId];
    if(ret==nil){
        //通过远程接口中的[Person initWithDictionary]取得用户并存入缓存
        [Remote getPersonWithId:id callback:nil];
    }
    return ret;
}

+(ChatGroup*)getChatGroup:(NSString*)id{
    NSString* objId=[BaseObject genIdentifier:[ChatGroup class] id:id];
    ChatGroup* ret=(ChatGroup*)[Cache get:objId];
    if(ret==nil){
        //通过远程接口中的[ChatGroup initWithDictionary]取得用户并存入缓存
        [Remote getChatGroupWithId:id callback:nil];
    }
    
    return ret;

}

+(void)resetContacts:(NSArray<Person*>*)persons{
    NSString* sql1=[NSString stringWithFormat:@"delete from %@ where namespace=?",CACHE_TABLENAME];
    [_cache_database_q inDatabase:^(FMDatabase *db) {
        if([db open]){
            [db executeUpdate:sql1,NAMESPACE_CONTACTS];
        }
        [db close];
    }];
    [Cache addContacts:persons];
}
+(void)addContacts:(NSArray<Person*>*)persons{
    [Cache putInCache:persons namespace:NAMESPACE_CONTACTS];
}
+(Person*)getPersonFromContacts:(NSString*)personid{
    NSString* objId=[BaseObject genIdentifier:[Person class] id:personid];
    return (Person*)[Cache get:objId namespace:NAMESPACE_CONTACTS];
}
@end
