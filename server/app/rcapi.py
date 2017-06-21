#coding=utf-8
import os
import json
import unittest
import logging
from rong import *


_logger=logging.getLogger('app')

global rc_client
rc_client=ApiClient()

def rc_user_get_token(user_id, name, portrait_uri):
    global rc_client
    result=rc_client.user_get_token(user_id, name, portrait_uri)
    if result[u'code']!=200:
        return None,None
    return result[u'token'],result[u'userId']


def rc_group_create(user_id_list,groupid,groupname):
    global rc_client
    if len(user_id_list)>0:
        result=rc_client.group_create(user_id_list,groupid,groupname)
        if result[u'code']!=200:
            return False
    else:
        return False
    return True

def rc_group_quit(user_id_list, group_id):
    global rc_client
    if len(user_id_list)>0:
        result=rc_client.group_quit(user_id_list,group_id)
        if result[u'code']!=200:
            return False
    return True

def rc_group_dismiss(user_id, group_id):
    global rc_client
    result=rc_client.group_dismiss(user_id,group_id)
    if result[u'code']!=200:
        return False
    return True

def rc_group_join(user_id_list, group_id, group_name):
    global rc_client
    if len(user_id_list)>0:
        result=rc_client.group_join(user_id_list, group_id, group_name)
        if result[u'code']!=200:
            return False
    return True

def rc_group_refresh(group_id, group_name):
    global rc_client
    result=rc_client.group_refresh(group_id, group_name)
    if result[u'code']!=200:
        return False
    return True


