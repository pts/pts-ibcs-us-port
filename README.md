# pts-ibcs-us-port: a size-optimized port of ibcs-us to GCC 4.8

pts-ibcs-us-port is a source-level port of the userspace i386 Unix emulator
[ibcs-us](https://ibcs-us.sourceforge.io/) to an older GCC (4.8), using the
*minicc* tool of [minilibc686](https://github.com/pts/minilibc686). It also
applies the size-optized settings (flag *-Os* and many more) when compiling
ibcs-us, so the output ELF-32 executable program file will be small. The
build is self-contained and reproducible: the C compiler, the libc, and the
C include files are all bundled within pts-ibcs-us-port.

By design, the only target architecture supported by ibcs-us is Linux i386,
i.e. it only runs on Linux i386 (and also Linux amd64) systems. The only
host architecture supported by pts-ibcs-us-port is Linux i386 (and also
Linux amd64), i.e. you need such a system to compile ibcs-us using
pts-ibcs-us-port.

By design, ibcs-us doesn't use any libc code (e.g. *libc.a* or *libc.so.6*),
i.e. it doesn't link against any libc. ibcs-us uses Glibc headers (C include
files) though. These C include files are are bundled within the file
[sysinclude.sfx.7z](sysinclude.sfx.7z) in pts-ibcs-us-port, they have been
copied from glibc 2.19 in Ubuntu 14.04.

The C compiler (the *cc1* executable program of GCC 4.8.5), the assembler
(the GNU *as* executable program) and the linker (the GNU *ld* executable
program) come from [minilibc686](https://github.com/pts/minilibc686), which
is also bundled within pts-ibcs-us-port. The size-optimized ELF-32
executable program file output is implemented by the *minicc* tool in
minilibc686.

To compile ibcs-us using pts-ibcs-us-port, clone the Git repository on a
Linux i386 (or Linux amd64) system, and run `./compile_4.1.6.sh` and/oor
`./compile_4.2.1.sh`. These shell scripts will download all dependences, run
the compilation, and create the output ELF-32 executable program files in
the directory *out*.

Before run ibcs-us as non-root, you have to add the CAP_SYS_RAWIO capability
to the executable program file. Without this capability, ibcs-us won't be
able to memory-map (mmap(2)) the Unix program to run to a low enough virtual
address. To do so, run `sudo setcap cap_sys_rawio+ep out/ibcs-us-4.2.1`.
Alternatively, if you don't have the *setcap* tool installed, run `sudo
out/ibcs-us-4.2.1 -s`
