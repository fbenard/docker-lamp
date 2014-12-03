docker-lamp
===========

This Docker image allows to quickly run a web application based on a full LAMP stack (Linux, Apache, MySQL, PHP).

![Build status](https://circleci.com/gh/fbenard/docker-lamp.svg?style=shield&circle-token=1e6b07920fa6676dafe860d85dbd9674b02ff456)


## Install

You must have Docker installed on your machine prior to using this image.


## Getting started

Simply pull this image from the Docker hub and run it:

```
docker pull fbenard/docker-lamp
docker run --rm -it -p 80:80 fbenard/docker-lamp
app.sh
```

Edit your hosts so that local.app.com goes to the IP address of the Docker container.

Then open you browser and reach out to http://local.app.com/


## Build the image

Note that you can clone this repository and build the image yourself:

```
git clone https://github.com/fbenard/docker-lamp
cd docker-lamp
docker build -t fbenard/docker-lamp .
```


## Build your own image

It is highly recommended to extend this image by writing your own Dockerfile. This will for instance allow you to customize Apache virtual hosts. First, write a Dockerfile:

```
# Base image

FROM fbenard/docker-lamp


# Maintainers

MAINTAINER Me "me@me.com"


# Add files to image

ADD Docker/custom-app.conf /etc/apache2/sites-available/app.conf
ADD vhost-1 /var/www/app/vhost-1
ADD vhost-2 /var/www/app/vhost-2
ADD vhost-3 /var/www/app/vhost-3
```

Then, build your custom image and run it as you would run the base image:

```
cd custom-app
docker build -t me/custom-app .
docker run --rm -it  -p 80:80 me/custom-app
app.sh
```


## For developers

If you're a developer, you might want to work on your own local code and reach MySQL:

```
docker run --rm -it -p 80:80 -p 3306:3306 -v <PATH_TO_LOCAL_APP>:/var/www/app fbenard/docker-lamp
```
