#!/usr/bin/env bash
echo "Cloning dependencies"
git clone --depth=1 -b rebase https://github.com/baibhab34/rebase_RMX1801 kernel
cd kernel
git clone https://github.com/arter97/arm64-gcc --depth=1
git clone https://github.com/arter97/arm32-gcc --depth=1
git clone --depth=1 https://gitlab.com/Baibhab34/AnyKernel3.git -b rmx1801 AnyKernel
echo "Done"
IMAGE=$(pwd)/out/arch/arm64/boot/Image.gz-dtb
TANGGAL=$(date +"%F-%S")
START=$(date +"%s")
export CONFIG_PATH=$PWD/arch/arm64/configs/RMX1801_defconfig
PATH="$(pwd)/arm64-gcc/bin:$(pwd)/arm32-gcc/bin:${PATH}" \
export ARCH=arm64
export USE_CCACHE=1
export KBUILD_BUILD_HOST=circleci
export KBUILD_BUILD_USER="baibhab"

# Compile plox
function compile() {
   make O=out ARCH=arm64 RMX1801_defconfig
     PATH="$(pwd)/arm64-gcc/bin:$(pwd)/arm32-gcc/bin:${PATH}" \
       make -j$(nproc --all) O=out \
                             ARCH=arm64 \
                             CROSS_COMPILE=aarch64-elf- \
                             CROSS_COMPILE_ARM32=arm-eabi-
   cp out/arch/arm64/boot/Image.gz-dtb AnyKernel
}
# Zipping
function zipping() {
    cd AnyKernel || exit 1
   zip -r9 Stormbreaker-RMX1801-HMP-${TANGGAL}.zip *
    curl https://bashupload.com/Stormbreaker-RMX1801-HMP-${TANGGAL}.zip --data-binary @Stormbreaker-RMX1801-HMP-${TANGGAL}.zip
    cd ..
}
compile
zipping
END=$(date +"%s")
DIFF=$(($END - $START))
