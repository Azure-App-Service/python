#!/usr/bin/env bash
set -x -e

buildnumber=${4-$(date -u +"%y%m%d%H%M")}

docker build --no-cache -t "$1"/python:3.7.0_"$buildnumber" .
docker tag "$1"/python:3.7.0_"$buildnumber" "$1"/python:latest

#docker login -u "$2" -p "$3"

#docker push "$1"/python:3.7.0_"$buildnumber"
#docker push "$1"/python:latest

#docker logout
