# README

## 1.`booter.asm`

引导程序

## 2.`kernel`文件夹

由kennel.asm,kernel_a.asm,kernel_c.c和stdio.h,ouch.asm,**register.h**组成

共同组成内核代码

## 3.`usrprog`文件夹

由topleft.asm,topright.asm,bottomleft.asm,bottomright.asm和list.asm组成

各自是用户程序代码

- #### 其中c_test文件夹

包含c基本库实现的测试程序**main.c,main.asm,stdio.h**

## 4.`temp`文件夹

存储汇编后的二进制文件

## 5.lib文件夹

包含**system_a.asm和system_c.c**（系统调用的函数实现）

## 6.`combine.sh`

整合脚本，需要在linux下运行

## 7.`myosv5.img`

软盘镜像文件，可在`VM VirtualBox`运行

## 8.`bochsrc`

bochs调试的配置文件