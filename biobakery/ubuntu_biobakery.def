# Copyright (c) 2015-2016, Gregory M. Kurtzer. All rights reserved.
# 
# "Singularity" Copyright (c) 2016, The Regents of the University of California,
# through Lawrence Berkeley National Laboratory (subject to receipt of any
# required approvals from the U.S. Dept. of Energy).  All rights reserved.

BootStrap: debootstrap
OSVersion: xenial
MirrorURL: http://us.archive.ubuntu.com/ubuntu/


%runscript
    echo "This is what happens when you run the container..."


%post
    # need to create mount point for home dir
    mkdir /uufs
    mkdir /scratch
    cd /root
    echo $PATH

    sed -i 's/$/ universe/' /etc/apt/sources.list
    apt-get update
    apt-get -y --force-yes install vim
    apt-get install -y --force-yes libatlas-base-dev

    #MC issue with locale (LC_ALL, LANGUAGE), to get it right:
    locale-gen "en_US.UTF-8"
    dpkg-reconfigure locales
    export LANGUAGE="en_US.UTF-8"
    echo 'LANGUAGE="en_US.UTF-8"' >> /etc/default/locale
    echo 'LC_ALL="en_US.UTF-8"' >> /etc/default/locale

    # update all packages
    apt-get dist-upgrade --yes
    
    # packages required for deb building and installation
    apt-get install -y --force-yes mercurial git gdebi-core python-pip
    pip install setuptools --upgrade
    
    # install dos2unix
    apt-get install dos2unix -y --force-yes 
    
    # FFTW3 with hope that numpy may pick it
    apt-get install libfftw3-dev libtiff5-dev -y --force-yes

    # install dependencies for homebrew
    apt-get install -y --force-yes  ruby-full
    
    #MC install additional dependencies
    apt-get install -y software-properties-common python-software-properties apt-transport-https
    # install the latest version of r
    add-apt-repository 'deb https://cloud.r-project.org/bin/linux/ubuntu xenial/'
    gpg --keyserver hkp://keyserver.ubuntu.com:80 --recv-keys E084DAB9
    gpg -a --export E084DAB9 | apt-key add -
    apt-get update
    apt-get install r-base -y
    
    
    # install dependencies for numpy and matplotlib
    apt-get install -y python2.7-dev pkg-config
    
    # install java openjdk for biobakery tools
    apt-get install -y openjdk-8-jre
    
    #MC some more dependencies - for bowtie2
    apt-get install -y libtbb-dev
    
    #MC some more dependencies - lefse test needs wget
    apt-get install -y wget

    # install homebrew, not as root as no longer allowed as of Nov 2016
    # then update to get the latest version
    # next move executable/library so install (plus Cellar when added) is in /usr/local/bin
    # this is the location required to use bottles
    git clone https://github.com/Linuxbrew/linuxbrew.git /opt/linuxbrew
    
    #MC need to create an user to install the brew packages
    useradd -m brewuser

    chown -R brewuser /opt/linuxbrew
    #MC first su to brewuser to do the brew update (perhaps not really necessary to do update right after git clone)
    chown -R brewuser /usr/local/
    #MC this cant run as root - so continue as an user
    # get error whenever run this the first time, but, second time it starts up fine
    # some hacky solutions to this are here: https://discuss.circleci.com/t/brew-update-command-fails/5211/4
    # but none of them work, so just run update twice, ignoring its first error
    su -c '/opt/linuxbrew/bin/brew update || true ; /opt/linuxbrew/bin/brew update  ' brewuser

    # back to root to do the moving below
    mv /opt/linuxbrew/bin/brew /usr/local/bin/
    mv /opt/linuxbrew/Library /usr/local/
    chown -R brewuser /usr/local/

    #MC ---- now su to brewuser to install all the brew packages
    # su commands dont start from the user home dir
    cd /home/brewuser
    # install freetype dependency which needs to be installed
    # from source (instead of a bottle) for this platform
    su -c 'brew install freetype --build-from-source' brewuser
    
    # add the biobakery tool formulas
    su -c 'brew tap biobakery/biobakery' brewuser
    
    # download all tool suite resources prior to install
    # this allows for a retry incase a download fails
    # this prevents install errors due to download time out errors
    # if an error occurs, exit from this script
    # fetch requires initial dependency tap
    su -c 'brew tap homebrew/science' brewuser
    su -c 'brew tap homebrew/dupes' brewuser
    su -c 'brew fetch biobakery_tool_suite --retry --deps || exit 1' brewuser
    #MC this takes a while ....
    
    # install biobakery tool suite
    su -c 'brew install biobakery_tool_suite' brewuser
    #MC crash in bowtie2 build - missing tbb/mutex.h - getting tbb via apt-get above

    chown -R root /usr/local/
    echo $PATH
    # complaint that humann2_databases is not found
    export PATH=/usr/local/bin:$PATH
    
    # install humann2 utility mapping files and larger demo chocophlan database
    humann2_databases --download utility_mapping full /opt/humann2_databases/
    humann2_databases --download chocophlan DEMO /opt/humann2_databases/
    
    # Looks like R_LIBS is not getting passed to R, need to replace R_LIBS with R_LIBS_SITE or R_LIBS_USER
    sed -ie 's/R_LIBS=/R_LIBS_USER=/g' /usr/local/bin/*.py
    sed -ie 's/R_LIBS=/R_LIBS_USER=/g' /usr/local/bin/*.R

    # ---------------------------------------------------------------
    # install R packages for visualization
    # ---------------------------------------------------------------
    
    # install R packages to root R library
    R -q -e "install.packages('vegan',repos='http://cran.r-project.org')"
    R -q -e "install.packages('ggplot2',repos='http://cran.r-project.org')"
    
    # install dependencies of EBImage (a dependency of ggtree) and then install ggtree
    R -q -e "source('https://bioconductor.org/biocLite.R'); biocLite('EBImage'); biocLite('ggtree')"
    
    # printf '\n\n\nbioBakery install complete.\n\nbioBakery dependencies that require licenses are not included. Refer to the instructions in the bioBakery documentation for more information: https://bitbucket.org/biobakery/biobakery/wiki/biobakery_basic#rst-header-install-biobakery-dependencies .\n\n'

    # licensed program - may need new license 
    # need to get this first http://www.drive5.com/usearch/download_academic_site.html
    USEARCH_URL="http://drive5.com/cgi-bin/upload3.py?license=2017031414422118742"
    wget -O /usr/local/bin/usearch $USEARCH_URL
    chmod 111 /usr/local/bin/usearch

    echo "
      export PATH=/usr/local/bin:$PATH
      export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
    " >> /environment

%test
    # /environment does not seem to be passed to %test
    export PATH=/usr/local/bin:$PATH
    export LD_LIBRARY_PATH=/usr/local/lib:$LD_LIBRARY_PATH
    biobakery_demos --tool all --mode test --threads 4
    
