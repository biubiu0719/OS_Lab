

extern void printInPos(char *msg, int len, int row, int col);//在指定位置打印字符串
extern void putchar_color(char c,int color);//在光标处打印一个字符
extern char getch();//获取键盘输入
#include"stdarg.h"
//获取字符串长度
int strlen(const char *str) {
    int count = 0;
    while (str[count] != '\0')
    {
        count++;
    }
    return count ;  // 循环中使用后递增，因此这里需要减1
}

//比较字符串
int strcmp(const char* str1, const char* str2) {
    int i = 0;
    while (1) {
        if(str1[i]=='\0' || str2[i]=='\0')
         { 
            break; 
        }
        if(str1[i] != str2[i]) 
        { 
            break; 
        }
        ++i;
    }
    return str1[i] - str2[i];
}

void putchar(char c) {
    putchar_color(c, 0x07);
}

//光标处打印字符串
void print(const char* str) {
    int len=strlen(str);
    for(int i = 0; i < len; i++) {
        putchar(str[i]);
    }
}
void print1(const char* str) {
    char*aaa="aaaa\n";
    print(aaa);
    putchar('\n');
}
void print_color(char* str,int color) {
    int len=strlen(str);
    for(int i = 0; i < len; i++) {
        putchar_color(str[i],color);
    }
}
void readcmd(char* buffer,int maxlen)
{
    int i=0;
    while(1)
    {
        char tempc=getch();
        if(!(tempc==0xD || tempc=='\b' || tempc>=32 && tempc<=127))
        {
            continue;
        }
        if(i>0&&i<maxlen-1)
        {
            if(tempc==0x0D)
            {
                break;//回车，停止读取
            }
            else if(tempc=='\b')//删除键
            {
                putchar('\b');
                putchar(' ');
                putchar('\b');
                i--;
            }
            else
            {
                putchar_color(tempc,9);  
                buffer[i] = tempc;
                ++i;
            }         
        }
        else if(i>=maxlen-1)//达到字符最大值，只能退课或回车
        {
                if(tempc == '\b') 
                {  // 按下退格，则删除一个字符
                putchar('\b');
                putchar(' ');
                putchar('\b');
                i--;
                }
            else if(tempc == 0x0D) 
            {
                break;  // 按下回车，停止读取
            }
        }
        else if(i<=0)
        {
            if(tempc == 0x0D) {
                break;  // 按下回车，停止读取
            }
            else if(tempc != '\b') {
                putchar_color(tempc,9);  
                buffer[i] = tempc;
                ++i;
            }
        }
    }
    putchar('\r'); putchar('\n');
    buffer[i] = '\0';  
}

void getFirstWord(const char* str, char* buf) //获取指令头
{
    int i = 0;
    while(str[i] && str[i] == ' ')
    {
      i++;
    }
    int j=0;
    while(str[i] &&str[i] != ' ') {
        buf[j] = str[i];
        i++;
        j++;
    }
    buf[j] = '\0'; 
}

void getbackWord(const char* str, char* buf) 
{
    buf[0] = '\0';  
    int i = 0;
    while(str[i] && str[i] == ' ') {
        i++;
    }//过滤掉指令前的空格
    while(str[i] && str[i] != ' ') {
        i++;
    }//过滤掉指令头
    while(str[i] && str[i] == ' ') {
        i++;
    }//过滤掉中间的空格
    int j = 0;
    while(str[i]) {
        buf[j++] = str[i++];
    }
    buf[j] = '\0';  
}
//数字转字符串
char* itoa(int val, int jinzhi) 
{
	if(val==0) return "0";
	static char buf[32] = {0};
	int i = 30;
	for(; val && i ; --i, val /= jinzhi) {
		buf[i] = "0123456789ABCDEF"[val % jinzhi];
    }
	return &buf[i+1];
}
//判断是否是数字
int isnum(char c) {
    return c>='0' && c<='9';
}

int isnum126(char c) {//看数字是否是从1-4
    return c>='1' && c<='7';
}
int isnum124(char c) {//看数字是否是从1-4
    return c>='1' && c<='9';
}
int bcd2dec(int bcd)//bcd码转2进制用于转时间
{
    return ((bcd & 0xF0) >> 4) * 10 + (bcd & 0x0F);
}
extern char* itoa_c(int num, int base, char* str);
int my_printf(const char* fmt,...)
{
    //const char* fmt=fmt1;
    va_list arg_ptr;
    char arry[100];
    char *str;
    va_start(arg_ptr,fmt);
    while((*fmt)!='\0')
    {
        if(*fmt=='\n')
        {
            putchar('\n');
            putchar('\r');
        }
        else if(*fmt=='%')
        {
            fmt++;
            switch(*fmt)
            {
                case 'd':
                {
                    itoa_c(va_arg(arg_ptr,int),10,arry);
                    str=arry;
                    while(*str!='\0')
                    {
                        putchar(*str);
                        str++;
                    }
                }break;
                case 's':
                {
                    str=va_arg(arg_ptr,char*);
                    while(*str!='\0')
                    {
                        putchar(*str);
                        str++;
                    }
                }break;
                case 'c':
                {
                    putchar(va_arg(arg_ptr,int));
                }break;
                default:break;
            }
        }
        else
        {
            putchar(*fmt);
        }
        fmt++;
    }
    va_end(arg_ptr);
    str=(char*)0;
}
extern int atoi_c(char *str);
void my_scanf(const char* fmt,...)
{
    va_list arg_ptr;
    int dec;
    int *d_ptr;
    char str[50];
    char *s_ptr;
    char *c;
    va_start(arg_ptr,fmt);
    while((*fmt)!='\0')
    {
        if(*fmt=='%')
        {
            fmt++;
            switch(*fmt)
            {
                case 'd':
                {
                    readcmd(str,16);
                    dec=atoi_c(str);
                    d_ptr=va_arg(arg_ptr,int*);
                    *d_ptr=dec;
                }break;
                case 's':
                {
                    s_ptr=va_arg(arg_ptr,char*);
                    readcmd(s_ptr,16);
                }break;
                case 'c':
                {
                    c=va_arg(arg_ptr,char*);
                    readcmd(str,2);
                    *c=str[0];
                }break;
                default:break;
            }
            
        }
        else{

            }
            fmt++;
    }
    va_end(arg_ptr);
    s_ptr=(char*)0;
    d_ptr=(int*)0;
}