#!/bin/bash

output_file="myos.img"
asm_files=("booter" "kernel" "topleft" "topright" "bottomleft" "bottomright")


rm -f ${output_file}

for asm_file in ${asm_files[@]}
do
	nasm ${asm_file}.asm -o ${asm_file}.img
    cat ${asm_file}.img >> "${output_file}"
    rm -f ${asm_file}.img
    echo "[+] ${asm_file} done"
done

echo "[+] ${output_file} generated successfully."
