#
# Ubuntu Dockerfile
#
# https://github.com/dockerfile/ubuntu
#

# Pull base image.
FROM ubuntu:14.04

# Install.
RUN \
  sed -i 's/# \(.*multiverse$\)/\1/g' /etc/apt/sources.list && \
  apt-get update && \
  apt-get -y upgrade && \
  apt-get install -y build-essential pkg-config apt-utils libncurses-dev libreadline-dev sqlite3 && \
  apt-get install -y git wget mercurial libssl-dev libfreetype6-dev libxft-dev libsqlite3-dev openssl && \
  apt-get install -y libjpeg-dev liblapack-dev gfortran

ADD ./PhotoTest.ipynb /root/PhotoTest.ipynb
ADD ./Pokemon.ipynb /root/Pokemon.ipynb

# Set environment variables.
ENV HOME /root

# Define working directory.
WORKDIR /root

RUN hg clone https://hg.python.org/cpython -r v2.7.10
RUN git clone https://github.com/dimart/pokemon_recognition.git

RUN set -x \
    && cd /root/cpython/ \
    && ./configure \
    && make \
    && make install \
    && python -m ensurepip \
    && pip install pip --upgrade \
    && pip install virtualenv --upgrade \
    && pip install jupyter[all] --upgrade \
    && pip install matplotlib --upgrade \
    && pip install Pillow --upgrade \
    && pip install SciPy --upgrade \
    && pip install sklearn --upgrade \
    && pip install bunch --upgrade \
    && rm -rf /root/cpython/.hg \
    && cd /root/
 
EXPOSE 8888

# Define default command.
#CMD ["/usr/local/bin/jupyter notebook --no-browser --port 8888 --ip=*"]
