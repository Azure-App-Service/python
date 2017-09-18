#
# Dockerfile for Python
#
FROM ubuntu:16.04
MAINTAINER Azure App Service Container Images <appsvc-images@microsoft.com>


# ========
# ENV vars
# ========

#python
ENV PYTHON_VERSION "3.6.1"
ENV PYTHON_TAR_URL "https://www.python.org/ftp/python/$PYTHON_VERSION/Python-$PYTHON_VERSION.tar.xz"
ENV PYTHON_TAR_MD5 "692b4fc3a2ba0d54d1495d4ead5b0b5c"
ENV REQUESTS_TAR_URL "https://github.com/requests/requests/tarball/master"
# uwsgi
ENV UWSGI_DIR "/etc/uwsgi"

#Web Site Home
ENV HOME_SITE "/home/site/wwwroot"

# ssh
ENV SSH_PASSWD "root:Docker!"
#
ENV DOCKER_BUILD_HOME "/dockerbuild"


# =======
# Install
# =======

WORKDIR $DOCKER_BUILD_HOME

RUN set -ex \
	# tools
	&& tools=' \
		gcc \
		make \
		wget \
	' \
	&& apt-get update \
        && apt-get install -y -V --no-install-recommends $tools \
        && rm -r /var/lib/apt/lists/* \
	
	# build time libs
	&& buildTimeDeps=' \
		dpkg-dev \
		libbz2-dev \
		libc6-dev \
		libexpat1-dev \
		libffi-dev \
		libgdbm-dev \
		liblzma-dev \
		libncurses-dev \
		libreadline-dev \
		libsqlite3-dev \
		libssl-dev \
		tcl-dev \
		tk-dev \
		xz-utils \
		zlib1g-dev \
	' \
	&& apt-get update \
	&& apt-get install -y -V --no-install-recommends $buildTimeDeps \
	&& rm -r /var/lib/apt/lists/*

RUN set -ex \
	#python
	&& cd $DOCKER_BUILD_HOME \
	&& wget -O python.tar.xz "$PYTHON_TAR_URL" --no-check-certificate \
	&& echo "$PYTHON_TAR_MD5 *python.tar.xz" | md5sum -c - \
	&& mkdir -p /usr/src/python \
	&& tar -xf python.tar.xz -C /usr/src/python --strip-components=1 \
	&& cd /usr/src/python \
	&& gnuArch="$(dpkg-architecture --query DEB_BUILD_GNU_TYPE)" \
	&& ./configure \
		--build="$gnuArch" \
		--enable-loadable-sqlite-extensions \
		--enable-shared \
		--with-system-expat \
		--with-system-ffi \
		--without-ensurepip \
	&& make -j "$(nproc)" \
	&& make install \
	&& ldconfig \
	
	# pip
	&& wget https://bootstrap.pypa.io/get-pip.py --no-check-certificate \
        && python3 get-pip.py \

	# Microsoft Azure Client Libraries for Python
	&& pip install azure \

    # Requests
	&& cd $DOCKER_BUILD_HOME \
    && wget -O requests.tar.gz "$REQUESTS_TAR_URL" --no-check-certificate \
    && mkdir -p /usr/src/requests \
    && tar -xf requests.tar.gz -C /usr/src/requests --strip-components=1 \
    && cd /usr/src/requests \
    && python3 setup.py install \
        
    # Flask
	&& pip install Flask \
	
	# nginx
	&& apt-get update \
	&& apt-get install -y -V --no-install-recommends nginx \
	&& rm -r /var/lib/apt/lists/* \

	# uwsgi
	&& pip install http://projects.unbit.it/downloads/uwsgi-lts.tar.gz \
	# psycopg2
	&& pip install psycopg2 \
	
    # Django
    && pip install Django \
 
	# ssh
	&& apt-get update \
	&& apt-get install -y --no-install-recommends openssh-server \
	&& echo "$SSH_PASSWD" | chpasswd \

	# clean up
	&& apt-get purge -y -V -o APT::AutoRemove::RecommendsImportant=false --auto-remove $tools $buildTimeDeps \
	&& apt-get autoremove -y


# =========
# Configure
# =========

# nginx
COPY nginx-default-site /etc/nginx/sites-available/default
# uwsgi
COPY uwsgi.ini /tmp/
COPY uwsgi_django.ini /tmp
COPY index.py /tmp/
# ssh
COPY sshd_config /etc/ssh/

RUN set -ex \
	&& ln -s /usr/local/bin/python3.6 /usr/bin/python3 \
	&& ln -s /usr/bin/python3 /usr/bin/python \
	##
	&& rm -rf $DOCKER_BUILD_HOME/* \
        && rm -rf /usr/src/request/* \
	##
	&& test ! -d $UWSGI_DIR && mkdir -p $UWSGI_DIR

COPY entrypoint.sh /usr/local/bin
RUN chmod u+x /usr/local/bin/entrypoint.sh
EXPOSE 2222 8080
ENTRYPOINT ["entrypoint.sh"]
