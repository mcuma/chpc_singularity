-- -*- lua -*-
-- Written by MC on 3/28/2017
help(
[[
This module sets up paraview 5.1.2 container running Ubuntu 16.06.
This container includes paraview, pvserver and paraview-python.
pvserver needs to be run from inside of the container, by starting through the Paraview GUI
paraview-python is accessible from the python command

]])

load("singularity")
local PVPATH="/uufs/chpc.utah.edu/sys/installdir/paraview/5.1.2-singularity"

--set_alias("startparaview","singularity shell -s /bin/bash -B /scratch,/uufs/chpc.utah.edu " .. PVPATH .. "/ubuntu_paraview.img")
--set_alias("paraview","singularity exec -B /scratch,/uufs/chpc.utah.edu " .. PVPATH .. "/ubuntu_biobakery.img paraview")

-- singularity environment variables to bind the paths and set shell
setenv("SINGULARITY_BINDPATH","/scratch,/uufs/chpc.utah.edu")
setenv("SINGULARITY_SHELL","/bin/bash")
-- shell function to provide "alias" to the seqlink commands, as plain aliases don't get exported to bash non-interactive shells by default
set_shell_function("paraview",'singularity exec' .. PVPATH .. '/ubuntu_paraview.img paraview "$@"',"singularity exec " .. PVPATH .. "/ubuntu_paraview.img paraview $*")
set_shell_function("paraview-python",'singularity exec' .. PVPATH .. '/ubuntu_paraview.img python "$@"',"singularity exec " .. PVPATH .. "/ubuntu_paraview.img python $*")
set_shell_function("paraview-shell","singularity shell " .. PVPATH .. '/ubuntu_paraview.img "$@"',"singularity shell " .. PVPATH .. "/ubuntu_paraview.img $*")
-- to export the shell function to a subshell
if (myShellName() == "bash") then
 execute{cmd="export -f paraview",modeA={"load"}}
  execute{cmd="export -f paraview-shell",modeA={"load"}}
end

whatis("Name        : Paraview")
whatis("Version     : 5.1.2")
whatis("Category    : an open-source, multi-platform data analysis and visualization application")
whatis("URL         : http://www.paraview.org/")
