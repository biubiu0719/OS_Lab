#include"stdio.h"
#define BUFLEN 16
#define NEXTLINE putchar('\r');putchar('\n')
int main()
{
    char *prin="your str is:\n";
    my_printf(prin);

    char str[50];
    int number;
    char *scan="%s%d";
    my_scanf(scan,str,&number);//测试my_scanf

    char* temp="str:%s,number:%d\n";
    my_printf(temp,str,number);//测试my_printf

    char str2[50]="test gets and puts:\n\r";
    puts(str2);//显示提示

    gets(str2);//测试gets
    puts(str2);

    putchar('q');
    getch();
}