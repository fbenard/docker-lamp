# Base image

FROM ubuntu:14.04


# Maintainers

MAINTAINER Fabien BÉNARD "fb.spam@me.com"


# Install core packages

RUN sudo apt-get update && \
    DEBIAN_FRONTEND=noninteractive && \
    sudo apt-get install -yqq \
    apt-utils \
    dialog \
    debconf-utils


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
    php5 libapache2-mod-php5 php5-cli php5-curl php5-gd php5-imagick php5-intl php5-json php5-mcrypt php5-mysqlnd php5-redis \
    phpunit

RUN pecl install "channel://pecl.php.net/zip-1.5.0"


# Install Composer

RUN curl -sS https://getcomposer.org/installer | php
RUN sudo mv composer.phar /usr/local/bin/composer


# Add files to image

ADD app.conf /etc/apache2/sites-available/app.conf
ADD app.sh /usr/local/bin/app.sh

RUN chmod +x /usr/local/bin/app.sh
RUN mkdir -p /var/www/app
RUN ln -s /var/www/app /app


# Apache

RUN sudo a2enmod deflate
RUN sudo a2enmod expires
RUN sudo a2enmod headers
RUN sudo a2enmod rewrite
RUN sudo a2enmod ssl
RUN sudo a2enmod status

RUN sudo a2ensite app.conf


# Expose volumes

VOLUME /var/www/app


# Expose ports

EXPOSE 80
EXPOSE 3306
EXPOSE 6379


# Define working directory

WORKDIR /var/www/app


# Define entrypoint

ENTRYPOINT ["bash"]
