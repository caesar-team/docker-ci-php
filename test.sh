#!/bin/sh
NAME_CONTAINER=ci-test-php
docker stop $NAME_CONTAINER || true && docker rm $NAME_CONTAINER || true
docker run -d --name $NAME_CONTAINER -p 8080:8080 caesarteam/ci-test-php:7.4