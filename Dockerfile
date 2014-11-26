# Base image

FROM ubuntu:14.04


# Maintainers

MAINTAINER Fabien BÉNARD "fb.spam@me.com"


# Install packages

RUN sudo apt-get update && \
    sudo apt-get install -y \
    ntp \
    wget \
    curl \
    git \
    nano \
    apache2  \
    mysql-server \
    redis-server \
    php5 libapache2-mod-php5 php5-cli php5-curl php5-gd php5-imagick php5-intl php5-json php5-mcrypt php5-mysqlnd php5-redis \
    phpunit


# Setup 

RUN echo "Europe/Paris" | sudo tee /etc/timezone
RUN sudo dpkg-reconfigure --frontend noninteractive tzdata
RUN sudo service ntp stop
RUN sudo ntpdate -s time.nist.gov
RUN sudo service ntp start


# Expose ports

EXPOSE 80
EXPOSE 3306
EXPOSE 6379


# Install Composer

RUN curl -sS https://getcomposer.org/installer | php
RUN sudo mv composer.phar /usr/local/bin/composer


# Add files to image

ADD Apache.conf /etc/apache2/sites-available/Apache.conf
ADD services.sh /usr/local/bin/services.sh

RUN chmod +x /usr/local/bin/services.sh


# Apache

RUN sudo a2enmod deflate
RUN sudo a2enmod expires
RUN sudo a2enmod headers
RUN sudo a2enmod rewrite
RUN sudo a2enmod ssl
RUN sudo a2enmod status

RUN sudo a2ensite Apache.conf


# Install components

RUN cd /var/www/goloboard ; composer install --prefer-dist --no-interaction --no-dev


# Define working directory

WORKDIR /var/www/goloboard/


# Define entrypoint

ENTRYPOINT ["bash"]
