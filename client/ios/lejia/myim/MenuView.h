//
//  MenuView.h
//  myim
//
//  Created by Sean Shi on 15/10/13.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MenuView : UIView
-(void)addItem:(nonnull NSString*)text target:(nullable id)target action:(nullable SEL)action;
-(void)replaceItemText:(nonnull NSString*)text atIndex:(NSInteger)index;
-(void)notifyUpdate;
-(void)reloadView;
@end

