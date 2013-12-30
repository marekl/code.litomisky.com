---
layout: post
title: Use a Beaglebone Black or Raspberry Pi as a backup server
author : Marek Litomisky
tags : [backup, beaglebone, black, rsnapshot, rsync]
---

{% include JB/setup %}

This guide describes the process to configure a Raspberry Pi Model B or Beaglebone Black to as a backup server to backup Windows or Linux machines using rsnapshot and then to sync those backups across multiple backup servers using rsync.

This guide was written for Linux and tested under Ubuntu 13.04.

Considerations
--------------
The backup drives used will be formated as ext4 which Windows cannot understand by default. You can install a  [Windows ext4 driver][win-ext4-driver].

Required Hardware
-----------------

#### Raspberry Pi Model B

* Raspberry Pi Model B
* 2GB+ SD Card
* 2 Amp USB Micro power adapter
* USB hard drive with external power supply
* Optionaly a case to protect the Raspberry Pi

#### Beaglebone Black

* Beaglebone Black
* 2GB+ micro SD card
* 2 Amp 5 Volt power adapter for the Beaglebone Black
* USB hard drive with external power supply
* Optionaly a case to protect the Beaglebone Black

Setup Guide
-----------

* Install Arch Linux ARM on your device: (Click the Installation tab and follow the instructions)
  * [Raspberry Pi][raspberry-pi-archlinux]
  * [Beaglebone Black][beaglebone-black-archlinux]
    * When you extract the bootloader tarball onto the FAT16 partition of the micro SD card you will get permission errors. This is fine, keep going.
    * Make sure you install Archlinux Arm onto the eMMC! If you only install it onto the micro SD card, the next time your Beaglebone Black looses power and powers back up it will boot back into its original operating system.

* Connect your device to a network using an ethernet cable and power it up. You will need to find the IP address it was assigned by the DHCP server on your network. The default hostname is __alarm__.
* Once you have the IP you need to ssh in to the device:
		$ ssh root@ipaddress
  ssh will issue a warning about the key fingerprint. Type __yes__ and press`Enter`. When prompted for the password type in __root__ and hit `Enter`.

* Lets start by changing the __root__ password:
		$ passwd root
  Type in your new password twice when prompted. Make sure to choose a strong password, this device will store all your backup data!

* Next lets change the hostname to something more meaningful:
		$ nano /etc/hostname
  Replace the current hostname of __alarm__ with one of your choosing. Be descriptive.
  
  Press `Ctrl`+`O`, `Enter`, `Ctrl`+`X` to save and exit. The hostname will be updated the next time the device boots up.

* Update the system and install the packages we will need:
		$ pacman -Syu rsnapshot rsync sudo
  When asked if you want to proceed with the installation type __Y__ and press `Enter`.

* Now lets add the __backup__ user:
		$ useradd -m backup

* Create a password for the __backup__ user:
		$ passwd backup
  The process is identical to when we changed the password for root.

* Create a __sudo__ group and add the __backup__ user to it:
		$ groupadd sudo
        $ usermod -aG sudo backup

* Next we need to allow users in the __sudo__ group to use the sudo command:
		$ visudo
  This command will open the sudo configuration file in vi. Add the following line to the end of the file and save and exit:
  		%sudo ALL=(ALL) ALL

* Now that we have a new user with sudo privilidges it is time to secure the ssh server. We will do this by disabling root login and password authentication. This means that you will only be able to login to your backup server using a ssh key. Make sure to keep it safe!

* You can either use an existing ssh key or generate a new one. If you need to generate a key [this guide from Github can help][github-ssh-key-generation].

* Now lets login as __backup__:
		$ su backup

* Next we need to copy the public key over to the backup server. To start with we need to create a __.ssh__ directory in the backup users home directory:
		$ cd
        $ mkdir .ssh
        $ chmod 0700 .ssh

* To actually copy the public key we need to copy it from your local machine to the backup server. Exit the ssh session:
		$ exit

* Now you should be in a shell on your local machine. Navigate to the folder containing your public key and then use the following command to copy it over to your backup server. Replace __ipaddress__ with the actual IP address of your backup server. Your public key might also have a different filename.
		$ scp id_rsa.pub backup@ipaddress:.ssh/authorized_keys

* That's all it takes to enable ssh key login to your backup server. Lets make sure it works correctly. SSH into your backup server as the backup user. __You should not be asked to enter a password!__ If you have to enter a password, something went wrong.
		$ ssh backup@ipaddress

* Once you have ssh key authentication working correctly, it is time to disable password authentication. This helps improve the security of the ssh server. Edit __/etc/ssh/sshd_config__:
		$ sudo nano /etc/ssh/sshd_config
  Add the following lines to the bottom of the file and save and exit:
		PermitRootLogin no
        PermitEmptyPasswords no
        PasswordAuthentication no

* Now we have to restart the ssh server to activate the changes. Your existing ssh session will survive the restart but if something went wrong you may not be able to establish new sessions. __Do not close your current ssh session until you are sure the changes to the ssh server configuration were successful.__ Restart the ssh server:
		$ sudo service ssh restart

* Now open a new local shell and try to ssh into your backup server. If you can still login, you have successfully updated the sshd server settings.


* Restart?
* enable iptables?
* install fail2ban?
* configure usb drive
* configure rsnapshot
* configure rsync?

* http://spenserj.com/blog/2013/07/15/securing-a-linux-server/
* https://wiki.archlinux.org/index.php/Users_and_Groups
* https://help.github.com/articles/generating-ssh-keys#platform-linux

[win-ext4-driver]: http://www.paragon-software.com/home/extfs-windows/
[raspberry-pi-archlinux]: http://archlinuxarm.org/platforms/armv6/raspberry-pi
[beaglebone-black-archlinux]: http://archlinuxarm.org/platforms/armv7/ti/beaglebone-black
[github-ssh-key-generation]: https://help.github.com/articles/generating-ssh-keys#platform-linux