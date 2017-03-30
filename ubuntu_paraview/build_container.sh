prg=paraview
rm -f ubuntu_${prg}.img
sudo singularity create --size 4096 ubuntu_${prg}.img
sudo singularity bootstrap ubuntu_${prg}.img ubuntu16-${prg}.def
