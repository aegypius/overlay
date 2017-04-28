# aegypius gentoo overlay

This is my personal gentoo overlay. I use it to customize some ebuilds to my needs

## Requirements

- Gentoo Linux

## Installation

### Using [standard method](https://wiki.gentoo.org/wiki//etc/portage/repos.conf)

You can setup this overlay by running this one-liner:

    curl -sL https://aegypius.github.io/overlay/aegypius.conf | sudo tee -a /etc/portage/repos.conf.d/aegypius.conf

### Using layman

Ensure you have [Layman](http://layman.sourceforge.net/) installed or install it using:

    emerge -v app-portage/layman

Add this overlay this:

    layman -o https://aegypius.github.io/overlay/repositories.xml -f -a aegypius

---
[![Build Status](https://travis-ci.org/aegypius/overlay.svg?branch=master)](https://travis-ci.org/aegypius/overlay)
