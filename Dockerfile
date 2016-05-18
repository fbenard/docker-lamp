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
    apache2 \
    elasticsearch \
    mongodb \
    mysql-server \
    rabbitmq-server \
    redis-server \
    php7.0 php7.0-bz2 php7.0-cli php7.0-curl php7.0-dev php7.0-gd php7.0-intl php7.0-json php7.0-mcrypt php7.0-mysql php7.0-sqlite3 php7.0-xml php7.0-xsl php7.0-zip \
    php-imagick php-redis php-ssh2 \
    composer \
    libapache2-mod-php7.0 \
    nodejs npm


# Install ElasticSearch plugins

#RUN bash -x /usr/share/elasticsearch/bin/plugin install mobz/elasticsearch-head


# Install RabbitMQ plugins

RUN rabbitmq-plugins enable rabbitmq_management


# Create nodejs symblic link
# See https://github.com/nodejs/node-v0.x-archive/issues/3911

ln -s /usr/bin/nodejs /usr/bin/node


# Remove content of Apache host

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
