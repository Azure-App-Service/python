# Docker Image for Python
## Overview
This Python Docker image is built for [Azure Web App on Linux](https://docs.microsoft.com/en-us/azure/app-service-web/app-service-linux-intro).

## Components
This Docker image contains the following components:

1. Python **3.6.1**
2. Nginx **1.10.0**
3. uWSGI **2.0.15**
4. Psycopg2 **2.7.1**
5. Pip **9.0.1**
6. SSH

Ubuntu 16.04 is used as the base image.

The stack of components:
```
Browser <-> nginx <-> /tmp/uwsgi.sock <-> uWSGI <-> Your Python app <-> Psycopg2 <-> remote PostgreSQL database
```

## Features
This docker image enables you to:
- run your Python app on **Azure Web App on Linux**;
- connect you Python app to a remote PostgreSQL database;
- ssh to the docker container via the URL like below;
```
        https://<your-site-name>.scm.azurewebsites.net/webssh/host
```

## Predefined Nginx Locations
This docker image defines the following nginx locations for your static files.
- /images
- /css
- /js
- /static

For more information, see [nginx default site conf](./3.6.1/nginx-default-site).

## uWSGI INI
This docker image contains a default uWSGI ini file which is placed under /home/uwsgi and invoked like below:
```
uwsgi --uid www-data --gid www-data --ini=$UWSGI_INI_DIR/uwsgi.ini
```

You can customeize this ini file, and upload to /home/uwsgi to overwrite.

## Startup Log
The startup log file (**entrypoint.log**) is placed under the folder /home/LogFiles.

## How to Deploy Django Project
1. login the instance via the url like below:
```
        https://<your-site-name>.scm.azurewebsites.net/webssh/host
```
2. install Django
```
        pip install Django==1.11.3
```
3. upload your Django project, for example to the location /home/site/wwwroot
4. update /home/uwsgi/uwsgi.ini per the requirements of your project
5. run the command below
```
        uwsgi --uid www-data --gid www-data –ini=/home/uwsgi/uwsgi.ini
```
