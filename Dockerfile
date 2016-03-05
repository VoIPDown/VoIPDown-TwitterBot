FROM ruby:2.3
MAINTAINER zakelfassi

ADD ./code /code
WORKDIR /code

RUN gem install chatterbot

CMD ruby VoIPDown_MA.rb