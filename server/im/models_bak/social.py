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
        app_label='im'
    def toJson(self):
        ret=serializeModel(self)
        return ret

    @staticmethod
    def getWithPerson(personid):
        return Social.objects.filter(person__id=personid).first()
