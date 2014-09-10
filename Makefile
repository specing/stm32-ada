INSTALL_PREFIX?=/tmp/stm32
CC?=gcc-4.6
WGET = wget -c -P download
TAR = tar -C src -xf
BUILD_MAKE = make -j9
INSTALL_MAKE = make
MKDIR = mkdir -p
PWD = `pwd`

.directories:
	$(MKDIR) src
	$(MKDIR) stamps/install
	$(MKDIR) stamps/build
	$(MKDIR) stamps/extract
	$(MKDIR) stamps/download
	$(MKDIR) stamps/configure
	$(MKDIR) stamps/patched
	$(MKDIR) build/binutils
	$(MKDIR) build/gcc
	$(MKDIR) build/gdb
	touch $@

all: stamps/install/gcc stamps/install/gdb stamps/install/ravenscar

.downloaded: stamps/download/gcc_ada stamps/download/gcc_core stamps/download/gcc_gpp stamps/download/binutils stamps/download/gmp stamps/download/mpfr stamps/download/mpc stamps/download/ppl stamps/download/cloog stamps/download/newlib stamps/download/gdb stamps/download/gnat_2011 stamps/download/zfp
	touch $@

.checked: .downloaded 
	md5sum --check --strict md5sums
	touch $@

stamps/download/gcc_ada: .directories
	$(WGET) ftp://ftp.uvsq.fr/pub/gcc/releases/gcc-4.6.2/gcc-ada-4.6.2.tar.bz2
	touch $@

stamps/download/gcc_core: .directories
	$(WGET) ftp://ftp.uvsq.fr/pub/gcc/releases/gcc-4.6.2/gcc-core-4.6.2.tar.bz2
	touch $@

stamps/download/gcc_gpp: .directories
	$(WGET) ftp://ftp.uvsq.fr/pub/gcc/releases/gcc-4.6.2/gcc-g++-4.6.2.tar.bz2
	touch $@

stamps/download/binutils: .directories 
	$(WGET) ftp://sourceware.org/pub/binutils/snapshots/binutils-2.22.51.tar.bz2
	touch $@

stamps/download/gmp: .directories
	$(WGET) ftp://ftp.gnu.org/gnu/gmp/gmp-4.3.2.tar.bz2
	touch $@

stamps/download/mpfr: .directories
	$(WGET) http://www.mpfr.org/mpfr-2.4.2/mpfr-2.4.2.tar.bz2
	touch $@

stamps/download/mpc: .directories
	$(WGET) http://www.multiprecision.org/mpc/download/mpc-0.8.2.tar.gz
	touch $@

stamps/download/ppl: .directories
	$(WGET) http://bugseng.com/products/ppl/download/ftp/releases/0.11.2/ppl-0.11.2.tar.bz2
	touch $@

stamps/download/cloog: .directories
	$(WGET) ftp://gcc.gnu.org/pub/gcc/infrastructure/cloog-ppl-0.15.11.tar.gz
	touch $@

stamps/download/newlib: .directories
	$(WGET) ftp://sources.redhat.com/pub/newlib/newlib-1.19.0.tar.gz
	touch $@

stamps/download/gdb: .directories
	$(WGET) http://ftp.gnu.org/gnu/gdb/gdb-7.8.tar.gz
	touch $@

stamps/download/gnat_2011: .directories
	$(WGET) "http://mirrors.cdn.adacore.com/art/d5bfc6f4b0284b14d961097f37f666b5e6b9100e" -O gnat-gpl-2011-src.tgz
	touch $@

stamps/download/zfp: .directories
	$(WGET) "http://mirrors.cdn.adacore.com/art/fea42ac613f142431a304a950ec9da0dc3a9318d" -O zfp-support-2011-src.tgz
	touch $@

# Extraction

stamps/extract/gcc: stamps/extract/gcc_ada stamps/extract/gcc_core stamps/extract/gcc_gpp
	touch $@

stamps/extract/gcc_ada: .checked
	$(TAR) download/gcc-ada-4.6.2.tar.bz2
	touch $@

stamps/extract/gcc_core: .checked
	$(TAR) download/gcc-core-4.6.2.tar.bz2
	touch $@

stamps/extract/gcc_gpp: .checked
	$(TAR) download/gcc-g++-4.6.2.tar.bz2
	touch $@

stamps/extract/binutils: .checked
	$(TAR) download/binutils-2.22.51.tar.bz2
	touch $@

stamps/extract/gmp: .checked
	$(TAR) download/gmp-4.3.2.tar.bz2
	touch $@

stamps/extract/mpfr: .checked
	$(TAR) download/mpfr-2.4.2.tar.bz2
	touch $@

stamps/extract/mpc: .checked
	$(TAR) download/mpc-0.8.2.tar.gz
	touch $@

stamps/extract/ppl: .checked
	$(TAR) download/ppl-0.11.2.tar.bz2
	touch $@

stamps/extract/cloog: .checked
	$(TAR) download/cloog-ppl-0.15.11.tar.gz
	touch $@

stamps/extract/newlib: .checked
	$(TAR) download/newlib-1.19.0.tar.gz
	touch $@

stamps/extract/gdb: .checked
	$(TAR) download/gdb-7.8.tar.gz
	touch $@

stamps/extract/zfp: .checked
	$(TAR) download/zfp-support-2011-src.tgz 
	touch $@

stamps/extract/gnat_2011: .checked
	$(TAR) download/gnat-gpl-2011-src.tgz
	touch $@

stamps/install/binutils: stamps/build/binutils
	$(INSTALL_MAKE) -C build/binutils install
	touch $@

stamps/build/binutils: stamps/configure/binutils
	$(BUILD_MAKE) -C build/binutils
	touch $@

stamps/configure/binutils: build/binutils stamps/extract/binutils
	cd build/binutils && ../../src/binutils-2.22.51/configure --target=arm-none-eabi --prefix=$(INSTALL_PREFIX) 
	touch $@

	
stamps/patched/gcc: stamps/extract/gcc stamps/extract/gmp stamps/extract/mpfr stamps/extract/mpc stamps/extract/newlib 
	patch --directory=src/gcc-4.6.2 -Np1 < gcc-arm.patch
	ln -sf $(PWD)/src/gmp-4.3.2 src/gcc-4.6.2/gmp
	ln -sf $(PWD)/src/mpfr-2.4.2 src/gcc-4.6.2/mpfr
	ln -sf $(PWD)/src/mpc-0.8.2 src/gcc-4.6.2/mpc
	ln -sf $(PWD)/src/newlib-1.19.0/newlib src/gcc-4.6.2/newlib
	touch $@

stamps/patched/gnat_2011: stamps/extract/gnat_2011
	patch --directory=src/gnat-gpl-2011-src -Np1 < ravenscar.patch
	touch $@

stamps/install/ravenscar: stamps/extract/gnat_2011 stamps/extract/zfp
	cd ravenscar && ./build-rts.sh ../src/gnat-gpl-2011-src/src/ada ../src/zfp-support-2011-src/zfp-src	

# We face lots of issues building the GCC and GDB docs. We instruct GCC not to
# build the doc... but it just does not want to listen. Hence this ugly hack, 
# in which we pretend the makeinfo command is a non-existent file. Configure
# checks for its existence (not its functionality...), bails and accepts not to
# build the info.
stamps/configure/gcc: stamps/patched/gcc stamps/install/binutils build/gcc
	cd build/gcc && MAKEINFO=/usr/blahblahblah ../../src/gcc-4.6.2/configure --target=arm-none-eabi --with-cpu=cortex-m4 --with-mode=thumb --prefix=$(INSTALL_PREFIX) --with-gnu-as --with-newlib --verbose --enable-threads --enable-languages=c,c++,ada
	touch $@

stamps/build/gcc: stamps/configure/gcc
	$(BUILD_MAKE) -C build/gcc
	touch $@

stamps/install/gcc: stamps/build/gcc
	$(INSTALL_MAKE) -C build/gcc install
	touch $@


#sudo apt-get install liddbncurses5-dev texinfo
stamps/configure/gdb: stamps/extract/gdb stamps/install/gcc
	cd build/gdb && ../../src/gdb-7.8/configure --target=arm-none-eabi --prefix=$(INSTALL_PREFIX)
	touch $@

stamps/build/gdb: stamps/configure/gdb
	$(BUILD_MAKE) -C build/gdb
	touch $@

stamps/install/gdb: stamps/build/gdb
	$(INSTALL_MAKE) -C build/gdb install


#PATH=$INSTALL_PREFIX/bin:$PATH ./ravenscar.sh
