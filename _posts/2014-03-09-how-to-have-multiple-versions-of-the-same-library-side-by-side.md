---
layout: post
title: "How to Have Multiple Versions of OpenCV Side by Side"
description: ""
author: "krystof"
tags: [Linux, C++, Ubuntu, OpenCV, CMake]
---
{% include JB/setup %}

This tutorial will show you how you can have different versions of the same library side by side such that it's easy to change which version your code uses.

For example, I work a lot with OpenCV, the computer vision library. I like to be able to try out different features in the trunk version of the library, but prefer to use a stable release in production settings. It's actually pretty easy to have both versions on your computer, and select which one you'd like to use at compile time. 

The following assumes you're on a Linux machine. I'll use OpenCV as an example, but the concept applies to any library.


## Set up Both Versions of OpenCV

The big idea is that you don't want to "install" OpenCV into the system's default directories (/usr/lib or /usr/local/lib), since each version would place itself into an "opencv" directory, creating a big ol' mess.

I like to have a "libs" directory right under my home directory.
In this directory, create a separate directory for each OpenCV version. Let's say doing this, I created two directories:

	~/libs/opencv-trunk
	~/libs/opencv-2.4.8

Let's go through the compilation process for the trunk version of OpenCV:

1. Create the directory where you want the output files to go:

		cd ~/libs/opencv-trunk
		mkdir release
		cd release
		mkdir installed

	I'll put mine under ~/libs/opencv-trunk/release/installed

2. Tell CMake your compilation options

		cmake -DCMAKE_INSTALL_PREFIX=/home/krystof/libs/opencv-trunk/release/installed -DCMAKE_BUILD_TYPE="Release" .. 

	CMAKE_INSTALL_PREFIX is the directory where you want the final output files. I'm also telling CMake to compile the Release (optimized) version of the library; you might (and I do) want to have Release and Debug versions available.

3. Compile!

		make install

	You can look under the install directory to verify that all the library files were created there.



## Create a Simple Test Program

Let's make sure our process worked.

Here's a simple program that prints the running OpenCV version:

main.cpp:

	#include <iostream>
	#include "opencv2/core/version.hpp"

	int main(int argc, char ** argv)
	{
	  std::cout << "OpenCV version: "
				<< CV_MAJOR_VERSION << "." 
				<< CV_MINOR_VERSION << "."
				<< CV_SUBMINOR_VERSION
				<< std::endl;
	  return 0;
	}


Makefile:

	CPP = g++

	# OpenCV trunk
	CPPFLAGS = -L/home/krystof/libs/opencv-trunk/release/installed/libs \
		   -I/home/krystof/libs/opencv-trunk/release/installed/include

	# Opencv 2.4.8
	#CPPFLAGS = -L/home/krystof/libs/opencv-2.4.8/release/installed/libs \
		   -I/home/krystof/libs/opencv-2.4.8/release/installed/include

	all: test

	test: main.cpp
		$(CPP) $(CPPFLAGS) $^ -o $@


Make sure you adjust the paths in the Makefile to match your own, based on where you installed the different OpenCV versions. Based on which CPPFLAGS line in the Makefile you leave in, you should get one of the following outputs:

	OpenCV version: 2.4.8

or

	OpenCV version: 3.0.0

3.0.0 is the output from the trunk version here.

So there you go! All you have to do is change one line in a Makefile, and your code gets compiled with different versions of OpenCV!
