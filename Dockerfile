FROM ruby:3.2.0
LABEL maintainer="hz@muszaki.info"

RUN curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add -
RUN apt-get update -qq && \
    apt-get install -y -qq apt-transport-https postgresql-client && \
    apt-get remove yarn
RUN curl -sL https://deb.nodesource.com/setup_14.x | bash -
RUN echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list
RUN sh -c 'echo "deb [arch=amd64] http://dl.google.com/linux/chrome/deb/ stable main" >> /etc/apt/sources.list.d/google.list'
RUN wget -q -O - https://dl-ssl.google.com/linux/linux_signing_key.pub | apt-key add -
RUN apt-get update && apt-get install -y -qq nodejs yarn google-chrome-stable
RUN printf "install: -N\nupdate: -N\n" >> ~/.gemrc

RUN mkdir /myapp
WORKDIR /myapp

COPY Gemfile /myapp/Gemfile
COPY Gemfile.lock /myapp/Gemfile.lock
RUN gem install bundler && bundle install -j "$(getconf _NPROCESSORS_ONLN)" --retry 5

COPY package.json /myapp/package.json
COPY yarn.lock /myapp/yarn.lock

RUN yarn install
