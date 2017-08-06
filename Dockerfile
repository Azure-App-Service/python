FROM python:2.7
MAINTAINER Prashanth Madi<prashanthrmadi@gmail.com>

ENV DEPLOYMENT_TARGET=/app
ENV NGINX_VERSION 1.12.0-1~jessie
# Setup webserver and process manager

RUN apt-key adv --keyserver hkp://pgp.mit.edu:80 --recv-keys 573BFD6B3D8FBC641079A6ABABF5BD827BD9BF62 \
	&& echo "deb http://nginx.org/packages/debian/ jessie nginx" >> /etc/apt/sources.list \
	&& apt-get update \
	&& apt-get install -y libpcre3-dev build-essential \
	&& apt-get install --no-install-recommends --no-install-suggests -y \
						ca-certificates \
						nginx=${NGINX_VERSION} \
						nginx-module-xslt \
						nginx-module-geoip \
						nginx-module-image-filter \
						nginx-module-perl \
						nginx-module-njs \
						gettext-base \
						supervisor \
	            		openssh-server \
	&& rm -rf /var/lib/apt/lists/* \
	&& echo "root:Docker!" | chpasswd

# forward request and error logs to docker log collector
RUN mkdir -p /home/LogFiles/docker \
	&& ln -sf /dev/stdout /home/LogFiles/docker/access.log \
	&& ln -sf /dev/stderr /home/LogFiles/docker/error.log

COPY nginx.conf /etc/nginx/nginx.conf
COPY supervisord.conf /etc/supervisor/conf.d/supervisord.conf	
COPY sshd_config /etc/ssh/
COPY init_container.sh /bin/

RUN chmod 755 /bin/init_container.sh
  
# Copy app
COPY ./app ${DEPLOYMENT_TARGET}
WORKDIR ${DEPLOYMENT_TARGET}

# Install app dependent modules
RUN pip install -r requirements.txt

EXPOSE 80 2222

CMD ["/bin/init_container.sh"]
