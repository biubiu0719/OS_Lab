#!/bin/bash
rm -f myosv2.img

nasm -f bin booter.asm -o booter.bin
cd usrpro
nasm -f bin topleft.asm -o ../topleft.com
nasm -f bin topright.asm -o ../topright.com
nasm -f bin bottomleft.asm -o ../bottomleft.com
nasm -f bin bottomright.asm -o ../bottomright.com
nasm -f bin list.asm -o ../list.com
cd ..
dd if=booter.bin of=myosv2.img bs=512 count=1 2>/dev/null
dd if=topleft.com of=myosv2.img bs=512 seek=1 count=1 2>/dev/null
dd if=topright.com of=myosv2.img bs=512 seek=2 count=1 2>/dev/null
dd if=bottomleft.com of=myosv2.img bs=512 seek=3 count=1 2>/dev/null
dd if=bottomright.com of=myosv2.img bs=512 seek=4 count=1 2>/dev/null
dd if=list.com of=myosv2.img bs=512 seek=5 count=2 2>/dev/null
rm *.bin
rm *.com

