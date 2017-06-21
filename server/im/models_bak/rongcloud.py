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



class RongCloud(models.Model):
    id=models.CharField(primary_key=True, max_length=32,default=uuid_default, editable=False)
    person=models.OneToOneField(Person,related_name='rongcloud')
    token=models.CharField(max_length=100,null=False)

    class Meta:
        db_table='t_im_rongcloud'
        app_label='im'
    def toJson(self):
        return serializeModel(self)

