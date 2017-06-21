//
//  Models.m
//  myim
//
//  Created by Sean Shi on 15/10/17.
//  Copyright © 2015年 车友会. All rights reserved.
//

#import "Models.h"
#import <qrencode.h>
#import "Cache.h"
#import "AreaManager.h"

@interface Person(){
    NSString* _socialname_firstletter;
    NSString* _nickname_firstletter;
    NSString* _name_firstletter;
}
@end

@implementation Person
+(instancetype) initWithDictionary:(NSDictionary*)data{
    Person* ret=[super initWithDictionary:data];
    [Cache putInCache:@[ret]];
    return ret;
}
-(NSString*)socialname{
    if([self isStaff]){
        return self.name;
    }else{
        return self.social.nickname;
    }
}

-(BOOL)isStaff{
    return ([self isTeacher] || [self isCustomerService] || [self isOperation]);
}
-(Social*)social{
    if(_social==nil){
        _social=[[Social alloc]init];
        _social.person=self.id;
        _social.nickname=@"";
        _social.introduction=@"";
    }else if([_social isKindOfClass:[NSDictionary class]]){
        _social=[Social initWithDictionary:(NSDictionary*)_social];
    }
    return _social;
}

-(Area*)area{
    if([_area isKindOfClass:[NSDictionary class]]){
        _area=[Area initWithDictionary:(NSDictionary*)_area];
    }
    return _area;
}

-(NSString*)phone{
    if(_phone==nil){
        _phone=@"";
    }
    return _phone;
}
-(NSString*)username{
    if(_username==nil){
        _username=@"";
    }
    return _username;
}
-(NSString*)email{
    if(_email==nil){
        _email=@"";
    }
    return _email;
}
-(NSString*)name{
    if(_name==nil){
        _name=@"";
    }
    return _name;
}
-(NSString*)idcard{
    if(_idcard==nil){
        _idcard=@"";
    }
    return _idcard;
}
-(NSString*)gender{
    if(_gender==nil){
        _gender=@"1";
    }
    return _gender;
}

-(NSString*)profession{
    if(_profession==nil){
        _profession=@"";
    }
    return _profession;
}

-(NSString*)character_type{
    if(_character_type==nil){
        _character_type=@"";
    }
    return _character_type;
}

-(NSString*)school_name{
    if(_school_name==nil){
        _school_name=@"";
    }
    return _school_name;
}

-(NSString*)school_id{
    if(_school_id==nil){
        _school_id=@"";
    }
    return _school_id;
}

-(NSArray<NSString*>*)interestschool{
    if(_interestschool==nil){
        _interestschool=[Utility initArray:nil];
    }
    return _interestschool;
}

-(NSString*)socialname_firstletter{
    if(_socialname_firstletter==nil){
        _socialname_firstletter=[Utility firstLatinLetter:self.socialname];
    }
    return _socialname_firstletter;
}
-(NSString*)nickname_firstletter{
    if(_nickname_firstletter==nil){
        _nickname_firstletter=[Utility firstLatinLetter:self.social.nickname];
    }
    return _nickname_firstletter;
}
-(NSString*)name_firstletter{
    if(_name_firstletter==nil){
        _name_firstletter=[Utility firstLatinLetter:_name];
    }
    return _name_firstletter;
}

-(NSString*)certified{
    if(_certified==nil){
        _certified=@"";
    }else if(![_certified isKindOfClass:[NSString class]]){
        _certified=[NSString stringWithFormat:@"%@",_certified];
    }
    
    return _certified;
}

-(BOOL)isCertified{
    BOOL a=[@"1" isEqualToString:self.certified];
    return a;
}

-(BOOL)isMale{
    return [Utility isMale:_gender];
}
-(UIImage*)genQRCodeWithSize:(CGFloat)size{
    UIImage* ret=nil;
     const char* _Nullable codeString=[NSString stringWithFormat:@"{\"type\":\"person\",\"id\":%@}",self.id].UTF8String;
    QRcode* code=QRcode_encodeString(codeString, 0, QR_ECLEVEL_H, QR_MODE_8, 1);
    if(code){
        // create context
        CGColorSpaceRef colorSpace =CGColorSpaceCreateDeviceRGB();
        CGContextRef ctx =CGBitmapContextCreate(0, size, size, 8, size * 4, colorSpace,kCGImageAlphaPremultipliedLast);
        
        CGAffineTransform translateTransform =CGAffineTransformMakeTranslation(0, -size);
        CGAffineTransform scaleTransform =CGAffineTransformMakeScale(1, -1);
        CGContextConcatCTM(ctx,CGAffineTransformConcat(translateTransform, scaleTransform));
        
        CGFloat qrMargin=0.0;
        unsigned char* data= code->data;
        float zoom = (double)size / (code->width + 2.0 * qrMargin);
        CGRect rectDraw =CGRectMake(0, 0, zoom, zoom);
        CGContextSetFillColor(ctx,CGColorGetComponents([UIColor blackColor].CGColor));
        for(int i = 0; i < code->width; ++i) {
            for(int j = 0; j < code->width; ++j) {
                if(*data & 1) {
                    rectDraw.origin =CGPointMake((j + qrMargin) * zoom,(i +qrMargin) * zoom);
                    CGContextAddRect(ctx, rectDraw);
                }
                ++data;
            }
        }
        CGContextFillPath(ctx);
        
        // get image
        CGImageRef qrCGImage =CGBitmapContextCreateImage(ctx);
        ret=[UIImage imageWithCGImage:qrCGImage];
        
        // some releases
        CGContextRelease(ctx);
        CGImageRelease(qrCGImage);
        CGColorSpaceRelease(colorSpace);
        QRcode_free(code);
    }
    return ret;
}

-(BOOL)isTeacher{
    return [@"teacher" isEqualToString:self.character_type];
}
-(BOOL)isStudent{
    return [@"student" isEqualToString:self.character_type];
}
-(BOOL)isCustomerService{
    return [@"customerservice" isEqualToString:self.character_type];
}

-(BOOL)isOperation{
    return [@"operation" isEqualToString:self.character_type];
}

@end


@implementation Social
+(instancetype) initWithDictionary:(NSDictionary*)data{
    Social* ret=[super initWithDictionary:data];
    [Cache putInCache:@[ret]];
    return ret;
}

-(NSString*)person{
    if(_person!=nil && ![_person isKindOfClass:[NSString class]]){
        _person=[Utility convertToString:_person];
    }
    return _person;
}

-(NSString*)nickname{
    if(_nickname==nil){
        _nickname=@"";
    }
    return _nickname;
}
-(NSString*)introduction{
    if(_introduction==nil){
        _introduction=@"";
    }
    return _introduction;
}



-(UIImage*) getHeaderImage{
    return [Storage getUserImage];
}
-(void) setHeaderImage:(UIImage*)image{
    [Storage setUserImage:image];
}


@end


@implementation Area

-(NSString*)level{
    if(_level!=nil && ![_level isKindOfClass:[NSString class]]){
        _level=[Utility convertToString:_level];
    }
    return _level;
}

-(NSString*)parent{
    if(_parent!=nil && ![_parent isKindOfClass:[NSString class]]){
        _parent=[Utility convertToString:_parent];
    }
    return _parent;
}

-(NSString*)name{
    if(_name==nil){
        _name=@"";
    }
    return _name;
}

-(NSString*)postcode{
    if(_postcode==nil){
        _postcode=@"";
    }
    return _postcode;
}
-(NSString*)namepath{
    if(_namepath==nil){
        _namepath=@"";
    }
    return _namepath;
}

-(NSArray<Area*>*)subarea{
    if(_subarea==nil || ![_subarea isKindOfClass:[NSArray class]]){
        _subarea=[AreaManager getSubArea:self];
    }else{
        if(![_subarea isKindOfClass:[NSMutableArray class]]){
            _subarea=[NSMutableArray arrayWithArray:_subarea];
        }
        for(int i=0;i<_subarea.count;i++) {
            if([_subarea[i] isKindOfClass:[NSDictionary class]]){
                ((NSMutableArray*)_subarea)[i]=[Area initWithDictionary:(NSDictionary*)_subarea[i]];
            }
            if(![_subarea[i] isKindOfClass:[Area class]]){
                ((NSMutableArray*)_subarea)[i]=[[Area alloc]init];
            }
        }
    }
    return _subarea;
}

@end

@implementation ChatGroupMember
-(Person*)person{
    if(_person==nil){
        _person=[[Person alloc]init];
    }else if([_person isKindOfClass:[NSDictionary class]]){
        _person=[Person initWithDictionary:(NSDictionary*)_person];
    }
    return _person;
}
-(NSString*)name{
    if(_name==nil){
        return self.person.social.nickname;
    }
    return _name;
}


@end

@implementation ChatGroup
+(instancetype) initWithDictionary:(NSDictionary*)data{
    ChatGroup* ret=[super initWithDictionary:data];
    [Cache putInCache:@[ret]];
    return ret;
}

-(NSMutableArray<ChatGroupMember*>*)members{
    if(_members==nil){
        _members=[Utility initArray:nil];
    }else{
        for(int i=0;i<_members.count;i++){
            if([_members[i] isKindOfClass:[NSDictionary class]]){
                _members[i]=[ChatGroupMember initWithDictionary:(NSDictionary*)_members[i]];
            }
        }
    }
    return _members;
}

-(NSString*)name{
    if(_name==nil){
        _name=@"未命名";
    }
    return _name;
}


@end



@implementation School

-(NSString*) name{
    if(_name==nil){
        _name=@"";
    }
    return _name;
}
-(NSString*) certified{
    if(_certified==nil){
        _certified=@"";
    }else if(![_certified isKindOfClass:[NSString class]]){
        _certified=[NSString stringWithFormat:@"%@",_certified];
    }
    return _certified;
}
-(NSString*) postcode{
    if(_postcode==nil){
        _postcode=@"";
    }
    return _postcode;
}
-(NSString*) otherarea{
    if(_otherarea==nil){
        _otherarea=@"";
    }
    return _otherarea;
}

-(NSString*) introduction{
    if(_introduction==nil){
        _introduction=@"";
    }
    return _introduction;
}

-(NSString*) imageurl{
    if(_imageurl==nil){
        _imageurl=@"";
    }
    return _imageurl;
}
-(NSString*) mppageurl{
    if(_mppageurl==nil){
        _mppageurl=@"";
    }
    return _mppageurl;
}

-(NSArray<NSString*>*)pictures{
    if(_pictures==nil){
        _pictures=[Utility initArray:nil];
    }
    return _pictures;
}
-(NSArray<SchoolClass*>*)classes{
    if(_classes==nil || ![_classes isKindOfClass:[NSArray class]]){
        _classes=[Utility initArray:nil];
    }else{
        if(![_classes isKindOfClass:[NSMutableArray class]]){
            _classes=[NSMutableArray arrayWithArray:_classes];
        }
        for(int i=0;i<_classes.count;i++) {
            if([_classes[i] isKindOfClass:[NSDictionary class]]){
                ((NSMutableArray*)_classes)[i]=[SchoolClass initWithDictionary:(NSDictionary*)_classes[i]];
            }
            if(![_classes[i] isKindOfClass:[SchoolClass class]]){
                ((NSMutableArray*)_classes)[i]=[[SchoolClass alloc]init];
            }
        }
    }
    return _classes;
}
-(Area*)area{
    if([_area isKindOfClass:[NSDictionary class]]){
        _area=[Area initWithDictionary:(NSDictionary*)_area];
    }else if(![_area isKindOfClass:[Area class]]){
        _area=nil;
    }
    return _area;
}


-(BOOL)isCertified{
    BOOL a=[@"1" isEqualToString:self.certified];
    return a;
}
@end


@implementation SchoolClass
-(NSString*) name{
    if(_name==nil){
        _name=@"";
    }
    return _name;
}

-(NSString*) cartype{
    if(_cartype==nil){
        _cartype=@"";
    }
    return _cartype;
}
-(NSString*) licensetype{
    if(_licensetype==nil){
        _licensetype=@"";
    }
    return _licensetype;
}
-(NSString*) trainingtime{
    if(_trainingtime==nil){
        _trainingtime=@"";
    }
    return _trainingtime;
}
-(NSString*) status{
    if(_status==nil){
        _status=@"";
    }
    return _status;
}
-(NSString*) fee{
    if(_fee==nil){
        _fee=@"";
    }else if([_fee isKindOfClass:[NSNumber class]]){
        _fee=((NSNumber*)_fee).stringValue;
    }
    return _fee;
}
-(NSString*) realfee{
    if(_realfee==nil){
        _realfee=@"";
    }else if([_realfee isKindOfClass:[NSNumber class]]){
        _realfee=((NSNumber*)_realfee).stringValue;
    }
    return _realfee;
}
-(NSString*) expiredate{
    if(_expiredate==nil){
        _expiredate=@"";
    }else if([_expiredate isKindOfClass:[NSDate class]]){
        _expiredate=((NSDate*)_expiredate).formatedString;
    }
    return _expiredate;
}
-(NSString*) remark{
    if(_remark==nil){
        _remark=@"";
    }
    return _remark;
}


@end

@implementation Student
-(Person*)person{
    if([_person isKindOfClass:[NSDictionary class]]){
        _person=[Person initWithDictionary:(NSDictionary*)_person];
    }
    if(![_person isKindOfClass:[Person class]]){
        _person=nil;
    }
    return _person;
}
-(School*)school{
    if([_school isKindOfClass:[NSDictionary class]]){
        _school=[School initWithDictionary:(NSDictionary*)_school];
    }
    if(![_school isKindOfClass:[School class]]){
        _school=nil;
    }
    return _school;
}


-(NSString*)certified{
    if(_certified==nil){
        _certified=@"";
    }else if(![_certified isKindOfClass:[NSString class]]){
        _certified=[NSString stringWithFormat:@"%@",_certified];
    }
    
    return _certified;
}


-(NSString*) status{
    if(_status==nil){
        _status=@"";
    }
    return _status;
}
-(NSString*) km1score{
    if(_km1score==nil){
        _km1score=@"";
    }
    return _km1score;
}
-(NSString*) km2score{
    if(_km2score==nil){
        _km2score=@"";
    }
    return _km2score;
}
-(NSString*) km3ascore{
    if(_km3ascore==nil){
        _km3ascore=@"";
    }
    return _km3ascore;
}
-(NSString*) km3bscore{
    if(_km3bscore==nil){
        _km3bscore=@"";
    }
    return _km3bscore;
}
-(NSString*) signupdate{
    if(_signupdate==nil){
        _signupdate=@"";
    }
    return _signupdate;
}
-(NSString*) licencedate{
    if(_licencedate==nil){
        _licencedate=@"";
    }
    return _licencedate;
}


-(BOOL)isCertified{
    return [@"1" isEqualToString:self.certified];
}
@end


@implementation Teacher
-(Person*)person{
    if([_person isKindOfClass:[NSDictionary class]]){
        _person=[Person initWithDictionary:(NSDictionary*)_person];
    }
    if(![_person isKindOfClass:[Person class]]){
        _person=nil;
    }
    return _person;
}
-(School*)school{
    if([_school isKindOfClass:[NSDictionary class]]){
        _school=[School initWithDictionary:(NSDictionary*)_school];
    }
    if(![_school isKindOfClass:[School class]]){
        _school=nil;
    }
    return _school;
}
-(NSMutableArray*)skill{
    if([_skill isKindOfClass:[NSArray class]] && ![_skill isKindOfClass:[NSMutableArray class]]){
        _skill=[NSMutableArray arrayWithArray:_skill];
    }
    if([_skill isKindOfClass:[NSMutableArray class]]){
        for(int i=0;i<_skill.count;i++){
            if([_skill[i] isKindOfClass:[NSDictionary class]]){
                _skill[i]=[Dict initWithDictionary:_skill[i]];
            }
        }
    }else{
        _skill=[Utility initArray:nil];
    }
    return _skill;
}

-(NSString*)certified{
    if(_certified==nil){
        _certified=@"";
    }else if(![_certified isKindOfClass:[NSString class]]){
        _certified=[NSString stringWithFormat:@"%@",_certified];
    }

    return _certified;
}
-(NSString*)status{
    if(_status==nil){
        _status=@"";
    }
    return _status;
}


-(BOOL)isCertified{
    return [@"1" isEqualToString:self.certified];
}
@end


@implementation CustomerService
-(Person*)person{
    if([_person isKindOfClass:[NSDictionary class]]){
        _person=[Person initWithDictionary:(NSDictionary*)_person];
    }
    if(![_person isKindOfClass:[Person class]]){
        _person=nil;
    }
    return _person;
}
-(School*)school{
    if([_school isKindOfClass:[NSDictionary class]]){
        _school=[School initWithDictionary:(NSDictionary*)_school];
    }
    if(![_school isKindOfClass:[School class]]){
        _school=nil;
    }
    return _school;
}

-(NSString*)certified{
    if(_certified==nil){
        _certified=@"";
    }else if(![_certified isKindOfClass:[NSString class]]){
        _certified=[NSString stringWithFormat:@"%@",_certified];
    }

    return _certified;
}
-(NSString*)status{
    if(_status==nil){
        _status=@"";
    }
    return _status;
}
-(NSString*)name{
    if(_name==nil){
        _name=@"";
    }
    return _name;
}


-(BOOL)isCertified{
    return [@"1" isEqualToString:self.certified];
}
@end

@implementation Operation
-(Person*)person{
    if([_person isKindOfClass:[NSDictionary class]]){
        _person=[Person initWithDictionary:(NSDictionary*)_person];
    }
    if(![_person isKindOfClass:[Person class]]){
        _person=nil;
    }
    return _person;
}
-(School*)school{
    if([_school isKindOfClass:[NSDictionary class]]){
        _school=[School initWithDictionary:(NSDictionary*)_school];
    }
    if(![_school isKindOfClass:[School class]]){
        _school=nil;
    }
    return _school;
}

-(NSString*)certified{
    if(_certified==nil){
        _certified=@"";
    }else if(![_certified isKindOfClass:[NSString class]]){
        _certified=[NSString stringWithFormat:@"%@",_certified];
    }

    return _certified;
}
-(NSString*)status{
    if(_status==nil){
        _status=@"";
    }
    return _status;
}
-(NSString*)name{
    if(_name==nil){
        _name=@"";
    }
    return _name;
}


-(BOOL)isCertified{
    return [@"1" isEqualToString:self.certified];
}
@end


//字典数据
@implementation Dict

-(NSString*) name{
    if(_name==nil){
        _name=@"";
    }
    return _name;
}
-(NSString*) value{
    if(_value==nil){
        _value=@"";
    }
    return _value;
}
-(NSString*) desc{
    if(_desc==nil){
        _desc=@"";
    }
    return _desc;
}
-(NSString*) order{
    if(_order==nil){
        _order=@"";
    }
    return _order;
}


@end


@implementation OperationCertificateItem
-(NSString*) name{
    if(_name==nil){
        _name=@"";
    }
    return _name;
}
-(NSString*) value{
    if(_value==nil){
        _value=@"";
    }
    return _value;
}
-(NSString*) imageurl{
    if(_imageurl==nil){
        _imageurl=@"";
    }
    return _imageurl;
}
-(NSString*) desc{
    if(_desc==nil){
        _desc=@"";
    }
    return _desc;
}
-(NSString*) order{
    if(_order==nil){
        _order=@"";
    }
    return _order;
}


@end



@implementation SchoolSignup
-(NSString*)createdate{
    if(_createdate==nil){
        _createdate=@"";
    }
    return _createdate;
}
-(NSString*)modifydate{
    if(_modifydate==nil){
        _modifydate=@"";
    }
    return _modifydate;
}
-(Person*)person{
    if([_person isKindOfClass:[NSDictionary class]]){
        _person=[Person initWithDictionary:(NSDictionary*)_person];
    }
    if(![_person isKindOfClass:[Person class]]){
        _person=nil;
    }
    return _person;
}
-(School*)school{
    if([_school isKindOfClass:[NSDictionary class]]){
        _school=[School initWithDictionary:(NSDictionary*)_school];
    }
    if(![_school isKindOfClass:[School class]]){
        _school=nil;
    }
    return _school;
}
-(SchoolClass*)schoolclass{
    if([_schoolclass isKindOfClass:[NSDictionary class]]){
        _schoolclass=[SchoolClass initWithDictionary:(NSDictionary*)_schoolclass];
    }
    if(![_schoolclass isKindOfClass:[SchoolClass class]]){
        _schoolclass=nil;
    }
    return _schoolclass;
}
-(NSString*)name{
    if(_name==nil){
        _name=@"";
    }
    return _name;
}
-(NSString*)phone{
    if(_phone==nil){
        _phone=@"";
    }
    return _phone;
}
-(NSString*)gender{
    if(_gender==nil){
        _gender=@"";
    }
    return _gender;
}
-(NSString*)age{
    if(_age==nil){
        _age=@"";
    }
    return _age;
}
-(NSString*)address{
    if(_address==nil){
        _address=@"";
    }
    return _address;
}
-(NSString*)remark{
    if(_remark==nil){
        _remark=@"";
    }
    return _remark;
}
-(NSString*)status{
    if(_status==nil){
        _status=@"";
    }
    return _status;
}



-(BOOL)isMale{
    return [Utility isMale:_gender];
}

-(BOOL)isNew{
    return [@"new" isEqualToString:self.status];
}
-(BOOL)isSignup{
    return [@"signup" isEqualToString:self.status];
}
-(BOOL)isAbandon{
    return [@"abandon" isEqualToString:self.status];
}

@end

@implementation CourseTimeTable

-(Teacher*)teacher{
    if(_teacher==nil){
        _teacher=[[Teacher alloc]init];
    }else if([_teacher isKindOfClass:[NSDictionary class]]){
        _teacher=[Teacher initWithDictionary:(NSDictionary*)_teacher];
    }
    return _teacher;
}
-(NSString*)name{
    if(_name==nil){
        _name=@"";
    }
    return _name;
}
-(NSString*)enabled{
    if(_enabled==nil){
        _enabled=@"";
    }else if(![_enabled isKindOfClass:[NSString class]]){
        _enabled=[NSString stringWithFormat:@"%@",_enabled];
    }
    return _enabled;
}
-(NSString*)publishdate{
    if(_publishdate==nil){
        _publishdate=@"";
    }
    return _publishdate;
}

-(NSString*)expiredate{
    if(_expiredate==nil){
        _expiredate=@"";
    }
    return _expiredate;
}

-(NSMutableArray<Course*>*)course{
    if(_course==nil || ![_course isKindOfClass:[NSArray class]]){
        _course=[Utility initArray:nil];
    }else{
        if(![_course isKindOfClass:[NSMutableArray class]]){
            _course=[NSMutableArray arrayWithArray:_course];
        }
        for(int i=0;i<_course.count;i++) {
            if([_course[i] isKindOfClass:[NSDictionary class]]){
                ((NSMutableArray*)_course)[i]=[Course initWithDictionary:(NSDictionary*)_course[i]];
            }
            if(![_course[i] isKindOfClass:[Course class]]){
                ((NSMutableArray*)_course)[i]=[[Course alloc]init];
            }
        }
    }
    return _course;
}



-(BOOL)isEnabled{
    return [@"1" isEqualToString:self.enabled];
}

@end

@interface Course(){
    NSString* _calendar;
    NSString* _weekday;
    NSString* _starttime;
    NSString* _endtime;
    NSString* _course;
    NSString* _studentnum;
    NSString* _remark;
    
}
@end
@implementation Course

+(instancetype)initWithDictionary:(NSDictionary *)data{
    Course* ret=[super initWithDictionary:data];
    ret.changed=false;
    return ret;
}

-(void)setCalendar:(NSString *)calendar{
    _calendar=calendar;
    _changed=true;
}
-(void)setWeekday:(NSString *)weekday{
    _weekday=weekday;
    _changed=true;
}
-(void)setStarttime:(NSString *)starttime{
    _starttime=starttime;
    _changed=true;
}
-(void)setEndtime:(NSString *)endtime{
    _endtime=endtime;
    _changed=true;
}
-(void)setCourse:(NSString *)course{
    _course=course;
    _changed=true;
}
-(void)setStudentnum:(NSString *)studentnum{
    _studentnum=studentnum;
    _changed=true;
}
-(void)setRemark:(NSString *)remark{
    _remark=remark;
    _changed=true;
}


-(NSString*)calendar{
    if(_calendar==nil){
        _calendar=@"";
    }
    return _calendar;
}
-(NSString*)weekday{
    if(_weekday==nil){
        _weekday=@"99";
    }else if(![_weekday isKindOfClass:[NSString class]]){
        _weekday=[NSString stringWithFormat:@"%@",_weekday];
    }
    return _weekday;
}
-(NSString*)starttime{
    if(_starttime==nil){
        _starttime=@"";
    }
    return _starttime;
}
-(NSString*)endtime{
    if(_endtime==nil){
        _endtime=@"";
    }
    return _endtime;
}
-(NSString*)studentnum{
    if(_studentnum==nil){
        _studentnum=@"";
    }else if([_studentnum isKindOfClass:[NSNumber class]]){
        _studentnum=((NSNumber*)_studentnum).stringValue;
    }
    return _studentnum;
}
-(NSString*)course{
    if(_course==nil){
        _course=@"";
    }
    return _course;
}
-(NSString*)courseDisplay{
    return [Utility descInDict:[Storage teacherSkillDict] fromValue:_course];
}
-(NSString*)remark{
    if(_remark==nil){
        _remark=@"";
    }
    return _remark;
}

@end



@implementation CourseAppointment

-(NSString*)date{
    if(_date==nil){
        _date=@"";
    }
    return _date;
}

-(Course*)course{
    if(_course==nil){
        _course=[[Course alloc]init];
    }else if([_course isKindOfClass:[NSDictionary class]]){
        _course=[Course initWithDictionary:(NSDictionary*)_course];
    }
    return _course;
}
-(Student*)student{
    if(_student==nil){
        _student=[[Student alloc]init];
    }else if([_student isKindOfClass:[NSDictionary class]]){
        _student=[Student initWithDictionary:(NSDictionary*)_student];
    }
    return _student;
}

-(Teacher*)teacher{
    if(_teacher==nil){
        _teacher=[[Teacher alloc]init];
    }else if([_teacher isKindOfClass:[NSDictionary class]]){
        _teacher=[Teacher initWithDictionary:(NSDictionary*)_teacher];
    }
    return _teacher;
}


-(NSString*)deleted{
    if(_deleted==nil){
        _deleted=@"";
    }else{
        _deleted=[NSString stringWithFormat:@"%@",_deleted];
    }
    return _deleted;
}
-(NSString*)expired{
    if(_expired==nil){
        _expired=@"";
    }else{
        _expired=[NSString stringWithFormat:@"%@",_expired];
    }
    return _expired;
}

-(CourseAppointmentEvaluation*)studentevaluation{
    if([_studentevaluation isKindOfClass:[NSDictionary class]]){
        _studentevaluation=[CourseAppointmentEvaluation initWithDictionary:(NSDictionary*)_studentevaluation];
    }
    return _studentevaluation;
}
-(CourseAppointmentEvaluation*)teacherevaluation{
    if([_teacherevaluation isKindOfClass:[NSDictionary class]]){
        _teacherevaluation=[CourseAppointmentEvaluation initWithDictionary:(NSDictionary*)_teacherevaluation];
    }
    return _teacherevaluation;
}

-(BOOL)isDeleted{
    return [@"1" isEqualToString:self.deleted];
}
-(BOOL)isExpired{
    return [@"1" isEqualToString:self.expired];
}

@end



@implementation CourseAppointmentEvaluation

-(NSNumber*)processNumber:(id)data withDefault:(NSNumber*)defaultValue{
    NSNumber* ret=defaultValue;
    if([data isKindOfClass:[NSNumber class]]){
        ret=(NSNumber*)data;
    }else if([data isKindOfClass:[NSString class]]){
        @try {
            ret=[NSNumber numberWithInt:((NSString*)_star1).floatValue];
        }
        @catch (NSException *exception) {
            ret=defaultValue;
        }
        @finally {
        }
    }
    return ret;
    
}

-(NSNumber*)star1{
    _star1=[self processNumber:_star1 withDefault:nil];
    return _star1;
}

-(NSNumber*)star2{
    _star2=[self processNumber:_star2 withDefault:nil];
    return _star2;
}
-(NSNumber*)star3{
    _star3=[self processNumber:_star3 withDefault:nil];
    return _star3;
}
-(NSNumber*)star4{
    _star4=[self processNumber:_star4 withDefault:nil];
    return _star4;
}
-(NSNumber*)star5{
    _star5=[self processNumber:_star5 withDefault:nil];
    return _star5;
}
-(NSNumber*)star6{
    _star6=[self processNumber:_star6 withDefault:nil];
    return _star6;
}
-(NSNumber*)star7{
    _star7=[self processNumber:_star7 withDefault:nil];
    return _star7;
}
-(NSNumber*)star8{
    _star8=[self processNumber:_star8 withDefault:nil];
    return _star8;
}
-(NSNumber*)star9{
    _star9=[self processNumber:_star9 withDefault:nil];
    return _star9;
}

-(NSNumber*)averagestar{
    _averagestar=[self processNumber:_averagestar withDefault:@0];
    return _averagestar;
}
@end