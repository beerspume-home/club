#coding=utf-8
from django.conf.urls import url

urlpatterns = [
    #返回服务器版本号
    url(r'^app/version/?$', 'app.views.version'),
    #发送短信验证码
    url(r'^app/sendSMSCode/?$', 'app.views.sendSMSCode'),
    #用户注册
    url(r'^app/userReg/?$', 'app.views.userReg'),
    #用户登录
    url(r'^app/userLogin/?$', 'app.views.userLogin'),
    #刷新访问令牌
    url(r'^app/refreshToken/?$', 'app.views.refreshToken'),
    #密码重置
    url(r'^app/resetPassword/?$', 'app.views.resetPassword'),
    #找找新好友
    url(r'^app/searchPerson/?$', 'app.views.searchPerson'),
    #获取用户信息
    url(r'^app/person/?$', 'app.views.person'),
    #获取用户二维码
    url(r'^app/personQRCode/?$', 'app.views.personQRCode'),
    #更新用户信息
    url(r'^app/updatePerson/?$', 'app.views.updatePerson'),
    #更新用户名
    url(r'^app/updatePersonUsername/?$', 'app.views.updatePersonUsername'),
    #更新用户地区
    url(r'^app/updatePersonArea/?$', 'app.views.updatePersonArea'),
    #更新用户头像
    url(r'^app/updateHeadImage/?$', 'app.views.updateHeadImage'),
    #获取用户头像
    url(r'^app/headImage/?$', 'app.views.headImage'),
    #获取用户原始头像
    url(r'^app/originHeadImage/?$', 'app.views.originHeadImage'),
    
    #获取用户的通讯录
    url(r'^app/contacts/?$', 'app.views.contacts'),
    #添加好友到通讯录
    url(r'^app/addContacts/?$', 'app.views.addContacts'),
    #判断第二个用户是否为第一个用户的好友
    url(r'^app/isFriend/?$', 'app.views.isFriend'),
    #查找手机号是否
    url(r'^app/searchPhones/?$', 'app.views.searchPhones'),

    #发起群聊
    url(r'^app/createChatGroup/?$', 'app.views.createChatGroup'),
    #获取群信息
    url(r'^app/chatGroup/?$', 'app.views.chatGroup'),
    #添加成员到群
    url(r'^app/addPersonToChatGroup/?$', 'app.views.addPersonToChatGroup'),
    #从群中删除成员
    url(r'^app/removePersonFromChatGroup/?$', 'app.views.removePersonFromChatGroup'),
    #设置群名称
    url(r'^app/updateChatGroupName/?$', 'app.views.updateChatGroupName'),
    #查找群
    url(r'^app/searchChatGroup/?$', 'app.views.searchChatGroup'),
    #获取群组头像
    url(r'^app/groupImage/?$', 'app.views.groupImage'),
    

    #获取地区数据版本
    url(r'^app/areaVersion/?$', 'app.views.areaVersion'),
    #获取地区数据
    url(r'^app/area/?$', 'app.views.area'),

    #创建学员身份
    url(r'^app/createStudent/?$', 'app.views.createStudent'),
    #删除学员身份
    url(r'^app/deleteStudent/?$', 'app.views.deleteStudent'),
    #取得学员对象
    url(r'^app/student/?$', 'app.views.student'),

    #创建教练身份
    url(r'^app/createTeacher/?$', 'app.views.createTeacher'),
    #删除教练身份
    url(r'^app/deleteTeacher/?$', 'app.views.deleteTeacher'),
    #取得教练对象
    url(r'^app/teacher/?$', 'app.views.teacher'),
    #搜索所有教练身份
    url(r'^app/allTeacherCharacter/?$', 'app.views.allTeacherCharacter'),

    #创建客服身份
    url(r'^app/createCustomerService/?$', 'app.views.createCustomerService'),
    #删除客服身份
    url(r'^app/deleteCustomerService/?$', 'app.views.deleteCustomerService'),
    #搜索所有客服身份
    url(r'^app/allCustomerServiceCharacter/?$', 'app.views.allCustomerServiceCharacter'),

    #创建运营身份
    url(r'^app/createOperation/?$', 'app.views.createOperation'),
    #删除运营身份
    url(r'^app/deleteOperation/?$', 'app.views.deleteOperation'),
    #搜索所有运营身份
    url(r'^app/allOperationCharacter/?$', 'app.views.allOperationCharacter'),

    #返回当前有效身份
    url(r'^app/availableCharacter/?$', 'app.views.availableCharacter'),
    #设置当前有效身份
    url(r'^app/setAvailableCharacter/?$', 'app.views.setAvailableCharacter'),
    #设置所有身份
    url(r'^app/allCharacter/?$', 'app.views.allCharacter'),
    
    #认证身份
    url(r'^app/certify/?$', 'app.views.certify'),

    #获得驾校信息
    url(r'^app/school/?$', 'app.views.school'),
    #搜索驾校
    url(r'^app/searchSchool/?$', 'app.views.searchSchool'),
    #搜索驾校模糊
    url(r'^app/searchSchoolFuzzy/?$', 'app.views.searchSchoolFuzzy'),
    #创建驾校
    url(r'^app/createSchool/?$', 'app.views.createSchool'),
    #图片URL
    url(r'^app/image/(.+)/?$', 'app.views.image'),
    #关注驾校
    url(r'^app/interestSchool/?$', 'app.views.interestSchool'),
    #取消关注驾校
    url(r'^app/uninterestSchool/?$', 'app.views.uninterestSchool'),
    #是否关注了驾校
    url(r'^app/isInterestedSchool/?$', 'app.views.isInterestedSchool'),
    #公众号-驾校列表
    url(r'^app/myInterestSchoolList/?$', 'app.views.myInterestSchoolList'),
    #驾校报名
    url(r'^app/schoolSignup/?$', 'app.views.schoolSignup'),
    #驾校报名列表
    url(r'^app/schoolSignupList/?$', 'app.views.schoolSignupList'),
    #更新报名状态
    url(r'^app/updateSchoolSignupStatus/?$', 'app.views.updateSchoolSignupStatus'),
    #更新驾校介绍
    url(r'^app/updateSchoolIntroduction/?$', 'app.views.updateSchoolIntroduction'),
    #更新驾校一景
    url(r'^app/updateSchoolPictures/?$', 'app.views.updateSchoolPictures'),

    #取得驾校的所有员工
    url(r'^app/schoolStaff/?$', 'app.views.schoolStaff'),

    #字典数据
    url(r'^app/dictdata/?$', 'app.views.dictdata'),

    #运营提交认证申请
    url(r'^app/submitOperationCertificate/?$', 'app.views.submitOperationCertificate'),
    #获取运营提交的认证申请
    url(r'^app/operationCertificate/?$', 'app.views.operationCertificate'),
    #撤销运营提交的认证申请
    url(r'^app/revokeOperationCertificate/?$', 'app.views.revokeOperationCertificate'),

    #添加驾校课程
    url(r'^app/addSchoolClass/?$', 'app.views.addSchoolClass'),
    #驾校所有的课程
    url(r'^app/allSchoolClass/?$', 'app.views.allSchoolClass'),
    #更改课程状态
    url(r'^app/changeStatusSchoolClass/?$', 'app.views.changeStatusSchoolClass'),


    #获取教练所有课表
    url(r'^app/teacherAllTimeTable/?$', 'app.views.teacherAllTimeTable'),
    #启用课表
    url(r'^app/enableTeacherTimeTable/?$', 'app.views.enableTeacherTimeTable'),
    #停用课表
    url(r'^app/disableTeacherTimeTable/?$', 'app.views.disableTeacherTimeTable'),
    #删除课表
    url(r'^app/deleteTeacherTimeTable/?$', 'app.views.deleteTeacherTimeTable'),
    #修改课表
    url(r'^app/updateTeacherTimeTable/?$', 'app.views.updateTeacherTimeTable'),
    #获取教练课程
    url(r'^app/teacherTimeTable/?$', 'app.views.teacherTimeTable'),
    #获取教练课程
    url(r'^app/teacherCourse/?$', 'app.views.teacherCourse'),
    #添加(更新)教练课程
    url(r'^app/updateTeacherCourse/?$', 'app.views.updateTeacherCourse'),
    #取得可预约教练
    url(r'^app/appointmentTeacherList/?$', 'app.views.appointmentTeacherList'),
    #取得教练的预约日历
    url(r'^app/appointmentCalendar/?$', 'app.views.appointmentCalendar'),
    #预约
    url(r'^app/createAppointment/?$', 'app.views.createAppointment'),
    #取消预约
    url(r'^app/cancelAppointment/?$', 'app.views.cancelAppointment'),
    #设置预约为缺勤
    url(r'^app/absentAppointment/?$', 'app.views.absentAppointment'),
    #取得一个约车记录
    url(r'^app/appointment/?$', 'app.views.appointment'),

    #学员-取得约车记录
    url(r'^app/studentAppointmentList/?$', 'app.views.studentAppointmentList'),
    #教练-取得约车记录
    url(r'^app/teacherAppointmentList/?$', 'app.views.teacherAppointmentList'),
    #教练-取得某日约车记录
    url(r'^app/teacherAppointmentListOfOneDay/?$', 'app.views.teacherAppointmentListOfOneDay'),
    #新建(更新)评价
    url(r'^app/updateAppointmentEvaluation/?$', 'app.views.updateAppointmentEvaluation'),



    #搜索学员
    url(r'^app/searchSchoolStudent/?$', 'app.views.searchSchoolStudent'),

    #记录日志
    url(r'^app/log/?$', 'app.views.log'),

    #统计-进入公众号的次数
    url(r'^app/statistic/mp_enter/(.+)/?$', 'app.statistic_views.mp_enter'),
]

