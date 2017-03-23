# Copyright (c) 2015-2016, Gregory M. Kurtzer. All rights reserved.
# 
# "Singularity" Copyright (c) 2016, The Regents of the University of California,
# through Lawrence Berkeley National Laboratory (subject to receipt of any
# required approvals from the U.S. Dept. of Energy).  All rights reserved.

BootStrap: debootstrap
OSVersion: jessie
MirrorURL: http://ftp.us.debian.org/debian/

%runscript
    seqlink "$@"


%post
    # need to create mount point for home dir
    mkdir /uufs
    mkdir /scratch
    cd /root

    apt-get update
    apt-get -y --force-yes install vim
    apt-get install -y --force-yes libatlas-base-dev

    # utility packages
    apt-get -y --force-yes install git wget zlib1g-dev
    # packages that SEQLink wants
    apt-get install -y --force-yes gcc g++ build-essential libbz2-dev swig

    # actual seqlink installation

    # install anaconda
    if [ -e Anaconda2-4.3.1-Linux-x86_64.sh ]; then
     rm Anaconda2-4.3.1-Linux-x86_64.sh
    fi
    wget https://repo.continuum.io/archive/Anaconda2-4.3.1-Linux-x86_64.sh
    bash Anaconda2-4.3.1-Linux-x86_64.sh -b -p /opt/anaconda2
    export PATH=/opt/anaconda2/bin:$PATH
    echo "PATH=/opt/anaconda2/bin:\$PATH" >> /environment
    echo "export PATH LD_LIBRARY_PATH" >> /environment

# trying stock python instead - anaconda uses different gcc which breaks cstatgen - did not work
#    apt-get install -y python2.7-dev pkg-config python-pip

    # install SEQLinkage
    if [ -e SEQLinkage ]; then
      rm -rf SEQLinkage
    fi
    git clone https://github.com/gaow/SEQLinkage.git
    cd SEQLinkage
    python setup.py install

# Anaconda built with gcc 4.4, SEQLinkage needs gcc 4.9 - get error 
# undefined symbol: __cxa_throw_bad_array_new_length
# this indicates building with 4.9 libstdc++.so but loading 4.8 
# /opt/anaconda2/lib/python2.7/site-packages/cstatgen/_cstatgen.so
# (in _cstatgen.so RPATH=/opt/anaconda2/lib )
# workaround - replace libstdc++.so.19 with libstdc++.so.20
   ana_lib=/opt/anaconda2/lib
   mv $ana_lib/libstdc++.so.6.0.19 $ana_lib/libstdc++.so.6.0.19.bak
   rm -rf $ana_lib/libstdc++.so $ana_lib/libstdc++.so.6
   cp /usr/lib/x86_64-linux-gnu/libstdc++.so.6.0.20 $ana_lib/.
   ln -s $ana_lib/libstdc++.so.6.0.20 $ana_lib/libstdc++.so.6
   ln -s $ana_lib/libstdc++.so.6.0.20 $ana_lib/libstdc++.so

# get the test directory so user can pull it
   cp -r /root/SEQLinkage/test /tmp

# remove big unneeded files
   rm -rf SEQLinkage
   rm -rf Anaconda2-4.3.1-Linux-x86_64.sh

%test

# assuming that we have the test files in /tmp/test
   # /environment does not seem to get set (2.2.1), so, set PATH
   export PATH=/opt/anaconda2/bin:$PATH
   # to run tests as user, need to do it in own directory with right permissions
   TESTDIR=/tmp/seqlink
   mkdir -p $TESTDIR
   cd $TESTDIR
   cp -r /tmp/test .
   cd test
   # just so we remember to use bash so we can use LMods shell function to wrap the container command
   echo "SHELL = /bin/bash" >> Makefile
   # finally run the tests
   make regular
   make missing
   cd
   rm -rf $TESTDIR
