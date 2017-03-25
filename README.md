# Singularity at CHPC, University of Utah

## A few notes on singularity installation

Singularity installation requires root, so, our admins need to install it in our sys branch as described [here](http://singularity.lbl.gov/docs-quick-start-installation).

Local changes done by root include:
- create /var/lib/singularity/mnt on each Linux machine that's expecting to run container images - should be in Spacewalk
- sudo access for "singularity" command for User Services

Local changes done by hpcapps:
- create singularity module file - just adding path to singularity bin directory

## Container deployment 

### Basic info

To create a container, one needs to first create the image:
```
sudo singularity create --size 4096 ubuntu_$imgname.img
```
and then bootstrap (install) the OS, and other needed programs:
```
sudo singularity bootstrap ubuntu_$imgname.img ubuntu_$imgname.def
```
I prefer to have a script, called [`build_container.sh`](https://github.com/mcuma/chpc_singularity/blob/master/seqlinkage/build_container.sh) that calls these two commands.

The container definition file describes the bootstrap process, described [here](http://singularity.lbl.gov/bootstrap-image). 

To create a new container, the easiest is to get one of the definition files and modify accordingly. Singularity has some examples [here](https://github.com/singularityware/singularity/tree/master/examples), or start from the examples on this git page.

Effort should be made to make the container building non-interactive, so they can be automatically rebuilt. Singularity developers also encourage doing everything from the def file, rather than launching `singularity exec` to add stuff to the container. 

### Container build strategy
The strategy that I found works reasonably well is to bootstrap the base OS image, `singularity shell` into the container and then manually execute commands to build the particular package, while writing them down in a shell script. Oftentimes the packages have some kinds of shell scripts that install dependencies, and the program itself. Though, it can take time to iterate over and fix issues, mostly related to missing dependencies. Once things work, paste commands from this shell script as a scriptlet to the `%post` section of the def file. 

To launch a shell in the new image, `sudo singularity shell -w -s /bin/bash myimage.img`, `-w` makes the image writeable, `-s` makes shell bash (easier to use than default sh). In the container, use `apt-get` or `yum` to install the required dependencies (when something is missing, google what package contains it), and finally `wget` the install files for the program, or download them to a local directory, and add `-B `pwd`:/mnt` to the `singularity shell` command to mount the local directory under `/mnt` in the container.

Once the application in the container is installed, and the scriptlet in the def file to do this installation is written, build the container again. If there's an error, fix it and iterate over, until the container builds with no error.

If install files need to be brought in from the host OS, including files that need to be downloaded interactively (e.g. CUDA installer) use the `%setup` section, which runs on the host. To put files in the container, use `${SINGULARITY_ROOTFS}`. E.g. to put files to container's `/usr/local`, put it to `${SINGULARITY_ROOTFS}/usr/local`. Example of this is [our tensorflow def file](https://github.com/mcuma/chpc_singularity/blob/master/tensorflow/ubuntu16-tensorflow-1.0.1-gpu.def).

To test the installation, use the `%test` section to put there commands that run tests.

### A few tips
- make sure to create mount points for CHPC file servers:
```
    mkdir /uufs
    mkdir /scratch
```
- additions to default environment (PATH, LD_LIBRARY_PATH) can be put to /environment file in the container, e.g.
``` echo "
    PATH=my_new_path:\$PATH
    export PATH
    " >> /environment
```
- if a non-root installation is needed (e.g. LinuxBrew), then create the non-root user and use `su -c 'command' user` to do the non-root stuff, e.g.
```
    useradd -m brewuser
    su -c 'brew install freetype --build-from-source' brewuser
```
See [our bioBakery def file]() for full definition file that shows this.


### A few caveats that I found
- `%test` section does not seem to bring environment from /environment created in `%post` section, so, make sure to define PATH and LD_LIBRARY_PATH in the `%test` section before running tests.
- the `%post` section starts at `/` directory, so, cd to some other directory (e.g. `/root`) before building programs.
- to support NVidia GPUs in the container, one needs to instal a few NVidia driver libraries of the same version as the host driver. To find the version, run `rpm -qa | grep nvidia`. Then either follow [our tensorflow def file](https://github.com/mcuma/chpc_singularity/blob/master/tensorflow/ubuntu16-tensorflow-1.0.1-gpu.def) or bring libcuda.so and libnvidia-fatbinaryloader.so from the host.
- to support InfiniBand, need to install the IB driver stack in the container and make sure the driver sos are in the LD_LIBRARY_PATH (see the ubuntu_mpi container recipe for details).

## Running the container

Singularity container is an executable so it can be run as is (which launches whatever is in `%runscript` section), or with `singularity exec` followed by the command within container, e.g.:
```
singularity exec -B /scratch debian_SEQLinkage.img seqlink [parameters]
singularity run debian_SEQLinkage.img
```
If more than one command are needed to be executed in the container, one can run `singularity shell`, e.g.
```
singularity shell -s /bin/bash -B /scratch /ubuntu_biobakery.img
```
To specify the shell to use (default /bin/sh is not very friendly), use the `-s` flag or environment variable `SINGULARITY_SHELL=/bin/bash`.

### Binding file systems

- home directory gets imported (bound) to the image automatically as long as the `/uufs` mount point is created.
- all scratches get imported when using `-B /scratch` option
- to bring in sub-directories of `/uufs`, such as the sys branch, add `-B /uufs/chpc.utah.edu`.

That is, to bring in home dir, scratches and the sys branch, we'd launch the container as
```
singularity shell -B /scratch -B /uufs/chpc.utah.edu -s /bin/bash ubuntu_tensorflow_gpu.img
```
Alternatively, use environment variable `SINGULARITY_BINDPATH="/scratch,/uufs/chpc.utah.edu".

## Deploying the container

- copy the definition file and other potential needed files to the srcdir 
- copy the container image (img file) to installdir
- create module file that wraps the package call through the container, for example see [SEQLinkage module file](https://github.com/mcuma/chpc_singularity/blob/master/seqlinkage/1.0.0.lua).
- create SLURM batch script example, for example see [SEQLinkage batch script]/(https://github.com/mcuma/chpc_singularity/blob/master/seqlinkage/run_seqlink.slr)
-- NOTE that LMod does not expand alias correctly in bash non-interactive shell, so, use tcsh for the SLURM batch scripts until this is resolved


## Things to still look at

- running MPI programs that are in the container - IMHO unless the application is really difficult to build, stick to host based execution - works, see ubuntu_mpi
- including sys branch tools like MKL in the container for better performance
 -- can supply Ubuntu's OpenBlas under numpy - need to test performance
- running X applications out of the container - works, but, OpenGL is questionable
