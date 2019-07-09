# newfile-detector-nf

Database-driven Nextflow app using Django ORM standalone

A basic demo app that demonstrates how to use a Django ORM Standalone Application database to drive a Nextflow workflow.

This app demonstrates how to use the Django ORM without a full Django app, in conjunction with Nextflow.

# Overview

Nextflow allows for the asynchronous parallel execution of a workflow. However, managing the selection of input files to be processed by the workflow gets tricky, especially when running Nextflow in an automated-fasion with an ever increasing dataset. It may be advantageous to maintain a database of files that have been previously processed, and so can be skipped in the Nextflow workflow. Currently, Nextflow does not have native database support used to accomplish this from within the Nextflow workflow.

Django ORM provides an easy and convenient method to interact with databases, such as SQLite, however it typically comes packaged in a full scale Django web app. 

This repository demonstrates how to use a tiny standalone instance of the Django ORM in order to leverage a SQLite database to allow for fine-tuned control over the operations of a Nextflow pipeline. 

## Method

The main Nextflow workflow script, `main.nf` globs up all of the files in the monitored directory, `files`, and creates a file list text from them. This text file is passed to `check_file_list.py`, which returns a new .csv formatted file list with only the items which are not already present in the databse.

The paths to the new files for processing are passed on to the rest of the Nextflow workflow for parallel asynchronous handling (you custom file handling actions go here). 

Finally, the successfully processed files are recorded in the database with `add_to_db.py`. 

# Installation

First, clone this repository:

```
git clone https://github.com/stevekm/newfile-detector-nf.git
cd newfile-detector-nf
```

Setup a local `conda` installation to hold the Django library and Nextflow installation

```
make conda-install
```

- NOTE: configured for macOS and Linux

Initialize the Django database

```
make init
```

- Run this every time changes are made to the database structure under `db/models.py`

- the command `make reinit` can be used to erase the current database and start over from scratch

You should also generate a new `SECRET_KEY` for your `bin/settings.py`.

If you do not wish to use a new `conda` installation as described, you can simply run the commands described in the `Makefile` with your pre-existing environment that includes a Django and Nextflow installation.

# Usage

Run the app with

```
make run
```

Output should look like this:

```
$ make run
nextflow run main.nf
N E X T F L O W  ~  version 19.04.1
Launching `main.nf` [sleepy_mirzakhani] - revision: 06e1bbb365
[warm up] executor > local
[6a/c9dae4] Submitted process > build_check_file_list
[e1/b541fe] Submitted process > do_thing_with_file (file1.txt)
[f2/a016ef] Submitted process > do_thing_with_file (file5.txt)
[8c/e600ab] Submitted process > do_thing_with_file (file2.txt)
[4e/955e84] Submitted process > do_thing_with_file (file4.txt)
[1d/f6a8ab] Submitted process > do_thing_with_file (file6.txt)
[3e/c30905] Submitted process > do_thing_with_file (file3.txt)
[f4/761ac8] Submitted process > update_database (file3.txt)
[9e/b2f4ca] Submitted process > update_database (file1.txt)
[f1/51490a] Submitted process > update_database (file5.txt)
[a3/74be71] Submitted process > update_database (file2.txt)
[2b/897f60] Submitted process > update_database (file4.txt)
[43/0c76f8] Submitted process > update_database (file6.txt)
```

When run a second time, the previous files will be skipped:

```
$ make run
nextflow run main.nf
N E X T F L O W  ~  version 19.04.1
Launching `main.nf` [extravagant_linnaeus] - revision: 06e1bbb365
[warm up] executor > local
[1a/1c1077] Submitted process > build_check_file_list
```

Upon adding more files to the `files` directory, they will be processed:

```
$ touch files/file7.txt
$ make run
nextflow run main.nf
N E X T F L O W  ~  version 19.04.1
Launching `main.nf` [clever_tesla] - revision: 06e1bbb365
[warm up] executor > local
[ff/bc54e0] Submitted process > build_check_file_list
[7a/3c990f] Submitted process > do_thing_with_file (file7.txt)
[cc/1d684f] Submitted process > update_database (file7.txt)
```

You can check the contents of the database easily with a command like this:

```
$ sqlite3 bin/db.sqlite3 'SELECT * FROM db_file'
1|file3.txt|/Users/kellys04/projects/newfile-detector-nf/files/file3.txt|2019-07-09 16:40:18.758721|2019-07-09 16:40:18.758750
2|file6.txt|/Users/kellys04/projects/newfile-detector-nf/files/file6.txt|2019-07-09 16:40:18.879453|2019-07-09 16:40:18.879473
3|file5.txt|/Users/kellys04/projects/newfile-detector-nf/files/file5.txt|2019-07-09 16:40:18.880001|2019-07-09 16:40:18.880029
4|file1.txt|/Users/kellys04/projects/newfile-detector-nf/files/file1.txt|2019-07-09 16:40:18.885003|2019-07-09 16:40:18.885026
5|file2.txt|/Users/kellys04/projects/newfile-detector-nf/files/file2.txt|2019-07-09 16:40:18.885257|2019-07-09 16:40:18.885277
6|file4.txt|/Users/kellys04/projects/newfile-detector-nf/files/file4.txt|2019-07-09 16:40:19.827689|2019-07-09 16:40:19.827707
7|file7.txt|/Users/kellys04/projects/newfile-detector-nf/files/file7.txt|2019-07-09 16:41:44.010490|2019-07-09 16:41:44.010514
```

# Application Structure

- `main.nf` - Nextflow script
- `bin` - Nextflow directory for executables; contains the Django app instance
- `bin/settings.py` - The Django settings module. Contains the database configuration in it. Modify this file to match your database credentials.
- `bin/manage.py` - Script for running Django projects.
- `bin/db` - The database configuration directory, used by Django to manage the database, contains `models.py` which contains models that define the database schema and Python interface.

# Software

Developed on macOS 10.12 High Sierra, should be compatible with most Linux installations.

- Python 3 (installed with `conda`)

- Django 2.1.5 (installed with `conda`)

- Nextflow 19.04.1 (installed with `conda`)

- SQLite 3

- GNU `make` and `bash` for running the `Makefile` recipes for easier app initialization and running
