#coding=utf-8
import datetime,os,base64,thread,time,calendar
from django.shortcuts import render
from django.conf import settings
from django.http import HttpResponse, HttpResponseRedirect, StreamingHttpResponse,HttpResponseNotFound
from  django  import  forms
from common.utils import *
from common.mimetype import *
from im.models import *
from app.rcapi import *
from PIL import Image
from app.decorators import *

_logger = logging.getLogger('app')

#公众号进入统计
@catchexception
def mp_enter(request,schoolid):
    operatorid=readFromDict(request.REQUEST,'operatorid')
    grainsize=readFromDict(request.REQUEST,'grainsize')
    d=parseDate(readFromDict(request.REQUEST,'selectedDate'))
    if d==None:
        d=datetime.datetime.now()

    datescope=[]
    if grainsize=='D':
        d=d.replace(hour=0,minute=0,second=0,microsecond=0)
        for i in range(0,24):
            d0=d+datetime.timedelta(hours=i)
            d1=d+datetime.timedelta(hours=i+1)
            datescope.append({'d0':d0,'d1':d})
    elif grainsize=='W':
        d=d.replace(hour=0,minute=0,second=0,microsecond=0)
        for i in range (0,7):
            d0=d-datetime.timedelta(days=i+1)
            d1=d-datetime.timedelta(days=i)
            datescope.append({'d0':d0,'d1':d})
    elif grainsize=='M':
        d=d.replace(day=1,hour=0,minute=0,second=0,microsecond=0)
        for i in range (0,calendar.monthrange(d.year,d.month)[1]):
            d0=d+datetime.timedelta(days=i)
            d1=d+datetime.timedelta(days=1+1)
            datescope.append({'d0':d0,'d1':d})
    elif:
        d=d.replace(month=1,day=1,hour=0,minute=0,second=0,microsecond=0)
        for i in range (0,12):
            d0=d.replace(month,i+1)
            d1=d+datetime.timedelta(days=calendar.monthrange(d.year,d.month)[1])
            datescope.append({'d0':d0,'d1':d})



    for i in range (0,7):
        d0=d-datetime.timedelta(days=1)
        datescope.append({'d0':d0,'d1':d})
        d=d0


    data=[]
    for i in range(0,len(datescope)):
        d0=datescope[i]['d0']
        d1=datescope[i]['d1']
        print d0,d1
        d_count=Log.objects.filter(name='enter_school_mp',ext1=schoolid,createdate__gte=d0,createdate__lt=d1).count()
        data.append(d_count)


    return jsonResponse(getHRD(data=data))