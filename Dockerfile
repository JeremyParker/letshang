FROM ruby:2.5.0

ENV LANG en_US.UTF-8
ENV LC_ALL en_US.UTF-8

RUN curl --silent --location https://deb.nodesource.com/setup_8.x | bash -
RUN apt-get update && apt-get install -y nodejs

RUN gem install bundler

ENV INSTALL_PATH /var/opt/app/letshang
RUN mkdir -p $INSTALL_PATH
WORKDIR $INSTALL_PATH

ADD Gemfile Gemfile
ADD Gemfile.lock Gemfile.lock
ADD .bundle/config .bundle/config

RUN bundle install

CMD bundle exec rails server
