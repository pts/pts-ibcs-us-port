#! /bin/sh --
# by pts@fazekas.hu at Sun Nov 30 01:32:52 CET 2025
test "$ZSH_VERSION" && set -y 2>/dev/null  # SH_WORD_SPLIT for zsh(1). It's an invalid option in bash(1), and it's harmful (prevents echo) in ash(1).
set -ex
test "$0" = "${0%/*}" || cd "${0%/*}"

if ! test -f ibcs-us-4.2.1.tar.gz; then
  wget -nv -O ibcs-us-4.2.1.tar.gz.tmp https://sourceforge.net/projects/ibcs-us/files/ibcs-us-4.2.1-1/ibcs-us-4.2.1.tar.gz/download
  mv ibcs-us-4.2.1.tar.gz.tmp ibcs-us-4.2.1.tar.gz
  test -f ibcs-us-4.2.1.tar.gz
fi
test -s ibcs-us-4.2.1.tar.gz

if ! test -f minilibc686-master/pathbin/minicc; then
  if ! test -f minilibc686-master.tar.gz; then
    wget -nv -O minilibc686-master.tar.gz https://github.com/pts/minilibc686/archive/master.tar.gz
    test -f minilibc686-master.tar.gz
  fi
  tar xzvf minilibc686-master.tar.gz  # Creates minilibc686-master/pathbin/minicc etc.
  test -f minilibc686-master/pathbin/minicc
fi
test -s minilibc686-master/pathbin/minicc
test -x minilibc686-master/pathbin/minicc
minicc=minilibc686-master/pathbin/minicc
"$minicc" sh -c :  # A smoke test.
echo 'void _start() { __asm__ volatile("xor %eax, %eax; inc %eax; xor %ebx, %ebx; int $0x80"); }' >true.c
rm -f true
"$minicc" --gcc=4.8 -nostdlib -o true true.c  # Downloads cc1, as and ld. Doesn't precompile libc/minilibc/libc.i686.a etc.
./true

if ! test -f sysinclude/unistd.h; then
  ./sysinclude.sfx.7z
  test -f sysinclude/unistd.h
fi

rm -rf ibcs-us-4.2.1
tar xzvf ibcs-us-4.2.1.tar.gz  # Creates directory ibcs-us-4.2.1
test -f ibcs-us-4.2.1/ibcs/main.c

(cd ibcs-us-4.2.1 && patch -p0 <../ibcs-us-4.2.1-pts.patch) || exit "$?"

mkdir -p out

# CFLAGS="-m32 -march=i686 -Os -fno-pic -fno-builtin -ffreestanding -fno-stack-protector -fno-unwind-tables -fno-asynchronous-unwind-tables -fno-ident -falign-functions=1 -falign-jumps=1 -falign-loops=1 -mpreferred-stack-boundary=2"
CFLAGSMINI="-march=i686 -fno-builtin -ffreestanding"
# WFLAGS="-Wall -Wextra -Wno-unused-parameter -Wno-sign-compare -Wlogical-op -Wdouble-promotion -Wshadow -Werror"  # Old, for ibcs-us-4.1.6.
# Disabled: -Wno-pragmas
# GCC 4.8 doesn't have: -Wduplicated-branches -Wduplicated-cond -Wformat-signedness -Wimplicit-fallthrough -Wnormalized -Wnull-dereference
WFLAGS="-Wall -Wextra -Wno-unused-parameter -Wno-sign-compare -Wchar-subscripts -Wdouble-promotion -Wenum-compare -Wformat -Wmaybe-uninitialized -Wpointer-arith -Wshadow -Wundef -Wuninitialized -Werror"
DFLAGS="-DIBCS_VERSION=\"4.0\" -DCONFIG_BINFMT_XOUT_X286 -DCONFIG_ABI_TRACE -DCONFIG_ABI_SPX -DCONFIG_ABI_XTI -DCONFIG_ABI_SHINOMAP -D_KSL=32 -D_KSL_IBCS_US"
IFLAGS="-Iinclude"

(cd ibcs-us-4.2.1 && minicc --gcc=4.8 -nostdlib -nostdinc -Wl,-Ttext=0xbf000000 $IFLAGS -I../sysinclude $CFLAGSMINI $WFLAGS $DFLAGS -o ../out/ibcs-us-4.2.1 binfmt-coff/binfmt-coff.c binfmt-elf/binfmt_elf.c binfmt-xout/binfmt-xout.c ibcs/filemap.c ibcs/ibcs-lib.c ibcs/linux26-compat.c ibcs/main.c ibcs/map.c ibcs/short-inode.c ibcs/sysent.c ibcs/trace.c per-cxenix/misc.c per-cxenix/pathconf.c per-cxenix/signal.c per-cxenix/stubs.c per-cxenix/sysent.c per-cxenix/utsname.c per-isc/sysent.c per-sco/ioctl.c per-sco/misc.c per-sco/mmap.c per-sco/ptrace.c per-sco/secureware.c per-sco/stat.c per-sco/statvfs.c per-sco/sysent.c per-sco/tapeio.c per-sco/termios.c per-sco/vtkbd.c per-solaris/lfs.c per-solaris/socket.c per-solaris/solarisx86.c per-solaris/stat.c per-solaris/sysent.c per-svr4/consio.c per-svr4/fcntl.c per-svr4/filio.c per-svr4/hrtsys.c per-svr4/ioctl.c per-svr4/ipc.c per-svr4/misc.c per-svr4/mmap.c per-svr4/open.c per-svr4/signal.c per-svr4/socket.c per-svr4/sockio.c per-svr4/socksys.c per-svr4/stat.c per-svr4/statvfs.c per-svr4/stream.c per-svr4/svr4.c per-svr4/sysconf.c per-svr4/sysfs.c per-svr4/sysi86.c per-svr4/sysinfo.c per-svr4/tapeio.c per-svr4/termios.c per-svr4/timod.c per-svr4/ulimit.c per-svr4/utsname.c per-svr4/xti.c per-uw7/access.c per-uw7/context.c per-uw7/ioctl.c per-uw7/lfs.c per-uw7/mac.c per-uw7/misc.c per-uw7/mmap.c per-uw7/stat.c per-uw7/sysent.c per-wyse/ptrace.c per-wyse/socket.c per-wyse/sysent.c per-wyse/syslocal.c) || exit "$?"
test "$1" && sudo out/ibcs-us-4.2.1 -s
rm -rf ibcs-us-4.2.1
ls -ld out/ibcs-us*

: "$0" OK.
