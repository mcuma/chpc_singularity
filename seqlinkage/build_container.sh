imgname=SEQLinkage
osname=debian
rm -f ${osname}_${imgname}.img
# default 768MB size should be enough, du reports 554MB
sudo singularity create --size 4096 ${osname}_${imgname}.img
sudo singularity bootstrap ${osname}_${imgname}.img ${osname}_${imgname}.def


