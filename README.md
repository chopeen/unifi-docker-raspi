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
# create a directory to persist UniFi data outside the container
export UNIFI_DIR=~/unifi/
mkdir $UNIFI_DIR

# set the directory to be owned by "unifi" user
sudo chown -R 999:999 $UNIFI_DIR

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

## Building the image

The base image was changed to `navikey/raspbian-buster`, so that it is possible to run the build
on Raspberry Pi Zero.

```shell
# set up Docker
curl -fsSL https://get.docker.com -o docker.sh
sh docker.sh
sudo usermod -aG docker pi

# set up the Buildx plugin
mkdir ~/.docker/cli-plugins/
curl -L "https://github.com/docker/buildx/releases/download/v0.7.1/buildx-v0.7.1.linux-arm-v6" > ~/.docker/cli-plugins/docker-buildx
chmod a+x ~/.docker/cli-plugins/docker-buildx

# clone the repository
git clone https://github.com/chopeen/unifi-docker-raspi.git
cd unifi-docker-raspi/

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

Running the build on Pi takes about an hour, so be patient.

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

## Important log4shell News

These tags have now been update with a hotfix for CVE-2021-45105 as well.

Please update to [v6.5.55](https://community.ui.com/releases/UniFi-Network-Application-6-5-55/48c64137-4a4a-41f7-b7e4-3bee505ae16e) as soon as possible as it contains a critical
fix for a remote code execution vulnerability (CVE-2021-44228 as well as CVE-2021-45046). I have also backported the fix to `v6.0.45` and `v5.14.23` for those on EOL hardware releases or who just prefer the older version.

To verify you have the latest hotfix applied on `v6.0.45` and `v5.14.23` you should see `Hotfix validated: cve-2021-45105` in your docker logs for your unifi container at startup

Again: Only the `v6.5.55`, `v6.0.45` and the `v5.14.23` tags have the fix backported to them. Please be sure you are running the one with the v in the tag name for those two older versions.

## `latest` tag

`latest` is now tracking unifi 6.5.x as of 2021-11-22.

## multiarch

All tags are now multiarch capable with `amd64`, `armhf`, and `arm64` builds included.
`armhf` for now uses mongodb 3.4, I do not see much of a path forward for `armhf` due to the lack of mongodb support for 32 bit arm, but I will
support it as long as feasibly possible, for now that date seems to be expiration of support for ubuntu 18.04.

## Run as non-root User

It is suggested you start running this as a non root user. The default right now is to run as root but if you set the docker run flag `--user` to `unifi` then the image will run as a special unfi user with the uid/gid 999/999. You should ideally set your data and logs to owned by the proper gid.
You will not be able to bind to lower ports by default. If you also pass the docker run flag `--sysctl` with `net.ipv4.ip_unprivileged_port_start=0` then you will be able to freely bind to whatever port you wish. This should not be needed if you are using the default ports.

## Mongo and Docker for windows
 Unifi uses mongo store its data. Mongo uses the fsync() system call on its data files. Because of how docker for windows works you can't bind mount `/unifi/db/data` on a docker for windows container. Therefore `-v ~/unifi:/unifi` won't work.
 [Discussion on the issue](https://github.com/docker/for-win/issues/138).

## Supported Docker Hub Tags and Respective `Dockerfile` Links

| Tag | Description |
|-----|-------------|
| [`latest`, `v6`, `v6.5`](https://github.com/jacobalberty/unifi-docker/blob/master/Dockerfile) | Tracks UniFi stable version - 6.5.55 as of 2021-12-14 [Change Log 6-5-55](https://community.ui.com/releases/UniFi-Network-Application-6-5-55/48c64137-4a4a-41f7-b7e4-3bee505ae16e)|

### Latest Release Candidate tags

| Version | Latest Tag |
|---------|------------|
| 6.5.x   | [`6.5.55`](https://github.com/jacobalberty/unifi-docker/blob/6.5.55/Dockerfile) |

These tags generally track the UniFi APT repository. We do lead the repository a little when it comes to pushing the latest version. The latest version gets pushed when it moves from `release candidate` to `stable` instead of waiting for it to hit the repository.

In adition to these tags you may tag specific versions as well, for example `jacobalberty/unifi:v6.2.26` will get you unifi 6.2.26 no matter what the current version is.
For release candidates it is advised to use the specific versions as the `rc` tag may jump from 5.6.x to 5.8.x then back to 5.6.x as new release candidates come out.

## Description

This is a containerized version of [Ubiqiti Network](https://www.ubnt.com/)'s Unifi Controller.

The following options may be of use:

- Set the timezone with `TZ` ([list of timezones](https://en.wikipedia.org/wiki/List_of_tz_database_time_zones))
- Bind mount the `data` and `log` volumes

It is suggested that you include --init to handle process reaping
Example to test with

```bash
mkdir -p unifi/data
mkdir -p unifi/log
docker run --rm --init -p 8080:8080 -p 8443:8443 -p 3478:3478/udp -e TZ='Africa/Johannesburg' -v ~/unifi:/unifi --name unifi jacobalberty/unifi:v6
```

**Note** you must omit `-v ~/unifi:/unifi` on windows, but you can use a local volume e.g. `-v unifi:/unifi` (omit the leading ~/) to persist the data on a local volume.

## Running with separate mongo container

A compose file has been included that will bring up mongo and the controller,
using named volumes for important directories.

Simply clone this repo or copy the `docker-compose.yml` file and run
```bash
docker-compose up -d
```

## Adopting Access Points/Switches/Security Gateway

### Layer 3 Adoption

The default example requires some l3 adoption method. You have a couple options to adopt.

#### Force adoption IP

Run UniFi Docker and open UniFi in browser. Go under Settings -> Controller and then enter the IP address of the Docker host machine in "Controller Hostname/IP", and check the "Override inform host with controller hostname/IP". Save settings and restart UniFi Docker container. 

#### SSH Adoption

The quickest one off method is to ssh into the access point and run the following commands:

```shell
mca-cli
set-inform http://<host_ip>:8080/inform
```

#### Other Options

You can see more options on the [UniFi website](https://help.ubnt.com/hc/en-us/articles/204909754-UniFi-Layer-3-methods-for-UAP-adoption-and-management)


### Layer 2 Adoption

You can also enable layer 2 adoption through one of two methods.

#### Host Networking

If you launch the container using host networking \(With the `--net=host` parameter on `docker run`\) Layer 2 adoption works as if the controller is installed on the host.

#### Bridge Networking

It is possible to configure the `macvlan` driver to bridge your container to the host's networking adapter. Specific instructions for this container are not yet available but you can read a write-up for docker at [collabnix.com/docker-17-06-swarm-mode-now-with-macvlan-support](http://collabnix.com/docker-17-06-swarm-mode-now-with-macvlan-support/).

## Beta Users

The `beta` image has been updated to support package installation at run time. With this change you can now install the beta releases on more systems, such as Synology. This should open up access to the beta program for more users of this docker image.


If you would like to submit a new feature for the images the beta branch is probably a good one to apply it against as well. I will be cleaing up the Dockerfile under beta and gradually pushing out the improvements to the other branches. So any major changes should apply cleanly against the `beta` branch.

### Installing Beta Builds On The Command Line

Using the Beta build is pretty easy, just use the `jacobalberty/unifi:beta` image and add `-e PKGURL=https://dl.ubnt.com/unifi/5.6.30/unifi_sysvinit_all.deb` to your usual command line.

Simply replace the url to the debian package with the version you prefer.


### Building Beta Using `docker-compose.yml` Version 2

This is just as easy when using version 2 of the docker-compose.yml file format.

Under your containers service definition instead of using `image: jacobalberty/unifi` use the following:

```shell
        image: jacobalberty/unifi:beta
         environment:
          PKGURL: https://dl.ubnt.com/unifi/5.6.40/unifi_sysvinit_all.deb
```

Once again, simply change PKGURL to point to the package you would like to use.

## Volumes:

### `/unifi`

This is a single monolithic volume that contains several subdirectories, you can do a single volume for everything or break up your old volumes into the subdirectories

#### `/unifi/data`

Old: `/var/lib/unifi`

This contains your UniFi configuration data.

#### `/unifi/log`

old: `/var/log/unifi`

This contains UniFi log files

#### `/unifi/cert`

old: `/var/cert/unifi`

To use custom SSL certs, you must map a volume with the certs to /unifi/cert

For more information regarding the naming of the certificates, see [Certificate Support](#certificate-support).

#### `/unifi/init.d`

This is an entirely new volume. You can place scripts you want to launch every time the container starts in here

### `/var/run/unifi`

Run information, in general you will not need to touch this volume. It is there to ensure UniFi has a place to write its PID files


### Legacy Volumes

These are no longer actually volumes, rather they exist for legacy compatibility. You are urged to move to the new volumes ASAP.

#### `/var/lib/unifi`

New name: `/unifi/data`

#### `/var/log/unifi`

New name: `/unifi/log`

## Environment Variables:

### `UNIFI_HTTP_PORT`

Default: `8080`

This is the HTTP port used by the Web interface. Browsers will be redirected to the `UNIFI_HTTPS_PORT`.

### `UNIFI_HTTPS_PORT`

Default: `8443`

This is the HTTPS port used by the Web interface.

### `PORTAL_HTTP_PORT`

Default: `80`

Port used for HTTP portal redirection.

### `PORTAL_HTTPS_PORT`

Default: `8843`

Port used for HTTPS portal redirection.

### `UNIFI_STDOUT`

Default: `unset`

Controller outputs logs to stdout in addition to server.log

### `TZ`

TimeZone. (i.e America/Chicago)

### `JVM_MAX_THREAD_STACK_SIZE`

used to set max thread stack size for the JVM

Ex:

```
--env JVM_MAX_THREAD_STACK_SIZE=1280k
```

as a fix for https://community.ubnt.com/t5/UniFi-Routing-Switching/IMPORTANT-Debian-Ubuntu-users-MUST-READ-Updated-06-21/m-p/1968251#M48264

### `LOTSOFDEVICES`
Enable this with `true` if you run a system with a lot of devices and or with a low powered system (like a Raspberry Pi)
This makes a few adjustments to try and improve performance: 

* enable unifi.G1GC.enabled
* set unifi.xms to JVM_INIT_HEAP_SIZE
* set unifi.xmx to JVM_MAX_HEAP_SIZE
* enable unifi.db.nojournal
* set unifi.dg.extraargs to --quiet

See [This website](https://help.ui.com/hc/en-us/articles/115005159588-UniFi-How-to-Tune-the-Network-Application-for-High-Number-of-UniFi-Devices) for an explanation 
of some of those options.

Default: `unset`

### `JVM_EXTRA_OPTS`
Used to start the JVM with additional arguments.

Default: `unset`

### `JVM_INIT_HEAP_SIZE`
Set the starting size of the javascript engine for example: `1024M`

Default: `unset`

### `JVM_MAX_HEAP_SIZE`
Java Virtual Machine (JVM) allocates available memory. 
For larger installations a larger value is recommended. For memory constrained system this value can be lowered. 

Default `1024M`

### External MongoDB environment variables

These variables are used to implement support for an [external MongoDB server](https://community.ubnt.com/t5/UniFi-Wireless/External-MongoDB-Server/td-p/1305297) and must all be set in order for this feature to work. Once all are set then the configuration file value for `db.mongo.local` will automatically be set to `false`.

### `DB_URI`

Maps to `db.mongo.uri`.

### `STATDB_URI`

Maps to `statdb.mongo.uri`.

### `DB_NAME`

Maps to `unifi.db.name`.


## Expose:

### 8080/tcp - Device command/control

### 8443/tcp - Web interface + API

### 8843/tcp - HTTPS portal

### 8880/tcp - HTTP portal

### 3478/udp - STUN service

### 6789/tcp - Speed Test (unifi5 only)

See [UniFi - Ports Used](https://help.ubnt.com/hc/en-us/articles/218506997-UniFi-Ports-Used)

## Multi-process container

While micro-service patterns try to avoid running multiple processes in a container, the unifi5 container tries to follow the same process execution model intended by the original debian package and it's init script, while trying to avoid needing to run a full init system.

`dumb-init` has now been removed. Instead it is now suggested you include --init in your docker run command line. If you are using docker-compose you can accomplish the same by making sure you use version 2.2 of the yml format and add `init: true` to your service definition.

`unifi.sh` executes and waits on the jsvc process which orchestrates running the controller as a service. The wrapper script also traps SIGTERM to issue the appropriate stop command to the unifi java `com.ubnt.ace.Launcher` process in the hopes that it helps keep the shutdown graceful.


## Init scripts

You may now place init scripts to be launched during the unifi startup in /usr/local/unifi/init.d to perform any actions unique to your unifi setup. An example bash script to set up certificates is in `/usr/unifi/init.d/import_cert`.

## Certificate Support

To use custom SSL certs, you must map a volume with the certs to /unifi/cert

They should be named:

```shell
cert.pem  # The Certificate
privkey.pem # Private key for the cert
chain.pem # full cert chain
```

If your certificate or private key have different names, you can set the environment variables `CERTNAME` and `CERT_PRIVATE_NAME` to the name of your certificate/private key, e.g. `CERTNAME=my-cert.pem` and `CERT_PRIVATE_NAME=my-privkey.pem`.

For letsencrypt certs, we'll autodetect that and add the needed Identrust X3 CA Cert automatically. In case your letsencrypt cert is already the chained certificate, you can set the `CERT_IS_CHAIN` environment variable to `true`, e.g. `CERT_IS_CHAIN=true`. This option also works together with a custom `CERTNAME`.

## TODO

This list is empty for now, please [add your suggestions](https://github.com/jacobalberty/unifi-docker/issues).
