# Decidim on Docker

This container is made to be easy to use and to deploy, and secure enough for OpenShift.

## Features

* SSL/https support on port 8443 with custom SSL certificates, or automatic openssl generation
* All official decidim modules installed

> including optional _decidim-consultations_ and _decidim-initiatives_, with cronjobs configured for _decidim-initiatives_ to run every 30 mns

* Able to run as non root user (must be root group), so works in OKD, or OpenShift
* Mail sending via SMTP with SSL
* All available languages activated (en, ar, ca, de, es, eu, fi, fr, gl, hu, id, it, nl, no, pl, pt, ru, sv, tr, uk)
* Working outside the box with no complex config
* Latest decidim version (v.0.19.0)
* Daily run of metrics and open-data export
* OAuth (Facebook, Twitter, Google, CAS) support, with automatic activation
* Highly customizable with environment variables
* Automatic admin creation
* Ability to run your init scripts before starting the server

## How to use it ?

You'll need a working postgresql db working, with the `pg_trgm` extension. If you don't have one, we will see how to create one.

You'll need to configure env variables for the decidim image.

### 1. Download images

```
docker pull postgres:latest

docker pull larueli/decidim-nonroot:latest
```

### 2. Get a secret key base

You must generate a secret key base for Ruby, the system who makes decidim run. This key is used to encrypt some data, so you must keep it, and never change it otherwise you would have troubles to access to your data if you relaunch your decidim container.

You can generate one with openssl

```
sudo apt-get update && sudo apt-get install -y openssl
openssl rand -hex 64
```


### 3. Configure mail

Create a mailbox and look for its smtp settings in order to send mails to your users.


### 4. Prepare the env variables

There are **mandatory** variables, you'll see later how to define them :

* DATABASE : if you don't have a postgresql db, don't worry, we'll create it later

    + `DATABASE_HOST` : ip or domain name of the database host
    + `DATABASE_PORT` : the port of postgresql, usually 5432
    + `DATABASE_USERNAME` : the username
    + `DATABASE_PASSWORD` : the password associated to the username

* RAILS :

    + `SECRET_KEY_BASE` : the value found earlier with `openssl`. You must NOT change this value after the first launch, or recreate the database !

* SMTP

    + `SMTP_USERNAME` : the username used to connect to smtp server. Do **not** escape the `@` if there is one.
    + `SMTP_PASSWORD`
    + `SMTP_ADDRESS` : the address of the smtp server
    + `SMTP_PORT` : the port, usually 465 for secure smtp
    + `SMTP_DOMAIN` : if your mail address is _xyz@domain.org_, this will be _domain.org_

* DECIDIM

    + `DEC_ADMIN_EMAIL` : mail of the admin account to be created. Do **not** escape the `@`
    + `DEC_ADMIN_PASSWORD` : its **strong** password
    + `DEC_NAME` : the name of your decidim instance.
    + `DEC_MAIL` : the mail address used to send mail via SMTP. Do **not** escape the `@`

There are also facultatives variables :

* Social authentification :
    + Facebook :
      + `OMNIAUTH_FACEBOOK_APP_ID`
      + `OMNIAUTH_FACEBOOK_APP_SECRET`
    + Google :
      + `OMNIAUTH_GOOGLE_CLIENT_ID`
      + `OMNIAUTH_GOOGLE_CLIENT_SECRET`
    + Twitter :
      + `OMNIAUTH_TWITTER_API_KEY`
      + `OMNIAUTH_TWITTER_API_SECRET`
    + CAS :
      + `CAS_URL` : full url to CAS, with https
      + `CAS_LOGIN` : usually `/login`
      + `CAS_VALIDATE_URL` : usually `/serviceValidate`
      + `CAS_LOGOUT` : usually `/logout`
      + `CAS_UID_FIELD` : The user attribute unique identifier.
    
* GEOCODER (HereMaps) : 
    + `GEOCODER_LOOKUP_APP_ID`
    + `GEOCODER_LOOKUP_APP_CODE`

* Etherpad :
    + `ETHERPAD_SERVER`
    + `ETHERPAD_API_KEY`

### 5. Docker-compose example

Docker-compose is a tool from Docker to use several containers at the same time.

#### A. Create the folders receiving data

```
mkdir decidim && cd decidim
mkdir -m 777 ssl decidim-uploads db-data
```

#### B. In the decidim folder, create a file named `scriptdb.sh` and put the following code in it :

```
#!/bin/bash
set -e

psql -v ON_ERROR_STOP=1 --username "$POSTGRES_USER" <<-EOSQL
CREATE EXTENSION pg_trgm;
EOSQL
```

It will install in our postgresql db an extension used for decidim.

#### C. In the decidim folder, create a file named docker-compose.yml

```
#
# Made by Ivann LARUELLE / larueli on GitHub and Docker Hub
# decidim-nonroot on Docker Hub and GitHub
#
decidim:
    image: larueli/decidim-nonroot:latest
    ports:
      - "8080:8080"
      - "8443:8443"
    environment:
      - SECRET_KEY_BASE=14bf2dcb94d4967b03cfb31574d7b0d8752321321482f28bd1cf3bf010fe6d335b79b7d7651a30a82205556def6ecbe73e79a3ce4b33c625aa1c1e0003a4369b
      - DATABASE_USERNAME=decidim_user
      - DATABASE_PASSWORD=CHANGEMEEEEEE
      - DATABASE_HOST=db
      - DATABASE_PORT=5432
      - SMTP_USERNAME=test@mail.fr
      - SMTP_PASSWORD=myPASSWD
      - SMTP_ADDRESS=smtp.test.fr
      - SMTP_DOMAIN=test.fr
      - SMTP_PORT=465
      - DEC_NAME=My first decidim instance
      - DEC_MAIL=test@mail.fr
      - DEC_ADMIN_EMAIL=admin@test.fr
      - DEC_ADMIN_PASSWORD=aVerYStrONGPassWORD
    user: "1004:0"
    volumes:
      - ./decidim-uploads:/decidim-app/public/uploads
      - ./ssl:/decidim-app/ssl
    links:
      - db
db:
    image: postgres:latest
    environment:
      - POSTGRES_PASSWORD=CHANGEMEEEEEE
      - POSTGRES_USER=decidim_user
    volumes:
      - ./scriptdb.sh:/docker-entrypoint-initdb.d/scriptdb.sh
      - ./db-data:/var/lib/postgresql/data
```

then

```sudo docker-compose up -d```

#### D. Customize settings, SSL, and run your scripts

You can edit the environment variables to add features, as described earlier. You **must** change the `SECRET_KEY_BASE` and all the passwords.

You can add inside the `ssl` folder your certificate as `ssl.crt` and your private key as `ssl.key`. Both must be readable by the root group. The web service will take it into account when you will launch your container. It there is no certificate, it will creates one with `openssl` to allow HTTPS connections out-the-box.

You can mount your scripts inside the `/docker-entrypoint-initdecidim.d` folder. They will be ran after the automated config, but before connecting to the DB and starting the server.

## Help / issues

If you need help about my docker container, or if there is an issue, go to the [GitHub page of this projet](https://github.com/larueli/decidim-nonroot), and open an issue. You can contact me here : ivann.laruelle[at]gmail.com.

You can check the official documentation :
* [For the deployment and configuration](https://github.com/decidim/decidim/tree/master/docs)
* [For the common usage of the tool](https://decidim.org/docs/)
* [The official github](https://github.com/decidim/decidim)

### Known issues

* If you change the `DEC_ADMIN_*` variables and relaunch the container, it will create a new admin, and not removing the old one if it exists. You can delete it manually in the system panel.
* You tell me !

# Author

I am [Ivann LARUELLE](https://www.linkedin.com/in/ilaruelle/), engineering student in Networks & Telecommunications at the [Université de Technologie de Troyes](https://www.utt.fr/) in France, which is a public engineering university.

This tool was made for the students, as I am a student representative, and in collaboration with the UTT Net Group, an non profit organization which aims to [provide IT Service](https://ung.utt.fr/tech/sia) to all UTT students and student organizations.

Contact me for any issue : ivann.laruelle[at]gmail.com

# Github / Licence

The whole project is built from the [decidim official github](https://github.com/decidim/decidim).

My Dockerfile and build files are on my [larueli/decidim-nonroot github](https://github.com/larueli/decidim-nonroot) repos
