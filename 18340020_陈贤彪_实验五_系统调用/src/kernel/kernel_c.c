#include"stdio.h"
#include"register.h"
#define BUFLEN 16
#define NEXTLINE putchar('\r');putchar('\n')

extern void clearScreen();
//extern char* getzifuchuan();
extern void loadrun(int size,int head,int cylinder,int sector);
extern void loadrun2(int size,int head,int cylinder,int sector);
extern int getDateYear();
extern int getDateMonth();
extern int getDateDay();
extern int getDateHour();
extern int getDateMinute();
extern int getDateSecond();
extern void shutdown();
extern char name[];
struct usepro
{
    int id;
    char* name;//程序名
    int size;//程序大小
    int cylinder;//柱面号
    int head;//磁头号
    int sector;//首扇区
}user[5];
void infident()
{
    user[0].id=1;
    user[0].name="topleft";
    user[0].size=2;
    user[0].cylinder=1;
    user[0].head=0;
    user[0].sector=1;
    //初始化用户1
    user[1].id=2;
    user[1].name="topright";
    user[1].size=2;
    user[1].cylinder=1;
    user[1].head=0;
    user[1].sector=3;
//初始化用户2
    user[2].id=3;
    user[2].name="bottomleft";
    user[2].size=2;
    user[2].cylinder=1;
    user[2].head=0;
    user[2].sector=5;
//初始化用户3
    user[3].id=4;
    user[3].name="bottomright";
    user[3].size=2;
    user[3].cylinder=1;
    user[3].head=0;
    user[3].sector=7;
    //初始化用户4
    user[4].id=5;
    user[4].name="system_test";
    user[4].size=2;
    user[4].cylinder=1;
    user[4].head=1;
    user[4].sector=17;

    user[5].id=6;
    user[5].name="c_test";
    user[5].size=24;
    user[5].cylinder=1;
    user[5].head=0;
    user[5].sector=11;
}
void startos() {
    clearScreen();
    char* title = "MYOS v5";
    char* subtitle = "Chen Xianbiao, 18340020";
    char* hint = "Press ENTER to start it";
    printInPos(title, strlen(title), 7, 20);
    printInPos(subtitle, strlen(subtitle), 8, 20);
    printInPos(hint, strlen(hint), 9, 20);
    infident();
    // putchar('a');
}

void showhelp() {
    char *help = 
    "    help - show information about builtin commands\r\n"
    "    clear - clean the scream\r\n"
    "    ls - show the information of user's program\r\n"
    "    run <id> - run users' programmes  example: `run 1234`\r\n"
    "    time - show the time\r\n"
    "    shutdown - shutdown the os\r\n"
    ;
    print_color(help,10);
}
int getnumofchar(char* str,char need)
{
    int num=0;
    for(int i=0;i<strlen(str);i++)
    {
        if(str[i]==need)
        {
            num++;
        }
    }
    return num;
}
void cmd()
{
    
    clearScreen();//清屏
    int qqq=7;
    
    const char* commands[] = {"help", "clear", "ls", "run", "time","shutdown"};
    char cmd[BUFLEN+1] = {0};
    char* prompt_string = "MYOS $ ";
    //print(name);
    //print(name);
    //putchar(name[0]);
    //char* ppp="123456%d%s%c\n";
    //my_printf(ppp,qqq,prompt_string,'a');
    char* p="the str is:";
    //char *p;
    //char test[100];
    //char test_c;
    //const char* scan="%s%c";
    //my_scanf(scan,test,&test_c);
    //putchar(test_c);
    //print(test);
    print(p);
     //p=getzifuchuan();
     p=name;
    print(p);
    NEXTLINE;
    int len=strlen(p);
    char* lll="the len of str:";
    print(lll);
    char *q=itoa(len,10);
    print(q);
    NEXTLINE;
    int charnum=getnumofchar(p,'1');
    q=itoa(charnum,10);
    lll="num of a in the str:";
    print(lll);
    print(q);
    //putchar(len);
    
    NEXTLINE;
    showhelp();
    while(1)
    {
            print_color(prompt_string,9);
            readcmd(cmd, BUFLEN);
            //print(cmd);
            char first[BUFLEN+1]={0};
            getFirstWord(cmd,first);
             //print(first);
             //NEXTLINE;
            char back[BUFLEN+1]={0};

            getbackWord(cmd,back);
            int backlen=strlen(back);
            //char *ll=itoa(backlen,10);
           // print(ll);
            //NEXTLINE;
            // print(back);
            // NEXTLINE;
            if(strcmp(first,commands[0])==0)//help
            {
                showhelp();
            }
            else if(strcmp(first,commands[1])==0)//clear
            {
                clearScreen();
            }
            else if(strcmp(first,commands[2])==0)//ls
            {
                loadrun(2,0,1,9);
                clearScreen();
            }
            else if(strcmp(first,commands[3])==0)//run
            {
                
                int flag=1;
                for(int i=0;i<backlen;i++)
                {
                    if(isnum126(back[i])!=1&&back[i]!=' '){flag=0;break;}
                    
                }
                if(flag==1)
                {
                    for(int i=0;i<backlen;i++)
                     {
                         if(back[i]=='1')loadrun(user[0].size, user[0].head,user[0].cylinder,user[0].sector);
                         else if(back[i]=='2')loadrun(user[1].size,user[1].head,user[1].cylinder,user[1].sector);
                         else if(back[i]=='3')loadrun(user[2].size,user[2].head,user[2].cylinder,user[2].sector);
                         else if(back[i]=='4')loadrun(user[3].size,user[3].head,user[3].cylinder,user[3].sector);
                         else if(back[i]=='5')loadrun(user[4].size,user[4].head,user[4].cylinder,user[4].sector);
                         else if(back[i]=='6')loadrun2(user[5].size,user[5].head,user[5].cylinder,user[5].sector);
                     }
                     clearScreen();
                }
                else
                {
                    char* inf="wrong program name";
                    print(inf);
                    NEXTLINE;
                }             
            }
            else if(strcmp(first,commands[4])==0)//time
            {
                putchar('2');
                putchar('0');
                print(itoa(bcd2dec(getDateYear()), 10)); putchar(' ');
                print(itoa(bcd2dec(getDateMonth()), 10)); putchar(' ');
                print(itoa(bcd2dec(getDateDay()), 10)); putchar(' ');
                print(itoa(bcd2dec(getDateHour()), 10)); putchar(':');
                print(itoa(bcd2dec(getDateMinute()), 10)); putchar(':');
                print(itoa(bcd2dec(getDateSecond()), 10));
                NEXTLINE;
            }
	    else if(strcmp(first,commands[5])==0)//shutdown
            {
                shutdown();
            }
            else
            {
                char* inf="wrong cmd";
                    print(inf);
                    NEXTLINE;
            }
            
    }
    //clearScreen();
}


