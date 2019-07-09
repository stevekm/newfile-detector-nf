#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Adds an item to the databse
"""
import os
import sys

# Initailize Django
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "settings")
# Ensure settings are read
from django.core.wsgi import get_wsgi_application
application = get_wsgi_application()
from db.models import File

def main():
    args = sys.argv[1:]
    filename = args[0]
    instance = File.objects.create(filename=filename)

if __name__ == '__main__':
    main()
