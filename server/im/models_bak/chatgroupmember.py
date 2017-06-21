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
        app_label='im'
    def toJson(self):
        ret=serializeModel(self)
        ret[u'person']=self.person.toJson()
        return ret
