# Base image

FROM ubuntu:14.04


# Maintainers

MAINTAINER Fabien BÉNARD "contact@fabienbenard.com"


# Environment variables

ENV DOCKER_MYSQL_PASSWORD root


# Install core packages

RUN sudo apt-get update && \
    DEBIAN_FRONTEND=noninteractive && \
    sudo apt-get install -yqq \
    apt-utils \
    dialog \
    debconf-utils \
    supervisor \
    software-properties-common python-software-properties


# Setup localization

RUN echo "locales locales/locales_to_be_generated multiselect en_US.UTF-8 UTF-8" | debconf-set-selections
RUN echo "locales locales/default_environment_locale  select  en_US.UTF-8" | debconf-set-selections
RUN DEBIAN_FRONTEND=noninteractive && \
    sudo apt-get install -yqq \
    locales && \
    sudo locale-gen en_US.UTF-8 && \
    sudo dpkg-reconfigure -f noninteractive locales

ENV LC_ALL en_US.UTF-8

RUN echo "Europe/Paris" | sudo tee /etc/timezone && \
    sudo dpkg-reconfigure --frontend noninteractive tzdata


# Install packages

RUN DEBIAN_FRONTEND=noninteractive \
    sudo apt-get install -yqq \
    wget curl \
    nano \
    git \
    zziplib-bin \
    apache2  \
    mysql-server \
    redis-server \
    php-pear \
    php5 libapache2-mod-php5 php5-cli php5-curl php5-gd php5-imagick php5-intl php5-json php5-mcrypt php5-mysqlnd php5-redis \
    phpunit

RUN pecl install zip


# Install ElasticSearch

RUN wget -qO - https://packages.elasticsearch.org/GPG-KEY-elasticsearch | sudo apt-key add -

RUN sudo add-apt-repository "deb http://packages.elasticsearch.org/elasticsearch/1.4/debian stable main"

RUN sudo apt-get update && \
    DEBIAN_FRONTEND=noninteractive && \
    sudo apt-get install -yqq \
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


# Add files to image

ADD config/app.conf /etc/apache2/sites-available/app.conf
ADD config/supervisord.conf /etc/supervisor/conf.d/supervisord.conf

RUN mkdir -p /var/www/app

ADD scripts/app.sh /usr/local/bin/app.sh
RUN chmod +x /usr/local/bin/app.sh


# Setup hosts

RUN echo "127.0.0.1    app.local" >> /etc/hosts


# Setup Supervisor

RUN mkdir -p /var/lock/apache2 /var/run/apache2 /var/log/supervisor


# Setup Apache

RUN sudo a2enmod deflate
RUN sudo a2enmod expires
RUN sudo a2enmod headers
RUN sudo a2enmod rewrite
RUN sudo a2enmod ssl
RUN sudo a2enmod status

RUN sudo a2ensite app.conf


# Setup MySQL

RUN sed -i -e"s/^bind-address\s*=\s*127.0.0.1/bind-address = 0.0.0.0/" /etc/mysql/my.cnf
RUN service mysql start && \
    mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'%' IDENTIFIED BY '${DOCKER_MYSQL_PASSWORD}' WITH GRANT OPTION; FLUSH PRIVILEGES;" && \
    mysql -u root -e "GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' IDENTIFIED BY '${DOCKER_MYSQL_PASSWORD}' WITH GRANT OPTION; FLUSH PRIVILEGES;" && \
    mysql -u root -p${DOCKER_MYSQL_PASSWORD} -e "CREATE DATABASE app CHARACTER SET utf8 COLLATE utf8_general_ci;" && \
    mysql -u root -p${DOCKER_MYSQL_PASSWORD} -e "GRANT ALL PRIVILEGES ON app.* TO 'app'@'%' IDENTIFIED BY 'app' WITH GRANT OPTION; FLUSH PRIVILEGES;" && \
    mysql -u root -p${DOCKER_MYSQL_PASSWORD} -e "GRANT ALL PRIVILEGES ON app.* TO 'app'@'%' IDENTIFIED BY 'app' WITH GRANT OPTION; FLUSH PRIVILEGES;"


# Expose volumes

VOLUME /var/www/app


# Expose ports

EXPOSE 80
EXPOSE 3306
EXPOSE 5672
EXPOSE 6379
EXPOSE 9200
EXPOSE 15672


# Define working directory

WORKDIR /var/www/app


# Run Supervisor daemon

ENTRYPOINT ["/usr/bin/supervisord"]
CMD ["-n"]
