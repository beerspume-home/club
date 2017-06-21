//
//  TAStudentRecordCell.h
//  myim
//
//  Created by Sean Shi on 15/12/10.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface TAStudentRecordCell : UITableViewCell

@end

@protocol TAStudentRecordCellDelegate <NSObject>

@required

@end

@interface TAStudentRecordCell()
@property (nonatomic,retain) CourseAppointment* appointment;
@property (nonatomic,retain) id<TAStudentRecordCellDelegate> delegate;

+(CGFloat)calcLayoutHeightWithAppointment:(CourseAppointment*)appointment andMaxWidth:(CGFloat)maxWidth;
@end