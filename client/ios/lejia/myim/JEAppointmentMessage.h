//
//  JEAppointmentMessage.h
//  myim
//
//  Created by Sean Shi on 15/12/2.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import <RongIMKit/RongIMKit.h>

@interface JEAppointmentMessage : RCMessageContent

@property (nonatomic,retain) NSString* teacherid;
@property (nonatomic,retain) NSString* studentid;
@property (nonatomic,retain) NSString* courseDate;
@property (nonatomic,retain) NSString* courseid;

@property (nonatomic,retain) NSString* courseStarttime;
@property (nonatomic,retain) NSString* courseEndtime;

@property (nonatomic,assign) BOOL isCanceled;

@end

@interface JEAppointmentMessageCell : RCMessageCell
@end

@protocol JEAppointmentMessageCellDelegate <NSObject>

@required
@end

@interface JEAppointmentMessageCell()
@property (nonatomic,assign) NSString* currentTeacherid;
@property (nonatomic,assign) NSString* currentStudentid;
@property (nonatomic,retain) NSIndexPath* indexPath;
@property (nonatomic,retain) id<JEAppointmentMessageCellDelegate> appointmentDelegate;
@end
