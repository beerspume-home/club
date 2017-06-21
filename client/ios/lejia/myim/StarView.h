//
//  StarView.h
//  myim
//
//  Created by Sean Shi on 15/12/6.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface StarView : UIView
@end

@protocol StarViewDelegate <NSObject>
@optional
-(void)starView:(StarView*)starView didChangeValue:(float)value;
@end

@interface StarView()

@property (nonatomic,assign) float value;
@property (nonatomic,assign) NSUInteger maxvalue;
@property (nonatomic,assign) CGFloat iconSize;
@property (nonatomic,assign) CGFloat iconPadding;
@property (nonatomic,assign) BOOL editable;
@property (nonatomic,retain) id<StarViewDelegate> delegate;

-(void)reloadView;
@end
