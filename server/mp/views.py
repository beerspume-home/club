#coding=utf-8
import datetime,os,base64,thread,time
from django.shortcuts import render,render_to_response
from django.conf import settings
from django.http import HttpResponse, HttpResponseRedirect, StreamingHttpResponse,HttpResponseNotFound
from  django  import  forms
from common.utils import *
from common.mimetype import *
from im.models import *
from app.rcapi import *
from PIL import Image

_logger = logging.getLogger('mp')


def schoolPage(request,schoolid):
    school=School.getWithId(schoolid)
    if school==None:
        return render_to_response('school_notfound.html',{})
    teachers=[]
    result=school.allTeacher()
    for t in result:
        teachers.append(t.toJson())

    return render_to_response('school_page.html',{'school':school,'teachers':teachers})

