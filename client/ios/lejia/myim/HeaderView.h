//
//  HeaderView.h
//  myim
//
//  Created by Sean Shi on 15/10/13.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef NS_ENUM(NSUInteger, HeaderItemType) {
    /**
     * 返回
     */
    HeaderItemType_Back = 1,
    /**
     * 添加
     */
    HeaderItemType_Add,
    /**
     * 保存
     */
    HeaderItemType_Save,
    /**
     *  确定
     */
    HeaderItemType_Ok,
    /**
     *  人
     */
    HeaderItemType_Person,
    /**
     *  多人
     */
    HeaderItemType_People,
    /**
     *  新建
     */
    HeaderItemType_New,
};

@interface HeaderView : UIView
@property(nonatomic,retain,nullable) UIView* leftBarItem;
@property(nonatomic,retain,nullable) UIView* rightBarItem;
@property(nonatomic,retain,nullable) NSString* title;
@property(nonatomic,retain,nullable) UIColor* titleColor;
@property(nonatomic,assign) CGFloat headHeight;


-(nonnull instancetype)initWithTitle:(nullable NSString*)title leftButton:(nullable UIView*)leftButton rightButton:(nullable UIView*)rightButton;
-(nonnull instancetype)initWithTitle:(nullable NSString*)title leftButton:(nullable UIView*)leftButton rightButton:(nullable UIView*)rightButton backgroundColor:(nullable UIColor*)backgroundColor titleColor:(nullable UIColor*)titleColor;
-(nonnull instancetype)initWithTitle:(nullable NSString*)title leftButton:(nullable UIView*)leftButton rightButton:(nullable UIView*)rightButton backgroundColor:(nullable UIColor*)backgroundColor titleColor:(nullable UIColor*)titleColor height:(CGFloat)height;

+(nonnull UIView*) genItemWithType:(HeaderItemType)type target:(nullable id)target action:(nullable SEL)action;

+(nonnull UIView*) genItemWithType:(HeaderItemType)type target:(nullable id)target action:(nullable SEL)action height:(CGFloat)height;

+(nonnull UIView*) genItemWithText:(nonnull NSString*)text target:(nullable id)target action:(nullable SEL)action;
+(nonnull UIView*) genItemWithText:(nonnull NSString*)text target:(nullable id)target action:(nullable SEL)action height:(CGFloat)height;

+(nonnull UIView*) genItemWithIcon:(UIImage*)image andText:(nonnull NSString*)text target:(nullable id)target action:(nullable SEL)action height:(CGFloat)height;
@end
