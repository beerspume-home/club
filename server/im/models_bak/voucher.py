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



# 会计凭证
class Voucher(models.Model):
    id=models.CharField(primary_key=True, max_length=32,default=uuid_default, editable=False)
    createdate=models.DateTimeField(auto_now_add=True)                              #记账日期
    modifydate=models.DateTimeField(auto_now=True)

    account=models.ForeignKey(Person,null=False,related_name='voucher')
    debid=models.CharField(max_length=100,null=False)                               #借方名称
    debidaccount=models.ForeignKey(Person,null=False,related_name='debid_account')  #借方账户
    debidtitle=models.CharField(max_length=100,null=False,choices=ACCOUNTING_TITLE_CHOICES)                          #借方科目
    credit=models.CharField(max_length=100,null=False)                              #贷方名称
    creditaccount=models.ForeignKey(Person,null=False,related_name='credit_account')#贷方账户
    credittitle=models.CharField(max_length=100,null=False,choices=ACCOUNTING_TITLE_CHOICES)                         #贷方科目
    amount=models.DecimalField(max_digits=19,decimal_places=2,default=0.0)          #发生额

    class Meta:
        db_table='t_im_voucher'
        app_label='im'
    def toJson(self):
        return serializeModel(self)

