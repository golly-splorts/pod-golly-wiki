SHELL=/bin/bash

ifeq ($(shell echo ${POD_GOLLY_WIKI_DIR}),)
$(error Environment variable POD_GOLLY_WIKI_DIR not defined. Please run "source environment" in the repo root directory before running make commands)
endif

ifeq ($(shell test -d ${POD_GOLLY_WIKI_DIR} || echo "nope"), nope)
$(error Environment variable POD_GOLLY_WIKI_DIR points to a non-existent directory)
endif

ifeq ($(shell which python3),)
$(error Please install python3)
endif

#ifeq ($(shell which aws),)
#$(error Please install aws-cli)
#endif
