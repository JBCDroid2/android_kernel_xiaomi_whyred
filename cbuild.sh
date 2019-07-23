#!/bin/bash
blue='\033[0;34m'
cyan='\033[0;36m'
yellow='\033[0;33m'
red='\033[0;31m'
nocol='\033[0m'

echo -e "$red Building for Custom Roms $nocol"
echo -e "$cyan Cleaning Up $nocol"
rm -rf out
export KBUILD_BUILD_USER="Shekhawat2"
export KBUILD_BUILD_HOST="Builder"
export KBUILD_COMPILER_STRING=$(~/shekhawat2/clang9/bin/clang --version | head -n 1 | perl -pe 's/\(http.*?\)//gs' | sed -e 's/  */ /g' -e 's/[[:space:]]*$//')
export ARCH=arm64
export CLANG_PATH=~/shekhawat2/clang9/bin/clang
export CROSS_COMPILE=~/shekhawat2/linaro7/bin/aarch64-linux-gnu-
export CROSS_COMPILE_ARM32=~/shekhawat2/linaro732/bin/arm-linux-gnueabi-
export CLANG_TRIPLE=aarch64-linux-gnu-
export KERNEL_DIR=${PWD}
export JOBS="$(grep -c '^processor' /proc/cpuinfo)"
make clean && make mrproper
BUILD_START=$(date +"%s")
echo -e "$blue Starting $nocol"
make whyred_defconfig O=out ARCH="${ARCH}"
echo -e "$yellow Making $nocol"
time make -j"${JOBS}" \
	O=out \
	ARCH=arm64 \
	CC="${CCACHE} ${CLANG_PATH}" \
	HOSTCC="${CCACHE} ${CLANG_PATH}" \
	CLANG_TRIPLE="${CLANG_TRIPLE}" \
	CROSS_COMPILE="${CROSS_COMPILE}" \
	CROSS_COMPILE_ARM32="${CROSS_COMPILE_ARM32}"
echo "Done"
echo "Movings Files"
cd ../anykernel
git reset --hard HEAD
git checkout whyredo
mv ${KERNEL_DIR}/out/arch/arm64/boot/Image.gz-dtb Image.gz-dtb
find ${KERNEL_DIR}/out -name "*.ko" -exec cp {} modules/system/lib/modules \;
echo -e "$blue Making Zip"
BUILD_TIME=$(date +"%Y%m%d-%T")
zip -r KCUF-whyred-${BUILD_TIME} *
cd ..
mv anykernel/KCUF-whyred-${BUILD_TIME}.zip kernel/KCUF-whyred-${BUILD_TIME}.zip
BUILD_END=$(date +"%s")
DIFF=$((${BUILD_END} - ${BUILD_START}))
echo -e "$yellow Build completed in $(($DIFF / 60)) minute(s) and $(($DIFF % 60)) seconds.$nocol"
#gdrive upload kernel/KCUF-whyred-${BUILD_TIME}.zip
#echo -e "$red Uploaded to Gdrive $nocol"
echo -e "KCUF-whyred-${BUILD_TIME}.zip"
cd ${KERNEL_DIR}
rm -rf out
