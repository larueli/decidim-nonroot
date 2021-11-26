[![Build Status](https://github.com/larueli/decidim-nonroot/actions/workflows/main.yml/badge.svg)](https://github.com/larueli/decidim-nonroot/actions/workflows/main.yml)

# Decidim on Docker

You'll find here the files used to build my Docker image for [decidim, free Open-Source participatory democracy for cities and organizations](https://decidim.org).

## Features

* All official decidim modules installed
> including optional _decidim-consultations_ and _decidim-initiatives_ and _decidim-conferences_
* Able to run as non root user (must be root group), so works in OKD/OpenShift
* Latest decidim version (check tags)
* Various omniauth strategies added (facebook, twitter, twitter, keycloak, openid, saml) and [decidim-ldap](https://github.com/diputacioBCN/decidim-diba) installed
* Ability to run your init scripts before starting the server
* Bundled with [docker-compose-wait](https://github.com/ufoscout/docker-compose-wait) which allow to wait for db to start

## How does it work ?

You can use the provided docker-compose.yml file to see how the container works. Make sure to set the env var `RAILS_SERVE_STATIC_FILES` to `true` and the `RAILS_ENV` to `production` !

This image exposes port 3000 (no ssl, you have to provide SSL by yourself with a reverse proxy), and has two volumes `/decidim-app/config` and `/decidim-app/public/uploads`. You can simply edit your config inside your container and restart it in order to take effect.

You can put your scripts with a volume mounted on `/docker-entrypoint-initdecidim.d`

## After deployment

1. You can create an admin from the terminal

```
bin/rails console
> email = "test@email.com"
> password = "mystrongpassword"
> user = Decidim::System::Admin.new(email: email, password: password, password_confirmation: password)
> user.save!
```

2. You can configure it as you wish ! The decidim doc about [installation](https://docs.decidim.org/en/install/) and [configuration](https://docs.decidim.org/en/configure/) is very complete.

## FAQ

### ERROR Access denied at boot of container

Make sure all the config volume of decidim is owned by the user running in the container (`10520` in the docker-compose example). To be sure, run
```
sudo chown -R 10520 /var/lib/docker/volumes/decidim-nonroot_decidim-config/_data
```

### I don't have any assets (css, js, ...) served !

Make sure the decidim container has the env var `RAILS_SERVE_STATIC_FILES` set to `true` and the `RAILS_ENV` set to `production`

## More info about the image

You can check [my DockerHub repo](https://hub.docker.com/repository/docker/larueli/decidim-nonroot).

# Author

I am [Ivann LARUELLE](https://www.linkedin.com/in/ilaruelle/), engineering student in Networks & Telecommunications at the [Université de Technologie de Troyes](https://www.utt.fr/) in France, which is a public engineering university.

This tool was made for the students, as I am a student representative, and in collaboration with the UTT Net Group, an non profit organization which aims to [provide IT Service](https://ung.utt.fr/tech/sia) to all UTT students and student organizations.

Contact me for any issue : ivann[at]laruelle.me

# Licence

MIT
