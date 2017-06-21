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

# 自然人鉴权
class Auth(models.Model):
    id=models.CharField(primary_key=True, max_length=32,default=uuid_default, editable=False)
    createdate=models.DateTimeField(auto_now_add=True)
    modifydate=models.DateTimeField(auto_now=True)

    person=models.OneToOneField(Person,related_name='auth')
    password=models.CharField(max_length=100,null=True)
    class Meta:
        db_table='t_im_auth'
        app_label='im'
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
