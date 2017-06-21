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



# 学员
class Student(models.Model):
    id=models.CharField(primary_key=True, max_length=32,default=uuid_default, editable=False)
    createdate=models.DateTimeField(auto_now_add=True)
    modifydate=models.DateTimeField(auto_now=True)

    person=models.ForeignKey(Person,null=False,related_name='student_character')
    school=models.ForeignKey(School,null=True,default=None,related_name='student')
    status=models.IntegerField(max_length=1,default=0)
    class Meta:
        db_table='t_im_student'
        app_label='im'
    def toJson(self):
        return serializeModel(self)

