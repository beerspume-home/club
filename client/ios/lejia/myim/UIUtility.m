//
//  UIUtility.m
//  myim
//
//  Created by Sean Shi on 15/10/27.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "UIUtility.h"

#define PADDING_LEFT 15
#define PADDING_RIGHT 15
#define SPLIT_HEIGHT 0.5

@interface ImagePicker : NSObject <UINavigationControllerDelegate, UIImagePickerControllerDelegate>{
    UIView* _maskView;
    UIView* _selectView;
    UIImagePickerController* _picker;
    
    BOOL _cameraEnable;
}
@property (nonatomic,assign) CGFloat width;
@property (nonatomic,assign) CGFloat height;
@property (nonatomic,assign) UIImagePickerControllerSourceType sourceType;
@property (nonatomic,retain) AController* fromViewController;
@property (nonatomic,retain) NSString* returnKey;

-(void)showWithSourceType:(UIImagePickerControllerSourceType)sourceType fromViewController:(AController*)fromViewController returnKey:(NSString*)returnKey size:(CGSize)size;
-(void)hide;
+(instancetype)sharedImagePicker;
@end

@interface ImagePickerViewController : AController
@end


static ImagePicker* imagePickerInstance;
@implementation ImagePicker
-(void)showWithSourceType:(UIImagePickerControllerSourceType)sourceType fromViewController:(AController*)fromViewController returnKey:(NSString*)returnKey  size:(CGSize)size{
    if(_maskView!=nil && _selectView!=nil){
        self.sourceType=sourceType;
        self.fromViewController=fromViewController;
        self.returnKey=returnKey;
        self.width=size.width;
        self.height=size.height;
        if(!_cameraEnable && sourceType==UIImagePickerControllerSourceTypeCamera){
            [Utility showError:@"摄像头设备不可用" type:ErrorType_Network];
            return;
        }
        
        if(sourceType !=UIImagePickerControllerSourceTypeCamera &&
           sourceType !=UIImagePickerControllerSourceTypePhotoLibrary &&
           sourceType !=UIImagePickerControllerSourceTypeSavedPhotosAlbum){
            _selectView.top=_selectView.superview.height;
            _maskView.hidden=false;
            _selectView.hidden=false;
            [UIView animateWithDuration:0.2 animations:^{
                _selectView.bottom=_selectView.superview.height-10;
            }];
        }else{
            [self openSystemPicker:_sourceType];
        }
    }
}
-(void)hide{
    if(_maskView!=nil && _selectView!=nil){
        [UIView animateWithDuration:0.2 animations:^{
            _selectView.top=_selectView.superview.height;
        } completion:^(BOOL finished) {
            if(finished){
                _maskView.hidden=true;
                _selectView.hidden=true;
            }
            
        }];
    }
}
-(void)hideImmediately{
    if(_maskView!=nil && _selectView!=nil){
        _selectView.top=_selectView.superview.height;
        _maskView.hidden=true;
        _selectView.hidden=true;
    }
}

-(void)gotoCamera{
    [self openSystemPicker:UIImagePickerControllerSourceTypeCamera];
}

-(void)gotoPhotoLibrary{
    [self openSystemPicker:UIImagePickerControllerSourceTypePhotoLibrary];
}

-(void)openSystemPicker:(UIImagePickerControllerSourceType)sourceType{
    if(_picker==nil){
        _picker=[[UIImagePickerController alloc]init];
        _picker.delegate=self;
        _picker.modalTransitionStyle=UIModalTransitionStyleCoverVertical;
        _picker.allowsEditing=false;
    }
    _picker.sourceType=sourceType;
    [_fromViewController presentViewController:_picker animated:true completion:nil];
    [self hideImmediately];
}

//图片库选择器的回调方法
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    [picker dismissViewControllerAnimated:false completion:^{
        UIImage* image=info[UIImagePickerControllerOriginalImage];
        [_fromViewController gotoPageWithClass:[ImagePickerViewController class]
                                    parameters:@{
                                                 @"image":image,
                                                 @"backclass":[_fromViewController class],
                                                 @"returnkey":_returnKey==nil?@"":_returnKey,
                                                 @"width":[NSNumber numberWithFloat:_width],
                                                 @"height":[NSNumber numberWithFloat:_height],
                                                 } animated:false];
//        [_fromViewController putValue:image byKey:_returnKey];
    }];
}

-(instancetype)init{
    ImagePicker* ret=[super init];
    _cameraEnable=[UIImagePickerController isSourceTypeAvailable: UIImagePickerControllerSourceTypeCamera];
    UIView* rootView=[UIApplication sharedApplication].keyWindow;
    if(rootView!=nil){
        CGFloat button_height=HEIGHT_BUTTON*1;
        UIColor* textColor=[UIColor whiteColor];
        if(_maskView==nil){
            _maskView=[[UIView alloc]init];
            [rootView addSubview:_maskView];
            _maskView.hidden=true;
            _maskView.frame=rootView.frame;
            _maskView.backgroundColor=[UIColor blackColor];
            _maskView.alpha=0.1;
            _maskView.userInteractionEnabled=true;
            [_maskView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(hide)]];
        }
        if(_selectView==nil){
            _selectView=[[UIView alloc]init];
            [rootView addSubview:_selectView];
            _selectView.width=_selectView.superview.width-10;
            _selectView.height=_cameraEnable?button_height*2+0.5:button_height;
            _selectView.top=_selectView.superview.height;
            _selectView.centerX=_selectView.superview.width/2;
            _selectView.layer.cornerRadius=5;
            _selectView.backgroundColor=COLOR_HEADER_BG;//[UIColor whiteColor];
            
            if(_cameraEnable){
                [UIUtility genButtonToSuperview:_selectView
                                            top:0
                                          title:@"拍照"
                                backgroundColor:_selectView.backgroundColor
                                      textColor:textColor//COLOR_HEADER_BG
                                          width:_selectView.width
                                         height:button_height
                                         target:self
                                         action:@selector(gotoCamera)
                 ];
                [UIUtility genSplitToSuperview:_selectView top:HEIGHT_BUTTON width:_selectView.width];
            }
            [UIUtility genButtonToSuperview:_selectView
                                        top:_cameraEnable?button_height+0.5:0
                                      title:@"选取照片"
                            backgroundColor:_selectView.backgroundColor
                                  textColor:textColor
                                      width:_selectView.width
                                     height:HEIGHT_BUTTON
                                     target:self
                                     action:@selector(gotoPhotoLibrary)
             ];
            
        }
        
    }
    return ret;
    
}

+(instancetype)sharedImagePicker{
    if(imagePickerInstance==nil){
        imagePickerInstance=[[ImagePicker alloc]init];
    }
    return imagePickerInstance;
}

@end

@interface ImagePickerViewController(){
    UIImage* _image;
    Class _backClass;
    NSString* _returnKey;
    
    UIView* backView;
    UIImageView* _imageView;
    UIView* _pickView;
    
    CGFloat _width;
    CGFloat _height;
    CGFloat _lastScale;
    CGSize _initSize;
}

@end
@implementation ImagePickerViewController

-(void)viewDidLoad{
    [super viewDidLoad];
    [self reloadView];
}
-(void) reloadView{
    [super reloadView];
    
    backView=[[UIView alloc]init];
    [self.view addSubview:backView];
    backView.layer.masksToBounds=true;
    backView.frame=backView.superview.frame;
    backView.backgroundColor=[UIColor blackColor];

    _imageView=[[UIImageView alloc]init];
    [backView addSubview:_imageView];
    _imageView.image=_image;

    _pickView=[[UIView alloc]init];
    [backView addSubview:_pickView];
    float w=backView.width*0.9;
    float h=backView.height*0.9;
    float scaleSize=_width/w>_height/h?_width/w:_height/h;
    _pickView.size=CGSizeMake(_width/scaleSize, _height/scaleSize);
    _pickView.center=_pickView.superview.innerCenterPoint;
    _pickView.layer.borderColor=[UIColor redColor].CGColor;
    _pickView.layer.borderWidth=1;
    
    float sw=_pickView.width/_image.size.width;
    float sh=_pickView.height/_image.size.height;
    _lastScale=sw>sh?sw:sh;
    _initSize=CGSizeMake(_image.size.width*_lastScale, _image.size.height*_lastScale);
    _imageView.size=_initSize;
    _imageView.center=_imageView.superview.innerCenterPoint;

    
    float maskAlpha=0.3;
    UIView* maskUp=[[UIView alloc]init];
    [backView addSubview:maskUp];
    maskUp.backgroundColor=[UIColor blackColor];
    maskUp.alpha=maskAlpha;
    maskUp.size=CGSizeMake(maskUp.superview.width, _pickView.top);
    maskUp.origin=CGPointMake(0, 0);
    UIView* maskDown=[[UIView alloc]init];
    [backView addSubview:maskDown];
    maskDown.backgroundColor=[UIColor blackColor];
    maskDown.alpha=maskAlpha;
    maskDown.size=CGSizeMake(maskUp.superview.width, maskDown.superview.height-_pickView.bottom);
    maskDown.origin=CGPointMake(0, _pickView.bottom);
    UIView* maskLeft=[[UIView alloc]init];
    [backView addSubview:maskLeft];
    maskLeft.backgroundColor=[UIColor blackColor];
    maskLeft.alpha=maskAlpha;
    maskLeft.size=CGSizeMake(_pickView.left, _pickView.height);
    maskLeft.origin=CGPointMake(0, _pickView.top);
    UIView* maskRight=[[UIView alloc]init];
    [backView addSubview:maskRight];
    maskRight.backgroundColor=[UIColor blackColor];
    maskRight.alpha=maskAlpha;
    maskRight.size=CGSizeMake(maskRight.superview.width-_pickView.right, _pickView.height);
    maskRight.origin=CGPointMake(_pickView.right, _pickView.top);
    
    
    UIView* panView=[[UIView alloc]init];
    [backView addSubview:panView];
    panView.frame=panView.superview.frame;
    panView.backgroundColor=[UIColor clearColor];
    panView.userInteractionEnabled=true;
    [panView addGestureRecognizer:[[UIPanGestureRecognizer alloc]initWithTarget:self action:@selector(pan:)]];
    [panView addGestureRecognizer:[[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinch:)]];
    
    
    
    UILabel* cancelLabel=[UIUtility genButtonToSuperview:backView
                                                     top:0
                                                   title:@"取消"
                                         backgroundColor:[UIColor clearColor]
                                               textColor:[UIColor whiteColor]
                                                   width:60
                                                  height:HEIGHT_BUTTON
                                                  target:self
                                                  action:@selector(gotoBack)];
    
    cancelLabel.left=0;
    cancelLabel.bottom=cancelLabel.superview.height;

    UILabel* savelLabel=[UIUtility genButtonToSuperview:backView
                                                     top:0
                                                   title:@"选取"
                                         backgroundColor:[UIColor clearColor]
                                               textColor:[UIColor whiteColor]
                                                   width:60
                                                  height:HEIGHT_BUTTON
                                                  target:self
                                                  action:@selector(save)];
    
    savelLabel.right=savelLabel.superview.width;
    savelLabel.bottom=cancelLabel.superview.height;

    
}
-(void)save{
    CGFloat x=_pickView.left-_imageView.left;
    CGFloat y=_pickView.top-_imageView.top;
    CGFloat w=_pickView.width;
    CGFloat h=_pickView.height;
    float scaleSize=_imageView.width/_image.size.width;

    CGFloat r_x=x/scaleSize;
    CGFloat r_y=y/scaleSize;
    CGFloat r_w=w/scaleSize;
    CGFloat r_h=h/scaleSize;
    
    /* 这里要做三件事
     * 1.截取选中区域
     * 2.将图片方向转为正向，否则上传后图片有可能旋转
     * 3.将图片放大/缩小到需要的尺寸
     */
    
    UIImage* retImage=[[[_image imageInRect:CGRectMake(r_x, r_y, r_w, r_h)] fixOrientation]scaleToSize:(_width>_height?_width:_height)];
    
    NSDictionary* retParameter=@{
                                 _returnKey:retImage,
                                 };
    if(_backClass!=nil){
        [self gotoBackToViewController:_backClass paramaters:retParameter];
    }else{
        [self gotoBackWithParamaters:retParameter];
    }

}

-(void)pan:(UIPanGestureRecognizer*)sender{
    CGPoint point=[sender translationInView:backView];
    CGFloat targetLeft=_imageView.left+ point.x;
    CGFloat targetTop=_imageView.top+point.y;
    if(targetTop>_pickView.top)targetTop=_pickView.top;
    if(targetLeft>_pickView.left)targetLeft=_pickView.left;
    if(targetTop+_imageView.height<_pickView.bottom)targetTop=_pickView.bottom-_imageView.height;
    if(targetLeft+_imageView.width<_pickView.right)targetLeft=_pickView.right-_imageView.width;
    _imageView.origin=CGPointMake(targetLeft,targetTop);
    [sender setTranslation:CGPointMake(0, 0) inView:backView];
}
-(void)pinch:(UIPinchGestureRecognizer*)sender{
    CGFloat scale=sender.scale;
    if(scale>1){
        _imageView.transform=CGAffineTransformMakeScale(_lastScale+(scale-1), (_lastScale+(scale-1)));
    }else{
        _imageView.transform=CGAffineTransformMakeScale(_lastScale*scale, _lastScale*scale);
    }
    if(_imageView.top>_pickView.top
       || _imageView.left>_pickView.left
       || _imageView.top+_imageView.height<_pickView.bottom
       || _imageView.left+_imageView.width<_pickView.right){
        CGFloat w=_initSize.width;
        CGFloat h=_initSize.height;
        float sw=_pickView.width/w;
        float sh=_pickView.height/h;
        float scaleSize=sw>sh?sw:sh;
        _imageView.transform=CGAffineTransformMakeScale(scaleSize,scaleSize);

//        if(_imageView.top>_pickView.top)_imageView.top=_pickView.top;
//        if(_imageView.left>_pickView.left)_imageView.left=_pickView.left;
//        if(_imageView.top+_imageView.height<_pickView.bottom)_imageView.top=_pickView.bottom-_imageView.height;
//        if(_imageView.left+_imageView.width<_pickView.right)_imageView.left=_pickView.right-_imageView.width;
    
    }
    if(sender.state==UIGestureRecognizerStateEnded){
        if(scale>1){
            _lastScale+=(scale-1);
        }else{
            _lastScale*=scale;
        }
    }
}

-(void)putValue:(id)value byKey:(NSString *)key{
    if([@"image" isEqualToString:key]){
        _image=value;
    }else if([@"backclass" isEqualToString:key]){
        _backClass=value;
    }else if([@"returnkey" isEqualToString:key]){
        _returnKey=value;
    }else if([@"width" isEqualToString:key]){
        _width=((NSNumber*)value).floatValue;
    }else if([@"height" isEqualToString:key]){
        _height=((NSNumber*)value).floatValue;
    }
}
@end



@implementation UIUtility

+(nonnull UILabel*)genFeatureItemRightLabel{
    return [UIUtility genFeatureItemRightLabel:NSTextAlignmentLeft];
}
+(nonnull UILabel*)genFeatureItemRightLabel:(NSTextAlignment)textAlignment{
    UILabel* ret=[[UILabel alloc]init];
    ret.backgroundColor=[UIColor clearColor];
    ret.textColor=COLOR_TEXT_SECONDARY;
    ret.font=FONT_TEXT_SECONDARY;
    ret.textAlignment=textAlignment;
    ret.numberOfLines=0;
    return ret;
}

+(NSString*)getFeatureTitle:(nonnull UIView*)v{
    NSString* ret=nil;
    if(v.tagObject!=nil && [v.tagObject isKindOfClass:[NSDictionary class]]){
        ret=((UILabel*)(((NSDictionary*)v.tagObject)[@"titleLabel"])).text;
    }
    return ret;
}
+(NSString*)getFeatureTextValue:(nonnull UIView*)v{
    NSString* ret=nil;
    if(v.tagObject!=nil && [v.tagObject isKindOfClass:[NSDictionary class]] && [((NSDictionary*)v.tagObject)[@"rightObj"] isKindOfClass:[UILabel class]]){
        UILabel* label=((NSDictionary*)v.tagObject)[@"rightObj"];
        ret=label.text;
    }
    return ret;
}
+(void)setFeatureItem:(nonnull UIView*)v text:(nullable NSString*)text{
    if(v.tagObject!=nil && [v.tagObject isKindOfClass:[NSDictionary class]] && [((NSDictionary*)v.tagObject)[@"rightObj"] isKindOfClass:[UILabel class]]){
        UILabel* label=((NSDictionary*)v.tagObject)[@"rightObj"];
        label.text=text;
        label.numberOfLines=0;
        NSTextAlignment textAlignment=label.textAlignment;
        [Utility fitLabel:label usePadding:true];
        label.textAlignment=textAlignment;
        if(label.width>label.superview.width*0.5){
            label.width=label.superview.width*0.5;
        }
        v.height=label.height+10>v.height?label.height+10:v.height;
        label.right=label.superview.width-PADDING_RIGHT;
        label.centerY=v.height/2;
        
    }
}


+(void)setFeatureItem:(nonnull UIView*)v image:(nullable UIImage*)image{
    if(v.tagObject!=nil && [v.tagObject isKindOfClass:[NSDictionary class]] && [((NSDictionary*)v.tagObject)[@"rightObj"] isKindOfClass:[UIImageView class]]){
        UIImageView* imageView=((NSDictionary*)v.tagObject)[@"rightObj"];
        imageView.image=image;
    }
}

+(void)setFeatureItem:(nonnull UIView*)v imageUrl:(nullable NSString*)imageUrl defaultImage:(nullable UIImage*)defaultImage{
    if(v.tagObject!=nil && [v.tagObject isKindOfClass:[NSDictionary class]] && [((NSDictionary*)v.tagObject)[@"rightObj"] isKindOfClass:[UIImageView class]]){
        UIImageView* imageView=((NSDictionary*)v.tagObject)[@"rightObj"];
        NSURL* url=[NSURL URLWithString:imageUrl];
        [imageView sd_setImageWithURL:url placeholderImage:defaultImage];
    }
}


+(UIView*)genFeatureItemInSuperView:(nonnull UIView*)superview top:(CGFloat)top title:(nonnull NSString*)title height:(CGFloat)height rightObj:(nullable UIView*)rightObj target:(nullable id)target action:(nullable SEL)action showSplit:(BOOL)showSplit{
    //信息栏
    UIView* ret=[[UIView alloc]init];
    ret.backgroundColor=COLOR_FEATURE_BAR_BG;
    ret.userInteractionEnabled=true;
    [ret addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:target action:action]];
    [superview addSubview:ret];
    [ret setFrame:CGRectMake(0, top, ret.superview.width, height)];
    //信息栏文字
    UILabel* titleLabel=[[UILabel alloc]init];
    titleLabel.backgroundColor=[UIColor clearColor];
    titleLabel.textColor=COLOR_TEXT_NORMAL;
    titleLabel.font=FONT_TEXT_NORMAL;
    titleLabel.text=title;
    titleLabel.numberOfLines=0;
    [ret addSubview:titleLabel];
    [Utility fitLabel:titleLabel usePadding:false];
    titleLabel.textAlignment=NSTextAlignmentLeft;
    UILabel* tmpLabel=[Utility genLabelWithText:@"一行" bgcolor:nil textcolor:nil font:titleLabel.font];
    [Utility fitLabel:tmpLabel usePadding:false];
    ret.height=titleLabel.height+(height-tmpLabel.height);
    titleLabel.left=PADDING_LEFT;
    titleLabel.centerY=titleLabel.superview.height/2;
    //右边内容
    if(rightObj!=nil){
        [ret addSubview:rightObj];
        ret.tagObject=@{
                        @"titleLabel":titleLabel,
                        @"rightObj":rightObj,
                        };
        rightObj.right=rightObj.superview.width-PADDING_RIGHT;
        rightObj.centerY=rightObj.superview.height/2;
    }
    //分割线
    if(showSplit){
        UIView* split=[[UIView alloc]init];
        split.backgroundColor=COLOR_SPLIT;
        [ret addSubview:split];
        split.size=CGSizeMake(split.superview.width-PADDING_LEFT-PADDING_RIGHT, SPLIT_HEIGHT);
        split.top=0;
        split.centerX=split.superview.width/2;
        
    }
    
    return ret;
}



#pragma mark 生成按钮
+(nonnull UILabel*)genButtonToSuperview:(nonnull UIView*)superview top:(CGFloat)top title:(nonnull NSString*)title target:(nullable id)target action:(nullable SEL)action{
    UILabel* ret=[[UILabel alloc]init];
    ret.backgroundColor=COLOR_BUTTON_BG;
    ret.textColor=COLOR_BUTTON_TEXT;
    ret.textAlignment=NSTextAlignmentCenter;
    ret.layer.masksToBounds=YES;
    ret.layer.cornerRadius=CORNERRADIUS_BUTTON;
    ret.text=title;
    ret.font=FONT_BUTTON;
    ret.userInteractionEnabled=true;
    [ret addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:target action:action]];
    [superview addSubview:ret];

    ret.size=CGSizeMake(superview.width-BUTTON_DEFAULT_ENGE*2, HEIGHT_BUTTON);
    ret.top=top;
    ret.centerX=superview.width/2;
    return ret;
}

+(nonnull UILabel*)genButtonToSuperview:(nonnull UIView*)superview top:(CGFloat)top title:(nonnull NSString*)title backgroundColor:(UIColor*)backgroundColor textColor:(UIColor*)textColor width:(CGFloat)width height:(CGFloat)height target:(nullable id)target action:(nullable SEL)action{
    UILabel* ret=[[UILabel alloc]init];
    ret.backgroundColor=backgroundColor;
    ret.textColor=textColor;
    ret.textAlignment=NSTextAlignmentCenter;
    ret.layer.masksToBounds=YES;
    ret.layer.cornerRadius=CORNERRADIUS_BUTTON;
    ret.text=title;
    ret.font=FONT_BUTTON;
    ret.userInteractionEnabled=true;
    [ret addGestureRecognizer:[[UITapGestureRecognizer alloc] initWithTarget:target action:action]];
    [superview addSubview:ret];
    
    ret.size=CGSizeMake(width, height);
    ret.top=top;
    ret.centerX=superview.width/2;
    return ret;
}




#pragma mark 生成分割线
+(nonnull UIView*)genSplitToSuperview:(nonnull UIView*)superview top:(CGFloat)top width:(CGFloat)width{
    UIView* split=[[UIView alloc]init];
    split.backgroundColor=COLOR_SPLIT;
    [superview addSubview:split];
    split.size=CGSizeMake(width, SPLIT_HEIGHT);
    split.top=top;
    split.centerX=split.superview.width/2;
    return split;
}
    


#pragma mark 生成认证标记
+(nonnull UILabel*)genCertifiedLabel:(BOOL)certified{
    return [UIUtility genCertifiedLabelWithFont:[UIFont fontWithName:FONT_TEXT_SECONDARY.familyName size:FONT_TEXT_SECONDARY.pointSize*0.8] certified:certified];
}
+(nonnull UILabel*)genCertifiedLabelWithFont:(UIFont*)font certified:(BOOL)certified{
    //认证标记
    NSString* certifiedText=@"尚未认证";
    UIColor* certifiedColor=[UIColor orangeColor];
    if(certified){
        certifiedText=@"已认证";
        certifiedColor=UIColorFromRGB(0x439aa7);
    }
    UILabel* certifiedLabel=[[UILabel alloc]init];
    certifiedLabel.textAlignment=NSTextAlignmentCenter;
    certifiedLabel.text=certifiedText;
    certifiedLabel.textColor=certifiedColor;
    certifiedLabel.font=font ;
    certifiedLabel.layer.borderWidth=0.5;
    certifiedLabel.layer.borderColor=certifiedLabel.textColor.CGColor;
    certifiedLabel.layer.cornerRadius=3;
    [Utility fitLabel:certifiedLabel WithWidthPadding:certifiedLabel.font.pointSize/4 WithHeightPadding:certifiedLabel.font.pointSize/4];
    return certifiedLabel;
}

#pragma mark 显示图片输入选择

+(void)showImagePickerWithSourceType:(UIImagePickerControllerSourceType)sourceType fromViewController:(AController*)fromViewController returnKey:(NSString*)returnKey size:(CGSize)size{
    [[ImagePicker sharedImagePicker] showWithSourceType:sourceType fromViewController:fromViewController returnKey:returnKey size:size];
}

#pragma maek 生成图章类的Label
+(UILabel*)genStampLabelWithText:(NSString*)text color:(UIColor*)color font:(UIFont*)font{
    if(color==nil){
        color=[UIColor blackColor];
    }
    if(font==nil){
        font=FONT_TEXT_SECONDARY;
    }
    
    UILabel* ret=[[UILabel alloc]init];
    ret.textAlignment=NSTextAlignmentCenter;
    ret.text=text;
    ret.textColor=color;
    ret.font=font ;
    ret.layer.borderWidth=0.5;
    ret.layer.borderColor=ret.textColor.CGColor;
    ret.layer.cornerRadius=3;
    [Utility fitLabel:ret WithWidthPadding:ret.font.pointSize/4 WithHeightPadding:ret.font.pointSize/4];
    return ret;
}

@end
