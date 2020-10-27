#
# Made by Ivann LARUELLE / larueli on GitHub and Docker Hub
# decidim-nonroot on Docker Hub and GitHub
#
FROM ruby:2.6.3

LABEL maintainer="ivann.laruelle@gmail.com"

ENV RAILS_ENV=production
ENV DECIDIM_VERSION=0.22.0

RUN apt-get update && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    apt-get update && apt-get install -y nodejs imagemagick yarn libicu-dev postgresql-client openssl nano bash curl git && apt-get autoremove && \
    mkdir -m 770 /home/docker-user && \
    gem install bundler && gem install bootsnap && gem install listen && mkdir -m 770 /decidim-app && gem install decidim -v ${DECIDIM_VERSION} && decidim /decidim-app

WORKDIR /decidim-app

EXPOSE 3000

RUN echo "gem 'omniauth-cas'" >> Gemfile && echo "gem 'omniauth-facebook'" >> Gemfile && echo "gem 'omniauth-google-oauth2'" >> Gemfile && echo "gem 'omniauth-twitter'" >> Gemfile && \
    echo "gem 'figaro'" >> Gemfile && echo "gem 'daemons'" >> Gemfile && echo "gem 'delayed_job_active_record'" >> Gemfile && echo "gem 'wkhtmltopdf-binary'" >> Gemfile && \
    echo "gem 'wicked_pdf'" >> Gemfile && echo "gem 'decidim-consultations', '${DECIDIM_VERSION}'" >> Gemfile &&  echo "gem 'decidim-initiatives', '${DECIDIM_VERSION}'" >> Gemfile && \
    bundle install

COPY entrycheck /entrycheck.sh

RUN RAILS_ENV=production bin/rails generate wicked_pdf && \
    RAILS_ENV=production bin/rails generate delayed_job:active_record && \
    RAILS_ENV=production bin/rails assets:precompile && \
    RAILS_ENV=production bin/rails decidim:install:migrations && \
    RAILS_ENV=production bin/rails decidim_initiatives:install:migrations && \
    RAILS_ENV=production bin/rails decidim_consultations:install:migrations && \
    chmod +x /entrycheck.sh && chgrp -R 0 /decidim-app && chmod -R g=rwx /decidim-app

VOLUME /decidim-app/public/uploads
VOLUME /decidim-app/config

ENTRYPOINT ["/entrycheck.sh"]
