# Generated by: Neurodocker version 0+unknown
# Latest release: Neurodocker version 0.7.0
# Timestamp: 2020/06/30 12:42:18 UTC
# 
# Thank you for using Neurodocker. If you discover any issues
# or ways to improve this software, please submit an issue or
# pull request on our GitHub repository:
# 
#     https://github.com/ReproNim/neurodocker

FROM ubuntu:16.04

USER root

ARG DEBIAN_FRONTEND="noninteractive"

ENV LANG="en_US.UTF-8" \
    LC_ALL="en_US.UTF-8" \
    ND_ENTRYPOINT="/neurodocker/startup.sh"
RUN export ND_ENTRYPOINT="/neurodocker/startup.sh" \
    && apt-get update -qq \
    && apt-get install -y -q --no-install-recommends \
           apt-utils \
           bzip2 \
           ca-certificates \
           curl \
           locales \
           unzip \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && sed -i -e 's/# en_US.UTF-8 UTF-8/en_US.UTF-8 UTF-8/' /etc/locale.gen \
    && dpkg-reconfigure --frontend=noninteractive locales \
    && update-locale LANG="en_US.UTF-8" \
    && chmod 777 /opt && chmod a+s /opt \
    && mkdir -p /neurodocker \
    && if [ ! -f "$ND_ENTRYPOINT" ]; then \
         echo '#!/usr/bin/env bash' >> "$ND_ENTRYPOINT" \
    &&   echo 'set -e' >> "$ND_ENTRYPOINT" \
    &&   echo 'export USER="${USER:=`whoami`}"' >> "$ND_ENTRYPOINT" \
    &&   echo 'if [ -n "$1" ]; then "$@"; else /usr/bin/env bash; fi' >> "$ND_ENTRYPOINT"; \
    fi \
    && chmod -R 777 /neurodocker && chmod a+s /neurodocker

ENTRYPOINT ["/neurodocker/startup.sh"]

RUN printf '#!/bin/bash\nls -la' > /usr/bin/ll

RUN chmod +x /usr/bin/ll

RUN mkdir /afm01 /90days /30days /QRISdata /RDS /data /short /proc_temp /TMPDIR /nvme /local /gpfs1 /working /winmounts /state /autofs /cluster /local_mount /scratch /clusterdata /nvmescratch

ENV PATH="/opt/itksnap-3.8.0/bin:$PATH" \
    LD_LIBRARY_PATH="/opt/itksnap-3.8.0/lib:$LD_LIBRARY_PATH"
RUN apt-get update -qq \
    && apt-get install -y -q --no-install-recommends \
           libcurl3 \
           libfontconfig1 \
           libfreetype6 \
           libglib2.0-0 \
           libglu1-mesa \
           libpng12-0 \
           libsm6 \
           libxrender1 \
           libxt6 \
    && apt-get clean \
    && rm -rf /var/lib/apt/lists/* \
    && echo "Downloading itksnap ..." \
    && mkdir -p /opt/itksnap-3.8.0 \
    && curl -fsSL --retry 5 https://sourceforge.net/projects/itk-snap/files/itk-snap/3.8.0/itksnap-3.8.0-20190612-Linux-x86_64-qt4.tar.gz/download \
    | tar -xz -C /opt/itksnap-3.8.0 --strip-components 1

ENV DEPLOY_PATH="/opt/itksnap-3.8.0/bin/"

ENTRYPOINT ["/opt/itksnap-3.8.0/bin/itksnap"]

RUN test "$(getent passwd neuro)" || useradd --no-user-group --create-home --shell /bin/bash neuro
USER neuro

RUN echo '{ \
    \n  "pkg_manager": "apt", \
    \n  "instructions": [ \
    \n    [ \
    \n      "base", \
    \n      "ubuntu:16.04" \
    \n    ], \
    \n    [ \
    \n      "run", \
    \n      "printf '"'"'#!/bin/bash\\\nls -la'"'"' > /usr/bin/ll" \
    \n    ], \
    \n    [ \
    \n      "run", \
    \n      "chmod +x /usr/bin/ll" \
    \n    ], \
    \n    [ \
    \n      "run", \
    \n      "mkdir /afm01 /90days /30days /QRISdata /RDS /data /short /proc_temp /TMPDIR /nvme /local /gpfs1 /working /winmounts /state /autofs /cluster /local_mount /scratch /clusterdata /nvmescratch" \
    \n    ], \
    \n    [ \
    \n      "itksnap", \
    \n      { \
    \n        "version": "3.8.0" \
    \n      } \
    \n    ], \
    \n    [ \
    \n      "env", \
    \n      { \
    \n        "DEPLOY_PATH": "/opt/itksnap-3.8.0/bin/" \
    \n      } \
    \n    ], \
    \n    [ \
    \n      "entrypoint", \
    \n      "/opt/itksnap-3.8.0/bin/itksnap" \
    \n    ], \
    \n    [ \
    \n      "user", \
    \n      "neuro" \
    \n    ] \
    \n  ] \
    \n}' > /neurodocker/neurodocker_specs.json
