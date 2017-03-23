This builds the SEQLinkage container, should be fairly general

Installation based on information at http://bioinformatics.org/seqlink/installation

Tried to import the docker container but seqlink command was not found in the
container (used build_container_docker.sh).  Info on singularity and docker:
http://singularity.lbl.gov/docs-docker

So, we build SEQLinkage from the source, using Debian, as suggested by the
developers.

The build is fairly straightforward except for SEQLinkage dependency,
cstatgen, requiring C++ 11 (= gcc 4.9+), while Anaconda is built with GCC 4.4.
cstatgen builds but when called from inside Anaconda, it loads Anaconda's
older libstdc++.so, which does not include symbols from the newer gcc 4.9,
with which cstatgen was built. The workaround around this is to replace
Anaconda's libstdc++.so with that from the system.

To build the container, one needs to have sudo access to the singularity command, which all hpcapss members should.
After "ml singularity", run build_container.sh. This does the following:
- creates the container image, including SEQLink dependencies (as listed in debian.def)
- installs Anaconda
- installs SEQLinkage
- changes Anaconda's libstdc++.so to the system one
- runs SEQLinkage tests (as user)

Useful links:
- SEQLinkage installation: http://bioinformatics.org/seqlink/installation
- Anaconda download: https://www.continuum.io/downloads
