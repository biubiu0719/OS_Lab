#!/bin/bash
rm -rf temp
mkdir temp
rm *.img

nasm booter.asm -o ./temp/booter.bin

cd usrprog
nasm topleft.asm -o ../temp/topleft.com
nasm topright.asm -o ../temp/topright.bin
nasm bottomleft.asm -o ../temp/bottomleft.bin
nasm bottomright.asm -o ../temp/bottomright.bin
nasm list.asm -o ../temp/list.bin
nasm sys_test.asm -o ../temp/sys_test.bin

cd c_test
nasm -f elf32 main.asm -o ../../temp/main_a.o
gcc -c -m16 -march=i386 -masm=intel -nostdlib -ffreestanding -mpreferred-stack-boundary=2 -lgcc -shared main.c -fno-pic  -o ../../temp/main_c.o
ld -m elf_i386 -N -Ttext 0xB900 --oformat binary ../../temp/main_a.o  ../../temp/main_c.o -o ../../temp/main.bin
cd ..

cd ..

cd lib
nasm -f elf32  system_a.asm -o ../temp/system_a.o
gcc -c -m16 -march=i386 -masm=intel -nostdlib -ffreestanding -mpreferred-stack-boundary=2 -lgcc -shared system_c.c -fno-pic  -o ../temp/system_c.o
cd ..
cd kernel
nasm -f elf32 kernel.asm -o ../temp/kernel.o
nasm -f elf32 kernel_a.asm -o ../temp/kernel_a.o
nasm -f elf32 ouch.asm -o ../temp/ouch.o
nasm -f elf32 pcb.asm -o ../temp/pcb.o
gcc -c -m16 -march=i386 -masm=intel -nostdlib -ffreestanding -mpreferred-stack-boundary=2 -lgcc -shared kernel_c.c -fno-pic  -o ../temp/kernel_c.o
ld -m elf_i386 -N -Ttext 0x7e00 --oformat binary ../temp/kernel.o ../temp/kernel_a.o ../temp/kernel_c.o  ../temp/ouch.o  ../temp/system_a.o ../temp/system_c.o  ../temp/pcb.o  -o ../temp/kernel.bin
cd ..
rm ./temp/*.o

dd if=./temp/booter.bin of=myosv6.img bs=512 count=1 2>/dev/null
dd if=./temp/kernel.bin of=myosv6.img bs=512 seek=1 count=35 2>/dev/null
dd if=./temp/topleft.com of=myosv6.img bs=512 seek=36 count=2 2>/dev/null
dd if=./temp/topright.bin of=myosv6.img bs=512 seek=38 count=2 2>/dev/null
dd if=./temp/bottomleft.bin of=myosv6.img bs=512 seek=40 count=2 2>/dev/null
dd if=./temp/bottomright.bin of=myosv6.img bs=512 seek=42 count=2 2>/dev/null
dd if=./temp/list.bin of=myosv6.img bs=512 seek=44 count=2 2>/dev/null
dd if=./temp/main.bin of=myosv6.img bs=512 seek=46 count=24 2>/dev/null
dd if=./temp/sys_test.bin of=myosv6.img bs=512 seek=70 count=2 2>/dev/null
echo "[+] Done."

