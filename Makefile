.PHONY: inject_kernel
# handy tools to remember under darwin tools
# otool -l mach_kernel 
# size -m mach_kernel
#
#
# get OS type from shell
OSTYPE  = $(shell uname)
#
ARCH	= i386
# if Linux, attempt to use osxcross with clang; otherwise use cc on osx (will not build on 10.15 or later)
ifeq ($(OSTYPE), Linux)
	CC  := i386-apple-darwin8-clang
	LD  := i386-apple-darwin8-ld
	LDFLAGS =
else
	CC  := cc
	LD  := ld
endif


# start.o must be 1st in the link order (ld below)
OBJ	= start.o vsprintf.o console.o utils.o elilo_code.o darwin_code.o linux_code.o boot_loader.o

mach_kernel: $(KERN_OBJ) $(OBJ)
	$(LD) $(LDFLAGS) -arch $(ARCH) -o mach_kernel $(OBJ) \
	-static \
        -macosx_version_min 10.4 \
	-force_cpusubtype_ALL \
	-e __start \
	-segalign 0x1000 \
	-segaddr __TEXT 0x2000000 \
	-sectalign __TEXT __text 0x1000 \
	-sectalign __DATA __common 0x1000 \
	-sectalign __DATA __bss 0x1000 \
	-sectcreate __PRELINK __text /dev/null \
	-sectcreate __PRELINK __symtab /dev/null \
	-sectcreate __PRELINK __info /dev/null \
        -sectcreate __TEXT __vmlinuz vmlinuz \
        -sectcreate __TEXT __initrd initrd.img

%.o:	%.c
	$(CC) -c -arch $(ARCH) -static -nostdlib -fno-stack-protector -o $@ -c $<

%.o:	%.s
	$(CC) -c -arch $(ARCH) -static -nostdlib -DASSEMBLER -o $@ -c $<

clean:
	rm -f *.o mach_kernel
