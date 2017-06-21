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

# 账户
class Account(models.Model):
    id=models.CharField(primary_key=True, max_length=32,default=uuid_default, editable=False)
    createdate=models.DateTimeField(auto_now_add=True)
    modifydate=models.DateTimeField(auto_now=True)

    person=models.OneToOneField(Person,related_name='account')
    cash=models.DecimalField(max_digits=19,decimal_places=2,default=0.0)            #现金余额
    receivable=models.DecimalField(max_digits=19,decimal_places=2,default=0.0)      #应收款余额
    payable=models.DecimalField(max_digits=19,decimal_places=2,default=0.0)         #应付款余额
    class Meta:
        db_table='t_im_account'
        app_label='im'
    def toJson(self):
        return serializeModel(self)
