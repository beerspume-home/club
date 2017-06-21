//
//  Storage.m
//  xcbteacher
//
//  Created by Sean Shi on 15/8/9.
//  Copyright (c) 2015年 车友会. All rights reserved.
//

#import "Storage.h"
#import "Utility.h"
#import "Debug.h"

@implementation Storage
+(NSString*)getDeviceid{
    NSString* ret=[[UIDevice currentDevice].identifierForVendor UUIDString];
    if(ret==nil){
        ret=@"";
    }
    return ret;
}

+(NSString*)getBaseUrl{
    NSString* ret=[[[NSBundle mainBundle] infoDictionary] objectForKey:BASE_URL_KEY];
    return ret;
}

+(void)setDeviceToken:(NSString*)token{
    if(token==nil){
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:BASE_STORAGE_DEVICE_TOKEN];
    }else{
        NSString* _deviceToken=[[token stringByTrimmingCharactersInSet:[NSCharacterSet characterSetWithCharactersInString:@"<>"]] stringByReplacingOccurrencesOfString:@" " withString:@""];
        
        [[NSUserDefaults standardUserDefaults]setObject:_deviceToken forKey:BASE_STORAGE_DEVICE_TOKEN];
    }
}
+(NSString*)getDeviceToken{
    return [[NSUserDefaults standardUserDefaults] objectForKey:BASE_STORAGE_DEVICE_TOKEN];
}

+(void)setGeTuiClientId:(NSString *)clientId{
    if(clientId==nil){
        [[NSUserDefaults standardUserDefaults] removeObjectForKey:BASE_STORAGE_GETUI_CLIENTID];
    }else{
        [[NSUserDefaults standardUserDefaults]setObject:clientId forKey:BASE_STORAGE_GETUI_CLIENTID];
    }
}
+(NSString*)getGeTuiClientId{
    return [[NSUserDefaults standardUserDefaults] objectForKey:BASE_STORAGE_GETUI_CLIENTID];
}

@end

@implementation Network
+(NSString*)getUrlWithCommand:(NSString*)command{
    NSString* urlString=[[Storage getBaseUrl] stringByAppendingPathComponent:command];
    return urlString;
}
+(NSString*)getUrlWithParameters:(NSString*)command parameters:(NSString*)obj, ... NS_REQUIRES_NIL_TERMINATION{
    va_list params;
    va_start(params, obj);
    NSString* paramsString=parseUrlParameter_v(obj,params);
    va_end(params);
    NSString* urlString=[self getUrlWithCommand:command];
    return [urlString stringByAppendingFormat:@"?%@",paramsString];
}

+(NSData*) requestUrlAsData:(NSString*)urlString{
    urlString=[urlString stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    NSData* ret=nil;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"GET"];
    [Network processRequestPreHandler:request];
    NSHTTPURLResponse* urlResponse = nil;
    NSError *error = [NSError errorWithDomain:@"Storage Network" code:0 userInfo:@{}];
    ret = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    [Network processRequestPostHandler:request response:urlResponse];
    return ret;
}

//文件上传
+(NSData*) uploadAsData:(NSString*)urlString parameters:(NSDictionary*)data{
    //创建Request对象
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    NSMutableData *body = [NSMutableData data];
    
    //设置表单项分隔符
    NSString *boundary = @"---------------------------14737809831466499882746641449";
    
    //设置内容类型
    NSString *contentType = [NSString stringWithFormat:@"multipart/form-data; boundary=%@",boundary];
    [request addValue:contentType forHTTPHeaderField: @"Content-Type"];
    
    for(NSString* key in data){
        id value=data[key];
        if([value isKindOfClass:[NSData class]]){
            NSData* data_value=(NSData*)value;
            //写入文件的内容
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"; filename=\"%@\"\r\n",key,key] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"Content-Type: image/jpeg\r\n\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:data_value];
            [body appendData:[[NSString stringWithFormat:@"\r\n"] dataUsingEncoding:NSUTF8StringEncoding]];
        }else if([value isKindOfClass:[NSString class]]){
            NSString* str_value=(NSString*)value;
            //写入参数内容
            [body appendData:[[NSString stringWithFormat:@"--%@\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[[NSString stringWithFormat:@"Content-Disposition: form-data; name=\"%@\"\r\n\r\n",key] dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[str_value dataUsingEncoding:NSUTF8StringEncoding]];
            [body appendData:[@"\r\n" dataUsingEncoding:NSUTF8StringEncoding]];
        }
    }
    
    //写入尾部内容
    [body appendData:[[NSString stringWithFormat:@"--%@--\r\n", boundary] dataUsingEncoding:NSUTF8StringEncoding]];
    
    [request setHTTPBody:body];
    [Network processRequestPreHandler:request];
    
    NSHTTPURLResponse *urlResponse = nil;
    NSError *error = [NSError errorWithDomain:@"Storage Network" code:0 userInfo:@{}];
    NSData* resultData = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    [Network processRequestPostHandler:request response:urlResponse];
    return resultData;
}

+(NSData*) requestUrlAsData:(NSString*)urlString parameters:(NSDictionary*)data{
    for(NSString* key in data){
        if([data[key] isKindOfClass:[NSData class]]){
            return [Network uploadAsData:urlString parameters:data];
        }
    }
    
    NSData* ret=nil;
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    [request setURL:[NSURL URLWithString:urlString]];
    [request setHTTPMethod:@"POST"];
    NSString* param=parseUrlParameter_d(@"",data);
    request.HTTPBody=[param dataUsingEncoding:NSUTF8StringEncoding];
    [Network processRequestPreHandler:request];

    NSHTTPURLResponse* urlResponse = nil;
    NSError *error = [NSError errorWithDomain:@"Storage Network" code:0 userInfo:@{}];
    debugLog(@"%@?%@",urlString,param);
    ret = [NSURLConnection sendSynchronousRequest:request returningResponse:&urlResponse error:&error];
    [Network processRequestPostHandler:request response:urlResponse];
    return ret;
}

+(NSString*) requestUrlAsText:(NSString*)urlString;{
    NSMutableString* ret=nil;
    NSData *responseData = [self requestUrlAsData:urlString];
    if(responseData!=nil){
        ret = [[NSMutableString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    }
    return ret;
}

+(NSString*) requestUrlAsText:(NSString*)urlString parameters:(NSDictionary*)data{
    NSMutableString* ret=nil;
    NSData *responseData = [self requestUrlAsData:urlString parameters:data];
    if(responseData!=nil){
        ret = [[NSMutableString alloc] initWithData:responseData encoding:NSUTF8StringEncoding];
    }
    return ret;
}
+(StorageCallbackData*) requestUrlAsJson:(NSString*)urlString{
    StorageCallbackData* callback_data=[[StorageCallbackData alloc]init];
    callback_data.code=0;
    callback_data.message=@"";
    callback_data.data=nil;
    NSData* responseData=[self requestUrlAsData:urlString];
    while(true){
        if(responseData==nil){
            callback_data.code=99;
            callback_data.message=@"网络异常";
            break;
        }
        NSDictionary* response=[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
        if(response==nil){
            callback_data.code=98;
            callback_data.message=@"数据格式异常(JSON格式错误)";
            break;
        }
        NSInteger code=((NSNumber*)[response objectForKey:@"code"]).integerValue;
        NSString* msg=(NSString*)[response objectForKey:@"msg"];
        id data=[response objectForKey:@"data"];
        callback_data.code=code;
        callback_data.message=msg;
        callback_data.data=data;
        break;
    }
    
    return callback_data;
}
+(StorageCallbackData*) requestUrlAsJson:(NSString*)urlString parameters:(NSDictionary*)data{
    StorageCallbackData* callback_data=[[StorageCallbackData alloc]init];
    callback_data.code=0;
    callback_data.message=@"";
    callback_data.data=nil;
    @try{
        NSData* responseData=[self requestUrlAsData:urlString parameters:data];
        while(true){
            if(responseData==nil){
                callback_data.code=99;
                callback_data.message=@"网络异常";
                break;
            }
            NSDictionary* response=[NSJSONSerialization JSONObjectWithData:responseData options:NSJSONReadingMutableContainers error:nil];
            if(response==nil){
                callback_data.code=98;
                callback_data.message=@"数据格式异常(JSON格式错误)";
                break;
            }
            NSInteger code=((NSNumber*)[response objectForKey:@"code"]).integerValue;
            NSString* msg=(NSString*)[response objectForKey:@"msg"];
            id data=[response objectForKey:@"data"];
            callback_data.code=code;
            callback_data.message=msg;
            callback_data.data=data;
            break;
        }
    }@catch(NSException* e){
        callback_data.code=100;
        callback_data.message=e.description;
    }
    
    return callback_data;
}

static NSMutableArray* preHandlerArray;
static NSMutableArray* postHandlerArray;

+(void) addRequestPreHandler:(void (^)(NSMutableURLRequest* request))handler{
    if(preHandlerArray==nil){
        preHandlerArray=[Utility initArray:preHandlerArray];
    }
    [preHandlerArray addObject:handler];
    
}
+(void) addRequestPostHandler:(void (^)(NSMutableURLRequest* request,NSHTTPURLResponse* response))handler{
    if(postHandlerArray==nil){
        postHandlerArray=[Utility initArray:postHandlerArray];
    }
    [postHandlerArray addObject:handler];
}
+(void)processRequestPreHandler:(NSMutableURLRequest*) request{
    if(preHandlerArray==nil){
        preHandlerArray=[Utility initArray:preHandlerArray];
    }
    for(int i=0;i<preHandlerArray.count;i++){
        ((void (^)(NSMutableURLRequest* request))preHandlerArray[i])(request);
    }
}
+(void)processRequestPostHandler:(NSMutableURLRequest*) request response:(NSHTTPURLResponse*) response{
    if(postHandlerArray==nil){
        postHandlerArray=[Utility initArray:postHandlerArray];
    }
    for(int i=0;i<postHandlerArray.count;i++){
        ((void (^)(NSMutableURLRequest* request,NSHTTPURLResponse* response))postHandlerArray[i])(request,response);
    }
}


+(void) registPushTokenForUser:(NSString*)userid url:(NSString*)url callback:(void (^)(StorageCallbackData* callback_data))callback;{
    runInBackground(^{
        NSString* token=[Storage getDeviceToken];
        //        NSString* token=[Storage getGeTuiClientId];
//        NSString* channel=@"ios";
        NSString* channel=@"igetui_ios";
        StorageCallbackData* callback_data=nil;
        if(token!=nil && userid!=nil){
            NSString* param=parseUrlParameter(@"deviceid",[Storage getDeviceid],@"userid",userid,@"devicetoken",token,@"channel",channel,nil);
            
            NSString* urlString=[url stringByAppendingFormat:@"?%@",param];
            callback_data=[self requestUrlAsJson:urlString];
        }else{
            callback_data=[[StorageCallbackData alloc]init];
            callback_data.code=10;
            callback_data.message=@"无效的Token或userid";
        }
        if(callback!=nil){
            runInMain(^{
                callback(callback_data);
            });
        }
    });
}

@end
