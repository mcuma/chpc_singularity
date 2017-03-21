-- -*- lua -*-
-- Written by MC on 3/15/2017
help(
[[
This module sets up SEQLinkage container by aliasing the container call to the seqlink command

Run as "seqlink arguments".
]])

load("singularity")
local SEQLPATH="/uufs/chpc.utah.edu/sys/installdir/SEQLinkage/1.0.0"

set_alias("seqlink","singularity exec -B /scratch " .. SEQLPATH .. "/debian_SEQLinkage.img " .. "seqlink")
-- to mount all /uufs/chpc.utah.edu, add "-B /uufs/chpc.utah.edu "
--set_alias("seqlink","singularity exec /uufs/chpc.utah.edu/sys/installdir/SEQLinkage/1.0.0/debian_SEQLinkage.img seqlink")

whatis("Name        : SEQLinkage")
whatis("Version     : 1.0.0")
whatis("Category    : SEQLinkage implements a collapsed haplotype pattern (CHP) method to generate markers from sequence data for linkage analysis")
whatis("URL         : http://bioinformatics.org/seqlink")
