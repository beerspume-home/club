//
//  AreaManager.h
//  myim
//
//  Created by Sean Shi on 15/10/29.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface AreaManager : NSObject

+(void)insertArea:(nonnull NSArray<Area*>*)areas  parent:(nullable Area*)parentArea;
+(void)clearArea;
+(nonnull NSArray<Area*>*)getSubArea:(nullable Area*)parentArea;
+(nonnull NSArray<Area*>*)getPathArea:(nonnull Area*)area;
@end
