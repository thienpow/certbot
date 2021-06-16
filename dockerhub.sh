#!/bin/sh


docker login
docker build --rm -t thienpow/certbot .
docker push thienpow/certbot