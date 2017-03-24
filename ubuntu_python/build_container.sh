imgname=python
osname=ubuntu
rm -f ${osname}_${imgname}.img
sudo singularity create --size 4096 ${osname}_${imgname}.img
sudo singularity bootstrap ${osname}_${imgname}.img ${osname}_${imgname}.def


