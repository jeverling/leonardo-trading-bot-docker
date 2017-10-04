FROM ubuntu:16.04

MAINTAINER Jesaja Everling <jeverling@gmail.com>

# apt-get will ask for input on keyboard layout otherwise: Setting up keyboard-configuration (1.108ubuntu15.3) ...
ENV DEBIAN_FRONTEND=noninteractive

RUN apt-get update && \
    apt-get install -y xpra openssh-server sudo unzip qt5-default && \
    apt-get clean && \
    apt-get -y autoremove && \
    rm -rf /var/lib/apt/lists/* /tmp/* /var/tmp/*

RUN mkdir /var/run/sshd
RUN sed -ri 's/^PermitRootLogin\s+.*/PermitRootLogin no/g' /etc/ssh/sshd_config
RUN sed -ri 's/UsePAM yes/UsePAM no/g' /etc/ssh/sshd_config
RUN echo "AllowUsers leonardo" >> /etc/ssh/sshd_config

RUN useradd -r -m leonardo
RUN echo 'leonardo:leonardo' | chpasswd
USER leonardo

RUN ssh-keygen -t rsa -N '' -f /home/leonardo/.ssh/id_rsa

WORKDIR /home/leonardo

RUN wget http://www.marginsoftware.de/downloads/leonArdo-linux.zip && \
    unzip leonArdo-linux.zip && \
    rm leonArdo-linux.zip


# this is a workaround for an issue I encountered on a VPS (due to SAN?): `line 13: ./leonArdo: Text file busy`
# Seems to be related to this: https://github.com/moby/moby/issues/9547
# Should not be necessary normally
RUN sed -ri 's/chmod \+x leonArdo/chmod +x leonArdo ; sync/g' /home/leonardo/leonArdo-linux/run-leonArdo.sh


RUN mkdir /home/leonardo/.leonardo
# we don't want this to be on ephemeral Docker filesystem
VOLUME /home/leonardo/.leonardo

WORKDIR /home/leonardo/leonArdo-linux

# we have to run sshd as root
USER root

COPY run_leonardo_in_xpra_and_start_sshd.sh /home/leonardo
RUN chmod +x /home/leonardo/run_leonardo_in_xpra_and_start_sshd.sh

EXPOSE 22

CMD /home/leonardo/run_leonardo_in_xpra_and_start_sshd.sh
