//
//  Remote.h
//  myim
//
//  Created by Sean Shi on 15/10/17.
//  Copyright © 2015年 车友会. All rights reserved.
//

#ifndef Remote_h
#define Remote_h

#import "Storage.h"

@interface Remote : NSObject

#pragma mark 获取有效的Rremote Url
/**
 *  获取有效的Rremote Url
 */
+(void) serverVersion:(NSString*)url callback:(void (^)(StorageCallbackData* callback_data))callback;

#pragma mark 记录日志
/**
 *  记录日志
 */
+(void) log:(NSString*)name ext:(NSArray<NSString*>*)ext callback:(void (^)(StorageCallbackData* callback_data))callback;

#pragma mark 登录
/**
 *  登录
 */
+(void) loginWithUsername:(NSString*)username password:(NSString*)password callback:(void (^)(StorageCallbackData* callback_data))callback;
#pragma mark 取得用户头像
/**
 *  取得用户头像
 */
+(void) headImageWithPerson:(NSString*)personid callback:(void (^)(StorageCallbackData* callback_data))callback;
#pragma mark 取得用户头像(url)
/**
 *  取得用户头像(url)
 */
+(void) headImageWithURL:(NSString*)url callback:(void (^)(StorageCallbackData* callback_data))callback;
#pragma mark 发送手机验证码
/**
 *  发送手机验证码
 */
+(void) sendSMSCodeWithPhone:(NSString*)phone callback:(void (^)(StorageCallbackData* callback_data))callback;

#pragma mark 注册
/**
 *  注册
 */
+(void) regWithPhone:(NSString*)phone smscode:(NSString*)smscode password:(NSString*)password callback:(void (^)(StorageCallbackData* callback_data))callback;

#pragma mark 重设密码
/**
 *  重设密码
 */
+(void) resetPasswordWithPhone:(NSString*)phone smscode:(NSString*)smscode password:(NSString*)password callback:(void (^)(StorageCallbackData* callback_data))callback;

#pragma mark 修改用户信息
/**
 *  修改用户信息
 */
+(void) updatePerson:(Person*)person callback:(void (^)(StorageCallbackData* callback_data))callback;

#pragma mark 修改用户名
/**
 *  修改用户名
 */
+(void) updatePersonUsername:(NSString*)username callback:(void (^)(StorageCallbackData* callback_data))callback;

#pragma mark 修改用户地区信息
/**
 *  修改用户地区信息
 */
+(void) updatePersonArea:(NSString*)areaid callback:(void (^)(StorageCallbackData* callback_data))callback;

#pragma mark 获取通讯录
/**
 *  获取通讯录
 */
+(void) contactsWithCallbak:(void (^)(StorageCallbackData* callback_data))callback;

#pragma mark 更新用户头像
/**
 *  更新用户头像
 */
+(void) updateHeadImageWithImage:(UIImage*)image callback:(void (^)(StorageCallbackData* callback_data))callback;

#pragma mark 查找新好友
/**
 *  查找新好友
 */
+(void) searchPersonWithUsername:(NSString*)username callback:(void (^)(StorageCallbackData* callback_data))callback;

#pragma mark 判断两人关系是否为好友
/**
 *  判断两人关系是否为好友
 */
+(void) isFriendBetweenMe:(NSString*)myid andOther:(NSString*)otherid callback:(void (^)(StorageCallbackData* callback_data))callback;

#pragma mark 添加到通讯录
/**
 *  添加到通讯录
 */
+(void) addContacts:(NSString*)friendid callback:(void (^)(StorageCallbackData* callback_data))callback;

#pragma mark 获取指定用户信息
/**
 *  获取指定用户信息
 */
+(void) getPersonWithId:(NSString*)personid callback:(void (^)(StorageCallbackData* callback_data))callback;

#pragma mark 发起群聊
/**
 *  发起群聊
 */
+(void) createChatGroup:(NSString*)ownerid persons:(NSArray<NSString*>*)persons callback:(void (^)(StorageCallbackData* callback_data))callback;

#pragma mark 查找当前用户所属的群组
/**
 *  查找当前用户所属的群组
 */
+(void) searchChatGroup:(void (^)(StorageCallbackData* callback_data))callback;

#pragma mark 获取指定群
/**
 *  获取指定群
 */
+(void) getChatGroupWithId:(NSString*)groupid callback:(void (^)(StorageCallbackData* callback_data))callback;

#pragma mark 从群中删除成员
/**
 *  从群中删除成员
 */
+(void) removeMember:(NSString*)personid fromChatGroup:(NSString*)groupid callback:(void (^)(StorageCallbackData* callback_data))callback;

#pragma mark 添加成员到群组
/**
 *  添加成员到群组
 */
+(void) addMembers:(NSArray<NSString*>*)persons toChatGroup:(NSString*)groupid callback:(void (^)(StorageCallbackData* callback_data))callback;

#pragma mark 更新群组名称
/**
 *  更新群组名称
 */
+(void) updateGroup:(NSString*)groupid name:(NSString*)groupname callback:(void (^)(StorageCallbackData* callback_data))callback;

#pragma mark 获取图片
/**
 *  获取图片
 */
+(void) imageWithUrl:(NSString*)urlString calback:(void (^)(StorageCallbackData* callback_data))callback;

#pragma mark 更新地区数据
/**
 *  更新地区数据
 */
+(void) updateAreaData:(void (^)(StorageCallbackData* callback_data))callback;

#pragma mark 查找驾校
/**
 *  查找驾校
 */
+(void) searchSchool:(NSString*)searchkey fuzzy:(BOOL)fuzzy start:(NSInteger)start offset:(NSInteger)offset callback:(void (^)(StorageCallbackData* callback_data))callback;

#pragma mark 创建驾校
/**
 *  创建驾校
 */
+(void) createSchool:(NSString*)schoolname areaid:(NSString*)areaid callback:(void (^)(StorageCallbackData* callback_data))callback;

#pragma mark 教练教学科目
/**
 *  教练教学科目
 */
+(void) dictWithName:(NSString*)dictname callback:(void (^)(StorageCallbackData* callback_data))callback;

#pragma mark 创建学员身份
/**
 *  创建学员身份
 */
+(void) createStudent:(NSString*)personid schoolid:(NSString*)schoolid status:(NSString*)status  signupdate:(NSString*)signupdate km1score:(NSString*)km1score km2score:(NSString*)km2score km3ascore:(NSString*)km3ascore km3bscore:(NSString*)km3bscore licencedate:(NSString*)licencedate callback:(void (^)(StorageCallbackData* callback_data))callback;
/**删除学员身份*/
+(void)deleteStudent:(NSString *)studentid callback:(void (^)(StorageCallbackData* callback_data))callback;
#pragma mark 取得学员身份
/**
 *  取得学员身份
 */
+(void) student:(NSString*)studentid callback:(void (^)(StorageCallbackData* callback_data))callback;


#pragma mark 创建教练身份
/**
 *  创建教练身份
 */
+(void) createTeacher:(NSString*)personid schoolid:(NSString*)schoolid skills:(NSString*)skills callback:(void (^)(StorageCallbackData* callback_data))callback;

/**删除教练身份*/
+(void)deleteTeacher:(NSString *)teacherid callback:(void (^)(StorageCallbackData* callback_data))callback;
#pragma mark 取得教练对象
/**
 *  取得教练对象
 */
+(void) teacher:(NSString*)teacherid callback:(void (^)(StorageCallbackData* callback_data))callback;

#pragma mark 我的所有教练身份
/**
 *  我的所有教练身份
 */
+(void) allTeacherCharacter:(NSString*)personid callback:(void (^)(StorageCallbackData* callback_data))callback;

#pragma mark 创建客服身份
/**
 *  创建客服身份
 */
+(void) createCustomerService:(NSString*)personid schoolid:(NSString*)schoolid callback:(void (^)(StorageCallbackData* callback_data))callback;
/**删除客服身份*/
+(void)deleteCustomerService:(NSString *)CustomerServiceid callback:(void (^)(StorageCallbackData* callback_data))callback;
#pragma mark 我的所有客服身份
/**
 *  我的所有客服身份
 */
+(void) allCustomerCharacter:(NSString*)personid callback:(void (^)(StorageCallbackData* callback_data))callback;

#pragma mark 创建运营身份
/**
 *  创建运营身份
 */
+(void) createOperation:(NSString*)personid schoolid:(NSString*)schoolid callback:(void (^)(StorageCallbackData* callback_data))callback;
/**删除运营身份*/
+(void)deleteOperation:(NSString *)operationid callback:(void (^)(StorageCallbackData* callback_data))callback;
#pragma mark 我的所有运营身份
/**
 *  我的所有运营身份
 */
+(void) allOperation:(NSString*)personid callback:(void (^)(StorageCallbackData* callback_data))callback;

#pragma mark 我的所有身份
/**
 *  我的所有身份
 */
+(void) allCharacter:(NSString*)personid callback:(void (^)(StorageCallbackData* callback_data))callback;

#pragma mark 取得当前有效身份
/**
 *  取得当前有效身份
 */
+(void) availableCharacter:(NSString*)personid callback:(void (^)(StorageCallbackData* callback_data))callback;

#pragma mark 设置当前有效身份
/**
 *  设置当前有效身份
 */
+(void) setAvailableCharacter:(NSString*)personid character:(BaseObject*)character callback:(void (^)(StorageCallbackData* callback_data))callback;

#pragma mark 关注驾校
/**
 *  关注驾校
 */
+(void) interestSchool:(NSString*)schoolid callback:(void (^)(StorageCallbackData* callback_data))callback;

#pragma mark 取消关注驾校
/**
 *  取消关注驾校
 */
+(void) uninterestSchool:(NSString*)schoolid callback:(void (^)(StorageCallbackData* callback_data))callback;

#pragma mark 是否关注驾校
/**
 *  是否关注驾校
 */
+(void) isInterestedSchool:(NSString*)schoolid callback:(void (^)(StorageCallbackData* callback_data))callback;

#pragma mark 我关注的驾校
/**
 *  我关注的驾校
 */
+(void) myInterestedSchool:(NSInteger)start offset:(NSInteger)offset callback:(void (^)(StorageCallbackData* callback_data))callback;

#pragma mark 取得驾校所有员工
/**
 *  取得驾校所有员工
 */
+(void) allStaffOfSchool:(NSString*)schoolid charactertype:(NSString*)charactertype  callback:(void (^)(StorageCallbackData* callback_data))callback;

#pragma mark 查询一组手机号是否存在
/**
 *  查询一组手机号是否存在
 */
+(void) searchPhones:(nonnull NSArray<NSString*>*)phones callback:(void (^)(StorageCallbackData* callback_data))callback;

#pragma mark 驾校报名
/**
 *  驾校报名
 */
+(void) schoolSignup:(NSString*)personid school:(NSString*)schoolid classid:(NSString*)classid name:(NSString*)name phone:(NSString*)phone gender:(NSString*)gender age:(NSString*)age address:(NSString*)address remark:(NSString*)remark callback:(void (^)(StorageCallbackData* callback_data))callback;

#pragma mark 驾校报名列表
/**
 *  驾校报名列表
 */
+(void) schoolSignupList:(NSString*)schoolid showtreated:(BOOL)showtreated start:(NSInteger)start offset:(NSInteger)offset callback:(void (^)(StorageCallbackData* callback_data))callback;

#pragma mark 更新报名状态
/**
 *  更新报名状态
 */
+(void) updateSchoolSignupStatus:(NSString*)schoolsignupid status:(NSString*)status callback:(void (^)(StorageCallbackData* callback_data))callback;

#pragma mark 驾运营提交认证申请报名
/**
 *  驾运营提交认证申请报名
 */
+(void) submitOperationCertificate:(NSDictionary<NSString*,id>*)data callback:(void (^)(StorageCallbackData* callback_data))callback;

#pragma mark 获取运营提交的认证申请
/**
 *  获取运营提交的认证申请
 */
+(void) operationCertificate:(NSString*)operationid callback:(void (^)(StorageCallbackData* callback_data))callback;

#pragma mark 撤销运营提交的认证申请
/**
 *  撤销运营提交的认证申请
 */
+(void) revokeOperationCertificate:(NSString*)operationid callback:(void (^)(StorageCallbackData* callback_data))callback;


#pragma mark 认证员工
/**
 *  认证员工
 */
+(void) certify:(BaseObject*)character certify:(BOOL)certify callback:(void (^)(StorageCallbackData* callback_data))callback;


#pragma mark 获得驾校信息
/**
 *  获得驾校信息
 */
+(void) school:(NSString*)schoolid callback:(void (^)(StorageCallbackData* callback_data))callback;

#pragma mark 更新驾校介绍
/**
 *  更新驾校介绍
 */
+(void) updateSchoolIntroduce:(NSString*)schoolid introduction:(NSString*)introduction callback:(void (^)(StorageCallbackData* callback_data))callback;

#pragma mark 更新驾校一景
/**
 *  更新驾校一景
 */
+(void) updateSchoolPictures:(NSString*)schoolid pics:(NSArray<UIImage*>*)pics callback:(void (^)(StorageCallbackData* callback_data))callback;


#pragma mark 添加驾校班级
/**
 *  添加驾校班级
 */
+(void) addSchoolClass:(NSString*)operationid name:(NSString*)name cartype:(NSString*)cartype licensetype:(NSString*)licensetype trainingtime:(NSString*)trainingtime fee:(NSString*)fee realfee:(NSString*)realfee expiredate:(NSString*)expiredate remark:(NSString*)remark callback:(void (^)(StorageCallbackData* callback_data))callback;


#pragma mark 驾校所有的课程
/**
 *  驾校所有的课程
 */
+(void) allSchoolClass:(NSString*)schoolid callback:(void (^)(StorageCallbackData* callback_data))callback;


#pragma mark 更改课程状态
/**
 *  更改课程状态
 */
+(void) changeStatusSchoolClass:(NSString*)operationid schoolclassid:(NSString*)schoolclassid status:(NSString*)status callback:(void (^)(StorageCallbackData* callback_data))callback;


#pragma mark 搜索学员
/**
 *  搜索学员
 */
+(void) searchSchoolStudent:(NSString*)schoolid searchkey:(NSString*)searchkey callback:(void (^)(StorageCallbackData* callback_data))callback;

#pragma mark 获取教练课程
/**
 *  获取教练课程
 */
+(void) teacherTimeTable:(NSString*)timetableid callback:(void (^)(StorageCallbackData* callback_data))callback;

#pragma mark 添加(/更新)教练课程
/**
 *  添加(/更新)教练课程
 */
+(void) updateTeacherCourse:(NSString*)teacherid timetableid:(NSString*)timetableid courseList:(NSArray<Course*>*)courseList callback:(void (^)(StorageCallbackData* callback_data))callback;

#pragma mark 取得可预约教练
/**
 *  取得可预约教练
 */
+(void) appointmentTeacherList:(NSString*)studentid callback:(void (^)(StorageCallbackData* callback_data))callback;


#pragma mark 获取教练所有课表
/**
 *  获取教练所有课表
 */
+(void) teacherAllTimeTable:(NSString*)teacherid callback:(void (^)(StorageCallbackData* callback_data))callback;


#pragma mark 取得教练的预约日历
/**
 *  取得教练的预约日历
 */
+(void) appointmentCalendar:(NSString*)teacherid studentid:(NSString*)studentid callback:(void (^)(StorageCallbackData* callback_data))callback;


#pragma mark 预约
/**
 *  预约
 */
+(void) createAppointment:(NSString*)studentid date:(NSString*)dateString courseid:(NSString*)courseid remark:(NSString*)remark callback:(void (^)(StorageCallbackData* callback_data))callback;

#pragma mark 取消预约
/**
 *  取消预约
 */
+(void) cancelAppointment:(NSString*)studentid date:(NSString*)dateString courseid:(NSString*)courseid callback:(void (^)(StorageCallbackData* callback_data))callback;

#pragma mark 设置预约为缺勤
/**
 *  设置预约为缺勤
 */
+(void) absentAppointment:(NSString*)appointmentid callback:(void (^)(StorageCallbackData* callback_data))callback;

#pragma mark 获取教练课程
/**
 *  获取教练课程
 */
+(void) teacherCourse:(NSString*)courseid callback:(void (^)(StorageCallbackData* callback_data))callback;


#pragma mark 学员-取得约车记录
/**
 *  学员-取得约车记录
 */
+(void) studentAppointmentList:(NSString*)studentid showexpired:(BOOL)showexpired start:(NSInteger)start offset:(NSInteger)offset callback:(void (^)(StorageCallbackData* callback_data))callback;


#pragma mark 教练-取得约车记录
/**
 *  教练-取得约车记录
 */
+(void) teacherAppointmentList:(NSString*)teacherid showexpired:(BOOL)showexpired start:(NSInteger)start offset:(NSInteger)offset callback:(void (^)(StorageCallbackData* callback_data))callback;

#pragma mark 教练-取得某日约车记录
/**
 *  教练-取得某日约车记录
 */
+(void) teacherAppointmentListOfOneDay:(NSString*)teacherid date:(NSDate*)date start:(NSInteger)start offset:(NSInteger)offset callback:(void (^)(StorageCallbackData* callback_data))callback;

#pragma mark 取得一个约车记录
/**
 *  取得一个约车记录
 */
+(void) appointment:(NSString*)appointmentid callback:(void (^)(StorageCallbackData* callback_data))callback;


#pragma mark 新建(更新)评价
/**
 *  新建(更新)评价
 */
+(void) updateAppointmentEvaluation:(nonnull CourseAppointmentEvaluation*)evaluation who:(nonnull NSString*)who callback:(void (^)(StorageCallbackData* callback_data))callback;
@end


#endif /* Remote_h */
