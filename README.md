[Admiral Ackbar's Code Emporium](aace)
==================

Setup
-----

* Install [VirtualBox](virtualbox)

		# apt-get install virtualbox

* Install [Vagrant](vagrant)

		# apt-get install vagrant

* Clone the repository and boot the VM:

		$ git clone git@github.com:marekl/code.litomisky.com.git
		$ cd code.litomisky.com
		$ vagrant up
	
* Point your browser to `localhost:4000`

Add a post
----------

* Once you have completed the setup and can view a local version of the site at `localhost:4000`, you can add a post with the following commands:

		$ vagrant ssh
		$ rake post title="Post Title Here"
		$ exit

* This will create a new post with the current date and the title you specified. The file will be created under `_posts`, find it there and add your content. The `rake post` command can also add other information to the post for you:

		# Usage: rake post title="A Title" [date="2012-02-09"] [tags=[tag1,tag2]] [author="author"]

* Once you are done with the post check that it looks correct on your local site and then commit and push it to GitHub. This will call a post commit hook to automatically deploy your changes to the live site.

Cleanup
-------

Remove all traces of the VM:

	$ vagrant destroy

Suspend the VM for a faster boot next time but more disk usage:

	$ vagrant suspend

FAQ
---
**Q.** The local version of the site isn't regenerating. What should I do?

**A.** This is an issue with Vagrant shared folders not passing file system events between the host and client OS. Run regen.sh to regenerate the site.

[aace]: http://code.litomisky.com/
[virtualbox]: https://www.virtualbox.org
[vagrant]: http://www.vagrantup.com