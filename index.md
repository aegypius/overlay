---
layout: default
title: aegypius/overlay @ GitHub
---
[![Wercker](https://img.shields.io/wercker/ci/53da278938296a86630000b9.svg?style=flat-square)]()
[![GitHub stars](https://img.shields.io/github/stars/aegypius/overlay.svg?style=flat-square)]()

## Usage

### Using [standard method](https://wiki.gentoo.org/wiki//etc/portage/repos.conf)

You can setup this overlay by running this one-liner:

    curl -sL https://aegypius.github.io/overlay/aegypius.conf | sudo tee -a /etc/portage/repos.conf.d/aegypius.conf

### Using layman

Add this overlay to you [Layman](http://layman.sourceforge.net/) overlays with:

    $ layman -o http://aegypius.github.io/overlay/repositories.xml -f -a aegypius

## Authors

- [@aegypius](https://github.com/aegypius)

## Download

You can download this project either [zip](https://github.com/aegypius/overlay/zipball/master) or [tar](https://github.com/aegypius/overlay/tarball/master) format.

You can also clone this project with [git](http://git-scm.com) by running:

    $ git clone git://github.com/aegypius/overlay
