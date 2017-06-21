#coding=utf-8
import datetime,os,base64,thread,time
from itertools import chain
from django.shortcuts import render
from django.conf import settings
from django.http import HttpResponse, HttpResponseRedirect, StreamingHttpResponse,HttpResponseNotFound
from django.db import transaction
from django import  forms
from common.utils import *
from common.mimetype import *
from im.models import *
from app.rcapi import *
from PIL import Image
from app.decorators import *

_logger = logging.getLogger('app')

#返回服务器版本号
@catchexception
def version(request):
    return jsonResponse(getHRD(data='0001'))

#获取图片
@catchexception
def image(request,imageid):
    image=ImageStore.getWithId(imageid)
    if image!=None:
        imageFile=image.filepath
        imageFile=os.path.join(settings.IMAGE_PATH,imageFile)
        if not os.path.exists(imageFile):
            return HttpResponseNotFound()
        extname=imageFile[imageFile.find('.'):]
        mimetype=getMimeType(extname)
        response = StreamingHttpResponse(file_iterator(imageFile),content_type=mimetype)
        filesize=os.path.getsize(imageFile)
        response['Content-Length']=filesize
        return response
    else:
        return HttpResponseNotFound()

#发送短信验证码
@catchexception
def sendSMSCode(request):
    ret=jsonResponse({})
    phone=readFromDict(request.REQUEST,'phone')
    if not checkPhoneNumber(phone):
        return jsonResponse(getHRD(code=1,msg='无效的手机号'))

    smscode=SMSCode.getValidSMSCode(phone)
    if smscode==None:
        smscode=SMSCode.genNewSMSCode(phone)
    _logger.info('smscode: %s'%(smscode))
    return jsonResponse(getHRD(data={'phone':phone,'smscode':smscode}))


#用户注册
@catchexception
def userReg(request):
    phone=readFromDict(request.REQUEST,'phone')
    smscode=readFromDict(request.REQUEST,'smscode')
    name=readFromDict(request.REQUEST,'name')
    idcard=readFromDict(request.REQUEST,'idcard')
    gender=readFromDict(request.REQUEST,'gender')
    password=readFromDict(request.REQUEST,'password')
    if not checkPhoneNumber(phone):
        return jsonResponse(getHRD(code=1,msg='无效的手机号'))
    if idcard!=None and not checkIDCard(idcard):
        return jsonResponse(getHRD(code=2,msg='无效的身份证号'))
    if password==None:
        return jsonResponse(getHRD(code=3,msg='需要输入密码'))
    if not SMSCode.verifySMSCode(phone,smscode):
        return jsonResponse(getHRD(code=4,msg='验证码无效'))

    if gender!=None and not Person.validGender(gender):
        gender=Person.defaultGender()

    person=Person.getWithPhone(phone)
    if person!=None:
        return jsonResponse(getHRD(code=5,msg='用户已存在'))


    # 允许重复的自然人存在
    person=Person.create(phone=phone,name=name,idcard=idcard,gender=gender,password=password,nickname='乐友')
    if person==None:
        return jsonResponse(getHRD(code=6,msg='创建用户失败'))

    try:
        rc_user_token=person.getRCUserToken()
    except Exception,e:
        return jsonResponse(getHRD(code=7,msg='获取rc_user_token失败,请管理员查看社交系统账户数量设置'))

    data={'person':person.toJson(),'rc_user_token':rc_user_token}
    return jsonResponse(getHRD(data=data))

#密码重置
@catchexception
def resetPassword(request):
    phone=readFromDict(request.REQUEST,'phone')
    smscode=readFromDict(request.REQUEST,'smscode')
    password=readFromDict(request.REQUEST,'password')
    if not checkPhoneNumber(phone):
        return jsonResponse(getHRD(code=1,msg='无效的手机号'))
    if password==None:
        return jsonResponse(getHRD(code=3,msg='需要输入密码'))
    if not SMSCode.verifySMSCode(phone,smscode):
        return jsonResponse(getHRD(code=4,msg='验证码无效'))

    person=Person.getWithPhone(phone)
    if person==None:
        return jsonResponse(getHRD(code=5,msg='用户不存在'))

    Auth.setNewPasswordForPerson(person.id,password)
    return jsonResponse(getHRD(data=person.toJson()))

#用户登录
@catchexception
def userLogin(request):
    username=readFromDict(request.REQUEST,'username') #可以是手机号，用户名，邮箱
    password=readFromDict(request.REQUEST,'password')
    deviceid=readFromDict(request.REQUEST,'deviceid')

    person=Person.getWithFuzzy(username)
    if person==None or not Auth.verifyPassword(person.id,password):
        return jsonResponse(getHRD(code=1,msg='登录失败'))

    token=AccessToken.genNewTokenWithPerson(person,deviceid,7200)
    if token==None:
        return jsonResponse(getHRD(code=2,msg='获取令牌失败'))

    token_data=token.toJson()
    data={'person':person.toJson(),'rc_user_token':person.getRCUserToken(),'access_token':token_data}
    return jsonResponse(getHRD(data=data))

#刷新访问令牌
@catchexception
def refreshToken(request):
    personid=readFromDict(request.REQUEST,'personid') #可以是手机号，用户名，邮箱
    deviceid=readFromDict(request.REQUEST,'deviceid')
    oldtoken=readFromDict(request.REQUEST,'oldtoken')

    person=Person.getWithId(personid)
    if person==None:
        return jsonResponse(getHRD(code=1,msg='用户不存在'))

    token=AccessToken.refreshTokenWithPerson(person,deviceid,oldtoken,7200)
    if token==None:
        return jsonResponse(getHRD(code=2,msg='获取令牌失败'))

    data=token.toJson()
    return jsonResponse(getHRD(data=data))

#找找新好友
@auth
def searchPerson(request):
    username=readFromDict(request.REQUEST,'username')

    if username==None:
        return jsonResponse(getHRD(code=1,msg='需要查找什么'))

    person=Person.getWithFuzzy(username)
    if person==None:
        return jsonResponse(getHRD(code=2,msg='用户不存在'))
    return jsonResponse(getHRD(data=person.toJson()))

#判断第二个用户是否为第一个用户的好友
@auth
def isFriend(request):
    myid=readFromDict(request.REQUEST,'myid')
    otherid=readFromDict(request.REQUEST,'otherid')
    data={'isfriend':'0'}
    if myid!=otherid:
        person=Person.getWithId(myid)
        if person!=None and person.isFriendWithPersonid(otherid):
            data['isfriend']='1'
    else:
        data['isfriend']='1'
    return jsonResponse(getHRD(data=data))

#获取用户信息
@auth
def person(request):
    personid=readFromDict(request.REQUEST,'id')
    person=Person.getWithId(personid)
    if person==None:
        return jsonResponse(getHRD(code=1,msg='没找到信息'))
    img,path=person.genQRCode()
    return jsonResponse(getHRD(data=person.toJson()))

#获取用户二维码
@auth
def personQRCode(request):
    personid=readFromDict(request.REQUEST,'id')
    person=Person.getWithId(personid)
    if person==None:
        return HttpResponseNotFound()
    
    qrcodePath=person.getQRCodeFilepath()
    if not os.path.exists(qrcodePath):
        person.genQRCode()
    
    extname=qrcodePath[qrcodePath.find('.'):]
    mimetype=getMimeType(extname)
    response = StreamingHttpResponse(file_iterator(qrcodePath),content_type=mimetype)
    filesize=os.path.getsize(qrcodePath)
    response['Content-Length']=filesize
    return response

#更新用户信息
@auth
def updatePerson(request):
    personid=readFromDict(request.REQUEST,'personid')
    # phone=readFromDict(request.REQUEST,'phone')
    # username=readFromDict(request.REQUEST,'username')
    email=readFromDict(request.REQUEST,'email')
    name=readFromDict(request.REQUEST,'name')
    idcard=readFromDict(request.REQUEST,'idcard')
    gender=readFromDict(request.REQUEST,'gender')

    nickname=readFromDict(request.REQUEST,'nickname')
    introduction=readFromDict(request.REQUEST,'introduction')

    person=Person.getWithId(personid)
    if person==None:
        return jsonResponse(getHRD(code=1,msg='用户不存在'))
    #手机号不能修改
    # #用户名只能设置一次并且不能重复
    # if (person.username==None or len(person.username)==0) and (username!=None and len(username)>0) and Person.usernameIsAvailable(username):
    #     person.username=username
    #电子邮件不能重复
    if person.email!=email and Person.emailIsAvailable(email):
        person.email=email
    if person.name!=name:
        person.name=name
    if person.idcard!=idcard:
        person.idcard=idcard
    if person.gender!=gender:
        person.gender=gender
    person.save()

    social=person.social
    if social==None:
        social=Social()
        social.person=person
    social.nickname=nickname
    social.introduction=introduction

    social.save()
    return jsonResponse(getHRD(data=person.toJson()))

#更新用户名
@auth
def updatePersonUsername(request):
    personid=readFromDict(request.REQUEST,'personid')
    username=readFromDict(request.REQUEST,'username')

    if username==None or len(username)==0:
        return jsonResponse(getHRD(code=4,msg='请输入用户名'))

    person=Person.getWithId(personid)
    if person==None:
        return jsonResponse(getHRD(code=1,msg='用户不存在'))
    #用户名只能设置一次并且不能重复
    if person.username!=None and len(person.username)>0:
        return jsonResponse(getHRD(code=2,msg='用户名只能设置一次'))
    if not Person.usernameIsAvailable(username):
        return jsonResponse(getHRD(code=3,msg='用户名已被使用'))

    person.username=username
    person.save()
    return jsonResponse(getHRD(data=person.toJson()))


# 更新用户地区
@auth
def updatePersonArea(request):
    personid=readFromDict(request.REQUEST,'personid')
    areaid=readFromDict(request.REQUEST,'areaid')

    person=Person.getWithId(personid)
    if person==None:
        return jsonResponse(getHRD(code=1,msg='用户不存在'))
    area=Area.getWithId(areaid)
    if area==None:
        return jsonResponse(getHRD(code=2,msg='地区不存在'))
    person.area=area;
    person.save()
    return jsonResponse(getHRD(data=person.toJson()))

#更新用户头像
@auth
def updateHeadImage(request):
    if request.method=='POST':
        personid=readFromDict(request.REQUEST,'personid')
        headimage_obj=request.FILES.get('headimage', None)
        if headimage_obj == None:
            return jsonResponse(getHRD(code=1,msg='没有找到上传的图片'))

        originImageFile=None
        try:
            #保存原始图片
            originImageFilepath=Person.genOriginHeadImageFilepath(personid)
            originImageFile=open(originImageFilepath,'wb')
            originImageFile.write(headimage_obj.read())
            originImageFile.close()

            imageFilepath=Person.genHeadImageFilepath(personid)
            image=Image.open(originImageFilepath)
            w,h=image.size
            if w>h:
                h=int(float(h)/float(w)*180)
                w=180
            else:
                w=int(float(w)/float(h)*180)
                h=180
            image.resize((w,h)).save(imageFilepath,'png')

            # groups=ChatGroup.search(personid)
            # for g in groups:
            #     g.genGroupImage()
            thread.start_new_thread(updateGroupImage, (personid,))

        except Exception,e:
            _logger.exception(e)
            return jsonResponse(getHRD(code=2,msg='系统错误'))
        finally:
            if originImageFile!=None:
                originImageFile.close()
    return jsonResponse(getHRD())

#更新群组图像
updateGroupImage_lock = thread.allocate_lock()
@auth
def updateGroupImage(personid):
    updateGroupImage_lock.acquire()
    try:
        groups=ChatGroup.search(personid)
        for g in groups:
            g.genGroupImage()
    except Exception,e:
        _logger.exception(e)
    finally:
        updateGroupImage_lock.release()
        thread.exit_thread()

#获取用户头像
@auth
def headImage(request):
    personid=readFromDict(request.REQUEST,'personid')
    imageFile=Person.genHeadImageFilepath(personid)
    if not os.path.exists(imageFile):
        return HttpResponseNotFound()
    extname=imageFile[imageFile.find('.'):]
    mimetype=getMimeType(extname)
    response = StreamingHttpResponse(file_iterator(imageFile),content_type=mimetype)
    filesize=os.path.getsize(imageFile)
    response['Content-Length']=filesize
    return response

#获取用户原始头像
@auth
def originHeadImage(request):
    personid=readFromDict(request.REQUEST,'personid')
    imageFile=Person.genOriginHeadImageFilepath(personid)
    if not os.path.exists(imageFile):
        return HttpResponseNotFound()
    extname=imageFile[imageFile.find('.'):]
    mimetype=getMimeType(extname)
    response = StreamingHttpResponse(file_iterator(imageFile),content_type=mimetype)
    filesize=os.path.getsize(imageFile)
    response['Content-Length']=filesize
    return response

#获取用户的通讯录
@auth
def contacts(request):

    # time.sleep(5)
    personid=readFromDict(request.REQUEST,'personid')
 
    contactbook=ContactBook.getWithPersonid(personid)
    if contactbook==None:
        return jsonResponse(getHRD(code=1,msg='用户不存在'))

    contacts=contactbook.contacts.all()
    data=[]
    for c in contacts:
        data.append(c.person.toJson())
    return jsonResponse(getHRD(data=data))

#添加好友到通讯录
@auth
def addContacts(request):
    personid=readFromDict(request.REQUEST,'personid')
    friendid=readFromDict(request.REQUEST,'friendid')

    contactbook=ContactBook.getWithPersonid(personid)
    if contactbook==None:
        return jsonResponse(getHRD(code=1,msg='用户不存在'))

    friend=Person.getWithId(friendid)
    if friend==None:
        return jsonResponse(getHRD(code=2,msg='好友用户不存在'))

    contactbook.addContacts(friend)
    return jsonResponse(getHRD())

#查找手机号是否
@auth
def searchPhones(request):
    phones=readFromDict(request.REQUEST,'phones')
    phones=phones.split(',')

    persons=Person.searchWithPhones(phones)
    data=[]
    for p in persons:
        data.append(p.toJson())
    return jsonResponse(getHRD(data=data))

#发起群聊
@auth
def createChatGroup(request):
    ownerid=readFromDict(request.REQUEST,'ownerid')
    persons=readFromDict(request.REQUEST,'persons')
    persons=persons.split(',')

    chatGroup=ChatGroup.create(ownerid,persons)
    if(chatGroup==None):
        return jsonResponse(getHRD(code=1,msg='创建群聊失败'))

    user_id_list=chatGroup.member_id_list()
    groupid=chatGroup.id
    groupname=chatGroup.name
    if not rc_group_create(user_id_list,groupid,groupname):
        chatGroup.delete()
        return jsonResponse(getHRD(code=2,msg='聊天服务异常'))

    return jsonResponse(getHRD(data=chatGroup.toJson()))

#获取群信息
@auth
def chatGroup(request):
    groupid=readFromDict(request.REQUEST,'groupid')
    group=ChatGroup.getWithId(groupid)
    if group==None:
        return jsonResponse(getHRD(code=1,msg='没有找到群'))
    return jsonResponse(getHRD(data=group.toJson()))


#添加成员到群
@auth
def addPersonToChatGroup(request):
    operatorid=readFromDict(request.REQUEST,'operatorid')
    persons=readFromDict(request.REQUEST,'persons')
    groupid=readFromDict(request.REQUEST,'groupid')
    persons=persons.split(',')
    group=ChatGroup.getWithId(groupid)
    if group==None:
        return jsonResponse(getHRD(code=1,msg='群组不存在'))

    if not group.isMember(operatorid):
        return jsonResponse(getHRD(code=2,msg='操作者不是群组成员'))

    group.addMember(persons)

    return jsonResponse(getHRD())
    
#从群中删除成员
@auth
def removePersonFromChatGroup(request):
    personid=readFromDict(request.REQUEST,'personid')
    groupid=readFromDict(request.REQUEST,'groupid')
    group=ChatGroup.getWithId(groupid)
    if group!=None:
        group.removeMember(personid)
    return jsonResponse(getHRD())

#设置群名称
@auth
def updateChatGroupName(request):
    groupid=readFromDict(request.REQUEST,'groupid')
    groupname=readFromDict(request.REQUEST,'groupname')
    group=ChatGroup.getWithId(groupid)
    if group==None:
        return jsonResponse(getHRD(code=1,msg='群组不存在'))
    group.updateName(groupname)
    return jsonResponse(getHRD(data=group.toJson()))

#查找群
@auth
def searchChatGroup(request):
    personid=readFromDict(request.REQUEST,'personid')
    result=ChatGroup.search(personid)
    data=[]
    for r in result:
        data.append(r.toJson())
    
    return jsonResponse(getHRD(data=data))

#获取群组头像
@auth
def groupImage(request):
    groupid=readFromDict(request.REQUEST,'groupid')
    imageFile=ChatGroup.genImageFilepath(groupid)
    if not os.path.exists(imageFile):
        return HttpResponseNotFound()
    extname=imageFile[imageFile.find('.'):]
    mimetype=getMimeType(extname)
    response = StreamingHttpResponse(file_iterator(imageFile),content_type=mimetype)
    filesize=os.path.getsize(imageFile)
    response['Content-Length']=filesize
    return response


#获取地区数据版本
@auth
def areaVersion(request):
    areaVersion=Dictionary.areaVersion()
    return jsonResponse(getHRD(data=areaVersion))

#获取地区数据
@auth
def area(request):
    allArea=Area.toDict()
    return jsonResponse(getHRD(data=allArea))


#获得驾校信息
@auth
def school(request):
    schoolid=readFromDict(request.REQUEST,'schoolid')
    school=School.getWithId(schoolid)
    if school==None:
        return jsonResponse(getHRD(code=1,msg='驾校不存在'))
    return jsonResponse(getHRD(data=school.toJson()))

#搜索驾校
@auth
def searchSchool(request):
    searchkey=readFromDict(request.REQUEST,'searchkey')
    start=readIntFromDict(request.REQUEST,'start')
    offset=readIntFromDict(request.REQUEST,'offset')
    fuzzy=readIntFromDict(request.REQUEST,'fuzzy')
    if len(searchkey)==0:
        return jsonResponse(getHRD(code=1,msg='你要查找什么'))

    if offset==0:
        offset=30
    if fuzzy==0:
        result=School.search(searchkey)[start:start+offset]
    else:
        result=School.searchFuzzy(searchkey)[start:start+offset]

    if len(result)==0:
        return jsonResponse(getHRD(code=2,msg='没有找到符合的驾校'))

    data=[]
    for school in result:
        data.append(school.toJson())
    return jsonResponse(getHRD(data=data))

#创建驾校
@auth
def createSchool(request):
    schoolname=readFromDict(request.REQUEST,'schoolname')
    areaid=readFromDict(request.REQUEST,'areaid')
    school=School.create(name=schoolname,areaid=areaid)
    return jsonResponse(getHRD(data=school.toJson()))

#创建学员身份
@auth
def createStudent(request):
    personid=readFromDict(request.REQUEST,'personid')
    schoolid=readFromDict(request.REQUEST,'schoolid')
    status=readFromDict(request.REQUEST,'status')
    km1score=readIntFromDict(request.REQUEST,'km1score')
    km2score=readIntFromDict(request.REQUEST,'km2score')
    km3ascore=readIntFromDict(request.REQUEST,'km3ascore')
    km3bscore=readIntFromDict(request.REQUEST,'km3bscore')
    signupdate=readFromDict(request.REQUEST,'signupdate')
    licencedate=readFromDict(request.REQUEST,'licencedate')

    available=readIntFromDict(request.REQUEST,'available')

    student=Student.create(personid,schoolid)
    if student==None:
        return jsonResponse(getHRD(code=1,msg='创建学员失败'))
    student.status=status
    student.km1score=km1score
    student.km2score=km2score
    student.km3ascore=km3ascore
    student.km3bscore=km3bscore
    student.signupdate=parseDate(signupdate)
    student.licencedate=parseDate(licencedate)
    student.save()

    if available>0:
        student.person.setCharacterWithObj(student)

    return jsonResponse(getHRD(data=student.toJson()))


#删除学员身份
@auth
def deleteStudent(request):
    studentid=readFromDict(request.REQUEST,'studentid')
    student=Student.deleteWithId(studentid)

    if student==None:
        return jsonResponse(getHRD())
    else:
        return jsonResponse(getHRD(data=student.toJson()))

#取得学员身份
@auth
def student(request):
    studentid=readFromDict(request.REQUEST,'studentid')
    student=Student.getWithId(studentid)
    if student==None:
        return jsonResponse(getHRD(code=1,msg='找不到学员信息'))
    return jsonResponse(getHRD(data=student.toJson()))

#创建教练身份
@auth
def createTeacher(request):
    personid=readFromDict(request.REQUEST,'personid')
    schoolid=readFromDict(request.REQUEST,'schoolid')
    skills=readFromDict(request.REQUEST,'skills')
    skills=skills.split(',')
    available=readIntFromDict(request.REQUEST,'available')

    teacher=Teacher.create(personid,schoolid,skills)
    if teacher==None:
        return jsonResponse(getHRD(code=1,msg='创建教练失败'))

    if available>0:
        teacher.person.setCharacterWithObj(teacher)

    return jsonResponse(getHRD(data=teacher.toJson()))


#删除教练身份
@auth
def deleteTeacher(request):
    teacherid=readFromDict(request.REQUEST,'teacherid')
    obj=Teacher.deleteWithId(teacherid)

    if obj==None:
        return jsonResponse(getHRD())
    else:
        return jsonResponse(getHRD(data=obj.toJson()))


#取得教练对象
@auth
def teacher(request):
    teacherid=readFromDict(request.REQUEST,'teacherid')
    teacher=Teacher.getWithId(teacherid)
    if teacher==None:
        return jsonResponse(getHRD(code=1,msg='找不到教练'))
    return jsonResponse(getHRD(data=teacher.toJson()))



#我的所有教练身份
@auth
def allTeacherCharacter(request):
    personid=readFromDict(request.REQUEST,'personid')
    teachers=Teacher.getTeacherWithPersonid(personid)
    data=[]
    for t in teachers:
        data.append(t.toJson())
    return jsonResponse(getHRD(data=data))

#返回当前有效身份
@auth
def availableCharacter(request):
    personid=readFromDict(request.REQUEST,'personid')
    person=Person.getWithId(personid)
    if person==None:
        return jsonResponse(getHRD(code=1,msg='用户不存在'))
    character=person.getCharacter()
    characterType=''
    obj=None
    if isinstance(character,Teacher):
        characterType='teacher'
        obj=character.toJson()
    if isinstance(character,Student):
        characterType='student'
        obj=character.toJson()
    if isinstance(character,CustomerService):
        characterType='customerservice'
        obj=character.toJson()
    if isinstance(character,Operation):
        characterType='operation'
        obj=character.toJson()
    return jsonResponse(getHRD(data={'character_type':characterType,'obj':obj}))

#设置当前有效身份
@auth
def setAvailableCharacter(request):
    personid=readFromDict(request.REQUEST,'personid')
    charactertype=readFromDict(request.REQUEST,'character_type')
    characterid=readFromDict(request.REQUEST,'characterid')
    person=Person.getWithId(personid)
    if person==None:
        return jsonResponse(getHRD(code=1,msg='用户不存在'))
    person.setCharacter(charactertype,characterid)
    return  jsonResponse(getHRD())

#字典数据
@auth
def dictdata(request):
    dictname=readFromDict(request.REQUEST,'dictname')
    skills=Dictionary.getWithName(dictname)
    data=[]
    for s in skills:
        data.append(s.toJson())
    return jsonResponse(getHRD(data=data))


#关注驾校
@auth
def interestSchool(request):
    personid=readFromDict(request.REQUEST,'personid')
    schoolid=readFromDict(request.REQUEST,'schoolid')

    person=Person.getWithId(personid)
    if person==None:
        return jsonResponse(getHRD(code=1,msg='用户不存在'))

    school=person.interestSchool(schoolid)
    if school==None:
        return jsonResponse(getHRD(code=2,msg='关注失败'))
    return jsonResponse(getHRD(data=school.toJson()))

#取消关注驾校
@auth
def uninterestSchool(request):
    personid=readFromDict(request.REQUEST,'personid')
    schoolid=readFromDict(request.REQUEST,'schoolid')

    person=Person.getWithId(personid)
    if person==None:
        return jsonResponse(getHRD(code=1,msg='用户不存在'))

    school=person.uninterestSchool(schoolid)
    if school==None:
        return jsonResponse(getHRD(code=2,msg='取消关注失败'))
    return jsonResponse(getHRD(data=school.toJson()))


#是否关注了驾校
@auth
def isInterestedSchool(request):
    personid=readFromDict(request.REQUEST,'personid')
    schoolid=readFromDict(request.REQUEST,'schoolid')

    person=Person.getWithId(personid)
    if person==None:
        return jsonResponse(getHRD(code=1,msg='用户不存在'))

    data=person.isInterestSchool(schoolid)
    return jsonResponse(getHRD(data=data))

#公众号-驾校列表
@auth
def myInterestSchoolList(request):
    personid=readFromDict(request.REQUEST,'personid')
    start=readIntFromDict(request.REQUEST,'start')
    offset=readIntFromDict(request.REQUEST,'offset')
    if offset==0:
        offset=30

    person=Person.getWithId(personid)
    if person==None:
        return jsonResponse(getHRD(code=1,msg='用户不存在'))    

    result=person.interestedSchoolList()[start:start+offset]
    if len(result)==0:
        return jsonResponse(getHRD(code=2,msg='没有找到符合的驾校'))
    data=[]
    for school in result:
        data.append(school.toJson())
    return jsonResponse(getHRD(data=data))

#驾校报名
@auth
def schoolSignup(request):
    personid=readFromDict(request.REQUEST,'personid')
    schoolid=readFromDict(request.REQUEST,'schoolid')
    classid=readFromDict(request.REQUEST,'classid')
    name=readFromDict(request.REQUEST,'name')
    phone=readFromDict(request.REQUEST,'phone')
    gender=readFromDict(request.REQUEST,'gender')
    age=readFromDict(request.REQUEST,'age')
    address=readFromDict(request.REQUEST,'address')
    remark=readFromDict(request.REQUEST,'remark')
    if gender!=None and not Person.validGender(gender):
        gender=Person.defaultGender()

    signup=SchoolSignup.create(personid,schoolid,classid,name,phone,gender,age,address,remark)
    if signup==None:
        return jsonResponse(getHRD(code=1,msg='报名失败'))
    return jsonResponse(getHRD(data=signup.toJson()))


#驾校报名列表
@auth
def schoolSignupList(request):
    schoolid=readFromDict(request.REQUEST,'schoolid')
    start=readIntFromDict(request.REQUEST,'start')
    offset=readIntFromDict(request.REQUEST,'offset')
    if offset==0:
        offset=30
    showtreated=readFromDict(request.REQUEST,'showtreated')
    showtreated=(showtreated=='1')

    result=SchoolSignup.listWithSchoolid(schoolid,showtreated)[start:start+offset]
    if len(result)==0:
        return jsonResponse(getHRD(code=2,msg='没有找到符合结果'))
    data=[]
    for s in result:
        data.append(s.toJson())
    return jsonResponse(getHRD(data=data))

#更新报名状态
@auth
def updateSchoolSignupStatus(request):
    schoolsignupid=readFromDict(request.REQUEST,'schoolsignupid')
    status=readFromDict(request.REQUEST,'status')
    signup=SchoolSignup.getWithId(schoolsignupid)

    if signup==None:
        return jsonResponse(getHRD(code=1,msg='没有找到报名申请'))
    signup.updateStatus(status)
    return jsonResponse(getHRD(data=signup.toJson()))


#更新驾校介绍
@auth
def updateSchoolIntroduction(request):
    schoolid=readFromDict(request.REQUEST,'schoolid')
    introduction=readFromDict(request.REQUEST,'introduction')
    school=School.getWithId(schoolid)
    if school==None:
        return jsonResponse(getHRD(code=1,msg='没有找到符合的驾校'))
    school.introduction=introduction
    school.save()
    return jsonResponse(getHRD())
    
#更新驾校一景
@auth
def updateSchoolPictures(request):
    schoolid=readFromDict(request.REQUEST,'schoolid')
    school=School.getWithId(schoolid)
    if school==None:
        return jsonResponse(getHRD(code=1,msg='没有找到符合的驾校'))
    for p in school.pictures.all():
        p.deleteAndFile()

    for i in range(0,999):
        pic_name='pic%d'%i
        extname_name='pic%d_format'%i
        value=request.FILES.get(pic_name, None)
        extname=readFromDict(request.REQUEST,extname_name)
        if value==None:
            break;
        if extname==None:
            extname='jpg'
        imageStore=ImageStore.createInLocal(value,extname)
        school.pictures.add(imageStore)

    return jsonResponse(getHRD())


#取得驾校的所有员工
@auth
def schoolStaff(request):
    schoolid=readFromDict(request.REQUEST,'schoolid')
    charactertype=readFromDict(request.REQUEST,'character_type')

    school=School.getWithId(schoolid)
    if school==None:
        return jsonResponse(getHRD(code=1,msg='驾校不存在'))

    data=[]
    for p in school.allStaff(charactertype):
        data.append(p.toJson())
    return jsonResponse(getHRD(data=data))


#创建客服身份
@auth
def createCustomerService(request):
    personid=readFromDict(request.REQUEST,'personid')
    schoolid=readFromDict(request.REQUEST,'schoolid')
    available=readIntFromDict(request.REQUEST,'available')

    customerService=CustomerService.create(personid,schoolid)
    if customerService==None:
        return jsonResponse(getHRD(code=1,msg='创建客服失败'))

    if available>0:
        customerService.person.setCharacterWithObj(customerService)

    return jsonResponse(getHRD(data=customerService.toJson()))

#删除客服身份
@auth
def deleteCustomerService(request):
    customerserviceid=readFromDict(request.REQUEST,'customerserviceid')
    obj=CustomerService.deleteWithId(customerserviceid)

    if obj==None:
        return jsonResponse(getHRD())
    else:
        return jsonResponse(getHRD(data=obj.toJson()))

#搜索所有客服身份
@auth
def allCustomerServiceCharacter(request):
    personid=readFromDict(request.REQUEST,'personid')
    customerServices=CustomerService.getWithPersonid(personid)
    data=[]
    for t in customerServices:
        data.append(t.toJson())
    return jsonResponse(getHRD(data=data))


#创建运营身份
@auth
def createOperation(request):
    personid=readFromDict(request.REQUEST,'personid')
    schoolid=readFromDict(request.REQUEST,'schoolid')
    available=readIntFromDict(request.REQUEST,'available')

    obj=Operation.create(personid,schoolid)
    if obj==None:
        return jsonResponse(getHRD(code=1,msg='创建运营失败'))

    if available>0:
        obj.person.setCharacterWithObj(obj)
    return jsonResponse(getHRD(data=obj.toJson()))

#删除运营身份
@auth
def deleteOperation(request):
    operationid=readFromDict(request.REQUEST,'operationid')
    obj=Operation.deleteWithId(operationid)

    if obj==None:
        return jsonResponse(getHRD())
    else:
        return jsonResponse(getHRD(data=obj.toJson()))

#搜索所有运营身份
@auth
def allOperationCharacter(request):
    personid=readFromDict(request.REQUEST,'personid')
    objs=Operation.getWithPersonid(personid)
    data=[]
    for t in objs:
        data.append(t.toJson())
    return jsonResponse(getHRD(data=data))

#搜索所有身份
@auth
def allCharacter(request):
    personid=readFromDict(request.REQUEST,'personid')

    objs=list(chain(
        Student.getWithPersonid(personid)
        ,CustomerService.getWithPersonid(personid)
        ,Teacher.getTeacherWithPersonid(personid)
        ,Operation.getWithPersonid(personid)
        ))
    objs.sort(key=lambda x:x.modifydate,reverse=True)
    data=[]
    for t in objs:
        charactertype=None
        if isinstance(t,Student):
            charactertype='student'
        elif isinstance(t,Teacher):
            charactertype='teacher'
        elif isinstance(t,CustomerService):
            charactertype='customerservice'
        elif isinstance(t,Operation):
            charactertype='operation'
        if charactertype!=None:
            data.append({'character_type':charactertype,'obj':t.toJson()})
    return jsonResponse(getHRD(data=data))




#运营提交认证申请
@auth
def submitOperationCertificate(request):
    try:
        operationid=readFromDict(request.REQUEST,'operationid')
        operation=Operation.getWithId(operationid)
        if operation==None:
            return jsonResponse(getHRD(code=1,msg='运营帐号不存在'))
        if operation.certified:
            return jsonResponse(getHRD(code=3,msg='已通过认证'))
        summary=readFromDict(request.REQUEST,'summary')
        summary=json.loads(summary)

        items=[]
        for i in range(0,len(summary)):
            d=summary[i]
            item={}
            name=d['name']
            item['name']=name
            item['desc']=d['desc']
            d_type=''
            if 'type' in d:
                d_type=d['type']
            format=''
            if 'format' in d:
                format=d['format']
            value=''
            if d_type=='pic':
                value=request.FILES.get(name, None)
                value=ImageStore.createInLocal(value,format)
            else:
                value=readFromDict(request.REQUEST,name)
            item['value']=value
            item['order']=i
            items.append(item)

        OperationCertificate.create(operation,items)
    except Exception,e:
        _logger.exception(e)
        return jsonResponse(getHRD(code=2,msg='数据异常'))
    return jsonResponse(getHRD())

#获取运营提交的认证申请
@auth
def operationCertificate(request):
    operationid=readFromDict(request.REQUEST,'operationid')
    operation=Operation.getWithId(operationid)
    if operation==None:
        return jsonResponse(getHRD(code=1,msg='运营帐号不存在'))

    operationcertificate=OperationCertificate.getWithOperationid(operationid)
    if operationcertificate==None:
        return jsonResponse(getHRD(code=2,msg='没有认证申请'))
    data=[]
    for item in operationcertificate.item.all():
        data.append(item.toJson())

    return jsonResponse(getHRD(data=data))

#撤销运营提交的认证申请
@auth
def revokeOperationCertificate(request):
    operationid=readFromDict(request.REQUEST,'operationid')
    operation=Operation.getWithId(operationid)
    if operation==None:
        return jsonResponse(getHRD(code=1,msg='运营帐号不存在'))
    if operation.certified:
        return jsonResponse(getHRD(code=3,msg='已通过认证'))
    operationcertificate=OperationCertificate.getWithOperationid(operationid)
    if operationcertificate==None:
        return jsonResponse(getHRD(code=2,msg='没有认证申请'))
    operationcertificate.revoke()
    return jsonResponse(getHRD())


#认证身份
@auth
def certify(request):
    operationid=readFromDict(request.REQUEST,'operationid')
    charactertype=readFromDict(request.REQUEST,'character_type')
    characterid=readFromDict(request.REQUEST,'characterid')
    certify=readFromDict(request.REQUEST,'certify')

    operation=Operation.getWithId(operationid)
    if operation==None:
        return jsonResponse(getHRD(code=1,msg='运营账号不存在'))
    if not operation.certified:
        return jsonResponse(getHRD(code=2,msg='运营账号必须是已认证'))

    character=None
    if charactertype=='student':
        character=Student.getWithId(characterid)
    elif charactertype=='teacher':
        character=Teacher.getWithId(characterid)
    elif charactertype=='customerservice':
        character=CustomerService.getWithId(characterid)
    elif charactertype=='operation':
        character=Operation.getWithId(characterid)

    if character==None:
        return jsonResponse(getHRD(code=3,msg='指定的人员身份不存在'))

    if operation.school.id!=character.school.id:
        return jsonResponse(getHRD(code=4,msg='不能认证不同驾校的员工'))


    character.certify((certify=='1'))
    return jsonResponse(getHRD())


#添加驾校课程
@auth
def addSchoolClass(request):
    operationid=readFromDict(request.REQUEST,'operationid')
    name=readFromDict(request.REQUEST,'name')
    cartype=readFromDict(request.REQUEST,'cartype')
    licensetype=readFromDict(request.REQUEST,'licensetype')
    trainingtime=readFromDict(request.REQUEST,'trainingtime')
    fee=readIntFromDict(request.REQUEST,'fee')
    realfee=readIntFromDict(request.REQUEST,'realfee')
    expiredate=readFromDict(request.REQUEST,'expiredate')
    remark =readFromDict(request.REQUEST,'remark')



    operation=Operation.getWithId(operationid)
    if operation==None:
        return jsonResponse(getHRD(code=1,msg='运营账号不存在'))
    if not operation.certified:
        return jsonResponse(getHRD(code=2,msg='运营账号必须是已认证'))

    schoolClass=SchoolClasses()
    schoolClass.name=name
    schoolClass.cartype=cartype
    schoolClass.licensetype=licensetype
    schoolClass.trainingtime=trainingtime
    schoolClass.fee=fee
    schoolClass.realfee=realfee
    schoolClass.expiredate=expiredate
    schoolClass.remark=remark
    schoolClass.school=operation.school
    schoolClass.save()
    return jsonResponse(getHRD())

#驾校所有的课程
@auth
def allSchoolClass(request):
    schoolid=readFromDict(request.REQUEST,'schoolid')
    classes=SchoolClasses.allClassWithSchoolid(schoolid)
    data=[]
    for c in classes:
        data.append(c.toJson())
    return jsonResponse(getHRD(data=data))

#更改课程状态
@auth
def changeStatusSchoolClass(request):
    operationid=readFromDict(request.REQUEST,'operationid')
    schoolclassid=readFromDict(request.REQUEST,'schoolclassid')
    status=readFromDict(request.REQUEST,'status')

    operation=Operation.getWithId(operationid)
    if operation==None:
        return jsonResponse(getHRD(code=1,msg='运营账号不存在'))
    if not operation.certified:
        return jsonResponse(getHRD(code=2,msg='运营账号必须是已认证'))

    schoolclass=SchoolClasses.getWithId(schoolclassid)
    if schoolclass==None:
        return jsonResponse(getHRD(code=3,msg='课程不存在'))

    if operation.school.id!=schoolclass.school.id:
        return jsonResponse(getHRD(code=4,msg='不能操作其他驾校的课程'))

    schoolclass.status=status
    schoolclass.save()
    return jsonResponse(getHRD())

#获取教练所有课表
@auth
def teacherAllTimeTable(request):
    teacherid=readFromDict(request.REQUEST,'teacherid')
    teacher=Teacher.getWithId(teacherid)
    if teacher==None:
        return jsonResponse(getHRD(code=1,msg='找不到教练信息'))
    
    timetables=CourseTimeTable.getWithTeacherid(teacherid)
    data=[]
    for c in timetables:
        data.append(c.toJson())
    return jsonResponse(getHRD(data=data))

#删除课表
@auth
def deleteTeacherTimeTable(request):
    timetableid=readFromDict(request.REQUEST,'timetableid')
    timetable=CourseTimeTable.getWithId(timetableid)
    if timetable!=None:
        timetable.deleted=True
    return jsonResponse(getHRD())

#启用课表
@auth
def enableTeacherTimeTable(request):
    timetableid=readFromDict(request.REQUEST,'timetableid')
    timetable=CourseTimeTable.getWithId(timetableid)
    if timetable!=None:
        timetable.enabled=True
    return jsonResponse(getHRD())
#停用课表
@auth
def disableTeacherTimeTable(request):
    timetableid=readFromDict(request.REQUEST,'timetableid')
    timetable=CourseTimeTable.getWithId(timetableid)
    if timetable!=None:
        timetable.enabled=False
    return jsonResponse(getHRD())

#修改课表
@auth
def updateTeacherTimeTable(request):
    timetableid=readFromDict(request.REQUEST,'timetableid')
    name=readFromDict(request.REQUEST,'name')
    publishdate=readFromDict(request.REQUEST,'publishdate')
    expiredate=readFromDict(request.REQUEST,'expiredate')
    if publishdate!=None:
        publishdate=parseDate(publishdate)
    if expiredate!=None:
        expiredate=parseDate(expiredate)

    timetable=CourseTimeTable.getWithId(timetableid)
    if timetable==None:
        return jsonResponse(getHRD(code=1,msg='没有课程表'))

    if name!=None or publishdate!=None or expiredate!=None:
        if name!=None:
            timetable.name=name
        if publishdate!=None:
            timetable.publishdate=publishdate
        if expiredate!=None:
            timetable.expiredate=expiredate

    return jsonResponse(getHRD(timetable.toJson()))

#获取教练课程
@auth
def teacherTimeTable(request):
    timetableid=readFromDict(request.REQUEST,'timetableid')
    timetable=CourseTimeTable.getWithId(timetableid)
    if timetable==None:
        return jsonResponse(getHRD(code=1,msg='没有课程表'))

    return jsonResponse(getHRD(data=timetable.toJson()))


#获取教练课程
@auth
def teacherCourse(request):
    courseid=readFromDict(request.REQUEST,'courseid')
    course=Course.getWithId(courseid)
    if course==None:
        return jsonResponse(getHRD(code=1,msg='没有课程'))

    return jsonResponse(getHRD(data=course.toJson()))


#添加(更新)教练课程
@auth
def updateTeacherCourse(request):
    teacherid=readFromDict(request.REQUEST,'teacherid')
    timetableid=readFromDict(request.REQUEST,'timetableid')
    teacher=Teacher.getWithId(teacherid)
    if teacher==None:
        return jsonResponse(getHRD(code=1,msg='找不到教练信息'))

    timetable=None
    if timetableid==None:
        timetable=CourseTimeTable()
        timetable.teacher=teacher
        timetable.enabled=True
        timetable.name='未命名课表'
        timetable.save()

    else:
        timetable=teacher.timetable.filter(id=timetableid).first()
        if timetable==None:
            return jsonResponse(getHRD(code=2,msg='找不到课表信息'))
    for i in range(0,999):
        key_courseid='courseid_%d'%(i)
        key_deleted='deleted_%d'%(i)
        key_weekday='weekday_%d'%(i)
        key_starttime='starttime_%d'%(i)
        key_endtime='endtime_%d'%(i)
        key_course='course_%d'%(i)
        key_studentnum='studentnum_%d'%(i)
        key_remark='remark_%d'%(i)
        courseid=readFromDict(request.REQUEST,key_courseid)
        deleted=readIntFromDict(request.REQUEST,key_deleted,0)
        weekday=readIntFromDict(request.REQUEST,key_weekday,0)
        starttime=readFromDict(request.REQUEST,key_starttime)
        endtime=readFromDict(request.REQUEST,key_endtime)
        course=readFromDict(request.REQUEST,key_course)
        studentnum=readIntFromDict(request.REQUEST,key_studentnum,1)
        remark=readFromDict(request.REQUEST,key_remark)
        if starttime==None:
            break
        c=None
        if courseid==None:
            c=Course()
            c.timetable=timetable
            c.teacher=teacher
        elif deleted!=0:
            timetable.course.filter(id=courseid).update(deleted=True)
        else:
            c=timetable.course.filter(id=courseid).first()

        if c!=None:
            c.weekday=weekday
            c.starttime=parseTime(starttime)
            c.endtime=parseTime(endtime)
            c.course=course
            c.studentnum=studentnum
            c.remark=remark
            c.save()
    return jsonResponse(getHRD(data=timetable.toJson()))

#取得可预约教练
@auth
def appointmentTeacherList(request):
    studentid=readFromDict(request.REQUEST,'studentid')
    student=Student.getWithId(studentid)
    if student==None:
        return jsonResponse(getHRD(code=1,msg='学员不存在'))
    teachers=Teacher.relatedWithStudnt(studentid)
    data=[]
    for t in teachers:
        data.append(t.toJson())
    return jsonResponse(getHRD(data=data))

    return jsonResponse(getHRD())

#取得教练的预约日历
@auth
def appointmentCalendar(request):
    teacherid=readFromDict(request.REQUEST,'teacherid')
    studentid=readFromDict(request.REQUEST,'studentid')
    teacher=Teacher.getWithId(teacherid)
    if teacher==None:
        return jsonResponse(getHRD(code=1,msg='找不到教练信息'))
    student=Student.getWithId(studentid)
    if student==None:
        return jsonResponse(getHRD(code=2,msg='找不到学员信息'))

    timetable=CourseTimeTable.appointmentableWithTeacherid(teacherid)
    if timetable==None:
        return jsonResponse(getHRD(code=3,msg='没有定义课表'))

    today=datetime.date.today()
    appointments=CourseAppointment.objects.filter(student__id=studentid,course__timetable__teacher__id=teacherid,deleted=False,date__gte=today)
    appointments_data=[]
    for a in appointments:
        appointments_data.append(a.toJson())

    date_data=[]
    for i in range(0,15):
        date_course={}
        date=today+datetime.timedelta(days=i)
        dateString=formatDate(date)
        weekday=date.weekday()
        date_course['date']=dateString
        date_course['course']=[]
        courses=timetable.course.filter(deleted=False,weekday=weekday)
        for c in courses:
            c_data=c.toJson()
            appointmentcount=CourseAppointment.objects.filter(date=date,course=c,deleted=False).count()
            c_data['appointmentcount']=appointmentcount
            date_course['course'].append(c_data)
        date_data.append(date_course)
    data={
        'appointment':appointments_data,
        'date':date_data,
    }
    return jsonResponse(getHRD(data=data))

#预约
@auth
def createAppointment(request):
    studentid=readFromDict(request.REQUEST,'studentid')
    date=readFromDict(request.REQUEST,'date')
    courseid=readFromDict(request.REQUEST,'courseid')
    remark=readFromDict(request.REQUEST,'remark')

    date=parseDate(date)
    if date==None:
        return jsonResponse(getHRD(code=1,msg='日期格式错误'))

    student=Student.getWithId(studentid)
    if student==None:
        return jsonResponse(getHRD(code=2,msg='找不到学员信息'))
    course=Course.getWithId(courseid)
    if course==None:
        return jsonResponse(getHRD(code=3,msg='找不到课时信息'))

    appointment=CourseAppointment.objects.filter(date=date,course=course,student=student,deleted=False).first()
    if appointment==None:
        appointment=CourseAppointment()
        appointment.date=date
        appointment.course=course
        appointment.student=student
        appointment.teacher=course.teacher
        appointmentDatetime=datetime.datetime(date.year,date.month,date.day,course.starttime.hour,course.starttime.minute,0)
        appointment.datetime=appointmentDatetime
        appointment.studentremark=remark
        appointment.save()

    return jsonResponse(getHRD(data=appointment.toJson()))

#取消预约
@auth
def cancelAppointment(request):
    studentid=readFromDict(request.REQUEST,'studentid')
    date=readFromDict(request.REQUEST,'date')
    courseid=readFromDict(request.REQUEST,'courseid')

    date=parseDate(date)
    if date==None:
        return jsonResponse(getHRD(code=1,msg='日期格式错误'))

    student=Student.getWithId(studentid)
    if student==None:
        return jsonResponse(getHRD(code=2,msg='找不到学员信息'))
    course=Course.getWithId(courseid)
    if course==None:
        return jsonResponse(getHRD(code=3,msg='找不到课时信息'))

    appointment=CourseAppointment.objects.filter(date=date,course=course,student=student,deleted=False).first()
    if appointment!=None:
        appointment.deleted=True
        appointment.save()

    return jsonResponse(getHRD(data=appointment.toJson()))

#设置预约为缺勤
@auth
def absentAppointment(request):
    appointmentid=readFromDict(request.REQUEST,'appointmentid')
    appointment=CourseAppointment.getWithId(appointmentid)
    if appointment==None:
        return jsonResponse(getHRD(code=1,msg='没有找到约车记录'))

    appointment.absented=True
    appointment.save()

    return jsonResponse(getHRD(data=appointment.toJson()))

#取得一个约车记录
@auth
def appointment(request):
    appointmentid=readFromDict(request.REQUEST,'appointmentid')

    appointment=CourseAppointment.getWithId(appointmentid);
    if appointment==None:
        return jsonResponse(getHRD(code=1,msg='没有找到约车记录'))

    return jsonResponse(getHRD(data=appointment.toJson()))


#学员-取得约车记录
@auth
def studentAppointmentList(request):
    studentid=readFromDict(request.REQUEST,'studentid')
    showexpired=readFromDict(request.REQUEST,'showexpired')
    start=readIntFromDict(request.REQUEST,'start')
    offset=readIntFromDict(request.REQUEST,'offset')
    if offset==0:
        offset=30
    showexpired=('1'==showexpired)

    student=Student.getWithId(studentid)
    if student==None:
        return jsonResponse(getHRD(code=1,msg='找不到学员信息'))


    result=CourseAppointment.listWithStudentid(studentid,showexpired)[start:start+offset]
    if len(result)==0:
        return jsonResponse(getHRD(code=2,msg='没有更多的结果'))

    data=[]
    for r in result:
        data.append(r.toJson())

    return jsonResponse(getHRD(data=data))


#教练-取得约车记录
@auth
def teacherAppointmentList(request):
    teacherid=readFromDict(request.REQUEST,'teacherid')
    showexpired=readFromDict(request.REQUEST,'showexpired')
    start=readIntFromDict(request.REQUEST,'start')
    offset=readIntFromDict(request.REQUEST,'offset')
    if offset==0:
        offset=30
    showexpired=('1'==showexpired)

    teacher=Teacher.getWithId(teacherid)
    if teacher==None:
        return jsonResponse(getHRD(code=1,msg='找不到教练信息'))


    result=CourseAppointment.listWithTeacherid(teacherid,showexpired)[start:start+offset]
    if len(result)==0:
        return jsonResponse(getHRD(code=2,msg='没有更多的结果'))

    data=[]
    for r in result:
        data.append(r.toJson())

    return jsonResponse(getHRD(data=data))


#教练-取得某日约车记录
@auth
def teacherAppointmentListOfOneDay(request):
    teacherid=readFromDict(request.REQUEST,'teacherid')
    date=readFromDict(request.REQUEST,'date')
    start=readIntFromDict(request.REQUEST,'start')
    offset=readIntFromDict(request.REQUEST,'offset')
    if offset==0:
        offset=30

    date=parseDate(date)
    if date==None:
        return jsonResponse(getHRD(code=3,msg='日期格式错误，正确格式为YYYY-mm-dd'))

    teacher=Teacher.getWithId(teacherid)
    if teacher==None:
        return jsonResponse(getHRD(code=1,msg='找不到教练信息'))


    result=CourseAppointment.listOneDayWithTeacherid(teacherid,date)[start:start+offset]
    if len(result)==0:
        return jsonResponse(getHRD(code=2,msg='没有更多的结果'))

    data=[]
    for r in result:
        data.append(r.toJson())

    return jsonResponse(getHRD(data=data))


#新建(更新)评价
@auth
def updateAppointmentEvaluation(request):
    evaluationid=readFromDict(request.REQUEST,'evaluationid')
    appointmentid=readFromDict(request.REQUEST,'appointmentid')
    evaluationtext=readFromDict(request.REQUEST,'evaluation')
    who=readFromDict(request.REQUEST,'who')

    evaluation=CourseAppointmentEvaluation.getWithId(evaluationid);
    if evaluation==None:
        appointment=CourseAppointment.getWithId(appointmentid)
        if appointment==None:
            return jsonResponse(getHRD(code=1,msg='找不到约车信息'))
        evaluation=CourseAppointmentEvaluation()

    stars=[]
    for i in range(1,10):
        star=readFromDict(request.REQUEST,'star%d'%(i))
        if star==None:
            break;
        else:
            stars.append(int(star))
    averageStar=0 if len(stars)==0 else (float(sum(stars))/float(len(stars)))

    evaluation.who=who
    evaluation.appointment=appointment
    evaluation.evaluation=evaluationtext
    evaluation.averagestar=averageStar
    if len(stars)>0:
        evaluation.star1=stars[0]
    if len(stars)>1:
        evaluation.star2=stars[1]
    if len(stars)>2:
        evaluation.star3=stars[2]
    if len(stars)>3:
        evaluation.star4=stars[3]
    if len(stars)>4:
        evaluation.star5=stars[4]
    if len(stars)>5:
        evaluation.star6=stars[5]
    if len(stars)>6:
        evaluation.star7=stars[6]
    if len(stars)>7:
        evaluation.star8=stars[7]
    if len(stars)>8:
        evaluation.star9=stars[8]
    evaluation.save()

    appointment=CourseAppointment.getWithId(appointmentid)
    print type(appointment)
    if appointment==None:
        transaction.rollback()
        return jsonResponse(getHRD(code=1,msg='找不到约车信息'))
    return jsonResponse(getHRD(data=appointment.toJson()))


#搜索学员
@auth
def searchSchoolStudent(request):
    schoolid=readFromDict(request.REQUEST,'schoolid')
    searchkey=readFromDict(request.REQUEST,'searchkey')
    start=readIntFromDict(request.REQUEST,'start')
    offset=readIntFromDict(request.REQUEST,'offset')
    if searchkey==None or len(searchkey)==0:
        return jsonResponse(getHRD(code=1,msg='你要查找什么'))

    if offset==0:
        offset=30

    school=School.getWithId(schoolid)
    if school==None:
        return jsonResponse(getHRD(code=3,msg='驾校不存在'))
    result=Student.searchWithSchoolid(schoolid,searchkey)[start:start+offset]
    if len(result)==0:
        return jsonResponse(getHRD(code=2,msg='没有找到符合结果'))
    data=[]
    for r in result:
        data.append(r.toJson())
    return jsonResponse(getHRD(data=data))

#记录日志
def log(request):
    operatorid=readFromDict(request.REQUEST,'operatorid')
    name=readFromDict(request.REQUEST,'name')
    ext1=readFromDict(request.REQUEST,'ext1')
    ext2=readFromDict(request.REQUEST,'ext2')
    ext3=readFromDict(request.REQUEST,'ext3')
    ext4=readFromDict(request.REQUEST,'ext4')
    ext5=readFromDict(request.REQUEST,'ext5')
    ext6=readFromDict(request.REQUEST,'ext6')
    ext7=readFromDict(request.REQUEST,'ext7')
    ext8=readFromDict(request.REQUEST,'ext8')
    ext9=readFromDict(request.REQUEST,'ext9')

    log=Log()
    log.operatorid=operatorid
    log.name=name
    log.ext1=ext1
    log.ext2=ext2
    log.ext3=ext3
    log.ext4=ext4
    log.ext5=ext5
    log.ext6=ext6
    log.ext7=ext7
    log.ext8=ext8
    log.ext9=ext8
    log.save()
    return jsonResponse(getHRD())




