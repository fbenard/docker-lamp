docker-web
===========

This Docker image allows to quickly run a web application. It is shipped with Apache, MySQL, ElastciSearch and Redis.

![Build status](https://circleci.com/gh/fbenard/docker-web/tree/master.svg?style=shield&circle-token=1e6b07920fa6676dafe860d85dbd9674b02ff456)
[![SensioLabsInsight](https://insight.sensiolabs.com/projects/06c8e0eb-e37d-4c9c-9397-3fc9f6c909b4/mini.png)](https://insight.sensiolabs.com/projects/06c8e0eb-e37d-4c9c-9397-3fc9f6c909b4)


## Install

You must have Docker installed on your machine prior to using this image.

To install the binary `docker-web`, run:

```
curl -sS https://raw.githubusercontent.com/fbenard/docker-web/master/scripts/install.sh | sudo bash
```


## Getting started

Run your web application inside the docker-web image:

```
cd myapp
docker-web
```

Edit your hosts so that local.app.dev is forwarded to the IP address of the Docker container.

```
x.x.x.x    local.app.dev
```

Then open you browser and visit:

http://local.app.dev


## Services

docker-web is shipped with the following services:

- Apache on port 80 (`http`) and 443 (`https`)
- MySQL on port 3306 (`mysql`)
- ElasticSearch on port 9200 (`es`)
- Redis on port 6379 (`redis`)


**MySQL**

- Login: `root`
- Password: `root`

**ElasticSearch**

- http://local.app.dev:9200/_plugin/head/


# Bind services

By default no service is bound. However, the `-b` option allows you to easily decide to bind specific services as well as map them to custom ports. For instance,

- To bind only HTTP on port 8080:

```
docker-web -b "http:8080"
```

- To bind ElasticSearch and MySQL on default ports:

```
docker-web -b "es|mysql"
```

- To bind Redis on default port and MySQL on port 3000:

```
docker-web -b "redis|mysql:3000"
```
