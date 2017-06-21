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

#地区
class Area(models.Model):
    id=models.CharField(primary_key=True, max_length=32,default=uuid_default, editable=False)
    level=models.IntegerField(max_length=2,null=False)
    parent=models.CharField(max_length=32,null=True)
    name=models.CharField(max_length=100,null=False)
    postcode=models.CharField(max_length=100,null=False,unique=True)
    namepath=models.CharField(max_length=500,null=False)
    class Meta:
        db_table='t_im_area'
        app_label='im'
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

