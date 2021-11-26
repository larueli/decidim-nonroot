#
# Made by Ivann LARUELLE / larueli on GitHub and Docker Hub
# decidim-nonroot on Docker Hub and GitHub
#
ARG RUBY_VERSION=2.7.1
FROM ruby:${RUBY_VERSION}

LABEL maintainer="ivann.laruelle@gmail.com"

ENV RAILS_ENV=production
ARG DECIDIM_VERSION=0.25.2
ENV DECIDIM_VERSION=${DECIDIM_VERSION}

ARG DOCKER_COMPOSE_WAIT_VERSION=2.9.0
ENV DOCKER_COMPOSE_WAIT_VERSION=${DOCKER_COMPOSE_WAIT_VERSION}
ADD https://github.com/ufoscout/docker-compose-wait/releases/download/${DOCKER_COMPOSE_WAIT_VERSION}/wait /usr/local/bin/wait-hosts

COPY entrycheck /entrycheck.sh

RUN chmod uga+x /usr/local/bin/wait-hosts && apt-get update && curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | apt-key add - && \
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | tee /etc/apt/sources.list.d/yarn.list && \
    curl -sL https://deb.nodesource.com/setup_16.x | bash && \
    apt-get update && apt-get install -y nodejs imagemagick yarn libicu-dev postgresql-client openssl nano bash curl git && apt-get autoremove && \
    mkdir -m 770 /home/docker-user && \
    gem install bundler && gem install bootsnap && gem install listen && mkdir -m 770 /decidim-app && gem install decidim -v ${DECIDIM_VERSION} && decidim /decidim-app && \
    git clone https://github.com/diputacioBCN/decidim-diba.git && mv decidim-diba/decidim-ldap /decidim-app/decidim-ldap && \
    cd /decidim-app && \
    echo "gem 'omniauth-facebook'" >> Gemfile && echo "gem 'omniauth-twitter'" >> Gemfile && \
    echo "gem 'omniauth-keycloak'" >> Gemfile && echo "gem 'omniauth-openid'" >> Gemfile && echo "gem 'omniauth-saml'" >> Gemfile && \
    echo "gem 'figaro'" >> Gemfile && echo "gem 'daemons'" >> Gemfile && echo "gem 'delayed_job_active_record'" >> Gemfile && echo "gem 'wkhtmltopdf-binary'" >> Gemfile && \
    echo "gem 'decidim-consultations', '${DECIDIM_VERSION}'" >> Gemfile && echo "gem 'decidim-initiatives', '${DECIDIM_VERSION}'" >> Gemfile && \
    echo "gem 'decidim-conferences', '${DECIDIM_VERSION}'" >> Gemfile && echo "gem 'decidim-ldap', path: 'decidim-ldap'" >> Gemfile && \
    bundle install && \
    RAILS_ENV=production bin/rails generate wicked_pdf && \
    RAILS_ENV=production bin/rails generate delayed_job:active_record && \
    RAILS_ENV=production bin/rails assets:precompile && \
    RAILS_ENV=production bin/rails decidim:install:migrations && \
    RAILS_ENV=production bin/rails decidim_initiatives:install:migrations && \
    RAILS_ENV=production bin/rails decidim_ldap:install:migrations && \
    RAILS_ENV=production bin/rails decidim_consultations:install:migrations && \
    chmod +x /entrycheck.sh && chgrp -R 0 /decidim-app && chmod -R g=u /decidim-app && chgrp -R 0 /usr/local/bundle && chmod -R g=u /usr/local/bundle && \
    chown -R 0 "/.npm" && chmod -R g=u "/.npm" && \
    cp -rf /decidim-app/config /tmp/decidim-config

VOLUME /decidim-app/public/uploads
VOLUME /decidim-app/config
WORKDIR /decidim-app
EXPOSE 3000
USER 15200:0

ENTRYPOINT ["/entrycheck.sh"]
