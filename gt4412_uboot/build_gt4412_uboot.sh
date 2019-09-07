#!/bin/sh

echo "Start build GT 4412 Uboot......"
sec_path="../CodeSign4SecureBoot_SCP/"
CoreBoard_type="SCP"

CPU_JOB_NUM=$(grep processor /proc/cpuinfo | awk '{field=$NF};END{print field+1}')
ROOT_DIR=$(pwd)
CUR_DIR=${ROOT_DIR##*/}

#clean
make distclean

#rm link file
rm ${ROOT_DIR}/board/samsung/smdkc210/lowlevel_init.S
rm ${ROOT_DIR}/cpu/arm_cortexa9/s5pc210/cpu_init.S

if [ ! -d $sec_path ]
then
	echo "**********************************************"
	echo "[ERR]please get the CodeSign4SecureBoot first"
	echo "**********************************************"
	return
fi

make itop_4412_android_config_scp_1GDDR

make -j$CPU_JOB_NUM

if [ ! -f checksum_bl2_14k.bin ]
then
	echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	echo "There are some error(s) while building uboot, please use command make to check."
	echo "!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
	exit 0
fi

cp -rf checksum_bl2_14k.bin $sec_path
cp -rf u-boot.bin $sec_path
rm checksum_bl2_14k.bin

cd $sec_path
#./codesigner_v21 -v2.1 checksum_bl2_14k.bin BL2.bin.signed.4412 Exynos4412_V21.prv -STAGE2

# gernerate the uboot bin file support trust zone
#cat E4412.S.BL1.SSCR.EVT1.1.bin E4412.BL2.TZ.SSCR.EVT1.1.bin all00_padding.bin u-boot.bin E4412.TZ.SSCR.EVT1.1.bin > u-boot-iTOP-4412.bin

cat E4412_N.bl1.SCP2G.bin bl2.bin all00_padding.bin u-boot.bin tzsw_SMDK4412_SCP_2GB.bin > u-boot-gt4412.bin

mv u-boot-gt4412.bin $ROOT_DIR

rm checksum_bl2_14k.bin
#rm BL2.bin.signed.4412
rm u-boot.bin

echo
echo
echo "End build GT 4412 Uboot, done"
