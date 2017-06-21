//
//  SelectDictDataVC.h
//  myim
//
//  Created by Sean Shi on 15/10/30.
//  Copyright © 2015年 车友会. All rights reserved.
//


@interface SelectDictDataVC : AController

@end


@protocol SelectDictDataDelegate <NSObject>

@required

-(void)selectDictData:(SelectDictDataVC*)selectDictDataVC valueDidChanged:(NSArray<Dict*>*)value inDataList:(NSArray<Dict*>*)dataList;

@optional
-(BOOL)selectDictDataCancel:(SelectDictDataVC*)selectDictDataVC;

@end

@interface SelectDictDataVC ()
@property (nonatomic,retain) id<SelectDictDataDelegate> delegate;
@end

