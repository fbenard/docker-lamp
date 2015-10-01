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

Edit your hosts so that `local.app.dev` is forwarded to the IP address of the Docker container.

```
x.x.x.x    local.app.dev
```

If you're running Docker on Linux, run `ifconfig eth0` to know your IP address. If you're running Windows or OS X, run `ifconfig vboxnet0`.


## Getting started

Run your web application inside the docker-web image:

```
cd myapp
docker run --rm -it --tty --entrypoint="bash" -p 80:80 -v `pwd`:/var/www/app fbenard/docker-web
```

Then open you browser and visit:

http://local.app.dev


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

- http://local.app.dev:9200/_plugin/head/
