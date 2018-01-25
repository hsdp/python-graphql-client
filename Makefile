.DEFAULT_GOAL := help

PACKAGE := beaker
TEST_PATH := ./tests

# Python settings
PYTHON_MAJOR := 3
PYTHON_MINOR := 6
ENV := env/py$(PYTHON_MAJOR)$(PYTHON_MINOR)

# System paths
SYS_PYTHON := python$(PYTHON_MAJOR)
ifdef PYTHON_MINOR
SYS_PYTHON := $(SYS_PYTHON).$(PYTHON_MINOR)
endif
SYS_VIRTUALENV := virtualenv

#ENV := ./env

BIN := $(ENV)/bin

PYTHON := $(BIN)/python
PIP := $(BIN)/pip
COVERAGE := $(BIN)/coverage
FLAKE8 := $(BIN)/flake8
PYTEST := $(BIN)/pytest

DEPENDS_DEV := $(ENV)/.depends-dev
ENVVARS_DEV := $(ENV)/.envvars-dev

IN_VIRTUALENV = $(shell python -c 'import sys; print (1 if hasattr(sys, "real_prefix") else 0)')

OPEN := open

#COLORS
GREEN  := $(shell tput -Txterm setaf 2)
YELLOW := $(shell tput -Txterm setaf 3)
BLUE := $(shell tput -Txterm setaf 4)
PURPLE  := $(shell tput -Txterm setaf 5)
TEAL  := $(shell tput -Txterm setaf 6)
WHITE  := $(shell tput -Txterm setaf 7)
RESET  := $(shell tput -Txterm sgr0)

# Add the following 'help' target to your Makefile
# And add help text after each target name starting with '\#\#'
# A category can be added with @category
HELP_FUN = \
    %help; \
    while(<>) { push @{$$help{$$2 // 'Targets'}}, [$$1, $$3] if /^([a-zA-Z\-]+)\s*:.*\#\#(?:@([a-zA-Z\-]+))?\s(.*)$$/ }; \
    print "Usage:\n  make [target]\n\n"; \
    for (sort keys %help) { \
    print "${WHITE}$$_:${RESET}\n"; \
    for (@{$$help{$$_}}) { \
    $$sep = " " x (20 - length $$_->[0]); \
    print "  ${BLUE}$$_->[0]${RESET}$$sep${YELLOW}$$_->[1]${RESET}\n"; \
    }; \
    print "\n"; }

help: ##Show this help.
	@perl -e '$(HELP_FUN)' $(MAKEFILE_LIST)


.PHONY: env
env: $(PIP)

$(PIP): .intall_virtualenv
ifeq ($(IN_VIRTUALENV), 0)
	$(SYS_VIRTUALENV) --python $(SYS_PYTHON) $(ENV)
	$(PIP) install wheel
endif

.PHONY: depends
depends: ## Create virtual env and install requirements.
depends: .depends-dev

.PHONY: .depends-dev
.depends-dev: env Makefile $(DEPENDS_DEV)

$(DEPENDS_DEV): Makefile requirements.txt
	$(PIP) install $(PIP_CACHE) -r requirements.txt
	touch $(ENVVARS_DEV)
	touch $(DEPENDS_DEV)  # flag to indicate dependencies are installed

.intall_virtualenv:
ifeq ($(IN_VIRTUALENV), 0)
	pip install --no-cache-dir virtualenv
endif

.virtual_env: .intall_virtualenv
ifeq ($(IN_VIRTUALENV), 0)
	virtualenv $(ENV)
endif

.PHONY: test
test: .depends-dev ##@Tests Run unit tests
	$(PYTEST) $(TESTS_PATH)

.PHONY: test-cov-term
test-cov-term: .depends-dev # Runs tests with cov report
	$(PYTEST) --cov-report term --cov beaker --cov-config=.coveragerc  $(TEST_PATH)

.PHONY: test-cov-html
test-cov-html:.depends-dev # Runs tests with cov report
	$(PYTEST)  --cov-report html --cov beaker --cov-config=.coveragerc $(TEST_PATH)

.PHONY: cov
cov: test-cov-term ##@Coverage View test coverage in terminal.

.PHONY: cov-report
cov-report: test-cov-html ##@Coverage View test coverage in html.
	$(COVERAGE) html
	$(OPEN) htmlcov/index.html


.PHONY: lint
lint: flake8 ##@Analysis Run Code Analysis.

PEP8_IGNORED := E501

flake8: .depends-dev
	$(FLAKE8) $(PACKAGE) tests --ignore=$(PEP8_IGNORED) --output-file=flake8-lint.txt --tee

.PHONY: clean
clean: ##@Clean Clean All
clean: clean-pyc clean-build clean-test clean-lint

.PHONY: clean-pyc
clean-pyc: ##@Clean Clean Cache.
	find . -name '*.pyc' -exec rm --force {} +
	find . -name '*.pyo' -exec rm --force {} +
	name '*~' -exec rm --force  {}

.PHONY: clean-build
clean-build: ##@Clean Clean Build Folders.
	rm --force --recursive build/
	rm --force --recursive dist/
	rm --force --recursive *.egg-info

.PHONY: clean-test
clean-test: ##@Clean Clean Tests.
	rm -rf .coverage htmlcov xunit.xml coverage.xml

.PHONY: clean-lint
clean-lint: ##@Clean Clean Lint.
	find . -name 'flake8-lint.txt' -delete

