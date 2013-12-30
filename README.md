code.litomisky.com
==================

Setup
-----

* Install [VirtualBox](https://www.virtualbox.org)
* Install [Vagrant](http://www.vagrantup.com)
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

* This will create a new post with the current date and the title you specified. The file will be created under `_posts`, find it there and add your content.

* Once you are done with the post check that it looks correct on your local site and then commit and push it to GitHub. This will call a post commit hook to automatically deploy your changes to the live site.

Cleanup
-------

	$ vagrant destroy

To remove all traces of the VM or

	$ vagrant suspend

To keep the VM disk and memory for quick startup the next time.