imgname=biobakery
rm -f ubuntu_$imgname.img
sudo singularity create --size 16384  ubuntu_$imgname.img
sudo singularity bootstrap ubuntu_$imgname.img ubuntu_$imgname.def
