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
        app_label='im'
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

