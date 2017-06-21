//
//  Models.m
//  xcbteacher
//
//  Created by Sean Shi on 15/8/15.
//  Copyright (c) 2015年 车友会. All rights reserved.
//

#import "BaseModels.h"
#import "Utility.h"
#import <objc/runtime.h>

@implementation BaseObject

-(id)valueForKey:(NSString *)key{
    return [super valueForKey:key];
}

-(NSString*)id{
    if(_id!=nil && ![_id isKindOfClass:[NSString class]]){
        _id=[Utility convertToString:_id];
    }
    return _id;
}

+(instancetype) initWithDictionary:(NSDictionary*)data{
    return autoFillObjFromDictionary([self alloc], data);
}
-(NSDictionary*) convertToDictionary{
    return convertObjToDictionary(self);
    
}

-(NSArray<NSDictionary<NSString*,NSString*>*>*)getAllProperties{
    NSMutableArray<NSDictionary<NSString*,NSString*>*>* ret=[Utility initArray:nil];
    u_int count;
    Class class=[self class];
    while([class isSubclassOfClass:[BaseObject class]]){
        objc_property_t *properties  =class_copyPropertyList(class, &count);
//        NSMutableArray *propertiesArray = [NSMutableArray arrayWithCapacity:count];
        for (int i = 0; i<count; i++)
        {
            const char* propertyName =property_getName(properties[i]);
            const char* propertyAttributes=property_getAttributes(properties[i]);
            
            NSString* attributes=[NSString stringWithCString:propertyAttributes encoding:NSASCIIStringEncoding];
            NSArray<NSString *>* attr=[attributes componentsSeparatedByString:@","];
            
            [ret addObject:@{
                            @"name":[NSString stringWithCString:propertyName encoding:NSASCIIStringEncoding],
                            @"returntype":attr[0],
                            @"readonly":[NSNumber numberWithBool:[@"R" isEqualToString:attr[1]]],
                                     }];
        }
        free(properties);
        class =class_getSuperclass(class);
    }
    return ret;
}

- (void)encodeWithCoder:(NSCoder *)aCoder{
    NSArray<NSDictionary<NSString*,NSString*>*>* ps=[self getAllProperties];
    
    for(NSDictionary<NSString*,NSString*>* p in ps){
        NSString* name=p[@"name"];
//        NSString* returntype=p[@"returntype"];
        BOOL readonly=p[@"readonly"].boolValue;
        if(!readonly){
            id value=[self valueForKey:name];
            [aCoder encodeObject:value forKey:name];
        }
    }
    
}
- (nullable instancetype)initWithCoder:(NSCoder *)aDecoder{
    NSArray<NSDictionary<NSString*,NSString*>*>* ps=[self getAllProperties];
    if (self = [super init])
    {
        if (aDecoder == nil)
        {
            return self;
        }
        for(NSDictionary<NSString*,NSString*>* p in ps){
            NSString* name=p[@"name"];
//            NSString* returntype=p[@"returntype"];
            BOOL readonly=p[@"readonly"].boolValue;
            if(!readonly){
                id value=[aDecoder decodeObjectForKey:name];
                [self setValue:value forKey:name];
            }
        }
    }
    return self;

}


-(BOOL)isEqual:(id)object{
    if([object isKindOfClass:[self class]]){
        return [self.id isEqualToString:((BaseObject*)object).id];
    }else{
        return false;
    }
}

-(NSString*)getIdentifier{
    return [BaseObject genIdentifier:[self class] id:self.id];
}
+(NSString*)genIdentifier:(Class)class id:(NSString*)objId{
    return [NSString stringWithFormat:@"%@-%@",NSStringFromClass(class),objId];
}
@end

@implementation StorageCallbackData
-(StorageCallbackData*) mutableDeepCopy{
    StorageCallbackData* ret=[StorageCallbackData alloc];
    ret.code=self.code;
    ret.message=[self.message copy];
    if([self.data respondsToSelector:@selector(mutableDeepCopy)]){
        ret.data=[self.data mutableDeepCopy];
    }else if([self.data respondsToSelector:@selector(mutableCopy)]){
        ret.data=[self.data mutableDeepCopy];
    }else if([self.data respondsToSelector:@selector(copy)]){
        ret.data=[self.data copy];
    }else{
        ret.data=self.data;
    }
    return ret;
}

@end
