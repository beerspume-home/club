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
from modelutils import *

_logger = logging.getLogger('im')

# 字典-用于教练，学员或其他对象
class Dictionary(models.Model):
    id=models.CharField(primary_key=True, max_length=32,default=uuid_default, editable=False)
    name=models.CharField(max_length=100,null=False,choices=DICTIONARY_TYPE_CHIOCE)
    value=models.CharField(max_length=100,null=False)
    desc=models.CharField(max_length=100,null=True)
    order=models.IntegerField(max_length=5,null=True)
    class Meta:
        db_table='t_im_dictionary'
        app_label='im'
    def toJson(self):
        return serializeModel(self)

    #地区数据版本
    @staticmethod
    def areaVersion():
        ret=0.0
        result=Dictionary.objects.filter(name=DICTIONARY_TYPE_CHIOCE[1][0]).first()
        if result!=None:
            try:
                ret=float(result.value)
            except Exception,e:
                pass
        return ret

    @staticmethod
    def getWithName(dictname):
        return Dictionary.objects.filter(name=dictname)

    @staticmethod
    def getWithId(dictid):
        return Dictionary.objects.filter(id=dictid).first()
