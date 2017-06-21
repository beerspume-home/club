//
//  FeatureItem.h
//  myim
//
//  Created by Sean Shi on 15/11/13.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import <Foundation/Foundation.h>

#define FEATURE_INPUTTYPE_Switch @"FEATURE_INPUTTYPE_Switch"

@interface FeatureItem : NSObject
@end

@protocol FeatureItemDelegate <NSObject>

@required
-(void)featureItem:(FeatureItem*)featureItem didValueChange:(NSString*)value;

@end

@interface FeatureItem ()

@property (nonatomic,retain) NSString* title;
@property (nonatomic,retain) NSString* rightValue;
@property (nonatomic,retain) NSString* rightText;
@property (nonatomic,retain) NSArray<Dict*>* rightDict;
@property (nonatomic,assign) CGFloat height;
@property (nonatomic,assign) CGFloat top;
@property (nonatomic,retain) UIView* superview;
@property (nonatomic,retain) id target;
@property (nonatomic,assign) SEL action;
@property (nonatomic,assign) BOOL showSplit;
@property (nonatomic,readonly) UIView* view;
@property (nonatomic,retain) NSString* inputType;
@property (nonatomic,assign) BOOL mutliSelect;
@property (nonatomic,assign) BOOL fitRightContent;
@property (nonatomic,retain) id<FeatureItemDelegate> delegate;

-(NSString*)getRightValue;

-(instancetype)initSwitchInSuperView:(nonnull UIView*)superview top:(CGFloat)top title:(nonnull NSString*)title  value:(BOOL)value height:(CGFloat)height showSplit:(BOOL)showSplit;

-(instancetype)initSelectInSuperView:(nonnull UIView*)superview top:(CGFloat)top title:(nonnull NSString*)title  value:(nonnull NSString*)value height:(CGFloat)height showSplit:(BOOL)showSplit dict:(NSArray<Dict*>*)dict mutliSelect:(BOOL)mutliSelect;

-(instancetype)initSelectInSuperView:(nonnull UIView*)superview top:(CGFloat)top title:(nonnull NSString*)title  value:(nonnull NSString*)value height:(CGFloat)height target:(nullable id)target action:(nullable SEL)action showSplit:(BOOL)showSplit dict:(NSArray<Dict*>*)dict mutliSelect:(BOOL)mutliSelect;

-(instancetype)initInputInSuperView:(nonnull UIView*)superview top:(CGFloat)top title:(nonnull NSString*)title  value:(nonnull NSString*)value height:(CGFloat)height showSplit:(BOOL)showSplit inputType:(NSString*)inputType;

-(instancetype)initInputInSuperView:(nonnull UIView*)superview top:(CGFloat)top title:(nonnull NSString*)title  value:(nonnull NSString*)value height:(CGFloat)height target:(nullable id)target action:(nullable SEL)action showSplit:(BOOL)showSplit inputType:(NSString*)inputType;

-(instancetype)initInSuperView:(nonnull UIView*)superview top:(CGFloat)top title:(nonnull NSString*)title  value:(nonnull NSString*)value height:(CGFloat)height target:(nullable id)target action:(nullable SEL)action showSplit:(BOOL)showSplit inputType:(NSString*)inputType dict:(NSArray<Dict*>*)dict mutliSelect:(BOOL)mutliSelect;

@end
