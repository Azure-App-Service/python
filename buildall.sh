#!/usr/bin/env bash
set -x -e

buildnumber=${4-$(date -u +"%y%m%d%H%M")}

docker build --no-cache -t "$1"/python:2.7_"$buildnumber" --file 2.7/Dockerfile 2.7
docker build --no-cache -t "$1"/python:3.6_"$buildnumber" --file 3.6.6/Dockerfile 3.6.6
docker build --no-cache -t "$1"/python:3.7_"$buildnumber" --file 3.7.0/Dockerfile 3.7.0