# Decidim on Docker

You'll find here the files used to build my Docker image for [decidim, free Open-Source participatory democracy for cities and organizations](https://decidim.org).

## Features

* All official decidim modules installed
> including optional _decidim-consultations_ and _decidim-initiatives_
* Able to run as non root user (must be root group), so works in OKD, or OpenShift, Kubernetes
* Latest decidim version (check tags)
* OAuth (Facebook, Twitter, Google, CAS) support
* Ability to run your init scripts before starting the server

## How does it work ?

You can use the provided docker-compose.yml file to see how the container works. Make sure to set the env var `RAILS_SERVE_STATIC_FILES` to `true` and the `RAILS_ENV` to `production` !

This image exposes port 3000 (no ssl, you have to provide SSL by yourself with a reverse proxy), and has two volumes `/decidim-app/config` and `/decidim-app/public/uploads`. You can simply edit your config inside your container and restart it in order to take effect.

### OpenShift

You may experience troubles with the config folder (`/decidim-app/config`) permissions, but this can be resolved by manually populating the volume (must be done only once).

1. Deploy it without attaching volumes. Copy the content of config folder on your personnal computer (by using oc) like `oc rsync decidim-prod-8-k94qd:/decidim-app/config/ config-decidim/`
2. Create a volume, and copy back the data you downloaded inside this volume. You have two ways : T
    * The openshift way : create a simple pod (webserver or anaything you want), attach this volume to it and copy back using oc.
    * The hard copy / scp way : connect directly to the machine hosting the data and copy the data of the config folder
3. Attach this volume to the pod and redeploy !

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
