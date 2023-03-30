FROM ubuntu:22.04

ENV APP_HOME /var/local/ohcount
ENV RBENV_PATH /usr/local/rbenv

RUN apt-get update \
  && apt-get install -y git libpcre3 libpcre3-dev libmagic-dev gperf gcc ragel swig software-properties-common

RUN apt-get install -y curl make zlib1g-dev bzip2 libreadline-dev # ruby build dependencies.
RUN git clone https://github.com/rbenv/rbenv.git $RBENV_PATH \
  && git clone https://github.com/sstephenson/ruby-build.git $RBENV_PATH/plugins/ruby-build \
  && echo 'export PATH="/usr/local/rbenv/shims:/usr/local/rbenv/bin:/usr/local/rbenv/plugins/ruby-build/bin:$PATH"' >> ~/.bashrc \
  && echo 'eval "$(rbenv init -)"' >> ~/.bashrc \
  && . ~/.bashrc \
  && rbenv install 2.6.9 && rbenv global 2.6.9 \
  && rbenv rehash

RUN mkdir -p $APP_HOME
COPY . $APP_HOME

RUN cd $APP_HOME && . ~/.bashrc && ./build

WORKDIR $APP_HOME
