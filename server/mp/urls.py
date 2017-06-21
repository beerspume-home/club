#coding=utf-8
from django.conf.urls import url

urlpatterns = [
    #获取用户信息
    url(r'^mp/schoolPage/(.+)/?$', 'mp.views.schoolPage'),

]

