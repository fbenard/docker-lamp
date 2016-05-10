# Base image

FROM ubuntu:latest


# Maintainers

MAINTAINER Fabien BÉNARD "fabien@benard.co"


# Environment variables

ENV DOCKER_MYSQL_PASSWORD root


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
    apache2  \
    mysql-server \
    redis-server \
    php-pear \
    php5 libapache2-mod-php5 php5-cli php5-curl php5-dev php5-gd php5-imagick php5-intl php5-json php5-mcrypt php5-mysqlnd php5-redis \
    libssh2-1-dev libssh2-php

RUN pecl install zip
RUN pecl install xdebug


# Install ElasticSearch

RUN wget -qO - https://packages.elastic.co/GPG-KEY-elasticsearch | sudo apt-key add -

RUN echo "deb http://packages.elastic.co/elasticsearch/1.6/debian stable main" | sudo tee -a /etc/apt/sources.list

RUN sudo apt-get update && \
    DEBIAN_FRONTEND=noninteractive && \
    sudo apt-get install -yqq --no-install-recommends \
    openjdk-7-jdk \
    elasticsearch

RUN sudo /usr/share/elasticsearch/bin/plugin -install mobz/elasticsearch-head


# Install RabbitMQ

RUN echo "deb http://www.rabbitmq.com/debian/ testing main" >> /etc/apt/sources.list

RUN wget https://www.rabbitmq.com/rabbitmq-signing-key-public.asc && \
    sudo apt-key add rabbitmq-signing-key-public.asc

RUN sudo apt-get update && \
    DEBIAN_FRONTEND=noninteractive && \
    sudo apt-get install -yqq \
    rabbitmq-server

RUN rabbitmq-plugins enable rabbitmq_management


# Install Composer

RUN curl -sS https://getcomposer.org/installer | php
RUN sudo mv composer.phar /usr/local/bin/composer


# Install Node.js and NPM

RUN curl --silent --location https://deb.nodesource.com/setup_0.12 | sudo bash -

RUN apt-get update && \
    DEBIAN_FRONTEND=noninteractive && \
    apt-get install -yqq \
    nodejs


# Add files to image

ADD config/apache/app.conf /etc/apache2/sites-available/app.conf
ADD config/es/elasticsearch.yml /etc/elasticsearch/elasticsearch.yml
ADD config/es/logging.yml /etc/elasticsearch/logging.yml
ADD config/supervisor/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

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

RUN sudo a2ensite app.conf


# Setup PHP

RUN echo "zend_extension=xdebug.so" >> /etc/php5/cli/php.ini
RUN echo "xdebug.max_nesting_level = 200" >> /etc/php5/cli/php.ini


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
