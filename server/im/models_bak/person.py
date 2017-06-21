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
from im.models import *

_logger = logging.getLogger('im')



# 自然人身份信息
class Person(models.Model):
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

    class Meta:
        db_table='t_im_person'
        app_label='im'

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
        ret=self.teacher_character.filter(status=0).first()
        if ret==None:
            ret=self.student_character.filter(status=0).first()
        return ret
    def isTeacher(self):
        character=self.getCharacter()
        return isinstance(character,Teacher)
    def isStudent(self):
        character=self.getCharacter()
        return isinstance(character,Student)


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
                    from im.models.rongcloud import RongCloud
                    rc=RongCloud()
                    rc.person=self;
                rc.token=token
                rc.save()
        return token


    @staticmethod
    def validGender(gender):
        for g in GENDER_CHOICES:
            if gender==g[0]:
                return True
        return False

    @staticmethod
    def defaultGender():
        return GENDER_CHOICES[0][0]
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

        from im.models.auth import Auth
        Auth.setNewPasswordForPerson(person.id,password)

        from im.models.social import Social
        social=Social()
        social.person=person
        social.nickname=nickname
        social.save()

        from im.models.account import Account
        account=Account()
        account.person=person
        account.save()

        return person

