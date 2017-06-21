//
//  SelectDictDataVC.m
//  myim
//
//  Created by Sean Shi on 15/10/19.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "SelectDictDataVC.h"


@interface SelectDictDataVC (){
    HeaderView* _header;
    
    NSString* _title;
    NSString* _dictname;
    NSString* _type;
    NSArray* _originValue;
    
    NSArray<Dict*>* _dictdata;
    NSMutableArray<Dict*>* _selectedValue;
    NSMutableArray<UIView*>* _dictView;
    BOOL _mutilSelect;
    
    UIImage* checkedIcon;
    UIImage* uncheckedIcon;
    
    BOOL _localDict;
    
}
@end

@implementation SelectDictDataVC
- (void)viewDidLoad {
    [super viewDidLoad];
    if(_dictdata!=nil){
        _localDict=true;
    }
    _selectedValue=[Utility initArray:nil];
    _dictView=[Utility initArray:nil];
    if(_mutilSelect){
        checkedIcon=[[UIImage imageNamed:@"selectdict_多选_已选择"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        uncheckedIcon=[[UIImage imageNamed:@"selectdict_多选_未选择"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }else{
        checkedIcon=[[UIImage imageNamed:@"selectdict_选中圆点"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        uncheckedIcon=[[UIImage imageNamed:@"selectdict_未选中圆点"]imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    }
    [self reloadView];
}

-(void)viewWillAppear:(BOOL)animated{
    [super viewWillAppear:animated];
    if(!_localDict){
        __block LoadingView* loadingView=[LoadingView addDefaultLoadingToSuperview:self.view];
        [Remote dictWithName:_dictname callback:^(StorageCallbackData *callback_data) {
            if(callback_data.code==0){
                _dictdata=callback_data.data;
                [self reloadView];
            }else{
                [Utility showError:callback_data.message type:ErrorType_Network];
            }
            [loadingView removeFromSuperview];
        }];
    }
}
-(void)reloadView{
    [super reloadView];
    
    //初始化标题栏
    _header=[[HeaderView alloc]
             initWithTitle:_title
             leftButton:[HeaderView genItemWithType:HeaderItemType_Back target:self action:@selector(cancel:) height:HEIGHT_HEAD_ITEM_DEFAULT]
             rightButton:(_mutilSelect?[HeaderView genItemWithType:HeaderItemType_Ok target:self action:@selector(ok)]:nil)
             backgroundColor:COLOR_HEADER_BG
             titleColor:COLOR_HEADER_TEXT
             height:HEIGHT_HEAD_DEFAULT
             ];
    [self.view addSubview:_header];
    
    UIScrollView* scrollView=[[UIScrollView alloc]init];
    [self.view addSubview:scrollView];
    scrollView.origin=CGPointMake(0, _header.bottom+12);
    scrollView.size=CGSizeMake(scrollView.superview.width, scrollView.superview.height-scrollView.top);
    if(_dictdata!=nil){
        _dictView=[Utility initArray:nil];
        CGFloat y=0;
        for(int i=0;i<_dictdata.count;i++){
            //选择项
            UIImageView* selectIcon=[[UIImageView alloc]init];
            selectIcon.tintColor=UIColorFromRGB(0x004065);
            selectIcon.size=CGSizeMake(20, 20);
            UIView* itemView=[UIUtility genFeatureItemInSuperView:scrollView
                                             top:y
                                           title:_dictdata[i].desc
                                          height:FEATURE_NORMAL_HEIGHT
                                        rightObj:selectIcon
                                          target:self
                                          action:@selector(selectItem:)
                                       showSplit:(i==0?false:true)
             ];
            selectIcon.tagObject=_dictdata[i];
            [_dictView addObject:itemView];
            y=itemView.bottom;
            
            if(_originValue!=nil && ([_originValue containsObject:_dictdata[i]] || [_originValue containsObject:_dictdata[i].value])){
                [_selectedValue addObject:_dictdata[i]];
            }
        }
        scrollView.contentSize=CGSizeMake(scrollView.width, y+12);
        
    }
    [self refreshData];
}
-(void)selectItem:(UIGestureRecognizer*)sender{
    UIView* rightObj=sender.view.tagObject[@"rightObj"];
    Dict* dict=rightObj.tagObject;
    if(_mutilSelect){
        if([_selectedValue containsObject:dict]){
            [_selectedValue removeObject:dict];
        }else{
            [_selectedValue addObject:dict];
        }
    }else{
        [_selectedValue removeAllObjects];
        [_selectedValue addObject:dict];
    }
    
    [self refreshData];
    if(!_mutilSelect){
        runDelayInMain(^{
            [self ok];
        }, 0.2);
    }
}

-(void)refreshData{
    for(int i=0;i<_dictView.count;i++){
        UIView* rightObj=_dictView[i].tagObject[@"rightObj"];
        Dict* dict=rightObj.tagObject;
        BOOL checked=false;
        if([_selectedValue containsObject:dict]){
            checked=true;
        }
        if(checked){
            [UIUtility setFeatureItem:_dictView[i] image:checkedIcon];
        }else{
            [UIUtility setFeatureItem:_dictView[i] image:uncheckedIcon];
        }
    }
}

-(void)ok{
    if(_selectedValue!=nil && _selectedValue.count>0){
        NSComparator cmptr = ^(Dict* obj1, Dict* obj2){
            if(![obj1 isKindOfClass:[Dict class]] || ![obj2 isKindOfClass:[Dict class]]){
                return NSOrderedSame;
            }else{
                int v1=obj1.order.intValue;
                int v2=obj2.order.intValue;
                return v1>v2?NSOrderedDescending:(v1==v2?NSOrderedSame:NSOrderedAscending);
            }
        };
        
        NSArray* returnValue=[_selectedValue sortedArrayUsingComparator:cmptr];
        if(self.delegate!=nil){
            [self.delegate selectDictData:self valueDidChanged:returnValue inDataList:_dictdata];
        }
        
        [self gotoBackWithParamaters:@{
                                       PAGE_PARAM_RETURN_VALUE:@{
                                               PAGE_PARAM_TYPE:_type,
                                               PAGE_PARAM_RETURN_VALUE:returnValue,
                                               },
                                       }];
    }else{
        [Utility showError:@"请选择" type:ErrorType_Business];
    }
}

-(void)cancel:(UIGestureRecognizer*)sender{
    BOOL canCancel=true;
    if(_delegate!=nil){
        @try {
            canCancel=[_delegate selectDictDataCancel:self];
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
    }else if([PAGE_PARAM_DICTNAME isEqualToString:key]){
        _dictname=value;
    }else if([PAGE_PARAM_TYPE isEqualToString:key]){
        _type=value;
    }else if([PAGE_PARAM_ORIGIN_VALUE isEqualToString:key]){
        _originValue=value;
    }else if([PAGE_PARAM_MUTILSELECT isEqualToString:key]){
        _mutilSelect=true;
    }else if([PAGE_PARAM_DATA isEqualToString:key]){
        _dictdata=value;
    }else if([PAGE_PARAM_DELEGATE isEqualToString:key]){
        _delegate=value;
    }
}
@end