#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""
Reads a list of files from an input .txt file
Then outputs a new .csv file with the input items that are not in the database
"""
import os
import sys
import csv

# Initailize Django
os.environ.setdefault("DJANGO_SETTINGS_MODULE", "settings")
# Ensure settings are read
from django.core.wsgi import get_wsgi_application
application = get_wsgi_application()
from db.models import File

def file_in_database(filename):
    """
    Checks if a file is already in the database
    """
    return(File.objects.filter(filename = filename).exists())

def main():
    args = sys.argv[1:]
    input_list_file = args[0]
    output_list_csv = args[1]

    file_list = []
    with open(input_list_file) as f:
        for line in f:
            file_list.append(line.strip())

    already_in_db = []
    not_in_db = []

    for filename in file_list:
        is_in_db = file_in_database(filename = filename)
        if is_in_db:
            already_in_db.append(filename)
        else:
            not_in_db.append(filename)

    with open(output_list_csv, "w") as fout:
        writer = csv.writer(fout)
        for filename in not_in_db:
            full_path = os.path.realpath(filename)
            row = [filename, full_path]
            writer.writerow(row)

if __name__ == '__main__':
    main()
