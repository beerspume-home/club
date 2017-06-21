#coding=utf-8
import datetime,hashlib,os,json,uuid
from common.utils import *
from django.db import models
from django.db.models import Q
from django.core.serializers import serialize,deserialize
from django.core.exceptions import *
from django.conf import settings
from app.rcapi import *
from PIL import Image,ImageDraw

_logger = logging.getLogger('im')

def uuid_default():
    return unicode(uuid.uuid1()).replace('-','')

def date_nextday():
    return datetime.date.today()+datetime.timedelta(days=1)

def date_halfyeay_later():
    return datetime.date.today()+datetime.timedelta(days=183)

def parseDatetimeColumn(data,json_obj):
    if not isinstance(json_obj,list):
        data=[data]
        json_obj=[json_obj]
    for i in range(0,len(json_obj)):
        if 'modifydate' in json_obj[i]:
            json_obj[i]['modifydate']=formatDatetime(data[i].modifydate)
        if 'createdate' in json_obj[i]:
            json_obj[i]['createdate']=formatDatetime(data[i].createdate)

# 转换QuerySet为json
def serializeModel(data):
    objs=None
    if isinstance(data,models.Model):
        objs=[data]
    elif isinstance(data,QuerySet) or isinstance(data,list) or isinstance(data,tuple):
        objs=data
    if objs!=None:
        json_data=json.loads(serialize('json',objs))
        ret=[]
        for o in json_data:
            o[u'fields'][u'id']=o[u'pk']
            ret.append(o[u'fields'])
        if isinstance(data,models.Model):
            ret=ret[0]
        parseDatetimeColumn(data,ret)
        return ret
    else:
        return None

#图片存储
class ImageStore(models.Model):
    id=models.CharField(primary_key=True, max_length=32,default=uuid_default, editable=False)
    filepath=models.CharField(max_length=1000,null=True)
    url=models.CharField(max_length=1000,null=True)
    class Meta:
        db_table='t_im_imagestore'
    def toJson(self):
        return serializeModel(self)
    def getUrl(self):
        if self.url!=None:
            return self.url
        else:
            return os.path.join(settings.SERVER_BASE_URL,'app/image/%s'%(self.id))
    def deleteAndFile(self):
        if self.filepath!=None:
            targetFile=os.path.join(ImageStore.getFilepath(),self.filepath)
            os.remove(targetFile)
        self.delete()

    @staticmethod
    def getWithId(imageid):
        return ImageStore.objects.filter(id=imageid).first()
    @staticmethod
    def getFilepath():
        if not os.path.exists(settings.IMAGE_PATH):
            os.mkdir(settings.IMAGE_PATH)
        return settings.IMAGE_PATH
    @staticmethod
    def createInLocal(imagefile,extname):
        ret=None
        if imagefile!=None:
            ret=ImageStore()
            ret.save()
            filepath=os.path.join(ImageStore.getFilepath(),'%s.%s'%(ret.id,extname))
            fileindb=open(filepath,'wb')
            fileindb.write(imagefile.read())
            fileindb.close()
            ret.filepath='%s.%s'%(ret.id,extname)
            ret.save()
        return ret



# 字典-用于教练，学员或其他对象
class Dictionary(models.Model):
    DICTIONARY_TYPE_CHIOCE=(
        (u'teacher_skill',u'教练教学科目'),
        (u'area_version',u'地区数据版本'),
    )
    id=models.CharField(primary_key=True, max_length=32,default=uuid_default, editable=False)
    name=models.CharField(max_length=100,null=False,choices=DICTIONARY_TYPE_CHIOCE)
    value=models.CharField(max_length=100,null=False)
    desc=models.CharField(max_length=100,null=True)
    order=models.IntegerField(null=True)
    class Meta:
        db_table='t_im_dictionary'
    def toJson(self):
        return serializeModel(self)

    #地区数据版本
    @staticmethod
    def areaVersion():
        ret=0.0
        result=Dictionary.objects.filter(name=Dictionary.DICTIONARY_TYPE_CHIOCE[1][0]).first()
        if result!=None:
            try:
                ret=float(result.value)
            except Exception,e:
                pass
        return ret

    @staticmethod
    def getWithName(dictname):
        return Dictionary.objects.filter(name=dictname).order_by('order')

    @staticmethod
    def getWithId(dictid):
        return Dictionary.objects.filter(id=dictid).first()

#地区
class Area(models.Model):
    id=models.CharField(primary_key=True, max_length=32,default=uuid_default, editable=False)
    level=models.IntegerField(null=False)
    parent=models.CharField(max_length=32,null=True)
    name=models.CharField(max_length=100,null=False)
    postcode=models.CharField(max_length=100,null=False,unique=True)
    namepath=models.CharField(max_length=500,null=False)
    class Meta:
        db_table='t_im_area'
    def toJson(self):
        return serializeModel(self)

    lastGetVersion=0
    lastGetData=None
    @staticmethod
    def toDict():
        newestAreaVersion=Dictionary.areaVersion()
        if newestAreaVersion>Area.lastGetVersion:
            Area.lastGetData=Area.getSubArea(None)
            Area.lastGetVersion=newestAreaVersion
        return Area.lastGetData

    @staticmethod
    def getWithId(areaid):
        return Area.objects.filter(id=areaid).first()
    @staticmethod
    def getWithPostcode(postcode):
        return Area.objects.filter(postcode=postcode).first()

    @staticmethod
    def getSubArea(parentArea):
        ret=[]
        level=1
        parent=None
        if parentArea!=None:
            level=parentArea.level+1
            parent=parentArea.id
        if level<10:
            sub=Area.objects.filter(level=level,parent=parent)
            for area in sub:
                area_dict=area.toJson()
                area_dict['subarea']=Area.getSubArea(area)
                ret.append(area_dict)
        return ret


# 驾校
class School(models.Model):
    id=models.CharField(primary_key=True, max_length=32,default=uuid_default, editable=False)
    createdate=models.DateTimeField(auto_now_add=True)
    modifydate=models.DateTimeField(auto_now=True)

    name=models.CharField(max_length=100,null=False)
    certified=models.BooleanField(null=False,default=False)
    postcode=models.CharField(max_length=100,null=False)
    otherarea=models.CharField(max_length=100,null=True)
    introduction=models.CharField(max_length=2000,null=True,default='')
    pictures=models.ManyToManyField(ImageStore) #驾校照片

    class Meta:
        db_table='t_im_school'
    def toJson(self,surface=False):
        ret=serializeModel(self)
        area=Area.getWithPostcode(self.postcode)
        if area!=None:
            ret['area']=area.toJson()
        ret['imageurl']=self.genImageUrl()
        ret['mppageurl']=self.genMPPageUrl()
        pictures=[]
        for p in self.pictures.all():
            pictures.append(p.getUrl())
            ret['pictures']=pictures
        if not surface:
            data=[]
            for c in self.classes.filter(status='published',expiredate__gt=datetime.datetime.now()):
                data.append(c.toJson())
            ret['classes']=data
        if self.operation.filter(status=0,certified=True).first()!=None:
            ret['certified']='1'
        else:
            ret['certified']='0'
        return ret
    def genImageUrl(self):
        return os.path.join(settings.SERVER_BASE_URL,'app/schoolImage?schoolid=%s'%(self.id))
    def genMPPageUrl(self):
        return os.path.join(settings.SERVER_BASE_URL,'mp/schoolPage/%s'%(self.id))
    #取得驾校的所有员工
    def allStaff(self,character_type=None):
        result=[]
        if(character_type=='teacher' or character_type==None or len(character_type.strip())==0):
            result+=self.teacher.filter(status=0,available=True)
        if(character_type=='customerservice' or character_type==None or len(character_type.strip())==0):
            result+=self.customerservice.filter(status=0,available=True)
        if(character_type=='operation' or character_type==None or len(character_type.strip())==0):
            result+=self.operation.filter(status=0,available=True)

        ret=[]
        for t in result:
            ret.append(t.person)
        return ret

    @staticmethod
    def getWithId(schoolid):
        return School.objects.filter(id=schoolid).first()

    #搜索驾校
    @staticmethod
    def search(searchkey):
        return School.objects.filter(name__contains=searchkey)
    #搜索驾校（包括简介）
    @staticmethod
    def searchFuzzy(searchkey):
        return School.objects.filter(Q(name__contains=searchkey)|Q(introduction__contains=searchkey))

    #创建驾校
    @staticmethod
    def create(name,areaid=None,postcode=None):
        if areaid!=None:
            area=Area.getWithId(areaid)
            if area!=None:
                postcode=area.postcode
        if postcode==None:
            postcode=''
        school=School()
        school.name=name
        school.postcode=postcode
        school.save()
        return school



# 自然人身份信息
class Person(models.Model):
    GENDER_CHOICES=(
        ('0','未知'),
        ('1','男'),
        ('2','女'),
        ('3','X'),
    )
    id=models.CharField(primary_key=True, max_length=32,default=uuid_default, editable=False)
    createdate=models.DateTimeField(auto_now_add=True)
    modifydate=models.DateTimeField(auto_now=True)

    phone=models.CharField(max_length=100,null=True,unique=True)
    username=models.CharField(max_length=100,null=True,unique=True)
    email=models.CharField(max_length=100,null=True,unique=True)
    name=models.CharField(max_length=100,null=True)
    idcard=models.CharField(max_length=100,null=True)
    gender=models.CharField(max_length=1,null=True,choices=GENDER_CHOICES)
    profession=models.ForeignKey(Dictionary,null=True)
    otherprofession=models.CharField(max_length=100,null=True)
    area=models.ForeignKey(Area,null=True)
    otherarea=models.CharField(max_length=100,null=True)
    interestschool=models.ManyToManyField(School)

    class Meta:
        db_table='t_im_person'

    def genImageUrl(self):
        return os.path.join(settings.SERVER_BASE_URL,'app/headImage?personid=%s'%(self.id))
    def genOriginImageUrl(self):
        return os.path.join(settings.SERVER_BASE_URL,'app/originHeadImage?personid=%s'%(self.id))
    def toJson(self):
        ret=serializeModel(self)
        #添加头像URL
        ret['imageurl']=self.genImageUrl()
        #添加原始头像URL
        ret['originimageurl']=self.genOriginImageUrl()
        #获取自然人的社交属性
        try:
            social=self.social
        except Exception,e:
            social=None
        if social!=None:
            ret['social']=social.toJson()
        else:
            ret['social']=None
        #获取自然人鉴权属性
        try:
            auth=self.auth
        except Exception,e:
            auth=None
        if auth!=None:
            ret['auth']=auth.toJson()
            ret['auth'].pop('password')
        else:
            ret['auth']=None
        #获取职业属性
        if ret['profession']==None:
            ret['profession']=ret['otherprofession']
        else:
            ret['profession']=self.profession.name
        ret.pop('otherprofession')
        #获取地区
        if ret['area']!=None:
            ret['area']=self.area.toJson()
        ret.pop('otherarea')

        #获得当前角色
        school_name=''
        school_id=''
        ret['certified']=False
        character=self.getCharacter()
        if character!=None:
            ret['character_type']=Person.getCharacterType(character)
            ret['certified']=character.certified
            school_name=character.school.name
            school_id=character.school.id

        #全部角色
        ret['all_character']=[]
        for r in self.getAllCharacter():
            ret['all_character'].append(r.toJson(surface=True))
            pass

        #所属驾校
        ret['school_name']=school_name
        ret['school_id']=school_id

        #关注的驾校
        data=[]
        for s in self.interestschool.all():
            data.append(s.id)
        ret['interestschool']=data

        return ret

    def genQRCode(self):
        savepath=self.getQRCodeFilepath()
        qrdata={'type':'person','id':self.id}
        img=genQRCode(qrdata)
        img.save(savepath)
        return img,savepath

    def getQRCodeFilepath(self):
        if not os.path.exists(settings.QRIMG_PATH):
            os.mkdir(settings.QRIMG_PATH)
        savepath=os.path.join(settings.QRIMG_PATH,'%s.png'%(self.id))
        return savepath
    def getHeadImageFilepath(self):
        return Person.genHeadImageFilepath(self.id)
    def getOriginHeadImageFilepath(self):
        return Person.genOriginHeadImageFilepath(self.id)

    def isFriendWithPersonid(self,personid):
        return Contacts.objects.filter(contactbook__owner__id=self.id,person__id=personid).first()!=None

    #获得当前身份(可能返回Teacher或Student对象)
    def getCharacter(self):
        ret=self.teacher_character.filter(available=True).first()
        if ret==None:
            ret=self.student_character.filter(available=True).first()
        if ret==None:
            ret=self.customerservice_character.filter(available=True).first()
        if ret==None:
            ret=self.operation_character.filter(available=True).first()
        return ret

    def getAllCharacter(self):
        ret=[]

        for r in self.teacher_character.filter():
            ret.append(r)

        for r in self.student_character.filter():
            ret.append(r)

        for r in self.customerservice_character.filter():
            ret.append(r)

        for r in self.operation_character.filter():
            ret.append(r)

        return ret

    #设置当前用户的活跃角色
    def setCharacter(self,charactertype,characterid):
        self.student_character.all().update(available=False)
        self.teacher_character.all().update(available=False)
        self.customerservice_character.all().update(available=False)
        self.operation_character.all().update(available=False)
        if charactertype=='student':
            self.student_character.filter(id=characterid).update(available=True)
        if charactertype=='teacher':
            self.teacher_character.filter(id=characterid).update(available=True)
        if charactertype=='customerservice':
            self.customerservice_character.filter(id=characterid).update(available=True)
        if charactertype=='operation':
            self.operation_character.filter(id=characterid).update(available=True)

    #设置当前用户的活跃角色
    def setCharacterWithObj(self,character):
        characterType=''
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
        if characterType!=None and characterType!='':
            self.setCharacter(characterType,character.id)


    def isTeacher(self):
        character=self.getCharacter()
        return isinstance(character,Teacher)
    def isStudent(self):
        character=self.getCharacter()
        return isinstance(character,Student)
    def isCustomerService(self):
        character=self.getCharacter()
        return isinstance(character,CustomerService)
    def isOperation(self):
        character=self.getCharacter()
        return isinstance(character,Operation)

    #关注驾校
    def interestSchool(self,schoolid):
        school=School.getWithId(schoolid)
        if school!=None:
            self.interestschool.add(school)
        return school
    #取消关注驾校
    def uninterestSchool(self,schoolid):
        school=School.getWithId(schoolid)
        if school!=None:
            self.interestschool.remove(school)
        return school

    #是否关注了驾校
    def isInterestSchool(self,schoolid):
        return (self.interestschool.filter(id=schoolid).first()!=None)

    #是否关注了驾校
    def interestedSchoolList(self):
        return self.interestschool.all()

    #获取融云user token
    def getRCUserToken(self):
        token=None
        rc=None
        try:
            rc=self.rongcloud
            token=rc.token
        except Exception,e:
            pass
        if token==None:
            token,userid=rc_user_get_token(self.id, self.social.nickname, self.genImageUrl())
            if token!=None:
                if rc==None:
                    rc=RongCloud()
                    rc.person=self;
                rc.token=token
                rc.save()
        return token

    @staticmethod
    def getCharacterType(character):
        ret=''
        if character!=None:
            if isinstance(character,Teacher):
                ret='teacher'
            if isinstance(character,Student):
                ret='student'
            if isinstance(character,CustomerService):
                ret='customerservice'
            if isinstance(character,Operation):
                ret='operation'
        return ret

    @staticmethod
    def validGender(gender):
        for g in Person.GENDER_CHOICES:
            if gender==g[0]:
                return True
        return False

    @staticmethod
    def defaultGender():
        return Person.GENDER_CHOICES[0][0]
    #username可以是手机号，用户名，邮箱
    @staticmethod
    def getWithFuzzy(username):
        return None if username==None else Person.objects.filter(Q(phone=username)|Q(username=username)|Q(email=username)).first()
    @staticmethod
    def getWithPhone(phone):
        return None if phone==None else Person.objects.filter(Q(phone=phone)).first()
    @staticmethod
    def getWithId(personid):
        return None if personid==None else Person.objects.filter(id=personid).first()
    @staticmethod
    def searchWithKey(key):
        return Person.objects.filter(
            Q(phone=key)
            |Q(username__contains=key)
            |Q(email__contains=key)
            |Q(social__nickname__contains=key)
            |Q(social__Intergetroduction__contains=key)
            )
    @staticmethod
    def searchWithPhones(phone_in_list):
        return Person.objects.filter(phone__in=phone_in_list)
    @staticmethod
    def usernameIsAvailable(username):
        return len(Person.objects.filter(username=username))==0
    @staticmethod
    def phoneIsAvailable(phone):
        return len(Person.objects.filter(phone=phone))==0
    @staticmethod
    def emailIsAvailable(email):
        return len(Person.objects.filter(email=email))==0
    @staticmethod
    def genHeadImageFilepath(personid):
        if not os.path.exists(settings.HEADIMG_PATH):
            os.mkdir(settings.HEADIMG_PATH)
        return os.path.join(settings.HEADIMG_PATH,'%s.png'%personid)
    @staticmethod
    def genOriginHeadImageFilepath(personid):
        if not os.path.exists(settings.HEADIMG_PATH):
            os.mkdir(settings.HEADIMG_PATH)
        return os.path.join(settings.HEADIMG_PATH,'origin_%s.png'%personid)

    #创建用户
    @staticmethod
    def create(phone,name,idcard,gender='1',password='',nickname='乐友'):
        person=Person()
        person.phone=phone
        person.name=name
        person.idcard=idcard
        person.gender=gender
        person.save()

        Auth.setNewPasswordForPerson(person.id,password)

        social=Social()
        social.person=person
        social.nickname=nickname
        social.save()

        account=Account()
        account.person=person
        account.save()

        return person

class AccessToken(models.Model):
    id=models.CharField(primary_key=True, max_length=32,default=uuid_default, editable=False)
    createdate=models.DateTimeField(auto_now_add=True)
    modifydate=models.DateTimeField(auto_now=True)

    person=models.ForeignKey(Person,related_name='accesstoken')
    deviceid=models.CharField(max_length=100,null=False)
    accesstoken=models.CharField(max_length=32,null=False)
    tokenexpiretime=models.DateTimeField(null=False)

    class Meta:
        db_table='t_im_access_token'
    def toJson(self):
        ret=serializeModel(self)
        ret['expire_in']=(self.tokenexpiretime-datetime.datetime.now()).total_seconds()
        return ret

    @staticmethod
    def getToken(personid,deviceid):
        accessToken=AccessToken.objects.filter(person__id=personid,deviceid=deviceid).first()
        if accessToken!=None and accessToken.tokenexpiretime>=datetime.datetime.now():
            return accessToken.accesstoken
        else:
            return None

    @staticmethod 
    def genNewTokenWithPerson(person,deviceid,expire_in_seconds=7200):
        token=None
        if person!=None:
            token=AccessToken.objects.filter(person__id=person.id,deviceid=deviceid).first()
            if token==None:
                token=AccessToken()
                token.person=person
                token.deviceid=deviceid
            token.accesstoken=uuid_default()
            token.tokenexpiretime=datetime.datetime.now()+datetime.timedelta(seconds=expire_in_seconds)
            token.save()
        return token

    @staticmethod 
    def refreshTokenWithPerson(person,deviceid,oldtoken,expire_in_seconds=7200,can_refresh_gap_seconds=300):
        token=None
        if person!=None:
            token=AccessToken.objects.filter(person__id=person.id,deviceid=deviceid,accesstoken=oldtoken).first()
            if token!=None:
                refresh_gap=datetime.timedelta(seconds=can_refresh_gap_seconds)
                if token.tokenexpiretime>=datetime.datetime.now()-refresh_gap and token.tokenexpiretime<=datetime.datetime.now()+refresh_gap:
                    token.accesstoken=uuid_default()
                    token.tokenexpiretime=datetime.datetime.now()+datetime.timedelta(seconds=expire_in_seconds)
                    token.save()
                elif token.tokenexpiretime>datetime.datetime.now()+refresh_gap:
                    token=None
        return token



# 自然人鉴权
class Auth(models.Model):
    id=models.CharField(primary_key=True, max_length=32,default=uuid_default, editable=False)
    createdate=models.DateTimeField(auto_now_add=True)
    modifydate=models.DateTimeField(auto_now=True)

    person=models.OneToOneField(Person,related_name='auth')
    password=models.CharField(max_length=100,null=True)

    class Meta:
        db_table='t_im_auth'
    def toJson(self):
        return serializeModel(self)

    @staticmethod 
    def genPassword(personid,password):
        return hashlib.md5('%s|happyengine_secret|%s'%(password,personid)).hexdigest()

    @staticmethod
    def setNewPasswordForPerson(personid,password):
        person=Person.objects.filter(id=personid).first()
        if person==None:
            return False
        password=Auth.genPassword(personid,password)
        personAuth=Auth.objects.filter(person=person).first()
        if personAuth==None:
            personAuth=Auth()
            personAuth.person=person
        personAuth.password=password
        personAuth.save()
        return True
    @staticmethod
    def verifyPassword(personid,password):
        personAuth=Auth.objects.filter(person__id=personid).first()
        if personAuth==None:
            return False
        password=Auth.genPassword(personid,password)
        return password==personAuth.password

# 自然人的社交相关属性
class Social(models.Model):
    id=models.CharField(primary_key=True, max_length=32,default=uuid_default, editable=False)
    createdate=models.DateTimeField(auto_now_add=True)
    modifydate=models.DateTimeField(auto_now=True)

    person=models.OneToOneField(Person,related_name='social')
    nickname=models.CharField(max_length=100,null=False)
    introduction=models.CharField(max_length=500,null=True,default='')

    class Meta:
        db_table='t_im_social'
    def toJson(self):
        ret=serializeModel(self)
        return ret

    @staticmethod
    def getWithPerson(personid):
        return Social.objects.filter(person__id=personid).first()

class RongCloud(models.Model):
    id=models.CharField(primary_key=True, max_length=32,default=uuid_default, editable=False)
    person=models.OneToOneField(Person,related_name='rongcloud')
    token=models.CharField(max_length=100,null=False)

    class Meta:
        db_table='t_im_rongcloud'
    def toJson(self):
        return serializeModel(self)


# 短信验证码存储
class SMSCode(models.Model):
    id=models.CharField(primary_key=True, max_length=32,default=uuid_default, editable=False)
    createdate=models.DateTimeField(auto_now_add=True)
    modifydate=models.DateTimeField(auto_now=True)

    phone=models.CharField(max_length=100,null=False)
    smscode=models.CharField(max_length=100,null=False)
    sendtime=models.DateTimeField(auto_now=True,null=False)
    expiretime=models.DateTimeField(null=False)
    class Meta:
        db_table='t_im_smscode'
    def toJson(self):
        return serializeModel(self)

    @staticmethod
    def getValidSMSCode(phone):
        ret=None
        now=datetime.datetime.now()
        result=SMSCode.objects.filter(phone=phone,expiretime__gt=(now-datetime.timedelta(minutes=5))).order_by('-sendtime')[:1]
        if result!=None and len(result)>0:
            ret=result[0].smscode
        return ret

    @staticmethod
    def verifySMSCode(phone,smscode):
        validSmscode=SMSCode.getValidSMSCode(phone)
        return validSmscode!=None and validSmscode==smscode

    @staticmethod
    def genNewSMSCode(phone):
        ret=None
        now=datetime.datetime.now()
        SMSCode.objects.filter(phone=phone,expiretime__gt=now).update(expiretime=now)
        # 生成6位随机数
        # smsCode=generatorCode(6)
        smsCode='111111'
        expiretime=datetime.datetime.now()+datetime.timedelta(hours=1)#一小时后过期
        objSMSCode=SMSCode()
        objSMSCode.phone=phone
        objSMSCode.smscode=smsCode
        objSMSCode.expiretime=expiretime
        objSMSCode.save()
        return smsCode

# 通讯录
class ContactBook(models.Model):
    id=models.CharField(primary_key=True, max_length=32,default=uuid_default, editable=False)
    createdate=models.DateTimeField(auto_now_add=True)
    modifydate=models.DateTimeField(auto_now=True)

    owner=models.OneToOneField(Person,null=False,related_name='contactbook')
    class Meta:
        db_table='t_im_contact_book'
    #添加联系人
    def addContacts(self,person):
        if person!=None:
            contacts=self.contacts.filter(person=person).first()
            if contacts==None:
                self.contacts.add(Contacts(person=person))
    #删除联系人
    def removeContacts(self,person):
        if person!=None:
            contacts=self.contacts.filter(person=person).first()
            if contacts!=None:
                contacts.delete()

    #获取用户的通讯录
    @staticmethod
    def getWithPersonid(personid):
        person=Person.getWithId(personid)
        if person==None:
            return None
        try:
            contactbook=person.contactbook
        except ObjectDoesNotExist,e:
            contactbook=ContactBook()
            contactbook.owner=person
            contactbook.save()
        return contactbook


# 通讯录联系人
class Contacts(models.Model):
    id=models.CharField(primary_key=True, max_length=32,default=uuid_default, editable=False)
    createdate=models.DateTimeField(auto_now_add=True)
    modifydate=models.DateTimeField(auto_now=True)

    contactbook=models.ForeignKey(ContactBook,null=False,related_name='contacts')
    person=models.ForeignKey(Person,null=False)
    class Meta:
        db_table='t_im_contacts'
    def toJson(self):
        ret=serializeModel(self)
        ret[u'person']=self.person.toJson()
        return ret


# 聊天群组
class ChatGroup(models.Model):
    id=models.CharField(primary_key=True, max_length=32,default=uuid_default, editable=False)
    createdate=models.DateTimeField(auto_now_add=True)
    modifydate=models.DateTimeField(auto_now=True)

    name=models.CharField(max_length=100,null=False)
    class Meta:
        db_table='t_im_chatgroup'
    def toJson(self):
        ret=serializeModel(self)
        members=self.member.all()
        members_json=[]
        for m in members:
            members_json.append(m.toJson())
        ret['members']=members_json
        ret['imageurl']=self.genImageUrl()
        return ret
    def member_id_list(self):
        ret=[]
        members=self.member.all()
        for m in members:
            ret.append(m.person.id)
        return ret
    def genImageUrl(self):
        return os.path.join(settings.SERVER_BASE_URL,'app/groupImage?groupid=%s'%(self.id))
    def getImageFilepath(self):
        return ChatGroup.genImageFilepath(self.id)
    # 生成群组图片
    def genGroupImage(self):
        members=self.member.all()[:9]
        maxW=180
        groupImage = Image.new('RGB', (maxW, maxW), (255, 255, 255))
        #成员小于等于4人则显示 2x2 头像矩阵
        #成员大于4小于等于9人则显示 3x3 头像矩阵
        w=maxW/3
        if len(members)<=4:
            w=maxW/2
        x=0
        y=0
        for m in members:
            person=m.person
            imageFilepath=person.getHeadImageFilepath()
            if not os.path.exists(imageFilepath):
                imageFilepath=os.path.join(settings.HEADIMG_PATH,'default.png')
            if os.path.exists(imageFilepath):
                image=Image.open(imageFilepath)
            else:
                image=Image.new('RGB', (w,w), (255, 255, 255))
            groupImage.paste(image.resize((w,w)),(x,y))
            x+=w
            if x>=maxW:
                x=0
                y+=w

        groupImage.save(self.getImageFilepath(),'png')

    # 删除成员
    def removeMember(self,personid):
        self.member.filter(person__id=personid).delete()
        rc_group_quit([personid],self.id)
        leftmembers=self.member.all()
        if len(leftmembers)<2:
            rc_group_dismiss(personid,self.id)
            self.delete()
        else:
            if(self.member.filter(isowner=True).first()==None):
                member=self.member.filter(group__id=self.id).first()
                member.isowner=True
                member.save()

    # 添加成员
    def addMember(self,persons):
        user_id_list=[]
        for personid in persons:
            if self.member.filter(person__id=personid).first()==None:
                person=Person.getWithId(personid)
                if person!=None:
                    self.member.create(person=person)
                    user_id_list.append(person.id)
        rc_group_join(user_id_list, self.id, self.name)

    #用户是否为群组成员
    def isMember(self,personid):
        return self.member.filter(person__id=personid).first()!=None

    #修改群组名称
    def updateName(self,groupname):
        self.name=groupname
        self.save()
        rc_group_refresh(self.id, groupname)


    @staticmethod
    def create(ownerid,memberarray):
        ret=None
        owner=Person.getWithId(ownerid)
        if owner!=None:
            ret=ChatGroup()
            ret.name=u'未命名'
            ret.save()
            member=ChatGroupMember()
            member.group=ret
            member.person=owner
            member.isowner=True
            member.save()
            for mid in memberarray:
                m=Person.getWithId(mid)
                if m!=None:
                    mm=ChatGroupMember()
                    mm.group=ret
                    mm.person=m
                    mm.isowner=False
                    mm.save()
            ret.genGroupImage()
        return ret
    @staticmethod
    def getWithId(groupid):
        return ChatGroup.objects.filter(id=groupid).first()

    @staticmethod
    def search(personid):
        return ChatGroup.objects.filter(member__person__id=personid)

    @staticmethod
    def genImageFilepath(groupid):
        if not os.path.exists(settings.GROUPIMG_PATH):
            os.mkdir(settings.GROUPIMG_PATH)
        return os.path.join(settings.GROUPIMG_PATH,'%s.png'%groupid)

# 聊天群组成员
class ChatGroupMember(models.Model):
    id=models.CharField(primary_key=True, max_length=32,default=uuid_default, editable=False)
    createdate=models.DateTimeField(auto_now_add=True)
    modifydate=models.DateTimeField(auto_now=True)

    person=models.ForeignKey(Person,null=False)
    group=models.ForeignKey(ChatGroup,null=False,related_name="member")
    isowner=models.BooleanField(null=False,default=False)
    name=models.CharField(max_length=100,null=True)
    class Meta:
        db_table='t_im_chatgroup_member'
    def toJson(self):
        ret=serializeModel(self)
        ret[u'person']=self.person.toJson()
        return ret


#驾校班级
class SchoolClasses(models.Model):
    STATUS_CHOICES = (
        ('new', u'未发布'),
        ('published', u'发布'),
        ('expired',u'过期'),
        ('deleted',u'删除'),
    )
    id=models.CharField(primary_key=True, max_length=32,default=uuid_default, editable=False)
    createdate=models.DateTimeField(auto_now_add=True)
    modifydate=models.DateTimeField(auto_now=True)

    school=models.ForeignKey(School,null=False,related_name='classes');
    name = models.CharField(max_length=100, null=False)  # 班级名称
    cartype = models.CharField(max_length=50, null=True)  # 车型
    licensetype = models.CharField(max_length=50, null=True)  # 驾照类型
    trainingtime = models.CharField(max_length=500, null=True)  # 训练时间
    status = models.CharField(max_length=50, null=False, choices=STATUS_CHOICES,default='new')  # 状态
    fee = models.IntegerField(null=True, default=0)  # 费用
    realfee = models.IntegerField(null=True, default=0)  # 优惠后实际费用
    expiredate = models.DateTimeField(null=True)  # 到期日期
    remark = models.CharField(max_length=1000,  null=True)  # 备注
    class Meta:
        db_table='t_im_schoolclass'
    def toJson(self):
        ret=serializeModel(self)
        ret['expiredate']=formatDate(self.expiredate)
        return ret

    @staticmethod
    def getWithId(schoolclassid):
        return SchoolClasses.objects.filter(id=schoolclassid).first()

    @staticmethod
    def allClassWithSchoolid(schoolid):
        return SchoolClasses.objects.filter(Q(status='new')|Q(status='published'),school__id=schoolid)


# 企业客服
class CustomerService(models.Model):
    STATUS_CHIOCE=(
        (0,u'正常'),
        (1,u'已离职'),
    )
    id=models.CharField(primary_key=True, max_length=32,default=uuid_default, editable=False)
    createdate=models.DateTimeField(auto_now_add=True)
    modifydate=models.DateTimeField(auto_now=True)

    person=models.ForeignKey(Person,null=False,related_name='customerservice_character')
    school=models.ForeignKey(School,null=False,default=None,related_name='customerservice')
    certified=models.BooleanField(null=False,default=False)
    status=models.IntegerField(default=0,choices=STATUS_CHIOCE)
    available=models.BooleanField(null=False,default=False)
    class Meta:
        db_table='t_im_customerservice'
    def toJson(self,surface=False):
        ret=serializeModel(self)
        if not surface:
            if self.person!=None:
                ret['person']=self.person.toJson()
        if self.school!=None:
            ret['school']=self.school.toJson()
        return ret
    #认证
    def certify(self,certified):
        self.certified=certified
        self.save()

    @staticmethod
    def create(personid,schoolid):
        person=Person.getWithId(personid)
        if person==None:
            return None
        school=School.getWithId(schoolid)
        if school==None:
            return None
        ret=CustomerService.objects.filter(person__id=personid,school__id=schoolid).first()
        if ret==None:
            ret=CustomerService()
            ret.person=person
            ret.school=school
        ret.save()
        return ret

    @staticmethod
    def getWithPersonid(personid):
        return CustomerService.objects.filter(person__id=personid)
    @staticmethod
    def getWithId(customerserviceid):
        return CustomerService.objects.filter(id=customerserviceid).first()
    @staticmethod
    def deleteWithId(customerserviceid):
        ret=CustomerService.getWithId(customerserviceid)
        if ret!=None:
            if ret.certified:
                ret.available=False
                ret.save()
            else:
                ret.delete()
                ret=None
        return ret
# 企业运营
class Operation(models.Model):
    STATUS_CHIOCE=(
        (0,u'正常'),
        (1,u'已离职'),
    )
    id=models.CharField(primary_key=True, max_length=32,default=uuid_default, editable=False)
    createdate=models.DateTimeField(auto_now_add=True)
    modifydate=models.DateTimeField(auto_now=True)

    person=models.ForeignKey(Person,null=False,related_name='operation_character')
    school=models.ForeignKey(School,null=False,default=None,related_name='operation')
    certified=models.BooleanField(null=False,default=False)
    status=models.IntegerField(default=0,choices=STATUS_CHIOCE)
    available=models.BooleanField(null=False,default=False)
    class Meta:
        db_table='t_im_operation'
    def toJson(self,surface=False):
        ret=serializeModel(self)
        if not surface:
            if self.person!=None:
                ret['person']=self.person.toJson()
        if self.school!=None:
            ret['school']=self.school.toJson()
        return ret

    #认证
    def certify(self,certified):
        self.certified=certified
        if certified==True and self.school.certified==False:
            self.school.certified=True
            self.school.save()
        elif certified==False and Operation.objects.filter(school__id=self.school.id,certified=True).first()==None:
            self.school.certified=False
            self.school.save()
            self.school.customerservice.all().update(certified=False)
            self.school.teacher.all().update(certified=False)
        self.save()

    @staticmethod
    def create(personid,schoolid):
        person=Person.getWithId(personid)
        if person==None:
            return None
        school=School.getWithId(schoolid)
        if school==None:
            return None
        ret=Operation.objects.filter(person__id=personid,school__id=schoolid).first()
        if ret==None:
            ret=Operation()
            ret.person=person
            ret.school=school
            ret.save()
        return ret
    @staticmethod
    def getWithPersonid(personid):
        return Operation.objects.filter(person__id=personid)
    @staticmethod
    def getWithId(operationid):
        return Operation.objects.filter(id=operationid).first()

    @staticmethod
    def deleteWithId(operationid):
        ret=Operation.getWithId(operationid)
        if ret!=None:
            if ret.certified:
                ret.available=False
                ret.save()
            else:
                ret.delete()
                ret=None
        return ret

# 教练
class Teacher(models.Model):
    STATUS_CHIOCE=(
        (0,u'正常'),
        (1,u'已离职'),
    )

    id=models.CharField(primary_key=True, max_length=32,default=uuid_default, editable=False)
    createdate=models.DateTimeField(auto_now_add=True)
    modifydate=models.DateTimeField(auto_now=True)

    person=models.ForeignKey(Person,null=False,related_name='teacher_character')
    school=models.ForeignKey(School,null=True,default=None,related_name='teacher')
    certified=models.BooleanField(null=False,default=False)
    skill=models.ManyToManyField(Dictionary) #教练技能，例如：科目2教学，科目3教学
    status=models.IntegerField(default=0,choices=STATUS_CHIOCE)
    available=models.BooleanField(null=False,default=False)

    class Meta:
        db_table='t_im_teacher'
    def toJson(self,surface=False):
        ret=serializeModel(self)
        if not surface:
            if self.person!=None:
                ret['person']=self.person.toJson()
        if self.school!=None:
            ret['school']=self.school.toJson()
        if self.skill!=None:
            skills=[];
            for s in self.skill.all():
                skills.append(s.toJson())
            ret['skill']=skills
        ret['appointmentsettings']=self.getAppointmentSettings().toJson()
        return ret
    #认证
    def certify(self,certified):
        self.certified=certified
        self.save()

    #取得教练约车设置
    def getAppointmentSettings(self):
        ret=None
        try:
            ret=self.appointmentsettings
        except Exception,e:
            ret=TeacherAppointmentSettings()
            ret.teacher=self
        return ret

    @staticmethod
    def create(personid,schoolid,skills):
        person=Person.getWithId(personid)
        if person==None:
            return None
        school=School.getWithId(schoolid)
        if school==None:
            return None
        teacher=Teacher.objects.filter(person__id=personid,school__id=schoolid).first()
        if teacher==None:
            teacher=Teacher()
            teacher.person=person
            teacher.school=school
            teacher.save()
        for s in teacher.skill.all():
            teacher.skill.remove(s)
        for s in skills:
            s=Dictionary.getWithId(s)
            if s!=None:
                teacher.skill.add(s)
        return teacher

    @staticmethod
    def getTeacherWithPersonid(personid):
        return Teacher.objects.filter(person__id=personid)
    @staticmethod
    def getWithId(teacherid):
        return Teacher.objects.filter(id=teacherid).first()

    @staticmethod
    def relatedWithStudnt(studentid):
        student=Student.getWithId(studentid)
        if student!=None:
            return Teacher.objects.filter(status=0,school__id=student.school.id)
        else:
            return []
    @staticmethod
    def deleteWithId(teacherid):
        ret=Teacher.getWithId(teacherid)
        if ret!=None:
            if ret.certified:
                ret.available=False
                ret.save()
            else:
                ret.delete()
                ret=None
        return ret


# 学员
class Student(models.Model):
    STATUS_CHIOCE=(
        ('signup',u'刚刚报名'),
        ('km1',u'理论学习(科目一)'),
        ('km2',u'场内驾驶(科目二)'),
        ('km3a',u'路考(科目三)'),
        ('km3b',u'安全文明驾驶常识(科目四)'),
        ('done',u'已取得驾照'),
    )
    id=models.CharField(primary_key=True, max_length=32,default=uuid_default, editable=False)
    createdate=models.DateTimeField(auto_now_add=True)
    modifydate=models.DateTimeField(auto_now=True)

    person=models.ForeignKey(Person,null=False,related_name='student_character')
    school=models.ForeignKey(School,null=True,default=None,related_name='student')
    certified=models.BooleanField(null=False,default=False)
    status=models.CharField(max_length=50,null=True)
    km1score=models.IntegerField(null=True,default=0)
    km2score=models.IntegerField(null=True,default=0)
    km3score=models.IntegerField(null=True,default=0)
    km4score=models.IntegerField(null=True,default=0)
    signupdate=models.DateField(null=True)
    licencedate=models.DateField(null=True)
    available=models.BooleanField(null=False,default=False)
    class Meta:
        db_table='t_im_student'
    def toJson(self,surface=False):
        ret=serializeModel(self)
        if not surface:
            if self.person!=None:
                ret['person']=self.person.toJson()
        if self.school!=None:
            ret['school']=self.school.toJson()
        return ret
    #认证
    def certify(self,certified):
        self.certified=certified
        self.save()

    @staticmethod
    def getWithId(studentid):
        return Student.objects.filter(id=studentid).first()
    @staticmethod
    def getWithPersonid(personid):
        return Student.objects.filter(person__id=personid)
    @staticmethod
    def create(personid,schoolid):
        person=Person.getWithId(personid)
        if person==None:
            return None
        school=School.getWithId(schoolid)
        if school==None:
            return None
        student=Student.objects.filter(person__id=personid,school__id=schoolid).first()
        if student==None:
            student=Student()
            student.person=person
            student.school=school
            student.save()
        return student
    @staticmethod
    def searchWithSchoolid(schoolid,searchkey):
        return Student.objects.filter(
            Q(person__name__contains=searchkey)
            |Q(person__phone__contains=searchkey)
            |Q(person__email__contains=searchkey)
            |Q(person__idcard__contains=searchkey)
            ,school__id=schoolid
        )

    @staticmethod
    def deleteWithId(studentid):
        student=Student.getWithId(studentid)
        if student!=None:
            if student.certified:
                student.available=False
                student.save()
            else:
                student.delete()
                student=None
        return student

#驾校报名
class SchoolSignup(models.Model):
    STATUS_CHOICES=(
        (u'new',u'未处理'),
        (u'signup',u'已完成报名'),
        (u'abandon',u'放弃'),
    )

    id=models.CharField(primary_key=True, max_length=32,default=uuid_default, editable=False)
    createdate=models.DateTimeField(auto_now_add=True)
    modifydate=models.DateTimeField(auto_now=True)

    person=models.ForeignKey(Person,null=False,related_name='school_signup')
    school=models.ForeignKey(School,null=False,related_name='school_signup')
    schoolclass=models.ForeignKey(SchoolClasses,null=False,related_name='school_signup')
    name=models.CharField(max_length=100,null=False)
    phone=models.CharField(max_length=50,null=False)
    gender=models.CharField(max_length=1,null=False)
    age=models.CharField(max_length=10,null=False)
    address=models.CharField(max_length=1000,null=False)
    remark=models.CharField(max_length=1000,null=True)
    status=models.CharField(max_length=50,null=False,default='new',choices=STATUS_CHOICES)

    class Meta:
        db_table='t_im_school_signup'
    def toJson(self,surface=False):
        ret=serializeModel(self)
        if not surface:
            if self.person!=None:
                ret['person']=self.person.toJson()
            if self.schoolclass!=None:
                ret['schoolclass']=self.schoolclass.toJson()
        return ret

    def updateStatus(self,status):
        self.status=status
        self.save()
        if Student.objects.filter(person__id=self.person.id,school__id=self.school.id).first()==None:
            student=Student.create(self.person.id,self.school.id)
            if student!=None:
                student.signupdate=self.createdate
                student.available=True
                student.certified=True
                student.status='signup'
                student.save()


    @staticmethod
    def create(personid,schoolid,classid,name,phone,gender,age,address,remark):
        now=datetime.datetime.now()
        limittime=now-datetime.timedelta(days=1)
        signup=SchoolSignup.objects.filter(person__id=personid,school__id=schoolid,createdate__gt=limittime).first()
        if signup==None:
            person=Person.getWithId(personid)
            if person!=None:
                school=School.getWithId(schoolid)
                if school!=None:
                    schoolclass=school.classes.filter(id=classid).first()
                    if schoolclass!=None:
                        signup=SchoolSignup()
                        signup.person=person
                        signup.school=school
                        signup.schoolclass=schoolclass
                        signup.name=name
                        signup.phone=phone
                        signup.gender=gender
                        signup.age=age
                        signup.address=address
                        signup.remark=remark
                        signup.save()
        else:
            _logger.debug('一天内不要多次报名')

        return signup

    @staticmethod
    def listWithSchoolid(schoolid,treated=False):
        ret=SchoolSignup.objects.filter(school__id=schoolid)
        #包含已处理的报名
        if not treated:
            ret=ret.exclude(~Q(status='new'))
        ret=ret.order_by('-createdate')
        return ret

    @staticmethod
    def getWithId(schoolsignupid):
        return SchoolSignup.objects.filter(id=schoolsignupid).first()

# 账户
class Account(models.Model):
    id=models.CharField(primary_key=True, max_length=32,default=uuid_default, editable=False)
    createdate=models.DateTimeField(auto_now_add=True)
    modifydate=models.DateTimeField(auto_now=True)

    person=models.OneToOneField(Person,related_name='account')
    cash=models.DecimalField(max_digits=19,decimal_places=2,default=0.0)            #现金余额
    receivable=models.DecimalField(max_digits=19,decimal_places=2,default=0.0)      #应收款余额
    payable=models.DecimalField(max_digits=19,decimal_places=2,default=0.0)         #应付款余额
    class Meta:
        db_table='t_im_account'
    def toJson(self):
        return serializeModel(self)

# 会计凭证
class Voucher(models.Model):
    ACCOUNTING_TITLE_CHOICE=(
        (u'cash',u'现金'),
        (u'receivable',u'应收款'),
        (u'payable',u'应付款'),
    )
    id=models.CharField(primary_key=True, max_length=32,default=uuid_default, editable=False)
    createdate=models.DateTimeField(auto_now_add=True)                              #记账日期
    modifydate=models.DateTimeField(auto_now=True)

    account=models.ForeignKey(Person,null=False,related_name='voucher')
    debid=models.CharField(max_length=100,null=False)                               #借方名称
    debidaccount=models.ForeignKey(Person,null=False,related_name='debid_account')  #借方账户
    debidtitle=models.CharField(max_length=100,null=False)                          #借方科目
    credit=models.CharField(max_length=100,null=False)                              #贷方名称
    creditaccount=models.ForeignKey(Person,null=False,related_name='credit_account')#贷方账户
    credittitle=models.CharField(max_length=100,null=False)                         #贷方科目
    amount=models.DecimalField(max_digits=19,decimal_places=2,default=0.0)          #发生额

    class Meta:
        db_table='t_im_voucher'
    def toJson(self):
        return serializeModel(self)

# 运营提交的认证申请
class OperationCertificate(models.Model):
    id=models.CharField(primary_key=True, max_length=32,default=uuid_default, editable=False)
    createdate=models.DateTimeField(auto_now_add=True)
    modifydate=models.DateTimeField(auto_now=True)
    operation=models.OneToOneField(Operation,related_name='certificate')
    class Meta:
        db_table='t_im_operation_certificate'
    def toJson(self):
        return serializeModel(self)
    #撤销申请
    def revoke(self):
        for item in self.item.all():
            try:
                item.imagevalue.deleteAndFile()
            except Exception,e:
                pass
            item.delete()
        self.delete()

    @staticmethod
    def create(operation,items):
        result=OperationCertificate.objects.filter(operation_id=operation.id)
        for r in result:
            r.revoke();

        ret=OperationCertificate()
        ret.operation=operation
        ret.save()
        for item in items:
            name=item['name']
            desc=item['desc']
            value=item['value']
            order=item['order']
            operationcertificateitem=OperationCertificateItem()
            operationcertificateitem.operationcertificate=ret
            operationcertificateitem.name=name
            operationcertificateitem.desc=desc
            operationcertificateitem.order=order
            if isinstance(value,ImageStore):
                operationcertificateitem.imagevalue=value
            else:
                operationcertificateitem.value=value
            operationcertificateitem.save()
        return ret
    @staticmethod
    def getWithOperationid(operationid):
        return OperationCertificate.objects.filter(operation__id=operationid).first()


class OperationCertificateItem(models.Model):
    id=models.CharField(primary_key=True, max_length=32,default=uuid_default, editable=False)
    createdate=models.DateTimeField(auto_now_add=True)
    modifydate=models.DateTimeField(auto_now=True)

    operationcertificate=models.ForeignKey(OperationCertificate,related_name='item')
    name=models.CharField(max_length=100,null=False)
    value=models.CharField(max_length=100,null=True)
    imagevalue=models.ForeignKey(ImageStore,null=True)
    desc=models.CharField(max_length=100,null=False)
    order=models.IntegerField(null=False)
    class Meta:
        db_table='t_im_operation_certificate_item'
    def toJson(self):
        ret=serializeModel(self)
        if self.imagevalue!=None:
            ret['imageurl']=self.imagevalue.getUrl()
        return ret


class TeacherAppointmentSettings(models.Model):
    id=models.CharField(primary_key=True, max_length=32,default=uuid_default, editable=False)
    createdate=models.DateTimeField(auto_now_add=True)
    modifydate=models.DateTimeField(auto_now=True)

    teacher=models.OneToOneField(Teacher,null=False,related_name='appointmentsettings')
    allowstudentappointment=models.BooleanField(null=False,default=True)
    defaultstudentnum=models.IntegerField(null=False,default=1)

    class Meta:
        db_table='t_im_teacher_appointment_settings'
    def toJson(self):
        ret=serializeModel(self)
        return ret

class CourseTimeTable(models.Model):
    id=models.CharField(primary_key=True, max_length=32,default=uuid_default, editable=False)
    createdate=models.DateTimeField(auto_now_add=True)
    modifydate=models.DateTimeField(auto_now=True)

    teacher=models.ForeignKey(Teacher,null=False,related_name='timetable')
    name=models.CharField(max_length=500,null=True)
    publishdate=models.DateField(null=True,default=date_nextday)
    expiredate=models.DateField(null=True,default=date_halfyeay_later)
    enabled=models.BooleanField(default=False)
    deleted=models.BooleanField(default=False)
    class Meta:
        db_table='t_im_coursetimetable'
    def toJson(self,surface=False):
        ret=serializeModel(self)
        if not surface:
            course=[]
            for c in self.course.filter(deleted=False):
                course.append(c.toJson())
            ret['course']=course
        ret['teacher']=self.teacher.toJson()
        return ret

    @staticmethod
    def getWithTeacherid(teacherid):
        return CourseTimeTable.objects.filter(teacher__id=teacherid,deleted=False)

    @staticmethod
    def getWithId(timetableid):
        return CourseTimeTable.objects.filter(id=timetableid).first()

    @staticmethod
    def appointmentableWithTeacherid(teacherid):
        return CourseTimeTable.objects.filter(teacher__id=teacherid,deleted=False,enabled=True).first()

class Course(models.Model):
    id=models.CharField(primary_key=True, max_length=32,default=uuid_default, editable=False)
    createdate=models.DateTimeField(auto_now_add=True)
    modifydate=models.DateTimeField(auto_now=True)

    timetable=models.ForeignKey(CourseTimeTable,null=False,related_name='course')
    weekday=models.IntegerField(null=False)
    starttime=models.TimeField(null=False)
    endtime=models.TimeField(null=False)
    course=models.CharField(max_length=500,null=False)
    studentnum=models.IntegerField(null=False,default=1)
    remark=models.CharField(max_length=1000,null=True)
    deleted=models.BooleanField(default=False)
    teacher=models.ForeignKey(Teacher,null=False,related_name='course')

    class Meta:
        db_table='t_im_course'
    def toJson(self):
        ret=serializeModel(self)
        ret['starttime']=self.starttime.strftime('%H:%M')
        ret['endtime']=self.endtime.strftime('%H:%M')
        return ret

    @staticmethod
    def getWithId(courseid):
        return Course.objects.filter(id=courseid).first()

class CourseAppointment(models.Model):
    id=models.CharField(primary_key=True, max_length=32,default=uuid_default, editable=False)
    createdate=models.DateTimeField(auto_now_add=True)
    modifydate=models.DateTimeField(auto_now=True)

    date=models.DateField(null=False)
    datetime=models.DateTimeField(null=False)
    course=models.ForeignKey(Course,null=False,related_name='appointment')
    student=models.ForeignKey(Student,null=False,related_name='appointment')
    teacher=models.ForeignKey(Teacher,null=False,related_name='appointment')
    deleted=models.BooleanField(default=False)
    absented=models.BooleanField(default=False)
    studentremark=models.CharField(max_length=1000,null=True)

    class Meta:
        db_table='t_im_course_appointment'
    def toJson(self):
        ret=serializeModel(self)
        ret['date']=formatDate(self.date)
        ret['course']=self.course.toJson()
        ret['student']=self.student.toJson()
        ret['teacher']=self.course.timetable.teacher.toJson()
        if self.datetime==None:
            appointmentDatetime=datetime.datetime(self.date.year,self.date.month,self.date.day,self.course.starttime.hour,self.course.starttime.minute,0)
        else:
            appointmentDatetime=self.datetime
        now=datetime.datetime.now()
        ret['expired']=appointmentDatetime<=now

        studentEvaluation=self.evaluation.filter(who='student').first()
        ret['studentevaluation']=None if studentEvaluation==None else studentEvaluation.toJson()
        teacherEvaluation=self.evaluation.filter(who='teacher').first()
        ret['teacherevaluation']=None if teacherEvaluation==None else teacherEvaluation.toJson()
        return ret

    @staticmethod
    def getWithId(appointmentid):
        return CourseAppointment.objects.filter(id=appointmentid).first()

    @staticmethod
    def listWithStudentid(studentid,showexpired=False):
        q=Q(student__id=studentid)
        now=datetime.datetime.now()
        if showexpired:
            q=q&Q(datetime__lte=now)
        else:
            q=q&Q(datetime__gt=now)
        return CourseAppointment.objects.filter(q).order_by('datetime','deleted')

    @staticmethod
    def listWithTeacherid(teacherid,showexpired=False):
        q=Q(teacher__id=teacherid)
        now=datetime.datetime.now()
        if showexpired:
            q=q&Q(datetime__lte=now)
        else:
            q=q&Q(datetime__gt=now)
        return CourseAppointment.objects.filter(q).order_by('datetime','deleted')

    @staticmethod
    def listOneDayWithTeacherid(teacherid,date=None):
        return CourseAppointment.objects.filter(teacher__id=teacherid,date=date).order_by('course__starttime','deleted')

class CourseAppointmentEvaluation(models.Model):
    WHO_CHOICES=(
        (u'student',u'学员评价'),
        (u'teacher',u'教练评价'),
    )
    id=models.CharField(primary_key=True, max_length=32,default=uuid_default, editable=False)
    createdate=models.DateTimeField(auto_now_add=True)
    modifydate=models.DateTimeField(auto_now=True)

    who=models.CharField(max_length=50,null=False)
    appointment=models.ForeignKey(CourseAppointment,null=False,related_name='evaluation')
    evaluation=models.CharField(max_length=2000,null=True)
    star1=models.IntegerField(null=True)
    star2=models.IntegerField(null=True)
    star3=models.IntegerField(null=True)
    star4=models.IntegerField(null=True)
    star5=models.IntegerField(null=True)
    star6=models.IntegerField(null=True)
    star7=models.IntegerField(null=True)
    star8=models.IntegerField(null=True)
    star9=models.IntegerField(null=True)
    averagestar=models.DecimalField(max_digits=9,decimal_places=2)



    class Meta:
        db_table='t_im_course_appointment_evaluation'
    def toJson(self):
        ret=serializeModel(self)
        return ret

    @staticmethod
    def getWithId(evaluationid):
        return CourseAppointmentEvaluation.objects.filter(id=evaluationid).first()



class Log(models.Model):
    id=models.CharField(primary_key=True, max_length=32,default=uuid_default, editable=False)
    createdate=models.DateTimeField(auto_now_add=True)
    modifydate=models.DateTimeField(auto_now=True)

    operatorid=models.CharField(max_length=32,null=False)
    name=models.CharField(max_length=100,null=True)
    ext1=models.CharField(max_length=100,null=True)
    ext2=models.CharField(max_length=100,null=True)
    ext3=models.CharField(max_length=100,null=True)
    ext4=models.CharField(max_length=100,null=True)
    ext5=models.CharField(max_length=100,null=True)
    ext6=models.CharField(max_length=100,null=True)
    ext7=models.CharField(max_length=100,null=True)
    ext8=models.CharField(max_length=100,null=True)
    ext9=models.CharField(max_length=100,null=True)

    class Meta:
        db_table='t_im_log'
    def toJson(self):
        ret=serializeModel(self)
        return ret
