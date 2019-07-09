SHELL:=/bin/bash
UNAME:=$(shell uname)

# install app
install: conda-install

# ~~~~~ Setup Conda ~~~~~ #
# this sets the system PATH to ensure we are using in included 'conda' installation for all software
PATH:=$(CURDIR)/conda/bin:$(PATH)
unexport PYTHONPATH
unexport PYTHONHOME

# install versions of conda for Mac or Linux
ifeq ($(UNAME), Darwin)
CONDASH:=Miniconda3-4.5.4-MacOSX-x86_64.sh
endif

ifeq ($(UNAME), Linux)
CONDASH:=Miniconda3-4.5.4-Linux-x86_64.sh
endif

CONDAURL:=https://repo.continuum.io/miniconda/$(CONDASH)

# install conda
conda:
	@echo ">>> Setting up conda..."
	@wget "$(CONDAURL)" && \
	bash "$(CONDASH)" -b -p conda && \
	rm -f "$(CONDASH)"

# install the conda and python packages required
# NOTE: **MUST** install ncurses from conda-forge for RabbitMQ to work!!
conda-install: conda
	conda install -y -c bioconda \
	django=2.1.5 \
	nextflow=19.04.1


# ~~~~~ Setup Django App ~~~~~ #
DB_FILE:=bin/db.sqlite3
DB_APP:=bin/db
DB_APP_DIR:=$(shell python -c 'import os; print(os.path.realpath("$(DB_APP)"))')

# initialize the database
init:
	python bin/manage.py makemigrations
	python bin/manage.py migrate


#  ~~~~~ Run the app ~~~~~ #
export NXF_ANSI_LOG=false
run:
	nextflow run main.nf

# start interactive shell with Djano initialized
shell:
	python bin/manage.py shell

# run arbitrary user-passed command
CMD:=
cmd:
	$(CMD)


# ~~~~~ Reset the App ~~~~~ #
# re-initialize the databases
reinit: nuke init

# destroy app database
nuke:
	echo $(DB_APP_DIR)
	@echo ">>> Removing database items:"; \
	rm -rfv $(DB_APP_DIR)/migrations/__pycache__ && \
	rm -fv $(DB_APP_DIR)/migrations/0*.py && \
	rm -fv $(DB_FILE)
