docker-web
==========

Quickly run and develop web applications.

![Build status](https://circleci.com/gh/fbenard/docker-web/tree/master.svg?style=shield&circle-token=1e6b07920fa6676dafe860d85dbd9674b02ff456)


## Install

You must have [Docker](https://docker.com) installed on your machine prior to using this image.

To pull the image:

```
docker pull fbenard/docker-web
```

## Getting started

Run your web application inside the docker-web image:

```
cd myapp
docker run --rm -it --tty --entrypoint="bash" -p 80:80 -v `pwd`:/var/www/html fbenard/docker-web
```

Then open you browser and visit:

http://localhost


## Services

The image is shipped with the following services:

- HTTP on port 80
- HTTPS on port 443
- MySQL on port 3306
- ElasticSearch on port 9200
- Redis on port 6379


**MySQL**

- Login: `root`
- Password: `root`

**ElasticSearch**

- http://localhost:9200/_plugin/head/
