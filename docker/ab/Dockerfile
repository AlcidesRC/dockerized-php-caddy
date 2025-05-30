# syntax=docker/dockerfile:1

#----------------------------------------------------------
# STAGE: BASE-IMAGE
#----------------------------------------------------------

FROM alpine:3.21.3 AS base-image

#----------------------------------------------------------
# STAGE: COMMON
#----------------------------------------------------------

FROM base-image AS common

RUN apk update && apk add --no-cache \
        apache2-utils \
        font-noto \
        fontconfig \
        gnuplot \
        terminus-font \
        ttf-freefont \
    && fc-cache -f \
    && fc-list | sort

WORKDIR /endpoints

#----------------------------------------------------------
# STAGE: BUILD
#----------------------------------------------------------

FROM common AS build

ARG HOST_USER_ID=1000
ARG HOST_USER_NAME=host-username
ARG HOST_GROUP_ID=1000
ARG HOST_GROUP_NAME=host-groupname

RUN addgroup --gid ${HOST_GROUP_ID} ${HOST_GROUP_NAME} \
    && adduser --shell /bin/sh --uid ${HOST_USER_ID} --ingroup ${HOST_GROUP_NAME} --no-create-home --disabled-password --gecos '' ${HOST_USER_NAME} $HOST_USER_NAME
