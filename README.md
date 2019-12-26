# Decidim on Docker

You'll find here the files used to build my Docker image for [decidim, free Open-Source participatory democracy for cities and organizations](https://decidim.org).

## Features

* SSL/https support on port 8443 with custom SSL certificates, or automatic openssl generation
* All official decidim modules installed

> including optional _decidim-consultations_ and _decidim-initiatives_, with cronjobs configured for _decidim-initiatives_ to run every 30 mns

* Able to run as non root user (must be root group), so works in OKD, or OpenShift, Kubernetes
* Mail sending via SMTP with SSL
* All available languages activated (en, ar, ca, de, es, eu, fi, fr, gl, hu, id, it, nl, no, pl, pt, ru, sv, tr, uk)
* Working outside the box with no complex config
* Latest decidim version (check tags)
* Daily run of metrics and open-data export
* OAuth (Facebook, Twitter, Google, CAS) support, with automatic activation
* Highly customizable with environment variables
* Ability to run your init scripts before starting the server

## How does it work ?

Feel free to check the Dockerfile to see how the image is built, and the entrycheck script to see what's executed inside your container when you run it.

## More info about the image

You can check [my DockerHub repo](https://hub.docker.com/repository/docker/larueli/decidim-nonroot).

# Author

I am [Ivann LARUELLE](https://www.linkedin.com/in/ilaruelle/), engineering student in Networks & Telecommunications at the [Université de Technologie de Troyes](https://www.utt.fr/) in France, which is a public engineering university.

This tool was made for the students, as I am a student representative, and in collaboration with the UTT Net Group, an non profit organization which aims to [provide IT Service](https://ung.utt.fr/tech/sia) to all UTT students and student organizations.

Contact me for any issue : ivann.laruelle[at]gmail.com

# Licence

You are free to download, use, modify, redistribute theses files. The only thing is that you must credit me and keep the header of the files.
