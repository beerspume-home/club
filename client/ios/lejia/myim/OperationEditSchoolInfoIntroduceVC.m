//
//  OperationEditSchoolInfoIntroduceVC.m
//  myim
//
//  Created by Sean Shi on 15/11/14.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "OperationEditSchoolInfoIntroduceVC.h"
#define MAX_LIMIT_NUMS 1000

@interface OperationEditSchoolInfoIntroduceVC ()<UITextViewDelegate>{
    NSString* _schoolid;
    School* _school;
    
    HeaderView* _headView;
    UIScrollView* _scrollView;
    UITextView* _textView;
    
    UILabel* _lineLimitView;
    
    CGFloat _keyboardHeight;
}

@end

@implementation OperationEditSchoolInfoIntroduceVC

- (void)viewDidLoad {
    [super viewDidLoad];
    [self reloadView];
}

-(void)viewWillAppear:(BOOL)animated{
    [self addKeyboardObserver];
    [self reloadRemoteData];
}
-(void)viewWillDisappear:(BOOL)animated{
    [self removeKeyboardObserver];
}

-(void)reloadRemoteData{
    __block LoadingView* lv=[LoadingView addDefaultLoadingToSuperview:self.view];
    [Remote school:_schoolid callback:^(StorageCallbackData *callback_data) {
        if(callback_data.code==0){
            _school=callback_data.data;
            [self refreshData];
        }else{
            [Utility showError:callback_data.message type:ErrorType_Network];
        }
        [lv removeFromSuperview];
    }];
}

-(void)refreshData{
    _textView.text=_school.introduction;
    [self refreshTextViewSize:_textView];
    _scrollView.contentSize=CGSizeMake(_scrollView.width, _textView.bottom);
    [_textView becomeFirstResponder];
}

-(void)reloadView{
    [super reloadView];

    _headView=[[HeaderView alloc]initWithTitle:@"驾校介绍"
                                    leftButton:[HeaderView genItemWithType:HeaderItemType_Back target:self action:@selector(gotoBack)]
                                   rightButton:[HeaderView genItemWithText:@"保存" target:self action:@selector(save:)]
               ];
    [self.view addSubview:_headView];

    _scrollView=[[UIScrollView alloc]init];
    [self.view addSubview:_scrollView];
    _scrollView.origin=CGPointMake(0, _headView.bottom);
    _scrollView.size=CGSizeMake(_scrollView.superview.width, _scrollView.superview.height-_scrollView.top);
    _scrollView.backgroundColor=[UIColor whiteColor];
    
    _textView=[[UITextView alloc]init];
    [_scrollView addSubview:_textView];
    _textView.backgroundColor=[UIColor whiteColor];
    _textView.origin=CGPointMake(0, 0);
    _textView.width=_textView.superview.width;
    _textView.text=@"";
    [self refreshTextViewSize:_textView];
    _textView.font=FONT_TEXT_NORMAL;
    _textView.delegate=self;
    _scrollView.bounces=false;
    
    _lineLimitView=[Utility genLabelWithText:@"" bgcolor:nil textcolor:COLOR_TEXT_SECONDARY font:FONT_TEXT_SECONDARY];

    _scrollView.contentSize=CGSizeMake(_scrollView.width, _textView.bottom);
}



- (CGSize)getStringRectInTextView:(NSString *)string InTextView:(UITextView *)textView;
{
    //
    //    NSLog(@"行高  ＝ %f container = %@,xxx = %f",self.textview.font.lineHeight,self.textview.textContainer,self.textview.textContainer.lineFragmentPadding);
    //
    //实际textView显示时我们设定的宽
    CGFloat contentWidth = CGRectGetWidth(textView.frame);
    //但事实上内容需要除去显示的边框值
    CGFloat broadWith    = (textView.contentInset.left + textView.contentInset.right
                            + textView.textContainerInset.left
                            + textView.textContainerInset.right
                            + textView.textContainer.lineFragmentPadding/*左边距*/
                            + textView.textContainer.lineFragmentPadding/*右边距*/);
    
    CGFloat broadHeight  = (textView.contentInset.top
                            + textView.contentInset.bottom
                            + textView.textContainerInset.top
                            + textView.textContainerInset.bottom);//+self.textview.textContainer.lineFragmentPadding/*top*//*+theTextView.textContainer.lineFragmentPadding*//*there is no bottom padding*/);
    
    //由于求的是普通字符串产生的Rect来适应textView的宽
    contentWidth -= broadWith;
    
    CGSize InSize = CGSizeMake(contentWidth, MAXFLOAT);
    
    NSMutableParagraphStyle *paragraphStyle = [[NSMutableParagraphStyle alloc]init];
    paragraphStyle.lineBreakMode = textView.textContainer.lineBreakMode;
    NSDictionary *dic = @{NSFontAttributeName:textView.font, NSParagraphStyleAttributeName:[paragraphStyle copy]};
    
    CGSize calculatedSize =  [string boundingRectWithSize:InSize options:NSStringDrawingUsesLineFragmentOrigin | NSStringDrawingUsesFontLeading attributes:dic context:nil].size;
    
    CGSize adjustedSize = CGSizeMake(ceilf(calculatedSize.width),calculatedSize.height + broadHeight);//ceilf(calculatedSize.height)
    return adjustedSize;
}

- (void)refreshTextViewSize:(UITextView *)textView
{
    CGSize size = [textView sizeThatFits:CGSizeMake(CGRectGetWidth(textView.frame), MAXFLOAT)];
    CGRect frame = textView.frame;
    frame.size.height = size.height;
    textView.frame = frame;
}

- (BOOL)textView:(UITextView *)textView shouldChangeTextInRange:(NSRange)range
 replacementText:(NSString *)text
{
    //对于退格删除键开放限制
    if (text.length == 0) {
        return YES;
    }
    
    UITextRange *selectedRange = [textView markedTextRange];
    //获取高亮部分
    UITextPosition *pos = [textView positionFromPosition:selectedRange.start offset:0];
    //获取高亮部分内容
    //NSString * selectedtext = [textView textInRange:selectedRange];
    
    //如果有高亮且当前字数开始位置小于最大限制时允许输入
    if (selectedRange && pos) {
        NSInteger startOffset = [textView offsetFromPosition:textView.beginningOfDocument toPosition:selectedRange.start];
        NSInteger endOffset = [textView offsetFromPosition:textView.beginningOfDocument toPosition:selectedRange.end];
        NSRange offsetRange = NSMakeRange(startOffset, endOffset - startOffset);
        
        if (offsetRange.location < MAX_LIMIT_NUMS) {
            return YES;
        }
        else
        {
            return NO;
        }
    }
    
    
    NSString *comcatstr = [textView.text stringByReplacingCharactersInRange:range withString:text];
    
    NSInteger caninputlen = MAX_LIMIT_NUMS - comcatstr.length;
    
    if (caninputlen >= 0)
    {
        //加入动态计算高度
        CGSize size = [self getStringRectInTextView:comcatstr InTextView:textView];
        CGRect frame = textView.frame;
        frame.size.height = size.height;
        
        textView.frame = frame;
        return YES;
    }
    else
    {
        NSInteger len = text.length + caninputlen;
        //防止当text.length + caninputlen < 0时，使得rg.length为一个非法最大正数出错
        NSRange rg = {0,MAX(len,0)};
        
        if (rg.length > 0)
        {
            NSString *s = @"";
            //判断是否只普通的字符或asc码(对于中文和表情返回NO)
            BOOL asc = [text canBeConvertedToEncoding:NSASCIIStringEncoding];
            if (asc) {
                s = [text substringWithRange:rg];//因为是ascii码直接取就可以了不会错
            }
            else
            {
                __block NSInteger idx = 0;
                __block NSString  *trimString = @"";//截取出的字串
                //使用字符串遍历，这个方法能准确知道每个emoji是占一个unicode还是两个
                [text enumerateSubstringsInRange:NSMakeRange(0, [text length])
                                         options:NSStringEnumerationByComposedCharacterSequences
                                      usingBlock: ^(NSString* substring, NSRange substringRange, NSRange enclosingRange, BOOL* stop) {
                                          
                                          NSInteger steplen = substring.length;
                                          if (idx >= rg.length) {
                                              *stop = YES; //取出所需要就break，提高效率
                                              return ;
                                          }
                                          
                                          trimString = [trimString stringByAppendingString:substring];
                                          
                                          idx = idx + steplen;
                                      }];
                
                s = trimString;
            }
            //rang是指从当前光标处进行替换处理(注意如果执行此句后面返回的是YES会触发didchange事件)
            [textView setText:[textView.text stringByReplacingCharactersInRange:range withString:s]];
            
            //由于后面反回的是NO不触发didchange
            [self refreshTextViewSize:textView];
            //既然是超出部分截取了，哪一定是最大限制了。
            _lineLimitView.text = [NSString stringWithFormat:@"%d/%ld",0,(long)MAX_LIMIT_NUMS];
        }
        return NO;
    }
    
}


- (void)textViewDidChange:(UITextView *)textView
{
    UITextRange *selectedRange = [textView markedTextRange];
    //获取高亮部分
    UITextPosition *pos = [textView positionFromPosition:selectedRange.start offset:0];
    
    //如果在变化中是高亮部分在变，就不要计算字符了
    if (selectedRange && pos) {
        return;
    }
    
    NSString  *nsTextContent = textView.text;
    NSInteger existTextNum = nsTextContent.length;
    
    if (existTextNum > MAX_LIMIT_NUMS)
    {
        //截取到最大位置的字符(由于超出截部分在should时被处理了所在这里这了提高效率不再判断)
        NSString *s = [nsTextContent substringToIndex:MAX_LIMIT_NUMS];
        
        [textView setText:s];
    }
    
    //不让显示负数 口口日
    _lineLimitView.text = [NSString stringWithFormat:@"%ld/%d",MAX(0,MAX_LIMIT_NUMS - existTextNum),MAX_LIMIT_NUMS];
    
    [self refreshTextViewSize:textView];
    
    
    _scrollView.contentSize=CGSizeMake(_scrollView.width, textView.bottom);
    
    [self scrollToCursor];
}

-(void)scrollToCursor{
    UITextRange *range = _textView.selectedTextRange;
    CGRect  rect = [_textView caretRectForPosition:range.start];
    [_scrollView scrollRectToVisible:rect animated:true];
}
-(void)resizeViews{
    _scrollView.height=self.view.height-_scrollView.top-_keyboardHeight;
    [self scrollToCursor];
}

-(void) keyboardWasShown:(NSNotification *)notif{
    NSDictionary *info = [notif userInfo];
    NSValue *value = [info objectForKey:UIKeyboardFrameBeginUserInfoKey];
    CGSize keyboardSize = [value CGRectValue].size;
    _keyboardHeight=keyboardSize.height;
    [self resizeViews];

}
- (void) keyboardWasHidden:(NSNotification *)notif
{
    _keyboardHeight=0;
    [self resizeViews];
}


-(void)addKeyboardObserver{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(keyboardWasShown:) name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter]  addObserver:self selector:@selector(keyboardWasHidden:) name:UIKeyboardWillHideNotification object:nil];
    
}
-(void)removeKeyboardObserver{
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillShowNotification object:nil];
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillHideNotification object:nil];
    
}

-(void)hiddenAll:(UIView *)v{
    if(![Utility isInputView:v]){
        [_textView resignFirstResponder];
    }
}

-(void)putValue:(id)value byKey:(NSString *)key{
    if([PAGE_PARAM_SCHOOL_ID isEqualToString:key]){
        _schoolid=value;
    }
}


-(void)save:(UIGestureRecognizer*)sender{
    __block LoadingView* lv=[LoadingView addDefaultLoadingToSuperview:self.view];
    [Remote updateSchoolIntroduce:_schoolid introduction:_textView.text callback:^(StorageCallbackData *callback_data) {
        if(callback_data.code==0){
            [Utility showMessage:@"驾校介绍已更改"];
            [self gotoBack];
        }else{
            [Utility showError:callback_data.message type:ErrorType_Network];
        }
        [lv removeFromSuperview];
    }];
}

@end
