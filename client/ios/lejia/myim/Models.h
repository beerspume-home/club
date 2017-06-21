//
//  Models.h
//  myim
//
//  Created by Sean Shi on 15/10/17.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "BaseModels.h"

@interface Area : BaseObject
@property (nonatomic,retain)NSString* level;
@property (nonatomic,retain)NSString* parent;
@property (nonatomic,retain)NSString* name;
@property (nonatomic,retain)NSString* postcode;
@property (nonatomic,retain)NSString* namepath;
@property (nonatomic,retain)NSArray<Area*>* subarea;
@end


@interface Social : BaseObject
@property (nonatomic,retain)NSString* person;
@property (nonatomic,retain)NSString* nickname;
@property (nonatomic,retain)NSString* introduction;
-(UIImage*) getHeaderImage;
-(void) setHeaderImage:(UIImage*)image;
@end

@interface Person : BaseObject
@property (nonatomic,retain)NSString* phone;
@property (nonatomic,retain)NSString* username;
@property (nonatomic,retain)NSString* email;
@property (nonatomic,retain)NSString* name;
@property (nonatomic,retain)NSString* idcard;
@property (nonatomic,retain)NSString* gender;
@property (nonatomic,retain)NSString* profession;
@property (nonatomic,retain)Social* social;
@property (nonatomic,retain)Area* area;
@property (nonatomic,retain)NSString* imageurl;
@property (nonatomic,retain)NSString* originimageurl;
@property (nonatomic,retain)NSString* character_type;
@property (nonatomic,retain)NSString* school_name;
@property (nonatomic,retain)NSString* school_id;
@property (nonatomic,retain)NSArray<NSString*>* interestschool;
@property (nonatomic,retain)NSString* certified;
@property (nonatomic,readonly)NSString* socialname;

@property (nonatomic,readonly)NSString* socialname_firstletter;
@property (nonatomic,readonly)NSString* nickname_firstletter;
@property (nonatomic,readonly)NSString* name_firstletter;

-(BOOL)isCertified;
-(BOOL)isMale;
-(UIImage*) genQRCodeWithSize:(CGFloat)size;
-(BOOL)isTeacher;
-(BOOL)isStudent;
-(BOOL)isCustomerService;
-(BOOL)isOperation;
-(BOOL)isStaff;
@end


@interface ChatGroupMember : BaseObject
@property (nonatomic,retain)Person* person;
@property (nonatomic,assign)BOOL isowner;
@property (nonatomic,retain)NSString* name;
@end

@interface ChatGroup : BaseObject
@property (nonatomic,retain)NSString* name;
@property (nonatomic,retain)NSMutableArray<ChatGroupMember*>* members;
@property (nonatomic,retain)NSString* imageurl;
@end

@interface SchoolClass : BaseObject
@property (nonatomic,retain)NSString* name;
@property (nonatomic,retain)NSString* cartype;
@property (nonatomic,retain)NSString* licensetype;
@property (nonatomic,retain)NSString* trainingtime;
@property (nonatomic,retain)NSString* status;
@property (nonatomic,retain)NSString* fee;
@property (nonatomic,retain)NSString* realfee;
@property (nonatomic,retain)NSString* expiredate;
@property (nonatomic,retain)NSString* remark;
@end


@interface School : BaseObject
@property (nonatomic,retain)NSString* name;
@property (nonatomic,retain)NSString* certified;
@property (nonatomic,retain)NSString* postcode;
@property (nonatomic,retain)NSString* otherarea;
@property (nonatomic,retain)NSString* introduction;
@property (nonatomic,retain)Area* area;
@property (nonatomic,retain)NSString* imageurl;
@property (nonatomic,retain)NSString* mppageurl;
@property (nonatomic,retain)NSArray<NSString*>* pictures;
@property (nonatomic,retain)NSArray<SchoolClass*>* classes;

-(BOOL)isCertified;
@end

@interface Student : BaseObject
@property (nonatomic,retain)Person* person;
@property (nonatomic,retain)School* school;
@property (nonatomic,retain)NSString* certified;
@property (nonatomic,retain)NSString* status;
@property (nonatomic,retain)NSString* km1score;
@property (nonatomic,retain)NSString* km2score;
@property (nonatomic,retain)NSString* km3ascore;
@property (nonatomic,retain)NSString* km3bscore;
@property (nonatomic,retain)NSString* signupdate;
@property (nonatomic,retain)NSString* licencedate;
@property (nonatomic,retain)NSString* createdate;
-(BOOL)isCertified;
@end

@interface Teacher : BaseObject
@property (nonatomic,retain)Person* person;
@property (nonatomic,retain)School* school;
@property (nonatomic,retain)NSMutableArray* skill;
@property (nonatomic,retain)NSString* certified;
@property (nonatomic,retain)NSString* status;
@property (nonatomic,retain)NSString* createdate;
-(BOOL)isCertified;
@end

@interface CustomerService : BaseObject
@property (nonatomic,retain)Person* person;
@property (nonatomic,retain)School* school;
@property (nonatomic,retain)NSString* name;
@property (nonatomic,retain)NSString* certified;
@property (nonatomic,retain)NSString* status;
@property (nonatomic,retain)NSString* createdate;
-(BOOL)isCertified;
@end

@interface Operation : BaseObject
@property (nonatomic,retain)Person* person;
@property (nonatomic,retain)School* school;
@property (nonatomic,retain)NSString* name;
@property (nonatomic,retain)NSString* certified;
@property (nonatomic,retain)NSString* status;
@property (nonatomic,retain)NSString* createdate;
-(BOOL)isCertified;
@end


//字典数据
@interface Dict : BaseObject
@property (nonatomic,retain)NSString* name;
@property (nonatomic,retain)NSString* value;
@property (nonatomic,retain)NSString* desc;
@property (nonatomic,retain)NSString* order;
@end


@interface OperationCertificateItem : BaseObject
@property (nonatomic,retain) NSString* name;
@property (nonatomic,retain) NSString* value;
@property (nonatomic,retain) NSString* imageurl;
@property (nonatomic,retain) NSString* desc;
@property (nonatomic,retain) NSString* order;
@end


@interface SchoolSignup : BaseObject
@property (nonatomic,retain) NSString* createdate;
@property (nonatomic,retain) NSString* modifydate;
@property (nonatomic,retain) Person* person;
@property (nonatomic,retain) School* school;
@property (nonatomic,retain) SchoolClass* schoolclass;
@property (nonatomic,retain) NSString* name;
@property (nonatomic,retain) NSString* phone;
@property (nonatomic,retain) NSString* gender;
@property (nonatomic,retain) NSString* age;
@property (nonatomic,retain) NSString* address;
@property (nonatomic,retain) NSString* remark;
@property (nonatomic,retain) NSString* status;
-(BOOL)isMale;
-(BOOL)isNew;
-(BOOL)isSignup;
-(BOOL)isAbandon;
@end

@interface Course : BaseObject
@end

@interface CourseTimeTable : BaseObject
@property (nonatomic,retain) Teacher* teacher;
@property (nonatomic,retain) NSString* name;
@property (nonatomic,retain) NSString* enabled;
@property (nonatomic,retain) NSString* publishdate;
@property (nonatomic,retain) NSString* expiredate;
@property (nonatomic,retain) NSMutableArray<Course*>* course;

-(BOOL)isEnabled;
@end

@interface Course()
@property (nonatomic,retain) NSString* timetable;
@property (nonatomic,retain) NSString* weekday;
@property (nonatomic,retain) NSString* starttime;
@property (nonatomic,retain) NSString* endtime;
@property (nonatomic,retain) NSString* course;
@property (nonatomic,readonly) NSString* courseDisplay;
@property (nonatomic,retain) NSString* studentnum;
@property (nonatomic,retain) NSString* appointmentcount;
@property (nonatomic,retain) NSString* remark;
@property (nonatomic,assign) BOOL deleted;
@property (nonatomic,assign) BOOL changed;
@end

@interface CourseAppointmentEvaluation : BaseObject
@end

@interface CourseAppointment : BaseObject
@property (nonatomic,retain) NSString* date;
@property (nonatomic,retain) Course* course;
@property (nonatomic,retain) Student* student;
@property (nonatomic,retain) Teacher* teacher;
@property (nonatomic,retain) NSString* deleted;
@property (nonatomic,retain) NSString* expired;
@property (nonatomic,retain) NSString* studentremark;
@property (nonatomic,retain) CourseAppointmentEvaluation* studentevaluation;
@property (nonatomic,retain) CourseAppointmentEvaluation* teacherevaluation;

-(BOOL)isDeleted;
-(BOOL)isExpired;
@end


@interface CourseAppointmentEvaluation()
@property (nonatomic,retain) NSString* createdate;
@property (nonatomic,retain) NSString* modifydate;
@property (nonatomic,retain) NSString* who;
@property (nonatomic,retain) NSString* appointment;
@property (nonatomic,retain) NSString* evaluation;
@property (nonatomic,retain) NSNumber* star1;
@property (nonatomic,retain) NSNumber* star2;
@property (nonatomic,retain) NSNumber* star3;
@property (nonatomic,retain) NSNumber* star4;
@property (nonatomic,retain) NSNumber* star5;
@property (nonatomic,retain) NSNumber* star6;
@property (nonatomic,retain) NSNumber* star7;
@property (nonatomic,retain) NSNumber* star8;
@property (nonatomic,retain) NSNumber* star9;
@property (nonatomic,retain) NSNumber* averagestar;
@end