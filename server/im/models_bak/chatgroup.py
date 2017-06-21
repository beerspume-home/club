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

# 聊天群组
class ChatGroup(models.Model):
    id=models.CharField(primary_key=True, max_length=32,default=uuid_default, editable=False)
    createdate=models.DateTimeField(auto_now_add=True)
    modifydate=models.DateTimeField(auto_now=True)

    name=models.CharField(max_length=100,null=False)
    class Meta:
        db_table='t_im_chatgroup'
        app_label='im'
    def toJson(self):
        ret=serializeModel(self)
        members=self.member.all()
        members_json=[]
        for m in members:
            members_json.append(m.toJson())
        ret['members']=members_json
        ret['imageurl']=self.genImageUrl()
        return ret
    def member_id_list(self):
        ret=[]
        members=self.member.all()
        for m in members:
            ret.append(m.person.id)
        return ret
    def genImageUrl(self):
        return os.path.join(settings.SERVER_BASE_URL,'app/groupImage?groupid=%s'%(self.id))
    def getImageFilepath(self):
        return ChatGroup.genImageFilepath(self.id)
    # 生成群组图片
    def genGroupImage(self):
        members=self.member.all()[:9]
        maxW=180
        groupImage = Image.new('RGB', (maxW, maxW), (255, 255, 255))
        #成员小于等于4人则显示 2x2 头像矩阵
        #成员大于4小于等于9人则显示 3x3 头像矩阵
        w=maxW/3
        if len(members)<=4:
            w=maxW/2
        x=0
        y=0
        for m in members:
            person=m.person
            imageFilepath=person.getHeadImageFilepath()
            if not os.path.exists(imageFilepath):
                imageFilepath=os.path.join(settings.HEADIMG_PATH,'default.png')
            image=Image.open(imageFilepath)
            groupImage.paste(image.resize((w,w)),(x,y))
            x+=w
            if x>=maxW:
                x=0
                y+=w

        groupImage.save(self.getImageFilepath(),'png')

    # 删除成员
    def removeMember(self,personid):
        self.member.filter(person__id=personid).delete()
        rc_group_quit([personid],self.id)
        leftmembers=self.member.all()
        if len(leftmembers)<2:
            rc_group_dismiss(personid,self.id)
            self.delete()
        else:
            if(self.member.filter(isowner=True).first()==None):
                member=self.member.filter(group__id=self.id).first()
                member.isowner=True
                member.save()

    # 添加成员
    def addMember(self,persons):
        user_id_list=[]
        for personid in persons:
            if self.member.filter(person__id=personid).first()==None:
                person=Person.getWithId(personid)
                if person!=None:
                    self.member.create(person=person)
                    user_id_list.append(person.id)
        rc_group_join(user_id_list, self.id, self.name)

    #用户是否为群组成员
    def isMember(self,personid):
        return self.member.filter(person__id=personid).first()!=None

    #修改群组名称
    def updateName(self,groupname):
        self.name=groupname
        self.save()
        rc_group_refresh(self.id, groupname)


    @staticmethod
    def create(ownerid,memberarray):
        ret=None
        owner=Person.getWithId(ownerid)
        if owner!=None:
            ret=ChatGroup()
            ret.name=u'未命名'
            ret.save()
            member=ChatGroupMember()
            member.group=ret
            member.person=owner
            member.isowner=True
            member.save()
            for mid in memberarray:
                m=Person.getWithId(mid)
                if m!=None:
                    mm=ChatGroupMember()
                    mm.group=ret
                    mm.person=m
                    mm.isowner=False
                    mm.save()
            ret.genGroupImage()
        return ret
    @staticmethod
    def getWithId(groupid):
        return ChatGroup.objects.filter(id=groupid).first()

    @staticmethod
    def search(personid):
        return ChatGroup.objects.filter(member__person__id=personid)

    @staticmethod
    def genImageFilepath(groupid):
        if not os.path.exists(settings.GROUPIMG_PATH):
            os.mkdir(settings.GROUPIMG_PATH)
        return os.path.join(settings.GROUPIMG_PATH,'%s.png'%groupid)
