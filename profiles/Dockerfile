FROM aegypius/gentoo-amd64

# Declare which profile to use
#
#   1 : default/linux/amd64/13.0
#   2 : default/linux/amd64/13.0/selinux
#   3 : default/linux/amd64/13.0/desktop
#   4 : default/linux/amd64/13.0/desktop/gnome
#   5 : default/linux/amd64/13.0/desktop/gnome/systemd
#   6 : default/linux/amd64/13.0/desktop/kde
#   7 : default/linux/amd64/13.0/desktop/kde/systemd
#   8 : default/linux/amd64/13.0/developer
#   9 : default/linux/amd64/13.0/no-multilib
#  10 : default/linux/amd64/13.0/x32
#  11 : hardened/linux/amd64
#  12 : hardened/linux/amd64/selinux
#  13 : hardened/linux/amd64/no-multilib
#  14 : hardened/linux/amd64/no-multilib/selinux
#  15 : hardened/linux/amd64/x32
#  16 : hardened/linux/uclibc/amd64
#  17 : hardened/linux/musl/amd64
#
# ====================================
ENV PORTAGE_PROFILE 1

# Download the latest portage snapshot
# ====================================
ADD http://distfiles.gentoo.org/snapshots/portage-latest.tar.bz2 /portage-latest.tar.bz2
WORKDIR /usr
RUN tar -xpjf /portage-latest.tar.bz2
RUN rm /portage-latest.tar.bz2
RUN eselect profile set $PORTAGE_PROFILE
RUN emerge --regen --quiet

# Upgrade every installed packages
# ================================
RUN emerge --update --verbose --newuse --deep @world
RUN etc-update -p
RUN emerge --depclean

# Prepare latest kernel source
# ============================
WORKDIR /usr/src/linux
RUN make oldconfig
RUN make modules_prepare

# Adds /overlay to PORTDIR_OVERLAY
# ================================
VOLUME /overlay
WORKDIR /overlay
RUN echo 'PORTDIR_OVERLAY="/overlay"' >> /etc/portage/make.conf
