//
//  AController.h
//  xcbteacher
//
//  Created by Sean Shi on 15/8/7.
//  Copyright (c) 2015年 车友会. All rights reserved.
//

#ifndef BaseLib_AController_h
#define BaseLib_AController_h

#import <UIKit/UIKit.h>

@interface AController : UIViewController{
    NSMutableArray* _lastAController;
    NSString* _pageName;
}

-(void)gotoBack;
-(void)gotoBackWithParamaters:(NSDictionary*)data;
-(void)gotoBackToViewController:(Class)class;
-(void)gotoBackToViewController:(Class)class paramaters:(NSDictionary*)data;
-(IBAction)btn_back_click:(id)sender;
-(void)gotoPage:(NSString*)pageNameInStoryboard;
-(void)gotoPage:(NSString*)pageNameInStoryboard outNav:(BOOL)outNav;
-(void)gotoPage:(NSString*)pageNameInStoryboard parameters:(NSDictionary*)data;
-(void)gotoPage:(NSString*)pageNameInStoryboard parameters:(NSDictionary*)data outNav:(BOOL)outNav;
-(void)gotoPageWithClass:(Class) classViewController;
-(void)gotoPageWithClass:(Class) classViewController outNav:(BOOL)outNav;
-(void)gotoPageWithClass:(Class) classViewController parameters:(NSDictionary*)data;
-(void)gotoPageWithClass:(Class) classViewController parameters:(NSDictionary*)data outNav:(BOOL)outNav;
-(void)gotoPageWithClass:(Class) classViewController animated:(BOOL)animated;
-(void)gotoPageWithClass:(Class) classViewController outNav:(BOOL)outNav animated:(BOOL)animated;
-(void)gotoPageWithClass:(Class) classViewController parameters:(NSDictionary*)data animated:(BOOL)animated;
-(void)gotoPageWithClass:(Class) classViewController parameters:(NSDictionary*)data outNav:(BOOL)outNav animated:(BOOL)animated;

-(void) putValue:(id)value byKey:(NSString*)key;
-(void) addLastAController:(AController*)a;
-(AController*) popLastAController;

-(NSString*) getPagename;
-(void)hiddenAll:(UIView*)v;
@end


#endif