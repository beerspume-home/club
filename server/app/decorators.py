#coding=utf-8
"""
Reference django.contrib.auth.decorators
"""

import logging,hashlib
from django.conf import settings
from django.shortcuts import redirect
from django.http import HttpResponseRedirect,HttpResponseForbidden
from common.utils import *
from im.models import *


_logger = logging.getLogger('app')

def catchexception(view_func):
    def decorator(request, *args, **kwargs):
        try:
            return view_func(request, *args, **kwargs)
        except Exception, e:
            _logger.exception(e)
            raise(e)
    return decorator



def auth(view_func):
    def decorator(request, *args, **kwargs):
        try:
            headers=request.META
            personid=headers.get('HTTP_PERSONID')
            deviceid=headers.get('HTTP_DEVICEID')
            datetime=headers.get('HTTP_DATETIME')
            sign=headers.get('HTTP_SIGN')
            _logger.debug("\nheader:\n  persionid:%s\n  deviceid:%s\n  datetime:%s\n  sign:%s\n"%(personid,deviceid,datetime,sign))

            if personid==None:
                return HttpResponseForbidden('No User')
            token=AccessToken.getToken(personid,deviceid)
            _logger.debug("\ntoken:%s"%(token))
            if token==None:
                # return HttpResponseForbidden('No Token')
                token=''
            sign_array=[personid,deviceid,datetime,token]
            sign_array.sort()
            _sign=hashlib.sha1(''.join(sign_array)).hexdigest()
            _logger.debug("\n_sign:%s"%(_sign))
            if sign!=_sign:
                return HttpResponseForbidden('Wrong sign')
            return view_func(request, *args, **kwargs)
        except Exception, e:
            _logger.exception(e)
            raise(e)
    return decorator

