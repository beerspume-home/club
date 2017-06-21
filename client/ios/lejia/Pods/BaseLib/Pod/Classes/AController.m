//
//  AController.m
//  xcbteacher
//
//  Created by Sean Shi on 15/8/7.
//  Copyright (c) 2015年 车友会. All rights reserved.
//

#import "AController.h"
#import "Utility.h"

@interface AController ()

@end

@implementation AController

/*
 #pragma mark - Navigation
 
 // In a storyboard-based application, you will often want to do a little preparation before navigation
 - (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
 // Get the new view controller using [segue destinationViewController].
 // Pass the selected object to the new view controller.
 }
 */
-(void)gotoBack{
    if(self.navigationController==nil){
        [self dismissViewControllerAnimated:true completion:nil];
    }else{
        [self.navigationController popViewControllerAnimated:true];
    }
}
-(void)gotoBackWithParamaters:(NSDictionary*)data{
    AController* last=[self popLastAController];
    if([last isKindOfClass:[AController class]] && data!=nil){
        [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            [last putValue:obj byKey:key];
        }];
    }
    [self gotoBack];
}
-(void)gotoBackToViewController:(Class)class{
    if(self.navigationController==nil){
        [self gotoBack];
    }else{
        for (UIViewController *controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:class]) {
                [self.navigationController popToViewController:controller animated:true];
            }
        }
    }
}
-(void)gotoBackToViewController:(Class)class paramaters:(NSDictionary*)data{
    if(self.navigationController==nil){
        [self gotoBackWithParamaters:data];
    }else{
        for (UIViewController *controller in self.navigationController.viewControllers) {
            if ([controller isKindOfClass:class]) {
                AController* last=(AController*)controller;
                if([last isKindOfClass:[AController class]] && data!=nil){
                    [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                        [last putValue:obj byKey:key];
                    }];
                }
                [self.navigationController popToViewController:controller animated:true];
                return;
            }
        }
        [self gotoBackWithParamaters:data];
    }
}

-(IBAction)btn_back_click:(id)sender{
    [self gotoBack];
}
-(void) putValue:(id)value byKey:(NSString*)key{}

-(void)gotoPage:(NSString*)pageNameInStoryboard{
    [self gotoPage:pageNameInStoryboard parameters:nil];
}

-(void)gotoPage:(NSString*)pageNameInStoryboard outNav:(BOOL)outNav{
    [self gotoPage:pageNameInStoryboard parameters:nil outNav:outNav];
}
-(void)gotoPage:(NSString*)pageNameInStoryboard parameters:(NSDictionary*)data outNav:(BOOL)outNav{
    UIViewController* target=[self.storyboard instantiateViewControllerWithIdentifier:pageNameInStoryboard];
    if([[target class] isSubclassOfClass:[AController class]]){
        [((AController*)target) addLastAController:self];
        if(data!=nil){
            AController* atarget=(AController*)target;
            [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                [atarget putValue:obj byKey:key];
            }];
        }
    }
    if(target!=nil){
        if(self.navigationController==nil || outNav){
            [self presentViewController:target animated:true completion:nil];
        }else{
            [self.navigationController pushViewController:target animated:true];
        }
    }
    
}

-(void)gotoPage:(NSString*)pageNameInStoryboard parameters:(NSDictionary*)data{
    [self gotoPage:pageNameInStoryboard parameters:data outNav:false];
}

//转到ViewController类对应的界面
-(void)gotoPageWithClass:(Class) classViewController{
    [self gotoPageWithClass:classViewController animated:true];
}
-(void)gotoPageWithClass:(Class) classViewController outNav:(BOOL)outNav{
    [self gotoPageWithClass:classViewController outNav:outNav animated:true];
    
}
-(void)gotoPageWithClass:(Class) classViewController parameters:(NSDictionary*)data{
    [self gotoPageWithClass:classViewController parameters:data animated:true];
}
-(void)gotoPageWithClass:(Class) classViewController parameters:(NSDictionary*)data outNav:(BOOL)outNav{
    [self gotoPageWithClass:classViewController parameters:data outNav:outNav animated:true];
}


-(void)gotoPageWithClass:(Class) classViewController animated:(BOOL)animated{
    [self gotoPageWithClass:classViewController parameters:nil outNav:false animated:animated];
}
-(void)gotoPageWithClass:(Class) classViewController outNav:(BOOL)outNav animated:(BOOL)animated{
    [self gotoPageWithClass:classViewController parameters:nil outNav:outNav animated:animated];
}
-(void)gotoPageWithClass:(Class) classViewController parameters:(NSDictionary*)data animated:(BOOL)animated{
    [self gotoPageWithClass:classViewController parameters:data outNav:false animated:animated];
}
-(void)gotoPageWithClass:(Class) classViewController parameters:(NSDictionary*)data outNav:(BOOL)outNav  animated:(BOOL)animated{
    if([classViewController isSubclassOfClass:[UIViewController class]]){
        UIViewController* target=[[classViewController alloc] init];
        if([[target class] isSubclassOfClass:[AController class]]){
            [((AController*)target) addLastAController:self];
            if(data!=nil){
                AController* atarget=(AController*)target;
                [data enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                    [atarget putValue:obj byKey:key];
                }];
            }
        }
        if(target!=nil){
            if(self.navigationController==nil || outNav){
                [self presentViewController:target animated:true completion:nil];
            }else{
                [self.navigationController pushViewController:target animated:animated];
            }
        }
    }
}



-(NSString*) getPagename{
    return _pageName;
}

-(void) addLastAController:(AController*)a{
    if(_lastAController==nil){
        _lastAController=[Utility initArray:_lastAController];
    }
    [_lastAController addObject:a];
}
-(AController*) popLastAController{
    if(_lastAController==nil){
        _lastAController=[Utility initArray:_lastAController];
    }
    if(_lastAController.count>0){
        AController* ret=(AController*)_lastAController.lastObject;
        [_lastAController removeLastObject];
        return ret;
    }else{
        return nil;
    }
}
-(void)hiddenAll:(UIView*)v{
    if(![Utility isInputView:v]){
        [self setEditing:false];
    }
}
@end
