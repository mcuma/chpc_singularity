This builds bioBakery container running Ubuntu

Installation based on information at https://bitbucket.org/biobakery/biobakery/wiki/biobakery_advanced#rst-header-build-biobakery-google-cloud, taking their build_biobakery.sh and modifying it for our Ubuntu image. 

The main hurdles were:
- LinuxBrew will not install as root, so, had to create an user "brewuser", chown files to him, run all the brew commands (in brew_all.sh) as this user, and then chown back to root.
- many bioBakery commands set R_LIBS variable before calling the program to set path to program specific R libraries. R_LIBS is not being picked up by R. Thus we modify all these commands to replace R_LIBS with R_LIBS_USER, which R reads correctly.

Rough install info
- get the basic image with build_container.sh
 -- ran out of disk space during brew build of BioBakery at 8 GB, went to 16 GB
- wget https://bitbucket.org/biobakery/biobakery/downloads/biobakery-v1.7.tar.gz
- get biobakery-v1.7/google_cloud/build_biobakery.sh, and modify it (fairly heavily)
- get license from http://www.drive5.com/usearch/download_academic_site.html, install usearch
- run the bioBakery tests as user
- the bioBakery build though LinuxBrew is LONG - at least 2 hrs
- the tests take a while as well


Useful links:
bioBakery advanced install - https://bitbucket.org/biobakery/biobakery/wiki/biobakery_advanced
usearch license site - http://www.drive5.com/usearch/download_academic_site.html
