docker-lamp
===========


## About

This Docker image allows web developers 

## Install

You must have Docker installed on your machine prior to using this image.


## Getting started

Simply pull this image from the Docker hub and run it:

```
docker pull fbenard/docker-lamp
docker run --rm -it -p 80:80 fbenard/docker-lamp
app.sh
```

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

```
docker run --rm -it -p 80:80 -p 3306:3306 -p 6379:6379 -v <PATH_TO_LOCAL_APP>:/var/www/app fbenard/docker-lamp
```
