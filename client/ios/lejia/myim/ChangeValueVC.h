//
//  ChangeValueVC.h
//  myim
//
//  Created by Sean Shi on 15/10/30.
//  Copyright © 2015年 车友会. All rights reserved.
//

#define CHANGEVALUE_INPUTTYPE_Default @"UIKeyboardTypeDefault"
#define CHANGEVALUE_INPUTTYPE_ASCIICapable @"UIKeyboardTypeASCIICapable"
#define CHANGEVALUE_INPUTTYPE_NumbersAndPunctuation @"UIKeyboardTypeNumbersAndPunctuation"
#define CHANGEVALUE_INPUTTYPE_URL @"UIKeyboardTypeURL"
#define CHANGEVALUE_INPUTTYPE_NumberPad @"UIKeyboardTypeNumberPad"
#define CHANGEVALUE_INPUTTYPE_PhonePad @"UIKeyboardTypePhonePad"
#define CHANGEVALUE_INPUTTYPE_NamePhonePad @"UIKeyboardTypeNamePhonePad"
#define CHANGEVALUE_INPUTTYPE_EmailAddress @"UIKeyboardTypeEmailAddress"
#define CHANGEVALUE_INPUTTYPE_DecimalPad @"UIKeyboardTypeDecimalPad"
#define CHANGEVALUE_INPUTTYPE_Twitter @"UIKeyboardTypeTwitter"
#define CHANGEVALUE_INPUTTYPE_WebSearch @"UIKeyboardTypeWebSearch"
#define CHANGEVALUE_INPUTTYPE_Date @"CHANGEVALUE_INPUTTYPE_Date"


@interface ChangeValueVC : AController

@end


@protocol ChangeValueDelegate <NSObject>

@required

-(void)changeValue:(ChangeValueVC*)changeValueVC valueDidChanged:(NSString*)value;

@optional
-(BOOL)changeValueCancel:(ChangeValueVC*)changeValueVC;

@end

@interface ChangeValueVC ()
@property (nonatomic,retain) id<ChangeValueDelegate> delegate;
@end

