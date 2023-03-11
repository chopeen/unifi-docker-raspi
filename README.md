# Running UniFi Controller on Raspberry Pi Zero

Docker image to run UniFi Controller (aka UniFi Network Application) on Raspberry
Pi Zero.

You can pull the image from [Docker Hub](https://hub.docker.com/r/chopeen/unifi-docker-raspi):

```shell
docker pull chopeen/unifi-docker-raspi:latest
```

This repository is a fork of [jacobalberty/unifi-docker](
https://github.com/jacobalberty/unifi-docker), with some additional ideas taken from
[jcberthon/unifi-docker](https://github.com/jcberthon/unifi-docker) and a [blog post by Tyson
Nichols](https://tynick.com/blog/09-08-2019/unifi-controller-with-raspberry-pi-and-docker/).

## Starting the container

```shell
export UNIFI_DIR=~/unifi/

# create a directory to persist UniFi data outside the container
mkdir $UNIFI_DIR

# set the directory to be owned by "unifi" user
sudo chown -R 999:999 $UNIFI_DIR
````

```shell
export UNIFI_DIR=~/unifi/

# (optional) stop the running container and rename it
docker container stop unifi_raspi
docker rename unifi_raspi unifi_raspi_old

# start the container
docker run \
  -d \
  --restart=unless-stopped \
  --init \
  -p 8080:8080 -p 8443:8443 -p 3478:3478/udp -p 10001:10001/udp \
  --volume $UNIFI_DIR:/unifi \
  -e TZ='Europe/Warsaw' \
  -e JVM_MAX_HEAP_SIZE='512m' \
  --memory 350m \
  --user unifi \
  --name unifi_raspi \
  chopeen/unifi-docker-raspi:latest
```

For explanation of the `docker run` arguments used above, see:

- [UniFi Controller With Raspberry Pi And Docker](
  https://tynick.com/blog/09-08-2019/unifi-controller-with-raspberry-pi-and-docker/)
- [jcberthon/unifi-docker # Running the container on low-memory devices](
  https://github.com/jcberthon/unifi-docker/blob/master/README.md#running-the-container-on-low-memory-devices)
- [jacobalberty/unifi-docker # Run as non-root User](
  https://github.com/jacobalberty/unifi-docker#run-as-non-root-user)

📝 **TODO:** Research the warning `Your kernel does not support memory limit capabilities or
the cgroup is not mounted. Limitation discarded.`

### Supported models

The image was tested with Raspberry Pi Zero W (2017).

<details>
  <summary>Zero W specs</summary>
  
```shell
$ cat /proc/cpuinfo
processor       : 0
model name      : ARMv6-compatible processor rev 7 (v6l)
BogoMIPS        : 697.95
Features        : half thumb fastmult vfp edsp java tls 
CPU implementer : 0x41
CPU architecture: 7
CPU variant     : 0x0
CPU part        : 0xb76
CPU revision    : 7

Hardware        : BCM2835
Revision        : 19000c1
Serial          : 00000000b8d1df6c
Model           : Raspberry Pi Zero W Rev 1.1
```

</details>

## Troubleshooting

```shell
# logs
less ~/unifi/log/server.log
less ~/unifi/log/mongod.log
docker logs unifi_raspi

# access the container's shell
docker exec -it unifi_raspi /bin/bash

# restart the container
docker restart unifi_raspi
```

## Building the image

🕸️ This instruction is now obsolete.

💡 If you provide your `DOCKERHUB_USERNAME` and `DOCKERHUB_TOKEN` in repository secrets
and change `DOCKER_IMAGE` value to point a repository in your account, the "Publish Docker image"
workflow (see `docker.yml`) will publish the image to Docker Hub automatically.

The base images were changed to:

- `navikey/raspbian-buster`
- `balenalib/raspberry-pi-golang:1-buster-build` (there is also Zero-specific [orange-pi-zero-golang](
   https://hub.docker.com/r/balenalib/orange-pi-zero-golang) - would it be better?)

so that it is possible to run the build on Raspberry Pi Zero.

```shell
# set up Docker
curl -fsSL https://get.docker.com -o docker.sh
sh docker.sh

# (optional) to run `docker` command without `sudo`; restart the session afterwards
sudo usermod -aG docker pi

# set up the Buildx plugin
mkdir ~/.docker/cli-plugins/
curl -L "https://github.com/docker/buildx/releases/download/v0.7.1/buildx-v0.7.1.linux-arm-v6" > ~/.docker/cli-plugins/docker-buildx
chmod a+x ~/.docker/cli-plugins/docker-buildx

# clone the repository
git clone https://github.com/chopeen/unifi-docker-raspi.git
cd unifi-docker-raspi/
```

```shell
# (optional) log in to Docker Hub, to avoid random errors when pulling base images
docker login

# build the image for appropriate platform
export UNIFI_REPOSITORY=chopeen/unifi-docker-raspi
docker buildx build --platform linux/arm/v6 -t ${UNIFI_REPOSITORY}:latest .

# tag the image with Controller version number
export UNIFI_VERSION=6.5.55
docker image tag ${UNIFI_REPOSITORY}:latest ${UNIFI_REPOSITORY}:${UNIFI_VERSION}

# publish the image to Docker Hub
docker push ${UNIFI_REPOSITORY}:latest
docker push ${UNIFI_REPOSITORY}:${UNIFI_VERSION}
```

Running the build on Zero W (2017) takes about an hour, so be patient.

<details>
  <summary>Expected output</summary>
  
```shell
$ docker buildx build --platform linux/arm/v6 -t chopeen/unifi-docker-raspi:latest .
[+] Building 3581.6s (19/20)                                                                                                                                                
[+] Building 3784.3s (20/20) FINISHED                                                                                                                                       
 => [internal] load build definition from Dockerfile                                                                                                                   3.5s
 => => transferring dockerfile: 2.76kB                                                                                                                                 1.5s
 => [internal] load .dockerignore                                                                                                                                      1.8s
 => => transferring context: 2B                                                                                                                                        0.1s
 => [internal] load metadata for docker.io/navikey/raspbian-buster:latest                                                                                             14.0s
 => [internal] load build context                                                                                                                                      2.3s
 => => transferring context: 16.55kB                                                                                                                                   0.4s
 => [ 1/15] FROM docker.io/navikey/raspbian-buster:latest@sha256:ae129c1204bdf26713d125c7092ae33f6d6cd597d9bf660952b1ea8bbc3d708d                                    574.7s
 => => resolve docker.io/navikey/raspbian-buster:latest@sha256:ae129c1204bdf26713d125c7092ae33f6d6cd597d9bf660952b1ea8bbc3d708d                                        3.1s
 => => sha256:ae129c1204bdf26713d125c7092ae33f6d6cd597d9bf660952b1ea8bbc3d708d 1.41kB / 1.41kB                                                                         0.0s
 => => sha256:afec9605c25178c20b3c637ec79b948617b2dd90a40cfb458a2c6d3821432e12 528B / 528B                                                                             0.0s
 => => sha256:f3051d5b3cafd34c223454a25f92c673441de3c0ae7d978835f8f69b6107ddd9 706B / 706B                                                                             0.0s
 => => sha256:2764edd039a4cf5f888ce940db1021b4f01e2f74ba952d584c6139d7b5f507e6 90.45MB / 90.45MB                                                                     103.0s
 => => extracting sha256:2764edd039a4cf5f888ce940db1021b4f01e2f74ba952d584c6139d7b5f507e6                                                                            408.7s
 => [ 2/15] RUN set -eux;  apt-get update;  apt-get install -y gosu;  rm -rf /var/lib/apt/lists/*                                                                    226.9s 
 => [ 3/15] RUN mkdir -p /usr/unifi      /usr/local/unifi/init.d      /usr/unifi/init.d      /usr/local/docker                                                        24.1s 
 => [ 4/15] COPY docker-entrypoint.sh /usr/local/bin/                                                                                                                 21.8s 
 => [ 5/15] COPY docker-healthcheck.sh /usr/local/bin/                                                                                                                19.1s 
 => [ 6/15] COPY docker-build.sh /usr/local/bin/                                                                                                                      12.7s 
 => [ 7/15] COPY functions /usr/unifi/functions                                                                                                                       12.2s 
 => [ 8/15] COPY import_cert /usr/unifi/init.d/                                                                                                                       12.7s
 => [ 9/15] COPY pre_build /usr/local/docker/pre_build                                                                                                                13.3s
 => [10/15] RUN chmod +x /usr/local/bin/docker-entrypoint.sh  && chmod +x /usr/unifi/init.d/import_cert  && chmod +x /usr/local/bin/docker-healthcheck.sh  && chmod   24.3s
 => [11/15] RUN set -ex  && mkdir -p /usr/share/man/man1/  && groupadd -r unifi -g 999  && useradd --no-log-init -r -u 999 -g 999 unifi  && /usr/local/bin/docker-  2335.0s 
 => [12/15] RUN mkdir -p /unifi && chown unifi:unifi -R /unifi                                                                                                        26.6s 
 => [13/15] COPY hotfixes /usr/local/unifi/hotfixes                                                                                                                   12.7s 
 => [14/15] RUN chmod +x /usr/local/unifi/hotfixes/* && run-parts /usr/local/unifi/hotfixes                                                                           49.4s 
 => [15/15] WORKDIR /unifi                                                                                                                                            11.0s 
 => exporting to image                                                                                                                                               372.9s 
 => => exporting layers                                                                                                                                              372.8s
 => => writing image sha256:475df499fbb7a30cb7b1c7d23d332a391047b9f0c42bc20153164af5aa4e7e4c                                                                           0.1s
 => => naming to docker.io/chopeen/unifi-docker-raspi:latest  
```

</details>

📝 **TODO:** Research how to perform this build on Ubuntu ([Getting started with Docker for Arm on
Linux](https://www.docker.com/blog/getting-started-with-docker-for-arm-on-linux/))

## Background

When I tried to use the original `jacobalberty/unifi-docker` image from [Docker Hub](
https://hub.docker.com/r/jacobalberty/unifi) on Raspberry Pi Zero, it failed with error:

```text
The requested image's platform (linux/arm/v7) does not match the detected host platform (linux/arm/v6) and no specific platform was requested
```

The supported platforms are: `linux/amd64`, `linux/arm/v7` and `linux/arm64`.

I tried building a new image from the original `Dockerfile` with `--platform linux/arm/v6`,
but - depending on the machine (Ubuntu laptop or Raspberry Pi) - it failed with different errors:

```shell
 => ERROR [internal] load metadata for docker.io/library/ubuntu:18.04                                                                                                  0.3s
------
 > [internal] load metadata for docker.io/library/ubuntu:18.04:
------
error: failed to solve: failed to solve with frontend dockerfile.v0: failed to create LLB definition: no match for platform in manifest sha256:0fedbd5bd9fb72089c7bbca476949e10593cebed9b1fb9edf5b79dbbacddd7d6: not found
```

```shell
 => ERROR [ 2/15] RUN set -eux;  apt-get update;  apt-get install -y gosu;  rm -rf /var/lib/apt/lists/*                                                                0.9s
------                                                                                                                                                                      
 > [ 2/15] RUN set -eux;        apt-get update;         apt-get install -y gosu;        rm -rf /var/lib/apt/lists/*:
#5 0.599 standard_init_linux.go:228: exec user process caused: exec format error
------
error: failed to solve: executor failed running [/bin/sh -c set -eux;   apt-get update;         apt-get install -y gosu;        rm -rf /var/lib/apt/lists/*]: exit code: 1
```

### Goal

The goal is to publish a Docker image with UniFi Controller for Raspberry Pi Zero as well as
provide some advice for running it on low-memory devices.

---

[original README below]

# Unifi-in-Docker (unifi-docker)

This repo contains a Dockerized version of [Ubiqiti Network's](https://www.ubnt.com/) Unifi Controller.

**Why bother?** Using Docker, you can stop worrying about version
hassles and update notices for
Unifi Controller, Java, _or_ your OS.
A Docker container wraps everything into one well-tested bundle.

To install, a couple lines on the command-line starts the container.
To upgrade, just stop the old container, and start up the new.
It's really that simple.

This container has been tested on Ubuntu, Debian, macOS, Windows,
and even Raspberry Pi hardware.

See the [Current Information](#Current-information) section for the latest versions.

## Setting up, Running, Stopping, Upgrading

First, install Docker on the "Docker host" -
the machine that will run the Docker
and Unifi Controller software.
Use any of the guides on the internet to install on your Docker host.
For Windows, see the [Microsoft guide for installing Docker.](https://docs.microsoft.com/en-us/windows/wsl/tutorials/wsl-containers)

Then use the following steps to set up the directories
and start the Docker container running.

### Setting up directories

_One-time setup:_ create the `unifi` directory on the Docker host.
Within that directory, create two sub-directories: `data` and `log`.

```bash
cd # by default, use the home directory
mkdir -p unifi/data
mkdir -p unifi/log
```

_Note:_ By default, this README assumes you will use the home directory
on Linux, Unix, macOS.
If you create the directory elsewhere, read the
[Options section](#options-on-the-command-line)
below to adjust.)

### Running Unifi-in-Docker

Each time you want to start Unifi, use this command.
Each of the options is [described below.](#options-on-the-command-line)

```bash
docker run -d --init \
   --restart=unless-stopped \
   -p 8080:8080 -p 8443:8443 -p 3478:3478/udp \
   -e TZ='Africa/Johannesburg' \
   -v ~/unifi:/unifi \
   --user unifi \
   --name unifi \
   jacobalberty/unifi
```

In a minute or two, (after Unifi Controller starts up) you can go to
[https://docker-host-address:8443](https://docker-host-address:8443)
to complete configuration from the web (initial install) or resume using Unifi Controller.

**Important:** Two points to be aware of when you're setting up your Unifi Controller:

* When your browser initially connects to the link above, you will
see a warning about an untrusted certificate.
If you are _certain_ that you have typed the address of the
Docker host correctly, agree to the connection.
* See the note below about **Override "Inform Host" IP** so your
Unifi devices can "find" the Unifi Controller.
 
### Stopping Unifi-in-Docker

To change options, stop the Docker container then re-run the `docker run...` command
above with the new options.
_Note:_ The `docker rm unifi` command simply removes the "name" from the previous Docker image.
No time-consuming rebuild is required.

```bash
docker stop unifi
docker rm unifi
```
### Upgrading Unifi Controller

All the configuration and other files created by Unifi Controller
are stored on the Docker host's local disk (`~/unifi` by default.)
No information is retained within the container.
An upgrade to a new version of Unifi Controller simply retrieves a new Docker container,
which then re-uses the configuration from the local disk.
The upgrade process is:

1. **MAKE A BACKUP** on another computer, not the Docker host _(Always, every time...)_
2. Stop the current container (see above)
3. Enter `docker run...` with the newer container tag (see [Current Information](#current-information) section below.)

## Options on the Command Line

The options for the `docker run...` command are:

- `-d` - Detached mode: Unifi-in-Docker runs in the background
- `--init` - Recommended to ensure processes get reaped when they die
- `--restart=unless-stopped` - If the container should stop for some reason,
restart it unless you issue a `docker stop ...`
- `-p ...` - Set the ports to pass through to the container.
`-p 8080:8080 -p 8443:8443 -p 3478:3478/udp`
is the minimal set for a working Unifi Controller. 
- `-e TZ=...` Set an environment variable named `TZ` with the desired time zone.
Find your time zone in this 
[list of timezones.](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones)
- `-e ...` See the [Environment Variables](#environment-variables)
section for more environment variables.
- `-v ...` - Bind the volume `~/unifi` on the Docker host
to the directory `/unifi`inside the container.
**These instructions assume you placed the "unifi" directory in your home directory.**
If you created the directory elsewhere, modify the `~/unifi` part of this option to match.
See the [Volumes](#volumes) discussion for other volumes used by Unifi Controller.
- `--user unifi` - Run as a non-root user. See the [Run as non-root User](#run-as-non-root-user) discussion below
- `jacobalberty/unifi` - the name of the container to use.
The `jacobalberty...` image is retrieved from [Dockerhub.](https://hub.docker.com/r/jacobalberty/unifi)
The [Current Information](#current-information) section below discusses the versions/tags that are available.

## Current Information

**The current "latest" version is Unifi Controller 7.3.83.
There are currently no hot-fix or CVE warnings
affecting Unifi Controller.**

You can choose the version of Unifi Controller in the `docker run ...` command.
In Docker terminology, these versions are specified by "tags".

For example, in this project the container named `jacobalberty/unifi`
(with no "tag")
provides the most recent stable release.
The table below lists recent versions.

The `rc` tag (for example, `jacobalberty/unifi:rc`)
uses the most recent Release Candidate from the UniFi APT repository.

You may also specify a version number (e.g., `jacobalberty/unifi:stable6`)
to get a specific version number, as shown in the table below.

_Note:_ In Docker, specifying an image with no tag 
(e.g., `jacobalberty/unifi`) gets the "latest" tag.
For Unifi-in-Docker, this uses the most recent stable version.

| Tag | Description | Changelog |
|-----|-------------|-----------|
| [`latest` `v7.3.83`](https://github.com/jacobalberty/unifi-docker/blob/master/Dockerfile) | Current Stable: Version 7.3.83 as of 2023-02-08 |[Change Log 7.3.83](https://community.ui.com/releases/UniFi-Network-Application-7-3-83/88f5ff3f-4c13-45e2-b57e-ad04b4140528)|
| [`rc`](https://github.com/jacobalberty/unifi-docker/blob/rc/Dockerfile) | Release Candidate: 7.2.92-rc as of 2022-07-29 | [Change Log 7.2.91-rc](https://community.ui.com/releases/UniFi-Network-Application-7-2-91/cdac73f0-7426-4276-ace8-8a96c656ba65) |
| [`stable-6`](https://github.com/jacobalberty/unifi-docker/blob/stable-6/Dockerfile) | Final stable version 6 (6.5.55) | [Change Log 6.5.55](https://community.ui.com/releases/UniFi-Network-Application-6-5-55/48c64137-4a4a-41f7-b7e4-3bee505ae16e) |
| [`stable-5`](https://github.com/jacobalberty/unifi-docker/blob/stable-5/Dockerfile) | Final stable version 5 (5.4.23) | [Change Log 5.14.23](https://community.ui.com/releases/UniFi-Network-Controller-5-14-23/daf90732-30ad-48ee-81e7-1dcb374eba2a) |

### multiarch

All available containers now support multiarch with `amd64`, `armhf`, and `arm64` builds included.
`armhf` for now uses mongodb 3.4, I do not see much of a path forward for `armhf` due
to the lack of mongodb support for 32 bit arm, but I will
support it as long as feasibly possible, for now that date seems to be expiration of support for ubuntu 18.04.

## Adopting Access Points and Unifi Devices

#### Override "Inform Host" IP

For your Unifi devices to "find" the Unifi Controller running in Docker,
you _MUST_ override the Inform Host IP
with the address of the Docker host computer.
(By default, the Docker container usually gets the internal address 172.17.x.x
while Unifi devices connect to the (external) address of the Docker host.)
To do this:

* Find **Settings -> System -> Other Configuration -> Override Inform Host:** in the Unifi Controller web GUI.
(It's near the bottom of that page.)
* Check the "Enable" box, and enter the IP address of the Docker host machine. 
* Save settings in Unifi Controller
* Restart UniFi-in-Docker container with `docker stop ...` and `docker run ...` commands.

See [Side Projects](https://github.com/jacobalberty/unifi-docker/blob/master/Side-Projects.md#other-techniques-for-adoption) for
other techniques to get Unifi devices to adopt your
new Unifi Controller.

## Volumes

Unifi looks for the `/unifi` directory (within the container)
for its special purpose subdirectories:

* `/unifi/data` This contains your UniFi configuration data. (formerly: `/var/lib/unifi`) 

* `/unifi/log` This contains UniFi log files (formerly: `/var/log/unifi`)

* `/unifi/cert` Place custom SSL certs in this directory. 
For more information regarding the naming of the certificates,
see [Certificate Support](#certificate-support). (formerly: `/var/cert/unifi`)

* `/unifi/init.d`
You can place scripts you want to launch every time the container starts in here

* `/var/run/unifi` 
Run information, in general you will not need to touch this volume.
It is there to ensure UniFi has a place to write its PID files

### Legacy Volumes

These are no longer actually volumes, rather they exist for legacy compatibility.
You are urged to move to the new volumes ASAP.

* `/var/lib/unifi` New name: `/unifi/data`
* `/var/log/unifi` New name: `/unifi/log`

## Environment Variables:

You can pass in environment variables using the `-e` option when you invoke `docker run...`
See the `TZ` in the example above.
Other environment variables:

* `UNIFI_HTTP_PORT`
This is the HTTP port used by the Web interface. Browsers will be redirected to the `UNIFI_HTTPS_PORT`.
**Default: 8080**

* `UNIFI_HTTPS_PORT`
This is the HTTPS port used by the Web interface.
**Default: 8443** 

* `PORTAL_HTTP_PORT`
Port used for HTTP portal redirection.
**Default: 80** 

* `PORTAL_HTTPS_PORT`
Port used for HTTPS portal redirection.
**Default: 8843** 

* `UNIFI_STDOUT`
Controller outputs logs to stdout in addition to server.log
**Default: unset** 

* `TZ`
TimeZone. (i.e America/Chicago)

* `JVM_MAX_THREAD_STACK_SIZE`
Used to set max thread stack size for the JVM
Example:

   ```
   --env JVM_MAX_THREAD_STACK_SIZE=1280k
   ```

   as a fix for [https://community.ubnt.com/t5/UniFi-Routing-Switching/IMPORTANT-Debian-Ubuntu-users-MUST-READ-Updated-06-21/m-p/1968251#M48264](https://community.ubnt.com/t5/UniFi-Routing-Switching/IMPORTANT-Debian-Ubuntu-users-MUST-READ-Updated-06-21/m-p/1968251#M48264)

* `LOTSOFDEVICES`
Enable this with `true` if you run a system with a lot of devices
and/or with a low powered system (like a Raspberry Pi).
This makes a few adjustments to try and improve performance: 

   * enable unifi.G1GC.enabled
   * set unifi.xms to JVM\_INIT\_HEAP\_SIZE
   * set unifi.xmx to JVM\_MAX\_HEAP\_SIZE
   * enable unifi.db.nojournal
   * set unifi.dg.extraargs to --quiet

   See [the Unifi support site](https://help.ui.com/hc/en-us/articles/115005159588-UniFi-How-to-Tune-the-Network-Application-for-High-Number-of-UniFi-Devices)
for an explanation of some of those options.
**Default: unset** 

* `JVM_EXTRA_OPTS`
Used to start the JVM with additional arguments.
**Default: unset** 

* `JVM_INIT_HEAP_SIZE`
Set the starting size of the javascript engine for example: `1024M`
**Default: unset** 

* `JVM_MAX_HEAP_SIZE`
Java Virtual Machine (JVM) allocates available memory. 
For larger installations a larger value is recommended. For memory constrained system this value can be lowered. 
**Default: 1024M** 

## Exposed Ports

The Unifi-in-Docker container exposes the following ports.
A minimal Unifi Controller installation requires you
expose the first three with the `-p ...` option.

* 8080/tcp - Device command/control 
* 8443/tcp - Web interface + API 
* 3478/udp - STUN service 
* 8843/tcp - HTTPS portal _(optional)_
* 8880/tcp - HTTP portal _(optional)_
* 6789/tcp - Speed Test (unifi5 only) _(optional)_

See [UniFi - Ports Used](https://help.ubnt.com/hc/en-us/articles/218506997-UniFi-Ports-Used) for more information.

## Run as non-root User

The default container runs Unifi Controller as root.
The recommended `docker run...` command above starts
Unifi Controller so the image runs as `unifi` (non-root)
user with the uid/gid 999/999.
You can also set your data and logs directories to be
owned by the proper gid.

_Note:_ When you run as a non-root user,
you will not be able to bind to lower ports by default.
(This would not necessary if you are using the default ports.)
If you must do this, also pass the 
`--sysctl net.ipv4.ip_unprivileged_port_start=0`
option on the `docker run...` to bind to whatever port you wish.

## Certificate Support

To use custom SSL certs, you must map a volume with the certs to `/unifi/cert`

They should be named:

```shell
cert.pem  # The Certificate
privkey.pem # Private key for the cert
chain.pem # full cert chain
```

If your certificate or private key have different names, you can set the environment variables `CERTNAME` and `CERT_PRIVATE_NAME` to the name of your certificate/private key, e.g. `CERTNAME=my-cert.pem` and `CERT_PRIVATE_NAME=my-privkey.pem`.

For letsencrypt certs, we'll autodetect that and add the needed Identrust X3 CA Cert automatically. In case your letsencrypt cert is already the chained certificate, you can set the `CERT_IS_CHAIN` environment variable to `true`, e.g. `CERT_IS_CHAIN=true`. This option also works together with a custom `CERTNAME`.

## Additional Information

This document describes everything you need to get Unifi-in-Docker running.
The [Side Projects and Background Info](https://github.com/jacobalberty/unifi-docker/blob/master/Side-Projects.md) page
provides more about what we've learned while developing Unifi-in-Docker.

## TODO

This list is empty for now, please [add your suggestions](https://github.com/jacobalberty/unifi-docker/issues).
