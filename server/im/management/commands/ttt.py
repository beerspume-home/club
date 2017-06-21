#coding=utf-8

from django.core.management.base import BaseCommand
from im.models import *


class Command(BaseCommand):
    def handle(self, *args, **options):
        schoolid='ca21c0ca7f2c11e5b41980e6500868b4'
        personid='b2b26c5981f711e5a2b080e6500868b4'
        school=School.getWithId(schoolid)
        if school==None:
            print '没有找到驾校'
            return

        signups=school.school_signup.all()
        print len(signups)

        person=Person.getWithId(personid)
        if person==None:
            print '没有找到用户'

        signups=person.school_signup.all()
        print len(signups)

        signup=SchoolSignup.create(personid,schoolid,'施骁','18600476605','1','30','aaaa','bbbbb')
        print signup

