############################################################
# Dockerfile to run appium for android devices
############################################################

FROM ubuntu:14.04
MAINTAINER Andreas Lüdeke

RUN apt-get update
RUN apt-get install -y wget

# ruby installation

RUN set -ex \
	&& buildDeps=' \
		ruby \
	' \
	&& apt-get update \
	&& curl -fSL -o ruby.tar.gz "http://cache.ruby-lang.org/pub/ruby/2.0/ruby-2.0.0-p481.tar.gz" \
	&& tar -xvzf ruby-2.0.0-p481.tar.gz
	&& rm ruby-2.0.0-p481.tar.gz
        && cd ruby-2.0.0-p481/                                                     
        && ./configure --prefix=/usr/local  
        && make
        && make install 

# install Android SDK dependencies
RUN apt-get install -y openjdk-7-jre-headless lib32z1 lib32ncurses5 lib32bz2-1.0 g++-multilib
RUN apt-get install -y python-setuptools python-dev build-essential

RUN easy_install supervisor pip
ADD requirements.txt ./
RUN pip install -r requirements.txt

# Main Android SDK
RUN wget -qO- "http://dl.google.com/android/android-sdk_r23.0.2-linux.tgz" | tar -zxv -C /opt/
RUN echo y | /opt/android-sdk-linux/tools/android update sdk --all --filter platform-tools,build-tools-20.0.0 --no-ui --force

ENV ANDROID_HOME /opt/android-sdk-linux

RUN apt-get -y install software-properties-common
RUN add-apt-repository ppa:chris-lea/node.js
RUN apt-get update
RUN apt-get -y install nodejs

RUN mkdir /opt/appium
RUN useradd -m -s /bin/bash appium
RUN chown -R appium:appium /opt/appium

USER appium
ENV HOME /home/appium

RUN cd /opt/appium && npm install appium

EXPOSE 4723
CMD /opt/appium/node_modules/appium/bin/appium.js
