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


# 通讯录
class ContactBook(models.Model):
    id=models.CharField(primary_key=True, max_length=32,default=uuid_default, editable=False)
    createdate=models.DateTimeField(auto_now_add=True)
    modifydate=models.DateTimeField(auto_now=True)

    owner=models.OneToOneField(Person,null=False,related_name='contactbook')
    class Meta:
        db_table='t_im_contact_book'
        app_label='im'
    #添加联系人
    def addContacts(self,person):
        if person!=None:
            contacts=self.contacts.filter(person=person).first()
            if contacts==None:
                self.contacts.add(Contacts(person=person))
    #删除联系人
    def removeContacts(self,person):
        if person!=None:
            contacts=self.contacts.filter(person=person).first()
            if contacts!=None:
                contacts.delete()

    #获取用户的通讯录
    @staticmethod
    def getWithPersonid(personid):
        person=Person.getWithId(personid)
        if person==None:
            return None
        try:
            contactbook=person.contactbook
        except ObjectDoesNotExist,e:
            contactbook=ContactBook()
            contactbook.owner=person
            contactbook.save()
        return contactbook

