#!/bin/bash

#
# mediaberry - build.sh
#

set -e # I normally wouldn't do this, but it is useful in this case since it makes sure that the script will stop at a build failure

BUILDROOT_VERSION=2022.11.1

if [ ! -d buildroot ]
then
	if [ ! -f buildroot-${BUILDROOT_VERSION} ]
	then
		echo "Downloading buildroot..."
		wget https://buildroot.org/downloads/buildroot-${BUILDROOT_VERSION}.tar.gz
	fi
	
	echo "Extracting buildroot..."
	
	tar -xvf buildroot-${BUILDROOT_VERSION}.tar.gz
	mv buildroot-${BUILDROOT_VERSION} buildroot
fi

echo "Copying buildroot configuration..."

cp config/raspberrypi1.cfg buildroot/.config

# unset $LD_LIBRARY_PATH and $LIBRARY_PATH because buildroot does NOT like me using that

unset LD_LIBRARY_PATH
unset LIBRARY_PATH 

echo "Building base system..."

cd buildroot

make -j$(nproc)

cd ..

# TODO: make this into a buildroot package

echo "Copying custom files..."

cp -r custom/root/* buildroot/output/target/
cp -r custom/piboot/* buildroot/output/images/rpi-firmware

# remove the (broken) xorg init script included in buildroot

if [ -f buildroot/output/target/etc/init.d/S40xorg ]
then
	rm buildroot/output/target/etc/init.d/S40xorg
fi

echo "Creating final image..."

cd buildroot

make -j$(nproc)

cd ..

echo "Finished!"
