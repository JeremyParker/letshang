FROM centos:centos7

RUN yum install -y https://dl.fedoraproject.org/pub/epel/epel-release-latest-6.noarch.rpm
RUN yum clean all && yum update -y

ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

# Base tools
RUN yum install -y \
  curl \
  gcc \
  gcc-c++ \
  git \
  make \
  tar \
  which

RUN yum install -y \
  bzip2 \
  libtool \
  libxml2 \
  libxslt \
  nc.x86_64 \
  aspell \
  aspell-en \
  aspell-devel

RUN yum install -y openssl-devel readline-devel zlib-devel

# install ruby
RUN git clone https://github.com/rbenv/ruby-build.git && cd ruby-build && PREFIX=/usr/local ./install.sh
RUN ruby-build 2.5.0 /usr/local
RUN gem install --no-document bundler

# Dependencies for pretty much every Ruby app
RUN yum install -y \
  postgresql94-devel \
  rubygems \
  libcurl-devel \
  libxml2-devel \
  libxslt-devel

RUN gem install bundler

RUN mkdir /letshang
WORKDIR /letshang

ADD Gemfile /letshang/Gemfile
ADD Gemfile.lock /letshang/Gemfile.lock
ADD .bundle/config /letshang/.bundle/config

RUN gem --version

RUN bundle install

ADD . /letshang
