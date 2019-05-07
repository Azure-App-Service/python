# Docker Image for Python
## Overview
This Python Docker image is built for [Azure Web App on Linux](https://docs.microsoft.com/en-us/azure/app-service-web/app-service-linux-intro).

## Components
This Docker image contains the following components:

1. Python **3.6.1**
2. Requests
3. Nginx **1.10.0**
4. uWSGI **2.0.15**
5. Psycopg2 **2.7.1**
6. Pip **9.0.1**
7. SSH
8. Azure SDK
9. Flask 
10. Django  **1.11.5**

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
This docker image contains a default uWSGI ini file which is placed under /etc/uwsgi and invoked like below:
```
uwsgi --uid www-data --gid www-data --ini=$UWSGI_INI_DIR/uwsgi.ini
```

You can customeize this ini file, and upload to /etc/uwsgi to overwrite.

This docker image also contains a uWSGI ini file for Django, which names uwsgi_django.ini. You can customeize it and uplad to /etc/uwsgi to overwrite uwsgi.ini.

## Startup Log
The startup log file (**entrypoint.log**) is placed under the folder /home/LogFiles.

## How to Deploy Django Project 
1. login the instance via the url like below:
```
        https://<your-site-name>.scm.azurewebsites.net/webssh/host
```
2. CD your location (For example /home/site/wwwroot), Run the command below to start a new project  (For example project name is hello), Then cd project location, update settings.py as need.
```
        python /usr/local/bin/django-admin.py startproject hello
```   
3. If your django project is exist, you can just upload it, for example to the location /home/site/wwwroot.
4. update /etc/uwsgi/uwsgi.ini per the requirements of your project. You can find a sample 
/tmp/uwsgi_django.ini. Reference: [How to use Django with uWSGI](https://docs.djangoproject.com/en/1.11/howto/deployment/wsgi/uwsgi/)
5. Run the command below to start uWSGI service
```
        uwsgi --uid www-data --gid www-data –ini=/etc/uwsgi/uwsgi.ini
```
