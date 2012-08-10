#!/bin/sh

# install dependencies
sudo aptitude install apache2-mpm-itk gcc mono-gmcs g++ guile-1.8 ghc lua5.1 \
                      ocaml php5 python ruby ruby1.9.3 scala racket golang \
                      openjdk-6-jdk python-pip gcc-multilib xdg-utils nodejs \
                      npm make python-webpy python-libapparmor apparmor \
                      libapache2-mod-wsgi

# install DMD (not available in apt)
wget http://ftp.digitalmars.com/dmd_2.060-0_i386.deb
sudo dpkg -i dmd_2.060-0_i386.deb
rm dmd_2.060-0_i386.deb
