#coding=utf-8
from django.conf.urls import patterns, include, url
from django.contrib import admin

urlpatterns = patterns('',
    # Examples:
    # url(r'^$', 'im.views.home', name='home'),
    # url(r'^blog/', include('blog.urls')),

    # url(r'^admin/', include(admin.site.urls)),
)

# APP接口
from app.urls import urlpatterns as app_urlpatterns
urlpatterns += app_urlpatterns


# 驾校运营平台
from mp.urls import urlpatterns as mp_urlpatterns
urlpatterns += mp_urlpatterns



# 系统运营平台
from backplatform.urls import urlpatterns as backplatform_urlpatterns
urlpatterns += backplatform_urlpatterns
