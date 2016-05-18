# Base image

FROM ubuntu:xenial


# Maintainers

MAINTAINER Fabien BÉNARD "fabien@benard.co"


# Environment variables

ENV DOCKER_MYSQL_PASSWORD root


# Add config files

ADD config/apache/vhost.conf /etc/apache2/sites-available/vhost.conf
ADD config/supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf


# Install core packages

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive && \
    apt-get install -yqq \
    apt-utils \
    dialog \
    debconf-utils \
    supervisor \
    software-properties-common python-software-properties


# Setup culture

RUN locale-gen en_US.UTF-8 && \
    dpkg-reconfigure --frontend noninteractive locales && \
    echo "LANG=en_US.UTF-8" > /etc/default/locale

RUN echo "Europe/Paris" | tee /etc/timezone && \
    dpkg-reconfigure --frontend noninteractive tzdata


# Install packages

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive \
    apt-get install -yqq \
    wget curl \
    nano \
    git \
    zziplib-bin \
    apache2 \
    elasticsearch \
    mysql-server \
    rabbitmq-server \
    redis-server \
    php-pear \
    php5 libapache2-mod-php5 php5-cli php5-curl php5-dev php5-gd php5-imagick php5-intl php5-json php5-mcrypt php5-mysqlnd php5-redis \
    libssh2-1-dev libssh2-php
    composer \

RUN pecl install zip
RUN pecl install xdebug







RUN rabbitmq-plugins enable rabbitmq_management


# Install Node.js and NPM

RUN curl --silent --location https://deb.nodesource.com/setup_0.12 | sudo bash -

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive && \
    apt-get install -yqq \
    nodejs



RUN rm -drf /var/www/html


# Setup hosts

RUN echo "127.0.0.1    docker.local" >> /etc/hosts


# Setup Supervisor

RUN mkdir -p /var/lock/apache2 /var/run/apache2 /var/log/supervisor


# Setup Apache

RUN a2enmod deflate
RUN a2enmod expires
RUN a2enmod headers
RUN a2enmod rewrite
RUN a2enmod ssl
RUN a2enmod status



# Setup PHP

RUN echo "zend_extension=xdebug.so" >> /etc/php5/cli/php.ini
RUN echo "xdebug.max_nesting_level = 200" >> /etc/php5/cli/php.ini
RUN a2ensite vhost.conf


# Setup MySQL

RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf
RUN service mysql start && \
    mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${DOCKER_MYSQL_PASSWORD}' WITH GRANT OPTION; FLUSH PRIVILEGES;" && \
    mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY '${DOCKER_MYSQL_PASSWORD}' WITH GRANT OPTION; FLUSH PRIVILEGES;" && \
    mysql -u root -p${DOCKER_MYSQL_PASSWORD} -e "CREATE DATABASE app CHARACTER SET utf8 COLLATE utf8_general_ci;" && \
    mysql -u root -p${DOCKER_MYSQL_PASSWORD} -e "GRANT ALL PRIVILEGES ON app.* TO 'app'@'%' IDENTIFIED BY 'app' WITH GRANT OPTION; FLUSH PRIVILEGES;" && \
    mysql -u root -p${DOCKER_MYSQL_PASSWORD} -e "GRANT ALL PRIVILEGES ON app.* TO 'app'@'%' IDENTIFIED BY 'app' WITH GRANT OPTION; FLUSH PRIVILEGES;"


# Setup Bash

RUN echo "service supervisor start" >> ~/.bashrc


# Expose volumes

VOLUME /var/www/html


# Expose ports

EXPOSE 80
EXPOSE 3306
EXPOSE 5672
EXPOSE 6379
EXPOSE 9200
EXPOSE 15672


# Define working directory

WORKDIR /var/www/html


# Run Supervisor daemon

ENTRYPOINT ["/usr/bin/supervisord"]
CMD ["-n"]
