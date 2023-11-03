# syntax=docker/dockerfile:1

## --- Stage 1
FROM ubuntu:lunar

ARG UID=1000
ARG GID=1000
ARG USERNAME=ubuntu
ARG PASSWORD=ubuntu

SHELL ["/bin/bash", "-c"]

USER root
WORKDIR /root

## ---------------------------------------------------------
## User Management ( run as root )
## ---------------------------------------------------------

## -------------------------------------
## DEFAULT User Demolition
## -------------------------------------

RUN userdel ubuntu

## -------------------------------------
## User Creation
## -------------------------------------

RUN useradd        \
  --create-home    \
  --no-log-init    \
  -u ${UID}        \
  -G sudo,dialout  \
  -s /usr/bin/bash \
  ${USERNAME}      \
  && (echo "${USERNAME}:${PASSWORD}" | chpasswd)

#### -------------------------------------------------------
#### System Management
#### -------------------------------------------------------

USER root
WORKDIR /root

ENV DEBIAN_FRONTEND=noninteractive

## -------------------------------------
## Bootstrap Packages
## -------------------------------------

RUN apt-get update      \
  && apt-get install -y \
  tzdata                \
  gnupg2                \
  git                   \
  curl                  \
  wget                  \
  file                  \
  tar                   \
  gzip                  \
  bzip2                 \
  xz-utils              \
  gcc                   \
  make                  \
  cmake                 \
  build-essential       \
  sudo                  \
  && apt-get clean      \
  && rm -rf /var/lib/apt/lists/*

## -------------------------------------
## Clangd-17 & Clang-Format 
## -------------------------------------

RUN  (echo 'deb http://apt.llvm.org/lunar/ llvm-toolchain-lunar-17 main' >/etc/apt/sources.list.d/llvm.list)      \
  && (echo 'deb-src http://apt.llvm.org/lunar/ llvm-toolchain-lunar-17 main' >>/etc/apt/sources.list.d/llvm.list) \
  && (curl https://apt.llvm.org/llvm-snapshot.gpg.key | apt-key add -) \
  && apt-get update     \
  && apt-get install -y \
  clangd-17        \
  clang-format     \
  && apt-get clean \
  && rm -rf /var/lib/apt/lists/*


## ---------------------------------------------------------
## HomeBrew / LinuxBrew Package Manager ( run as root )
## ---------------------------------------------------------

## -------------------------------------
## Bootstrap HomeBrew / LinuxBrew
## -------------------------------------

ENV NONINTERACTIVE=1

RUN bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
RUN chown ${USERNAME}:${USERNAME} -R /home/linuxbrew
RUN  (if [[ ! -d /etc/profile.d ]]; then mkdir /etc/profile.d; fi)                           \
  && (echo 'export PATH=/home/linuxbrew/.linuxbrew/bin:$PATH' >> /etc/profile.d/linuxbrew.sh)

