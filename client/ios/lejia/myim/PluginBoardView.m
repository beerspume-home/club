//
//  PluginBoardView.m
//  myim
//
//  Created by Sean Shi on 15/10/14.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "PluginBoardView.h"

@implementation PluginBoardView
/**
 *  添加扩展项，在会话中，可以在viewdidload后，向RCPluginBoardView添加功能项
 *
 *  @param image 图片
 *  @param title 标题
 *  @param index 索引
 */
-(void)insertItemWithImage:(UIImage*)image title:(NSString*)title atIndex:(NSInteger)index{
    
}

/**
 *  点击事件
 *
 *  @param pluginBoardView 功能模板
 *  @param index           索引
 */
-(void)pluginBoardView:(RCPluginBoardView*)pluginBoardView clickedItemAtIndex:(NSInteger)index{
    
}
@end
