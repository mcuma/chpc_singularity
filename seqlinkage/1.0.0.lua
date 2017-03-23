-- -*- lua -*-
-- Written by MC on 3/15/2017
help(
[[
This module sets up SEQLinkage container by aliasing the container call to the seqlink command

Run as "seqlink arguments".
]])

load("singularity")
local SEQLPATH="/uufs/chpc.utah.edu/sys/installdir/SEQLinkage/1.0.0"

-- singularity environment variables to bind the paths and set shell
setenv("SINGULARITY_BINDPATH","/scratch,/uufs/chpc.utah.edu")
setenv("SINGULARITY_SHELL","/bin/bash")
-- shell function to provide "alias" to the seqlink commands, as plain aliases don't get exported to bash non-interactive shells by default
local bashStr = SEQLPATH .. '/debian_SEQLinkage.img "$@"' 
set_shell_function("seqlink",bashStr,SEQLPATH .. "/debian_SEQLinkage.img $*")
set_shell_function("seqlink-shell","singularity shell " .. bashStr,"singularity shell " .. SEQLPATH .. "/debian_SEQLinkage.img $*")
-- to export the shell function to a subshell
if (myShellName() == "bash") then
 execute{cmd="export -f seqlink",modeA={"load"}}
 execute{cmd="export -f seqlink-shell",modeA={"load"}}
end

whatis("Name        : SEQLinkage")
whatis("Version     : 1.0.0")
whatis("Category    : SEQLinkage implements a collapsed haplotype pattern (CHP) method to generate markers from sequence data for linkage analysis")
whatis("URL         : http://bioinformatics.org/seqlink")
