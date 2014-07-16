---
layout: post
title: Disable the global menu in Ubuntu 13.04
author : Marek Litomisky
tags : [Ubuntu, Gobal Menu, customization]
---

Using the following steps you can disable the global menu. There are some issues 
with this approach so read the issues list before continuing. This guide is 
based on [this web upd8 article][1] and [this blog post][2].

### Issues

* Maximized applications still have the window controls (i.e. the close, 
  minimize, and resize buttons) on the global menu and you need to hover over 
  the global menu to access them. Non-maximized applications do not have this 
  issue.
* Some applications will still continue to use the global menu after this 
  modification. These need to be fixed manually. In Firefox, for example, a 
  plugin needs to be disabled.

### Disable the global menu

* Disable global menu integration in gnome apps (Most importantly, nautilus)

		gsettings set org.gnome.settings-daemon.plugins.xsettings overrides '@a{sv} {"Gtk/ShellShowsAppMenu": <int32 0>}'

* Create **/etc/X11/Xsession.d/81ubuntumenuproxy**
		
		sudo gedit /etc/X11/Xsession.d/81ubuntumenuproxy
		...
		export UBUNTU_MENUPROXY=0

* Restart your computer

* If any applications still use the global menu they probably use some 
  alternative integration mechanism and need to be dealt with individually. In 
  Firefox the **Global Menu Bar Integration** plugin needs to be disabled.

### Re-enable the global menu

* Delete **/etc/X11/Xsession.d/81ubuntumenuproxy**

		sudo rm /etc/X11/Xsession.d/81ubuntumenuproxy

* Re-enable global menu integration in gnome apps

		gsettings set org.gnome.settings-daemon.plugins.xsettings overrides '@a{sv} {}'

* Restart your computer

* Re-enable the global menu integration plugins for any applications that use an 
  alternative integration mechanism.

[1]: http://www.webupd8.org/2013/02/how-to-disable-gnome-shell-appmenu.html
[2]: http://rhubbarb.wordpress.com/2012/06/13/disable-ubuntu-unity-global-menu-bar/