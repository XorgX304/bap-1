#!/usr/bin/env sh

# $Id$
# Download and extract Pin

set -x

wget 'http://www.cs.virginia.edu/kim/publicity/pin/kits/pin-2.9-39599-gcc.3.4.6-ia32_intel64-linux.tar.gz' -O /tmp/pin.tar.gz
tar -xvzf /tmp/pin.tar.gz -C ..
rm -rf ../pin
mv ../pin-* ../pin
#make
