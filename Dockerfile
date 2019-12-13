#
# Made by Ivann LARUELLE / larueli on GitHub and Docker Hub
# decidim-nonroot on Docker Hub and GitHub
#
FROM ruby:2.6.3

LABEL maintainer="ivann.laruelle@gmail.com"

ENV RAILS_ENV=production

RUN apt-get update && apt-get install -y nodejs cron imagemagick libicu-dev postgresql-client openssl nano bash curl git && apt-get autoremove && \
    echo "root" > /etc/cron.allow && echo "docker-user" >> /etc/cron.allow && cron && mkdir -m 770 /home/docker-user && \
    gem install bundler && gem install passenger && mkdir -m 770 /decidim-app && passenger-install-nginx-module --auto --auto-download && gem install decidim && decidim /decidim-app

WORKDIR  /decidim-app

RUN echo "gem 'omniauth-cas'" >> Gemfile && echo "gem 'figaro'" >> Gemfile && echo "gem 'daemons'" >> Gemfile && echo "gem 'delayed_job_active_record'" >> Gemfile && \
    bundle install && rails generate delayed_job:active_record && \
    sed -i "s/  config.available_locales = \[:en, :ca, :es\]/  config.available_locales = \[:en, :ar, :ca, :de, :es, :eu, :fi, :fr, :gl, :hu, :id, :it, :nl, :no, :pl, :pt, :ru, :sv, :tr, :uk\]/g" config/initializers/decidim.rb && \
    echo "gem 'wkhtmltopdf-binary'" >> Gemfile && echo "gem 'wicked_pdf'" >> Gemfile && bundle install && rails generate wicked_pdf && \
    echo "gem 'decidim-consultations'" >> Gemfile && echo "gem 'decidim-initiatives'" >> Gemfile && bundle install && rails decidim_initiatives:install:migrations && rails decidim_consultations:install:migrations && \
    rails assets:precompile RAILS_ENV=production && chmod -R 770 /decidim-app && chmod -R g=rwx /usr/local/bundle/gems/decidim-core* && chmod -R g=rwx /usr/local/bundle/gems/omniauth-cas*

COPY nginx.conf /opt/nginx/conf/nginx.conf
COPY entrycheck /entrycheck.sh

RUN chgrp -R 0 /opt/nginx && chmod -R g=rwx /opt/nginx && \
    chgrp -R 0 /var/cache && chmod -R g=rwx /var/cache && \
    chgrp -R 0 /var/run && chmod -R g=rwx /var/run && \
    chmod g+w /etc/passwd && chmod +x /entrycheck.sh

EXPOSE 8080
EXPOSE 8443

VOLUME /decidim-app/public/uploads
VOLUME /decidim-app/ssl

ENTRYPOINT ["/entrycheck.sh"]
