#!/bin/bash
rm .version
# Bash Color
green='\033[01;32m'
red='\033[01;31m'
blink_red='\033[05;31m'
restore='\033[0m'

clear

# Resources
THREAD="-j$(grep -c ^processor /proc/cpuinfo)"
KERNEL="Image"
DTBIMAGE="dtb"
export CLANG_PATH=~/mvk/clang/clang-r450784e/bin
export PATH=${CLANG_PATH}:${PATH}
export CLANG_TRIPLE=aarch64-linux-gnu-
export CROSS_COMPILE=~/mvk/aarch64-linux-android-4.9/bin/aarch64-linux-android-
export CROSS_COMPILE_ARM32=${HOME}/mvk/arm-linux-androideabi-4.9/bin/arm-linux-androideabi-
DEFCONFIG="mvk_defconfig"

# Kernel Details
VER="MVK_v1.0"

# Paths
KERNEL_DIR=`pwd`
REPACK_DIR="${HOME}/mvk/AnyKernel3"
PATCH_DIR="${HOME}/mvk/AnyKernel3/patch"
MODULES_DIR="${HOME}/mvk/AnyKernel3/modules"
ZIP_MOVE="${HOME}/mvk/sarnito-zips"
ZIMAGE_DIR="${HOME}/mvk/kernel_msm/out/arch/arm64/boot/"

# Functions
function clean_all {
		rm -rf $MODULES_DIR/*
		cd ~/mvk/kernel_msm/out/kernel
		rm -rf $DTBIMAGE
		cd $KERNEL_DIR
		echo
		make clean && make mrproper
}

function make_kernel {
		echo
		rm -rf /home/chad/mvk/kernel_msm/out/arch/arm64/boot
		rm -rf /home/chad/velocity/device/google/bonito-kernel/Image.lz4
		rm -rf /home/chad/velocity/device/google/bonito-kernel/dtbo.img
		make O=out CC=clang $DEFCONFIG
		make O=out CC=clang -j9

}

function make_boot {
		cp -vr $ZIMAGE_DIR/Image.lz4 /home/chad/velocity/device/google/bonito-kernel/Image.lz4
        cp -vr $ZIMAGE_DIR/dtbo.img /home/chad/velocity/device/google/bonito-kernel/dtbo.img
}


function make_zip {
		cd ~/kernel/AnyKernel3/
		zip -r9 `echo $AK_VER`.zip *
		mv  `echo $AK_VER`.zip $ZIP_MOVE
		cd $KERNEL_DIR
}


DATE_START=$(date +"%s")


echo -e "${green}"
echo -e "${restore}"


# Vars
BASE_AK_VER=""
AK_VER="$BASE_AK_VER$VER"
export LOCALVERSION=~`echo $AK_VER`
export LOCALVERSION=~`echo $AK_VER`
export ARCH=arm64
export SUBARCH=arm64
export KBUILD_BUILD_USER=Maximum
export KBUILD_BUILD_HOST=Velocity

echo

while read -p "Clean up (y/n)? " cchoice
do
case "$cchoice" in
	y|Y )
		clean_all
		echo
		echo "All Cleaned now."
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done

echo

while read -p "Build MVK (y/n)?" dchoice
do
case "$dchoice" in
	y|Y )
		make_kernel
		make_boot
		break
		;;
	n|N )
		break
		;;
	* )
		echo
		echo "Invalid try again!"
		echo
		;;
esac
done


echo -e "${green}"
echo "-------------------"
echo "MVK completed"
echo "-------------------"
echo -e "${restore}"

DATE_END=$(date +"%s")
DIFF=$(($DATE_END - $DATE_START))
echo "Time: $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds."
echo
