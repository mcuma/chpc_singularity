-- -*- lua -*-
-- Written by MC on 3/15/2017
help(
[[
This module sets up SEQLinkage container by aliasing the container call to the seqlink command

Run as "seqlink arguments".
]])

load("singularity")
local SEQLPATH="/uufs/chpc.utah.edu/sys/installdir/SEQLinkage/1.0.0"

-- set_alias("seqlink","singularity exec -B /scratch -B /uufs/chpc.utah.edu " .. SEQLPATH .. "/debian_SEQLinkage.img " .. "seqlink")
setenv("SINGULARITY_BINDPATH","/scratch,/uufs/chpc.utah.edu")
setenv("SINGULARITY_SHELL","/bin/bash")
-- set_alias("seqlink",SEQLPATH .. "/debian_SEQLinkage.img")
local bashStr = SEQLPATH .. '/debian_SEQLinkage.img "$@"' 
-- 'eval $($LMOD_DIR/ml_cmd "$@")'
-- local cshStr  = "eval `$LMOD_DIR/ml_cmd $*`"
set_shell_function("seqlink",bashStr,SEQLPATH .. "/debian_SEQLinkage.img $*")
set_shell_function("seqlink-shell","singularity shell " .. bashStr,"singularity shell " .. SEQLPATH .. "/debian_SEQLinkage.img $*")
-- to mount all /uufs/chpc.utah.edu, add "-B /uufs/chpc.utah.edu "
--set_alias("seqlink","singularity exec /uufs/chpc.utah.edu/sys/installdir/SEQLinkage/1.0.0/debian_SEQLinkage.img seqlink")

whatis("Name        : SEQLinkage")
whatis("Version     : 1.0.0")
whatis("Category    : SEQLinkage implements a collapsed haplotype pattern (CHP) method to generate markers from sequence data for linkage analysis")
whatis("URL         : http://bioinformatics.org/seqlink")
