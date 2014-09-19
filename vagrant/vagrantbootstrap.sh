#!/usr/bin/env bash

SITE_ROOT="/vagrant/"

VAGRANT_HOME="/home/vagrant"
BOOTSTRAP_ROOT="$VAGRANT_HOME/.vagrantbootstrap"

# Fix "stdin: is not a tty"
# 
# From: https://github.com/myplanetdigital/vagrant-ariadne/commit/dd0592d05d4f5c881640540fdc43d8396e00ddd7
#
# If last line is `mesg n`, replace with conditional.
if [ "`tail -1 /root/.profile`" = "mesg n" ]
then
  echo 'Fixing future `stdin: is not a tty` errors...'
  sed -i '$d' /root/.profile
  cat << 'EOH' >> /root/.profile
  if `tty -s`; then
    mesg n
  fi
EOH
fi

# Make sure bootstrap root exists
if [ ! -d $BOOTSTRAP_ROOT ];
then
	mkdir $BOOTSTRAP_ROOT
fi

# Configure if needed
if [ ! -f "$BOOTSTRAP_ROOT/STRAPPED" ];
then
	touch "$BOOTSTRAP_ROOT/STRAPPED"

	# Update first
	apt-get update 2>/dev/null
	
	# Install packages
	apt-get install vim curl unzip git make ruby1.9.3 rake -y 2>/dev/null
	
	# Install JSON gem
	gem install --no-rdoc --no-ri json
	
	# Install Jekyll
	gem install --no-rdoc --no-ri jekyll
	
	# Change directory to the site root
	cd $SITE_ROOT
	
	# Serve with Jekyll
	touch "$BOOTSTRAP_ROOT/jekyllOutput"
	jekyll serve --watch >> "$BOOTSTRAP_ROOT/jekyllOutput" 2>&1 &
fi