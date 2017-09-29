#!/bin/bash
# coding: utf-8
# Copyright (c) 2017
# Gmail:liuzheng712
#

set -ex

source ./app.rc 

if [ ! -f ${NGINX_DIST} ]; then
  curl -LO ${NGINX_DOWNLOAD_LINK}
fi

tar xzf ${NGINX_DIST}
cd ${NGINX_FOLDER}

