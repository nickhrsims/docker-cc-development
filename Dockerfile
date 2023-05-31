# syntax=docker/dockerfile:1

FROM ubuntu:22.04
WORKDIR /opt
COPY opt/* .
RUN apt-get update
RUN apt-get install -y apt-utils
RUN apt-get install -y \
    sudo               \
    nano               \
    git                \
    zsh                \
    curl               \
    gcc                \
    python3            \
    python3-pip        \
    python3-venv


RUN apt-get clean
RUN useradd -m -G sudo,dialout -s /usr/bin/zsh developer
RUN echo "developer:password" | chpasswd

USER developer
WORKDIR /home/developer
RUN git clone https://github.com/grml/grml-etc-core.git .grml-core
RUN echo "source ~/.grml-core/etc/zsh/zprofile" > .zprofile
RUN echo "source ~/.grml-core/etc/zsh/zshrc" > .zshrc
RUN echo "source ~/.grml-core/etc/zsh/zshenv" > .zshenv
RUN echo "source ~/.grml-core/etc/zsh/zlogin" > .zlogin
RUN echo "source ~/.grml-core/etc/zsh/zlogout" > .zlogout

USER root
WORKDIR /root
