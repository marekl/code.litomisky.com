---
layout: post
title: How to configure Ubuntu 13.04 for use with A Yubikey
author : Marek Litomisky
tags : [Ubuntu, Yubikey, 2-Factor, authentication]
---

Setup Ubuntu to require Yubikey Challenge-Response during authentication
------------------------------------------------------------------------

This will configure Ubuntu to check for the presence of the correct Yubikey 
using the Challenge-Response protocol during the authentication of any user in 
the yubikey group. The use of the Challenge-Response protocol allows 
authentication without Internet access but it is not usable for ssh access 
because it requires direct hardware access to the Yubikey. Based on [this wiki 
article][1] and [this forum thread][2].

### Requirements
* A Yubikey, get one from: [Yubico][3]
* A free slot on the Yubikey to be configured for Challenge-Response
* Ubuntu (Works with Windows, Mac OS, and other flavors of Linux as well, but 
  this guide is for Ubuntu)

### Issues
* Logins using a GUI without a terminal visible will show a Password Incorrect 
  error when Yubikey authentication fails even if the actual password was 
  correct. There is no indication that authentication failed because a Yubikey 
  is not connected. Logins in a terminal will correctly show a Yubikey error.
* If a login attempt is made without the Yubikey connected the next attempt will 
  also fail even if the Yubikey is connected during the second attempt. The 
  second attempt after the Yubikey is plugged in will work.

### Setup
* Start by making an account that will be able to login to the machine without a 
  Yubikey so if something goes wrong you can get in and reset the changes. Use 
  the following command to enable the root account so it can be used for this 
  purpose. (You can just add another account with sudo privileges (do not add it 
  to the yubikey group!) if you do not want to enable the root account). Make 
  sure to use a strong password as this account will not be making use of 
  2-Factor Authentication.

		sudo passwd root

* Add the Yubico PPA update your software sources

		sudo add-apt-repository ppa:yubico/stable
		sudo apt-get update

* Install the **libpam-yubico** package

		sudo apt-get install libpam-yubico

* Install the **yubikey-personalization** package (optionally also install 
  **yubikey-personalization-gui** if you want a gui to change the settings of 
  your Yubikey)

		sudo apt-get install yubikey-personalization

* Plug in your Yubikey and run the following command to configure slot 2 for Challenge-Response

		sudo ykpersonalize -2 -ochal-resp -ochal-hmac -ohmac-lt64 -oserial-api-visible

* Create the **yubikey** group

		sudo groupadd yubikey

* Add the users that should be authenticated using a Yubikey to the group

    	sudo usermod -aG yubikey username

* Create **/etc/pam.d/yubikey**

		sudo gedit /etc/pam.d/yubikey
		...
		auth [success=1 default=ignore] pam_succeed_if.so quiet user notingroup yubikey
		auth		    required	    pam_yubico.so mode=challenge-response

* Edit **/etc/pam.d/common-auth** and add an include for yubikey at the top of the file

		sudo gedit /etc/pam.d/common-auth
		...
		######################
		# Manually added block
		@include yubikey
		#####################

* Run this command to set the current user up for Yubikey login:

		ykpamcfg -2 -v

* Logout and log back in. You should still only be asked for your password but 
  Yubikey Challenge-Response authentication is happening behind the scenes. Try 
  logging in with your Yubikey unplugged to confirm you are unable to login.  


Automatically lock the screen when the Yubikey is unplugged
-----------------------------------------------------------

This guide will configure your PC to lock automatically whenever your Yubikey is 
unplugged.

### Requirements
* Successfully complete the previous guide

### Issues
* If the Yubikey is unplugged when the computer is woken (i.e. you move the 
  mouse or touch the keyboard and the screen turns on) the first login attempt 
  will fail. The second attempt will succeed as normal.

### Setup
* Install **finger**
	
		sudo apt-get install finger

* Create **/etc/udev/rules.d/yubikey-screenlock.rules**

		sudo gedit /etc/udev/rules.d/yubikey-screenlock.rules
		...
		ACTION=="remove", ENV{ID_VENDOR}=="Yubico", RUN+="/usr/local/bin/gnome-screensaver-lock"

* Create **/usr/local/bin/gnome-screensaver-lock**

		sudo gedit /usr/local/bin/gnome-screensaver-lock
		...
		#!/bin/sh
		# Locks the screen if a Yubikey is not plugged in

		getXuser() {
			user=`finger | grep -m1 ":$displaynum " | awk '{print $1}'`

			if [ x"$user" = x"" ]; then
					user=`finger| grep -m1 ":$displaynum" | awk '{print $1}'`
			fi
			if [ x"$user" != x"" ]; then
					userhome=`getent passwd $user | cut -d: -f6`
					export XAUTHORITY=$userhome/.Xauthority
			else
					export XAUTHORITY=""
			fi
		}

		if [ -z "$(lsusb | grep Yubico)" ] ; then
			for x in /tmp/.X11-unix/*; do
				displaynum=`echo $x | sed s#/tmp/.X11-unix/X## | sed s#/##`
				getXuser
				if [ x"$XAUTHORITY" != x"" ]; then
					# extract current state
					export DISPLAY=":$displaynum"
				fi
			done

			GNOME_SCREENSAVER_PROC=`ps xa | grep gnome-screensaver | head -n 1 | perl -p -e '$_=join(",", (split)[0]);'`
			export `grep -z DBUS_SESSION_BUS_ADDRESS /proc/$GNOME_SCREENSAVER_PROC/environ`

			logger "YubiKey Removed - Locking Workstation"
			su $user -c "/usr/bin/gnome-screensaver-command --lock"
		fi

* Make **/usr/local/bin/gnome-screensaver-lock** executable

		sudo chmod u+x /usr/local/bin/gnome-screensaver-lock

* Finished. When you unplug your Yubikey the screen will automatically lock.


[1]: https://vtluug.org/wiki/Yubikey#PAM_two-factor_HMAC-SHA1_authentication
[2]: http://forum.yubico.com/viewtopic.php?f=8&t=246
[3]: http://www.yubico.com/
