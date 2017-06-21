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
        return ret
    else:
        return None

#生成UUID
def uuid_default():
    return unicode(uuid.uuid1()).replace('-','')

#字典表项目
DICTIONARY_TYPE_CHIOCE=(
    (u'teacher_skill',u'教练教学科目'),
    (u'area_version',u'地区数据版本'),
)

#性别
GENDER_CHOICES=(
    ('0','未知'),
    ('1','男'),
    ('2','女'),
    ('3','X'),
)

#记账科目
ACCOUNTING_TITLE_CHOICES=(
    (u'cash',u'现金'),
    (u'receivable',u'应收款'),
    (u'payable',u'应付款'),
)


