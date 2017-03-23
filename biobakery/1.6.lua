-- -*- lua -*-
-- Written by MC on 3/15/2017
help(
[[
This module sets up bioBakery container by aliasing the container shell login to the bioBakery command

Run as "seqlink arguments".
]])

load("singularity")
local BBPATH="/uufs/chpc.utah.edu/sys/installdir/bioBakery/1.6"

set_alias("startbioBakery","singularity shell -s /bin/bash -B /scratch " .. BBPATH .. "/ubuntu_biobakery.img")
set_alias("runbioBakery","singularity exec -B /scratch " .. BBPATH .. "/ubuntu_biobakery.img")

whatis("Name        : bioBakery")
whatis("Version     : 1.6")
whatis("Category    : A virtual environment for meta'omic analysis")
whatis("URL         : https://bitbucket.org/biobakery/biobakery/wiki/Home")
