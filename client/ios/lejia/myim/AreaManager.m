//
//  AreaManager.m
//  myim
//
//  Created by Sean Shi on 15/10/29.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "AreaManager.h"
#import <FMDatabase.h>
#import <FMDatabaseQueue.h>

#define AREA_DB_FILENAME @"area_db"
#define AREA_TABLENAME @"area"


static FMDatabaseQueue* _area_database_q;
static NSString* _area_db_filename;
static BOOL _area_inited;

@implementation AreaManager

+(void)initDB{
    if(!_area_inited){
        if(_area_db_filename==nil){
            _area_db_filename=[[NSHomeDirectory() stringByAppendingPathComponent:@"Documents"] stringByAppendingPathComponent:AREA_DB_FILENAME];
            
            debugLog(@"%@",_area_db_filename);
        }
        _area_database_q = [FMDatabaseQueue databaseQueueWithPath:_area_db_filename];
        NSString* sql=[NSString stringWithFormat:@"create table if not exists %@ (id varchar(32) primary key,level integer ,parent varchar(32), name varchar(100),postcode varchar(10),namepath varchar(500));",AREA_TABLENAME];
        [_area_database_q inDatabase:^(FMDatabase *db) {
            if([db open]){
                [db executeUpdate:sql];
            }
            [db close];
        }];
        _area_inited=true;
    }
}

+(void)insertArea:(nonnull NSArray<Area*>*)areas parent:(nullable Area*)parentArea{
    [AreaManager initDB];
    
    NSString* sql1=[NSString stringWithFormat:@"insert into %@ (id,level,parent,name,postcode,namepath) values (?,?,?,?,?,?);",AREA_TABLENAME];
    for(int i=0;i<areas.count;i++){
        Area* area=areas[i];
        if(area.id!=nil && area.id.length>0){
            NSString* areaid=area.id;
            NSInteger level=area.level.integerValue;
            NSString* parent=area.parent==nil?@"":area.parent;
            NSString* name=area.name;
            NSString* postcode=area.postcode;
            NSString* namepath=area.namepath;
            [_area_database_q inDatabase:^(FMDatabase *db) {
                if([db open]){
                    [db executeUpdate:sql1,
                     areaid,
                     [NSNumber numberWithInteger:level],
                     parent,
                     name,
                     postcode,
                     namepath];
                    [db close];
                }
            }];
            
            [AreaManager insertArea:area.subarea parent:area];
        }
    }
}

+(void)clearArea{
    [AreaManager initDB];
    
    NSString* sql1=[NSString stringWithFormat:@"delete from %@;",AREA_TABLENAME];
    [_area_database_q inDatabase:^(FMDatabase *db) {
        if([db open]){
            [db executeUpdate:sql1];
            [db close];
        }
    }];

}

+(nonnull NSArray<Area*>*)getSubArea:(nullable Area*)parentArea{
    [AreaManager initDB];
    NSMutableArray<Area*>* ret=[Utility initArray:nil];
    NSString* sql1=[NSString stringWithFormat:@"select id,level,parent,name,postcode,namepath from %@ where level=? and parent=?;",AREA_TABLENAME];
    NSInteger level=1;
    NSString* parent=@"";
    if(parentArea!=nil){
        level=parentArea.level.integerValue+1;
        parent=parentArea.id;
    }

    [_area_database_q inDatabase:^(FMDatabase *db) {
        if([db open]){
            FMResultSet* rs=[db executeQuery:sql1,[NSNumber numberWithInteger:level],parent];
            while ([rs next]) {
                Area* area=[[Area alloc]init];
                area.id=[rs stringForColumn:@"id"];
                area.level=[rs stringForColumn:@"level"];
                area.parent=[rs stringForColumn:@"parent"];
                area.name=[rs stringForColumn:@"name"];
                area.postcode=[rs stringForColumn:@"postcode"];
                area.namepath=[rs stringForColumn:@"namepath"];
                [ret addObject:area];
            }
            [db close];
        }
    }];
    return ret;

}

+(Area*)getAreaWithId:(NSString*)areaid{
    NSString* sql1=[NSString stringWithFormat:@"select id,level,parent,name,postcode,namepath from %@ where id=?;",AREA_TABLENAME];
    __block Area* area=nil;
    [_area_database_q inDatabase:^(FMDatabase *db) {
        if([db open]){
            FMResultSet* rs=[db executeQuery:sql1,areaid];
            if([rs next]) {
                area=[[Area alloc]init];
                area.id=[rs stringForColumn:@"id"];
                area.level=[rs stringForColumn:@"level"];
                area.parent=[rs stringForColumn:@"parent"];
                area.name=[rs stringForColumn:@"name"];
                area.postcode=[rs stringForColumn:@"postcode"];
                area.namepath=[rs stringForColumn:@"namepath"];
            }
            [db close];
        }
    }];
    return area;
    
}

+(nonnull NSArray<Area*>*)getPathArea:(nonnull Area*)area{
    NSMutableArray<Area*>* ret=[Utility initArray:nil];
    [ret addObject:area];
    for(int i=0;i<10;i++){
        Area* parentArea=[AreaManager getAreaWithId:area.parent];
        if(parentArea!=nil){
            [ret insertObject:parentArea atIndex:0];
        }else{
            break;
        }
    }
    return ret;
}

@end
