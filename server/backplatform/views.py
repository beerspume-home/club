#coding=utf-8
import datetime,os,base64,thread,time
from django.shortcuts import render
from django.conf import settings
from django.http import HttpResponse, HttpResponseRedirect, StreamingHttpResponse,HttpResponseNotFound
from  django  import  forms
from common.utils import *
from common.mimetype import *
from im.models import *
from app.rcapi import *
from PIL import Image

_logger = logging.getLogger('backplatform')

