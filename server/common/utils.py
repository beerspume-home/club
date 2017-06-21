#coding=utf-8
import json,logging,hashlib,datetime,time,random,re,qrcode,os
from urllib import quote
from django.http import HttpResponse,HttpResponseRedirect
from django.conf import settings

def readFromDict(dictobj,key,defaultvalue=None):
    ret=defaultvalue
    if dictobj and key and (key in dictobj):
        ret=dictobj[key]

    if ret!=None:
        ret=ret.strip()
    return ret

def readIntFromDict(dictobj,key,defaultvalue=0):
    ret=readFromDict(dictobj,key,None)
    try:
        ret=defaultvalue if ret==None else int(ret)
    except Exception,e:
        ret=defaultvalue
    return ret

# 随机生产六位验证码
def generatorCode(length):
    slcNum = [random.choice(string.digits) for i in range(length)]
    #打乱这个组合
    random.shuffle(slcNum)
    #生成密码
    genPwd = ''.join([i for i in slcNum])
    return genPwd

# 检查手机号是否合法
def checkPhoneNumber(phoneNumber):
    '''正则匹配电话号码'''
    match = re.compile('^\d{11}$').match(phoneNumber)
    if match:
        return True
    else:
        return False

# 检查身份证号
def checkIDCard(idcard):
    '''正则匹配电话号码'''
    match = re.compile('^(\d{18}|\d{15})$').match(idcard)
    if match:
        return True
    else:
        return False


# 构造文本格式的http返回格式
def textResponse(text):
    return HttpResponse(text,content_type='text/plain')
# 构造XML格式的http返回格式
def xmlResponse(data,ase=False,token='',encodingAESKey='',appid='',nonce=''):
    ret_xml=xmltodict.unparse(data)
    if ase:
        encryp = WXBizMsgCrypt(token,encodingAESKey,appid.encode('UTF-8'))
        ret,encrypt_xml = encryp.EncryptMsg(ret_xml.encode('UTF-8'),nonce)
        if ret==0:
            return HttpResponse(encrypt_xml,content_type='text/xml')
        else:
            return textResponse('Error')
    else:
        return HttpResponse(ret_xml,content_type='text/xml')
# 构造json格式的http返回格式
def jsonResponse(data):
    if isinstance(data,dict):
        ret=json.dumps(data)
    else:
        ret=data
    return HttpResponse(ret,content_type='application/json')
# 构造http response内容结构
def getHRD(data={},code=0,msg=''):
    return {'code':code,'msg':msg,'data':data}

# 生成二维码
def genQRCode(data):
    img=qrcode.make(data)
    return img

# 文件分流下载
def file_iterator(file_name, chunk_size=512):
  with open(file_name,'rb') as f:
    while True:
      c = f.read(chunk_size)
      if c:
        yield c
      else:
        break

# 格式化日期
def formatDate(date):
    if date!=None:
        return date.strftime('%Y-%m-%d')
    else:
        return ''
def formatDatetime(date):
    if date!=None:
        return date.strftime('%Y-%m-%d %H:%M:%S')
    else:
        return ''


# 格式化日期
def parseDate(date_str):
    if date_str!=None:
        try:
            return datetime.datetime.strptime(date_str,'%Y-%m-%d').date();
        except Exception,e:
            return None
    else:
        return None
def parseDatetime(date_str):
    if date_str!=None:
        try:
            return datetime.datetime.strptime(date_str,'%Y-%m-%d %H:%M:%S');
        except Exception,e:
            return None
    else:
        return None
def parseTime(time_str):
    ret=None
    if time_str!=None:
        try:
            return datetime.datetime.strptime(time_str,'%H:%M:%S').time();
        except Exception,e:
            pass

        if ret==None:
            try:
                return datetime.datetime.strptime(time_str,'%H:%M').time();
            except Exception,e:
                pass
    else:
        return ret
