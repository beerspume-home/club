//
//  TATeacherRecordCell.h
//  myim
//
//  Created by Sean Shi on 15/12/10.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TATeacherRecordCell : UITableViewCell

@end

@protocol TATeacherRecordCellDelegate <NSObject>

@required

@end

@interface TATeacherRecordCell()
@property (nonatomic,retain) CourseAppointment* appointment;
@property (nonatomic,retain) id<TATeacherRecordCellDelegate> delegate;

+(CGFloat)calcLayoutHeightWithAppointment:(CourseAppointment*)appointment andMaxWidth:(CGFloat)maxWidth;
@end