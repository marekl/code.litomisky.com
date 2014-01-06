---
layout: post
title: Use a fixed custom login background in Ubuntu 13.04
author : Marek Litomisky
tags : [Ubuntu, login, background, customization]
---

Configure lightdm (the display manager) to use a custom static background for 
the login page instead of the default setting of using each users wallpaper as 
the background for their login page. This does not affect the lock screen. This 
should work for Ubuntu 12.04 and up. Based on [this askubuntu answer][1] for the 
background and [this askubuntu answer][2] for the dot grid.

Setup a custom login background
-------------------------------

* Open terminal and get root

		sudo -i

* Allow the lightdm user to create a connection to the X server

		xhost +SI:localuser:lightdm

* Switch user to lightdm

		su lightdm -s /bin/bash

* Turn off the dynamic switching of the background

		gsettings set com.canonical.unity-greeter draw-user-backgrounds 'false'

* Disable the dot grid on the login background

		gsettings set com.canonical.unity-greeter draw-grid false

* Change the default background with a picture of your choice

		gsettings set com.canonical.unity-greeter background '/foo/wallpaper.png'

* Prevent the lightdm user from creating a connection to the X server

		xhost -SI:localuser:lightdm

Revert the changes
------------------

* Open terminal and get root

		sudo -i

* Allow the lightdm user to create a connection to the X server

		xhost +SI:localuser:lightdm

* Switch user to lightdm

		su lightdm -s /bin/bash

* Turn on the dynamic switching of the background

		gsettings reset com.canonical.unity-greeter draw-user-backgrounds

* Enable the dot grid on the login background

		gsettings set com.canonical.unity-greeter draw-grid

* Change the default background to the default value

		gsettings reset com.canonical.unity-greeter background

* Prevent the lightdm user from creating a connection to the X server

		xhost -SI:localuser:lightdm

[1]: http://askubuntu.com/questions/64001/how-do-i-change-the-wallpaper-in-lightdm/64002#64002
[2]: http://askubuntu.com/questions/72620/how-do-i-remove-the-dots-from-the-lightdm-greeter/121620#121620