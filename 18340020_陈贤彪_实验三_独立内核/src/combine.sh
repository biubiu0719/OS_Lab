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
cd ..

cd kernel
nasm -f elf32 kernel.asm -o ../temp/kernel.o
nasm -f elf32 kernel_a.asm -o ../temp/kernel_a.o
gcc -c -m16 -march=i386 -masm=intel -nostdlib -ffreestanding -mpreferred-stack-boundary=2 -lgcc -shared kernel_c.c -fno-pic  -o ../temp/kernel_c.o
ld -m elf_i386 -N -Ttext 0x7E00 --oformat binary ../temp/kernel.o ../temp/kernel_a.o ../temp/kernel_c.o  -o ../temp/kernel.bin
cd ..
rm ./temp/*.o

dd if=./temp/booter.bin of=myosv3.img bs=512 count=1 2>/dev/null
dd if=./temp/kernel.bin of=myosv3.img bs=512 seek=1 count=17 2>/dev/null
dd if=./temp/topleft.com of=myosv3.img bs=512 seek=18 count=2 2>/dev/null
dd if=./temp/topright.bin of=myosv3.img bs=512 seek=20 count=2 2>/dev/null
dd if=./temp/bottomleft.bin of=myosv3.img bs=512 seek=22 count=2 2>/dev/null
dd if=./temp/bottomright.bin of=myosv3.img bs=512 seek=24 count=2 2>/dev/null
dd if=./temp/list.bin of=myosv3.img bs=512 seek=26 count=2 2>/dev/null
echo "[+] Done."

