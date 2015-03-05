docker-web
===========

This Docker image allows to quickly run a web application.

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

Once inside the container, start services:

```
app.sh
```

Edit your hosts so that app.local is forwarded to the IP address of the Docker container.

```
x.x.x.x    app.local
```

Then open you browser and visit:

http://app.local


# Bind services

By default all services are bound to the Docker container on default ports:

- HTTP on port 80
- MySQL on port 3306
- Redis on port 6379

However if you need to either remove binding of a service or to map it to a different port, you can do so with the `-b` option. For instance,

- To bind only HTTP on port 8080:

```
docker-web -b "http:8080"
```

- To bind Apache and MySQL on default ports:

```
docker-web -b "http|mysql"
```

- To bind Apache on default port and MySQL on port 3000:

```
docker-web -b "http|mysql:3000"
```


## Services

**MySQL**

- Login: `root`
- Password: `root`
