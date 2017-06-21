//
//  ChangeValueVC.m
//  myim
//
//  Created by Sean Shi on 15/10/19.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "ChangeValueVC.h"

@interface ChangeValueVC ()<UITextViewDelegate>{
    HeaderView* _header;
    UITextView* _textField;
    UIView* _underLine;
    UILabel* _explainLabel;
    
    UILabel* _placeholderLabel;
    
    NSString* _title;
    NSString* _explain;
    NSString* _placeholder;
    NSString* _originValue;
    NSString* _type;
    NSString* _inputType;
}

@end

@implementation ChangeValueVC
- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadView];
}
-(void)reloadView{
    [super reloadView];
    //初始化标题栏
    _header=[[HeaderView alloc]
             initWithTitle:_title
             leftButton:[HeaderView genItemWithType:HeaderItemType_Back target:self action:@selector(cancel:) height:HEIGHT_HEAD_ITEM_DEFAULT]
             rightButton:[HeaderView genItemWithType:HeaderItemType_Ok target:self action:@selector(ok) height:HEIGHT_HEAD_ITEM_DEFAULT]
             backgroundColor:COLOR_HEADER_BG
             titleColor:COLOR_HEADER_TEXT
             height:HEIGHT_HEAD_DEFAULT
             ];
    [self.view addSubview:_header];
    
    //输入框
    _textField=[[UITextView alloc]init];
    [self.view addSubview:_textField];
    _textField.backgroundColor=[UIColor clearColor];
    _textField.text=_originValue;
    _textField.returnKeyType=UIReturnKeyDefault;
    _textField.delegate=self;
    _textField.textAlignment=NSTextAlignmentLeft;
    _textField.font=FONT_BUTTON;

//    [_textField addTarget:self action:@selector(valueDidChange:) forControlEvents:UIControlEventEditingChanged];

    [_textField becomeFirstResponder];
    if([CHANGEVALUE_INPUTTYPE_ASCIICapable isEqualToString:_inputType]){
        _textField.keyboardType=UIKeyboardTypeASCIICapable;
    }else if([CHANGEVALUE_INPUTTYPE_NumbersAndPunctuation isEqualToString:_inputType]){
        _textField.keyboardType=UIKeyboardTypeNumbersAndPunctuation;
    }else if([CHANGEVALUE_INPUTTYPE_URL isEqualToString:_inputType]){
        _textField.keyboardType=UIKeyboardTypeURL;
    }else if([CHANGEVALUE_INPUTTYPE_NumberPad isEqualToString:_inputType]){
        _textField.keyboardType=UIKeyboardTypeNumberPad;
    }else if([CHANGEVALUE_INPUTTYPE_PhonePad isEqualToString:_inputType]){
        _textField.keyboardType=UIKeyboardTypePhonePad;
    }else if([CHANGEVALUE_INPUTTYPE_EmailAddress isEqualToString:_inputType]){
        _textField.keyboardType=UIKeyboardTypeEmailAddress;
    }else if([CHANGEVALUE_INPUTTYPE_DecimalPad isEqualToString:_inputType]){
        _textField.keyboardType=UIKeyboardTypeDecimalPad;
    }else if([CHANGEVALUE_INPUTTYPE_Twitter isEqualToString:_inputType]){
        _textField.keyboardType=UIKeyboardTypeTwitter;
    }else if([CHANGEVALUE_INPUTTYPE_WebSearch isEqualToString:_inputType]){
        _textField.keyboardType=UIKeyboardTypeWebSearch;
    }else{
        _textField.keyboardType=UIKeyboardTypeDefault;
    }
    _textField.textContainerInset=(UIEdgeInsets){0,0,0,0};
    _textField.width=_textField.superview.width-50;
    CGSize size=getStringSizeLimitWithWidth(_textField.text, _textField.font, _textField.width);
    _textField.height=size.height;
    _textField.top=_header.bottom+20;
    _textField.centerX=_textField.superview.width/2;
    _textField.bounces=false;
    _textField.spellCheckingType=UITextSpellCheckingTypeNo;
    _textField.autocapitalizationType=UITextAutocapitalizationTypeNone;
    [_textField becomeFirstResponder];
    
    
    _placeholderLabel=[[UILabel alloc]init];
    [self.view addSubview:_placeholderLabel];
    _placeholderLabel.text=_placeholder;
    _placeholderLabel.textColor=_textField.textColor;
    _placeholderLabel.font=_textField.font;
    [_placeholderLabel fit];
    UIEdgeInsets layoutMargins=_textField.layoutMargins;
    _placeholderLabel.width=_textField.width-layoutMargins.left-layoutMargins.right;
    _placeholderLabel.left=_textField.left+layoutMargins.left;
    _placeholderLabel.centerY=_textField.centerY;
    _placeholderLabel.enabled=false;
    if([Utility isEmptyString:_textField.text]){
        _placeholderLabel.hidden=false;
    }else{
        _placeholderLabel.hidden=true;
    }
    
    //下划线
    _underLine=[[UIView alloc]init];
    [self.view addSubview:_underLine];
    _underLine.size=CGSizeMake(_textField.width+10, 1);
    _underLine.backgroundColor=[UIColor brownColor];
    _underLine.top=_textField.bottom+1;
    _underLine.centerX=_textField.centerX;
    //说明
    _explainLabel=[[UILabel alloc]init];
    [self.view addSubview:_explainLabel];
    _explainLabel.text=_explain;
    _explainLabel.textColor=COLOR_TEXT_SECONDARY;
    _explainLabel.font=FONT_TEXT_SECONDARY;
    _explainLabel.numberOfLines=0;
    [Utility fitLabel:_explainLabel];
    _explainLabel.textAlignment=NSTextAlignmentLeft;
    _explainLabel.top=_textField.bottom+4;
    _explainLabel.left=_textField.left;
    
}

-(void)ok{
    NSString* returnValue=[Utility trim:_textField.text];
    if(_delegate!=nil){
        [_delegate changeValue:self valueDidChanged:returnValue];
    }
    [self gotoBackWithParamaters:@{
                                   PAGE_PARAM_RETURN_VALUE:@{
                                           PAGE_PARAM_TYPE:_type,
                                           PAGE_PARAM_RETURN_VALUE:returnValue,
                                           },
                                   }];
}
-(void)cancel:(UIGestureRecognizer*)sender{
    BOOL canCancel=true;
    if(_delegate!=nil){
        @try {
            canCancel=[_delegate  changeValueCancel:self];
        }
        @catch (NSException *exception) {}
        @finally {}
    }
    if(canCancel){
        [self gotoBack];
    }
}

-(void)putValue:(id)value byKey:(NSString *)key{
    if([PAGE_PARAM_TITLE isEqualToString:key]){
        _title=value;
    }else if([PAGE_PARAM_EXPLAIN isEqualToString:key]){
        _explain=value;
    }else if([PAGE_PARAM_PLACEHOLDER isEqualToString:key]){
        _placeholder=value;
    }else if([PAGE_PARAM_ORIGIN_VALUE isEqualToString:key]){
        _originValue=value;
    }else if([PAGE_PARAM_TYPE isEqualToString:key]){
        _type=value;
    }else if([PAGE_PARAM_INPUTTYPE isEqualToString:key]){
        _inputType=value;
    }else if([PAGE_PARAM_DELEGATE isEqualToString:key]){
        _delegate=value;
    }
}

- (BOOL)textFieldShouldReturn:(UITextField *)textField{
    [self ok];
    return true;
}

- (void)textViewDidChange:(UITextView *)textView{
    NSString* text=_textField.text;
    CGSize size=getStringSizeLimitWithWidth(text, _textField.font, _textField.width);
    _textField.height=size.height;
    _underLine.top=_textField.bottom+1;
    _explainLabel.top=_textField.bottom+4;
    if([Utility isEmptyString:_textField.text]){
        _placeholderLabel.hidden=false;
    }else{
        _placeholderLabel.hidden=true;
    }
}

@end
