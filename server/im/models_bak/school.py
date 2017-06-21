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

    class Meta:
        db_table='t_im_school'
        app_label='im'
    def toJson(self):
        ret=serializeModel(self)
        area=Area.getWithPostcode(self.postcode)
        if area!=None:
            ret['area']=area.toJson()
        ret['imageurl']=self.genImageUrl()
        ret['mppageurl']=self.genMPPageUrl()
        return ret
    def genImageUrl(self):
        return os.path.join(settings.SERVER_BASE_URL,'app/schoolImage?schoolid=%s'%(self.id))
    def genMPPageUrl(self):
        return os.path.join(settings.SERVER_BASE_URL,'mp/schoolPage/%s'%(self.id))
    #取得驾校的所有教练
    def allTeacher(self):
        return self.teacher.all()

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
