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



# 通讯录联系人
class Contacts(models.Model):
    id=models.CharField(primary_key=True, max_length=32,default=uuid_default, editable=False)
    createdate=models.DateTimeField(auto_now_add=True)
    modifydate=models.DateTimeField(auto_now=True)

    contactbook=models.ForeignKey(ContactBook,null=False,related_name='contacts')
    person=models.ForeignKey(Person,null=False)
    class Meta:
        db_table='t_im_contacts'
        app_label='im'
    def toJson(self):
        ret=serializeModel(self)
        ret[u'person']=self.person.toJson()
        return ret

