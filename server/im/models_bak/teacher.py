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



# 教练
class Teacher(models.Model):
    STATUS_CHIOCE=(
        (0,u'正常'),
        (1,u'已离职'),
    )

    id=models.CharField(primary_key=True, max_length=32,default=uuid_default, editable=False)
    createdate=models.DateTimeField(auto_now_add=True)
    modifydate=models.DateTimeField(auto_now=True)

    person=models.ForeignKey(Person,null=False,related_name='teacher_character')
    school=models.ForeignKey(School,null=True,default=None,related_name='teacher')
    certified=models.BooleanField(null=False,default=False)
    skill=models.ManyToManyField(Dictionary) #教练技能，例如：科目2教学，科目3教学
    status=models.IntegerField(default=0,choices=STATUS_CHIOCE)

    class Meta:
        db_table='t_im_teacher'
        app_label='im'
    def toJson(self):
        ret=serializeModel(self)
        if self.person!=None:
            ret['person']=self.person.toJson()
        if self.school!=None:
            ret['school']=self.school.toJson()
        if self.skill!=None:
            skills=[];
            for s in self.skill.all():
                skills.append(s.toJson())
            ret['skill']=skills
        return ret

    @staticmethod
    def create(personid,schoolid,skills):
        person=Person.getWithId(personid)
        if person==None:
            return None
        school=School.getWithId(schoolid)
        if school==None:
            return None
        teacher=Teacher()
        teacher.person=person
        teacher.school=school
        teacher.save()
        for s in skills:
            s=Dictionary.getWithId(s)
            if s!=None:
                teacher.skill.add(s)
        return teacher

    @staticmethod
    def getTeacherWithPersonid(personid):
        return Teacher.objects.filter(person__id=personid)
