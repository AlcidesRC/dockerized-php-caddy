[![Continuous Integration](https://github.com/AlcidesRC/dockerized-php-caddy/actions/workflows/ci.yml/badge.svg)](https://github.com/AlcidesRC/dockerized-php-caddy/actions/workflows/ci.yml)

# Dockerized PHP - Caddy


> A _dockerized_ environment based on Caddy + PHP-FPM running on a Linux Alpine container. 


[TOC]

------



## Summary

This repository contains a _dockerized_ environment for building PHP applications based on **php:8.3.12-fpm-alpine** with Caddy support.

### Highlights

- Unified environment to build <abbr title="Command Line Interface">CLI</abbr>, <u>web applications</u> and/or <u>micro-services</u> based on **PHP8**.
- Multi-stage Dockerfile to allows you to create an optimized **development** or **production-ready** Docker images
- Uses **Caddy webserver**.
- PHP-FPM is **managed by Caddy**.
- **Everything in one single Docker service**.



------



## Requirements

To use this repository you need:

- [Docker](https://www.docker.com/) - An open source containerization platform.
- [Git](https://git-scm.com/) - The free and open source distributed version control system.
- [Make](https://www.gnu.org/software/make/) - A command to automate the build/manage process.
- [jq](https://jqlang.github.io/jq/download/) - A lightweight and flexible command-line JSON processor.


------



## Built with

| Type           | Component                                                | Description                                                  |
| -------------- | -------------------------------------------------------- | ------------------------------------------------------------ |
| Infrastructure | [Docker](https://www.docker.com/)                        | Containerization platform                                    |
| Service        | [Caddy Server](https://caddyserver.com/)                     | Open source web server with automatic HTTPS written in Go    |
| Service        | [Caddy Supervisor](https://github.com/baldinof/caddy-supervisor) | A module to run and supervise background processes from Caddy |
| Service        | [PHP-FPM](https://www.php.net/manual/en/install.fpm.php) | PHP with FastCGI Process Manager                             |
| Miscelaneous   | [Bash](https://www.gnu.org/software/bash/)               | Allows to create an interactive shell within containerized service |
| Miscelaneous   | [Make](https://www.gnu.org/software/make/)               | Allows to execute commands defined on a _Makefile_           |
| Miscelaneous   | [jq](https://jqlang.github.io/jq/download/)              | Allows to beautify the Docker inspections in JSON format     |



------



## Development Environment



> [!IMPORTANT]
>
> This development environment is based on [Dockerized PHP](https://github.com/alcidesrc/dockerized-php), a framework agnostic *dockerized* environment to create and deploy PHP applications.
>
> Please take a look to the [README.md](https://github.com/alcidesrc/dockerized-php/blob/main/README.md) file to know how to familiarize with it and get up and running.



> [!IMPORTANT]
>
> Default application is based on [PHP Skeleton](https://github.com/alcidesrc/php-skeleton), a minimalistic boilerplate to create PHP applications from scratch.
>
> Please take a look to the [README.md](https://github.com/alcidesrc/php-skeleton/blob/main/README.md) file to know how to familiarize with it and get up and running.



------



## Getting Started

Just clone the repository into your preferred path:

```bash
$ mkdir -p ~/path/to/my-new-project && cd ~/path/to/my-new-project
$ git clone git@github.com:alcidesrc/dockerized-php-caddy.git .
```

### Quickstart

```bash
$ make init
```

### TL;DR

#### Building the container

```bash
$ make build
```

#### Starting the container service

```bash
$ make up
```

#### Extracting Caddy Local Authority - 20XX ECC Root 

```bash
$ make install-caddy-certificate
```

#### Accessing to web application

```bash
$ make open-website
```

#### Stopping the container service

```bash
$ make down
```



------




## Security Vulnerabilities

Please review our security policy on how to report security vulnerabilities:

**PLEASE DON'T DISCLOSE SECURITY-RELATED ISSUES PUBLICLY**

### Supported Versions

Only the latest major version receives security fixes.

### Reporting a Vulnerability

If you discover a security vulnerability within this project, please [open an issue here](https://github.com/alcidesrc/dockerized-php-caddy/issues). All security vulnerabilities will be promptly addressed.



------



## License

The MIT License (MIT). Please see [LICENSE](./LICENSE) file for more information.
