//
//  OperationEditSchoolInfoPictureVC.m
//  myim
//
//  Created by Sean Shi on 15/11/14.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "OperationEditSchoolInfoPictureVC.h"

#define PADDING 5
//添加按钮Cell
@interface AddCell : UICollectionViewCell
@end
@protocol AddCellDelegate <NSObject>
@required
-(void)addCellClicked:(AddCell*)cell;
@end
@interface AddCell(){
    UIImageView* _imageView;
    BOOL _inited;
}

@property (nonatomic,retain) id<AddCellDelegate> delegate;

@end
@implementation AddCell

-(void)addClick{
    if(_delegate!=nil){
        [_delegate addCellClicked:self];
    }
}
-(void)initView{
    if(_imageView==nil){
        _imageView=[[UIImageView alloc]init];
        [self.contentView addSubview:_imageView];
        _imageView.image=[[UIImage imageNamed:@"添加_icon"] imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
        _imageView.tintColor=[UIColor redColor];
        _imageView.backgroundColor=[UIColor whiteColor];
        _imageView.userInteractionEnabled=true;
        [_imageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(addClick)]];
    }
    
    if(!_inited){
        self.contentView.backgroundColor=[UIColor whiteColor];
        self.contentView.layer.borderColor=COLOR_SPLIT.CGColor;
        self.contentView.layer.borderWidth=0.5;
        self.contentView.layer.cornerRadius=3;
        self.contentView.layer.shadowColor=[UIColor blackColor].CGColor;
        self.contentView.layer.shadowOpacity=0.2;
        self.contentView.layer.shadowRadius=1;
        self.contentView.layer.shadowOffset=CGSizeMake(0, 0.5);
        _inited=true;
    }

}
-(void)layoutSubviews{
    [super layoutSubviews];
    [self initView];
    CGFloat iconWidth=_imageView.superview.height*0.6;
    CGSize iconSize={iconWidth,iconWidth};
    _imageView.size=iconSize;
    _imageView.center=_imageView.superview.innerCenterPoint;
    
}

@end

//显示照片Cell
@interface PictureCell : UICollectionViewCell
@end

@protocol PictureCellDelegate <NSObject>

@required
-(void)pictureCell:(PictureCell*)cell showPicture:(UIImage*)image;
-(void)pictureCell:(PictureCell*)cell delWithIndex:(NSInteger)index;

@end

@interface PictureCell(){
    UIImageView* _imageView;
    UIImageView* _delButton;
    BOOL _inited;
}

@property (nonatomic,retain) NSString* imageurl;
@property (nonatomic,retain) UIImage* image;
@property (nonatomic,retain) id<PictureCellDelegate> delegate;
@property (nonatomic,assign) NSInteger index;

-(UIImage*)getImage;
@end
@implementation PictureCell

-(UIImage*)getImage{
    if(_imageView!=nil){
        return _imageView.image;
    }else{
        return nil;
    }
}
-(void)showPicture{
    if(_delegate!=nil){
        [_delegate pictureCell:self showPicture:_imageView==nil?nil:_imageView.image];
    }
}
-(void)delPicture{
    if(_delegate!=nil){
        [_delegate pictureCell:self delWithIndex:_index];
    }
}
-(void)initView{
    if(_imageView==nil){
        _imageView=[[UIImageView alloc]init];
        [self.contentView addSubview:_imageView];
        _imageView.contentMode=UIViewContentModeScaleAspectFit;
        _imageView.userInteractionEnabled=true;
        [_imageView addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(showPicture)]];
    }
    if(_delButton==nil){
        _delButton=[[UIImageView alloc]init];
        _delButton.image=[UIImage imageNamed:@"删除_红_icon"];
        _delButton.size=CGSizeMake(15, 15);
        [self.contentView addSubview:_delButton];
        _delButton.userInteractionEnabled=true;
        [_delButton addGestureRecognizer:[[UITapGestureRecognizer alloc]initWithTarget:self action:@selector(delPicture)]];
        
    }
    
    if(!_inited){
        self.contentView.backgroundColor=[UIColor whiteColor];
        self.contentView.layer.borderColor=COLOR_SPLIT.CGColor;
        self.contentView.layer.borderWidth=0.5;
        self.contentView.layer.cornerRadius=3;
        self.contentView.layer.shadowColor=[UIColor blackColor].CGColor;
        self.contentView.layer.shadowOpacity=0.2;
        self.contentView.layer.shadowRadius=1;
        self.contentView.layer.shadowOffset=CGSizeMake(0, 0.5);
        _inited=true;
    }

}
-(void)setImageurl:(NSString *)imageurl{
    [self initView];
    _image=nil;
    _imageurl=imageurl;
    [_imageView sd_setImageWithURL:[NSURL URLWithString:_imageurl] placeholderImage:[UIImage imageNamed:@"无图片"]];
    [self setNeedsLayout];
}
-(void)setImage:(UIImage *)image{
    [self initView];
    _imageurl=nil;
    _image=image;
    _imageView.image=_image;
    [self setNeedsLayout];
}
-(void)layoutSubviews{
    [super layoutSubviews];
    [self initView];
    _imageView.origin=CGPointMake(0, 0);
    _imageView.size=_imageView.superview.size;
    _delButton.top=0;
    _delButton.right=_delButton.superview.width;
    
}

@end

@interface OperationEditSchoolInfoPictureVC ()<UICollectionViewDelegate,UICollectionViewDataSource,PictureCellDelegate,AddCellDelegate>{
    NSString* _schoolid;
    School* _school;
    
    HeaderView* _headView;
    UICollectionView* _collectionView;
    
    
    NSInteger _numPerLine;
    CGFloat _lastScale;
    
    NSMutableArray* _images;
}

@end

@implementation OperationEditSchoolInfoPictureVC

- (void)viewDidLoad {
    [super viewDidLoad];
    _numPerLine=3;
    _lastScale=1;
    _images=[Utility initArray:nil];
    [self reloadView];
    [self reloadRemoteData];
}

-(void)viewWillDisappear:(BOOL)animated{
}

-(void)reloadRemoteData{
    __block LoadingView* lv=[LoadingView addDefaultLoadingToSuperview:self.view];
    [Remote school:_schoolid callback:^(StorageCallbackData *callback_data) {
        if(callback_data.code==0){
            _school=callback_data.data;
            _images=[NSMutableArray arrayWithArray:_school.pictures];
            [self refreshData];
        }else{
            [Utility showError:callback_data.message type:ErrorType_Network];
        }
        [lv removeFromSuperview];
    }];
}

-(void)refreshData{
    [_collectionView reloadData];
}

-(void)reloadView{
    [super reloadView];
    
    _headView=[[HeaderView alloc]initWithTitle:@"驾校一景"
                                    leftButton:[HeaderView genItemWithType:HeaderItemType_Back target:self action:@selector(gotoBack)]
                                   rightButton:[HeaderView genItemWithText:@"保存" target:self action:@selector(save:)]
               ];
    [self.view addSubview:_headView];
    
    UICollectionViewFlowLayout *flowLayout=[[UICollectionViewFlowLayout alloc] init];
    [flowLayout setScrollDirection:UICollectionViewScrollDirectionVertical];
    _collectionView=[[UICollectionView alloc]initWithFrame:CGRectMake(0, _headView.bottom, self.view.width, self.view.height-_headView.bottom) collectionViewLayout:flowLayout];
    [_collectionView registerClass:[PictureCell class] forCellWithReuseIdentifier:@"picture_cell"];
    [_collectionView registerClass:[AddCell class] forCellWithReuseIdentifier:@"add_cell"];
    _collectionView.delegate=self;
    _collectionView.dataSource=self;
    _collectionView.backgroundColor=[UIColor whiteColor];
    [self.view addSubview:_collectionView];
    
    [self.view addGestureRecognizer:[[UIPinchGestureRecognizer alloc]initWithTarget:self action:@selector(pinch:)]];

}

- (NSInteger)collectionView:(UICollectionView *)collectionView numberOfItemsInSection:(NSInteger)section{
    if(_images==nil){
        _images=[Utility initArray:nil];
        return 1;
    }else{
        return _images.count+1;
    }
}
- (UICollectionViewCell *)collectionView:(UICollectionView *)collectionView cellForItemAtIndexPath:(NSIndexPath *)indexPath{
    NSInteger index=indexPath.row;
    if(index<_images.count){
        NSString* cellname=@"picture_cell";
        PictureCell* cell=[collectionView dequeueReusableCellWithReuseIdentifier:cellname forIndexPath:indexPath];
        cell.delegate=self;
        id picture=_images[index];
        if([picture isKindOfClass:[NSString class]]){
            cell.imageurl=picture;
        }else if([picture isKindOfClass:[UIImage class]]){
            cell.image=picture;
        }
        cell.index=index;
        return cell;
    }else{
        NSString* cellname=@"add_cell";
        AddCell* cell=[collectionView dequeueReusableCellWithReuseIdentifier:cellname forIndexPath:indexPath];
        cell.delegate=self;
        return cell;
    }
}

//设置元素的的大小框
-(UIEdgeInsets)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout insetForSectionAtIndex:(NSInteger)section
{
    UIEdgeInsets top={PADDING,PADDING,PADDING,PADDING};
    return top;
}
//设置顶部的大小
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout referenceSizeForHeaderInSection:(NSInteger)section{
    CGSize size={0,0};
    return size;
}
//设置元素大小
-(CGSize)collectionView:(UICollectionView *)collectionView layout:(UICollectionViewLayout *)collectionViewLayout sizeForItemAtIndexPath:(NSIndexPath *)indexPath{
    CGFloat w=collectionView.superview.width/_numPerLine-(2*PADDING);
    CGSize size={w,w};
    return size;
}

-(void)pictureCell:(PictureCell *)pictureCell showPicture:(UIImage *)image{
    [self gotoPageWithClass:[ShowImageVC class] parameters:@{
                                                             PAGE_PARAM_IMAGE:image,
                                                             }];
}
-(void)pictureCell:(PictureCell *)cell delWithIndex:(NSInteger)index{
    if(index>=0 && index<_images.count){
        [_images removeObjectAtIndex:index];
        [self refreshData];
    }
}
-(void)addCellClicked:(AddCell *)cell{
    [UIUtility showImagePickerWithSourceType:99 fromViewController:self returnKey:@"pickphoto" size:CGSizeMake(450,300)];
    
}

-(void)pinch:(UIPinchGestureRecognizer*)sender{
    BOOL change=false;
    CGFloat scale=sender.scale-_lastScale;
    CGFloat a=0.3;
    if(scale>a){
        _numPerLine--;
        change=true;
    }else if(scale<-a){
        _numPerLine++;
        change=true;
    }
    if(change){
        _lastScale=sender.scale;
        _numPerLine=_numPerLine>5?5:(_numPerLine<2?2:_numPerLine);
        [self refreshData];
    }
    
    if(sender.state==UIGestureRecognizerStateEnded){
        _lastScale=1;
    }
}


-(void)save:(UIGestureRecognizer*)sender{
    NSMutableArray* cells=[NSMutableArray arrayWithArray: _collectionView.visibleCells];
    
    [cells sortUsingComparator:^NSComparisonResult(id  _Nonnull obj1, id  _Nonnull obj2) {
        NSComparisonResult ret =NSOrderedSame;
        if(![obj1 isKindOfClass:[PictureCell class]] && ![obj2 isKindOfClass:[PictureCell class]]){
            ret = NSOrderedSame;
        }else if([obj1 isKindOfClass:[PictureCell class]] && ![obj2 isKindOfClass:[PictureCell class]]){
            ret = NSOrderedAscending;
        }else if(![obj1 isKindOfClass:[PictureCell class]] && [obj2 isKindOfClass:[PictureCell class]]){
            ret = NSOrderedDescending;
        }else{
            int v1=((PictureCell*)obj1).index;
            int v2=((PictureCell*)obj2).index;
            ret = v1>v2?NSOrderedDescending:(v1==v2?NSOrderedSame:NSOrderedAscending);
        }
        return ret;
    }];
    
    NSMutableArray<UIImage*>* imageArray=[Utility initArray:nil];
    for(int i=0;i<cells.count;i++){
        PictureCell* cell=cells[i];
        if([cell isKindOfClass:[PictureCell class]]){
            UIImage* image=[cell getImage];
            if(image!=nil){
                [imageArray addObject:image];
            }
        }
    }
    if(imageArray.count>0){
        __block LoadingView* lv=[LoadingView addDefaultLoadingToSuperview:self.view];
        [Remote updateSchoolPictures:_schoolid pics:imageArray callback:^(StorageCallbackData *callback_data) {
            if(callback_data.code==0){
                [Utility showMessage:@"照片已保存"];
                [self gotoBack];
            }else{
                [Utility showError:callback_data.message type:ErrorType_Network];
            }
            [lv removeFromSuperview];
        }];
    }
}

-(void)putValue:(id)value byKey:(NSString *)key{
    if([PAGE_PARAM_SCHOOL_ID isEqualToString:key]){
        _schoolid=value;
    }else if([@"pickphoto" isEqualToString:key]){
        UIImage* image=value;
        [_images addObject:image];
        [self refreshData];
    }
}

@end
