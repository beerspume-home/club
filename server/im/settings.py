#coding=utf-8
"""
Django settings for im project.

For more information on this file, see
https://docs.djangoproject.com/en/1.7/topics/settings/

For the full list of settings and their values, see
https://docs.djangoproject.com/en/1.7/ref/settings/
"""

# Build paths inside the project like this: os.path.join(BASE_DIR, ...)
import os
BASE_DIR = os.path.dirname(os.path.dirname(__file__))


# Quick-start development settings - unsuitable for production
# See https://docs.djangoproject.com/en/1.7/howto/deployment/checklist/

# SECURITY WARNING: keep the secret key used in production secret!
SECRET_KEY = '9c2&ayk_xkfeixe^%==7!mv7zx-2z4#creudg#d^7)_q-#6eb)'

# SECURITY WARNING: don't run with debug turned on in production!
DEBUG = True

TEMPLATE_DEBUG = True

ALLOWED_HOSTS = []


# Application definition

INSTALLED_APPS = (
    # 'django.contrib.admin',
    # 'django.contrib.auth',
    'django.contrib.contenttypes',
    'django.contrib.sessions',
    'django.contrib.messages',
    'django.contrib.staticfiles',
    'im',
    'app', #移动端接口
    'mp', #公众号平台
)

MIDDLEWARE_CLASSES = (
    'django.contrib.sessions.middleware.SessionMiddleware',
    'django.middleware.common.CommonMiddleware',
    # 'django.middleware.csrf.CsrfViewMiddleware',
    # 'django.contrib.auth.middleware.AuthenticationMiddleware',
    # 'django.contrib.auth.middleware.SessionAuthenticationMiddleware',
    # 'django.contrib.messages.middleware.MessageMiddleware',
    # 'django.middleware.clickjacking.XFrameOptionsMiddleware',
    #'django.middleware.transaction.TransactionMiddleware',
)

ROOT_URLCONF = 'im.urls'

WSGI_APPLICATION = 'im.wsgi.application'


# Database
# https://docs.djangoproject.com/en/1.7/ref/settings/#databases

DATABASES = {
    'default': {
        'ENGINE': 'django.db.backends.sqlite3',
        'NAME': os.path.join(BASE_DIR, 'db.sqlite3'),
    }
}

# Internationalization
# https://docs.djangoproject.com/en/1.7/topics/i18n/

LANGUAGE_CODE = 'zh-cn'

TIME_ZONE = 'Asia/Shanghai'

USE_I18N = True

USE_L10N = True

USE_TZ = False


# Static files (CSS, JavaScript, Images)
# https://docs.djangoproject.com/en/1.7/howto/static-files/

STATIC_URL = '/static/'

#二维码图片存放路径
QRIMG_PATH= os.path.join(BASE_DIR,'../resourcefiles/qrimg')
#头像图片存放路径
HEADIMG_PATH= os.path.join(BASE_DIR,'../resourcefiles/headimg')
#群组图片存放路径
GROUPIMG_PATH= os.path.join(BASE_DIR,'../resourcefiles/groupimg')
#图片存放路径
IMAGE_PATH= os.path.join(BASE_DIR,'../resourcefiles/imagestore')
#服务器
SERVER_BASE_URL='http://localhost:8888/'

#融云配置
os.environ.setdefault('rongcloud_app_key', 'p5tvi9dst1414')
os.environ.setdefault('rongcloud_app_secret', 'A1asJtePUt1')

LOGGING = {
    'version': 1,
    'disable_existing_loggers': True,
    'formatters': {
        'verbose': {
            'format': '[%(levelname)s %(asctime)s %(filename)s:%(lineno)d %(process)d] %(message)s'
        },
        'simple': {
            'format': '%(levelname)s %(message)s'
        },
    },
    'handlers': {
        'null': {
            'level': 'ERROR',
            'class': 'django.utils.log.NullHandler',
        },
        'console': {
            'level': 'DEBUG',
            'class': 'logging.StreamHandler',
            'formatter': 'verbose'
        },
        'file': {
            'level': 'DEBUG',
            'class': 'logging.FileHandler',
            'filename': os.path.join(BASE_DIR,'../logs/im.log'),
            'formatter': 'verbose'
        },
        'mail_admins': {
            'level': 'ERROR',
            'class': 'django.utils.log.AdminEmailHandler'
        },
    },
    'loggers': {
        'django.db.backends': {
            'handlers': ['null'],
            'propagate': True,
            'level':'DEBUG',
        },        
        'django': {
            'handlers': ['null'],
            'propagate': True,
            'level': 'INFO',
        },
        'django.request': {
            'handlers': ['mail_admins'],
            'level': 'DEBUG',
            'propagate': True,
        },
        'app': {
            'handlers': ['console'],
            'level': 'DEBUG',
        },
        'im': {
            'handlers': ['console'],
            'level': 'DEBUG',
        },
        'mp': {
            'handlers': ['console'],
            'level': 'DEBUG',
        },
    }
}

