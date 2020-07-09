#include"stdio.h"
#include"pcb.h"
#define BUFLEN 16
#define NEXTLINE putchar('\r');putchar('\n')

extern void clearScreen();
//extern char* getzifuchuan();
extern void loadrun(int size,int head,int cylinder,int sector,int offset);
extern void loadrun2(int size,int head,int cylinder,int sector,int offset);
extern void loadm(int size,int head,int cylinder,int sector,int offset);
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
    int offset;
}user[7];
void infident()
{
    user[0].id=1;
    user[0].name="topleft";
    user[0].size=2;
    user[0].cylinder=1;
    user[0].head=0;
    user[0].sector=1;
    user[0].offset=0x1000;
    //初始化用户1
    user[1].id=2;
    user[1].name="topright";
    user[1].size=2;
    user[1].cylinder=1;
    user[1].head=0;
    user[1].sector=3;
    user[1].offset=0x2000;
//初始化用户2
    user[2].id=3;
    user[2].name="bottomleft";
    user[2].size=2;
    user[2].cylinder=1;
    user[2].head=0;
    user[2].sector=5;
    user[2].offset=0x3000;
//初始化用户3
    user[3].id=4;
    user[3].name="bottomright";
    user[3].size=2;
    user[3].cylinder=1;
    user[3].head=0;
    user[3].sector=7;
    user[3].offset=0x4000;
    //初始化用户4
    user[4].id=5;
    user[4].name="system_test";
    user[4].size=2;
    user[4].cylinder=1;
    user[4].head=1;
    user[4].sector=15;
    user[4].offset=0x0B900;

    user[5].id=6;
    user[5].name="c_test";
    user[5].size=22;
    user[5].cylinder=1;
    user[5].head=0;
    user[5].sector=11;
    user[5].offset=0xB900;

    user[6].id=6;
    user[6].name="c_test";
    user[6].size=2;
    user[6].cylinder=1;
    user[6].head=1;
    user[6].sector=17;
    user[6].offset=0x8000;
}
void startos() {
    clearScreen();
    char* title = "MYOS v7";
    char* subtitle = "Chen Xianbiao, 18340020";
    char* hint = "Press ENTER to start it";
    printInPos(title, strlen(title), 7, 20);
    printInPos(subtitle, strlen(subtitle), 8, 20);
    printInPos(hint, strlen(hint), 9, 20);
    infident();
    Register_init();
    current_process=0;
    // putchar('a');
}

void showhelp() {
    char *help = 
    "    help - show information about builtin commands\r\n"
    "    clear - clean the scream\r\n"
    "    ls - show the information of user's program\r\n"
    "    run <id> - run users' programmes  example: `run 1234`\r\n"
    "    runall <id> - run users' programs together\r\n"
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
    
    const char* commands[] = {"help", "clear", "ls", "run", "time","shutdown","runall"};
    char cmd[BUFLEN+1] = {0};
    char* prompt_string = "MYOS $ ";
    char* p="the str is:";

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
                loadrun(2,0,1,9,0xB10);
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
                         if(back[i]=='1')loadrun(user[0].size, user[0].head,user[0].cylinder,user[0].sector,user[0].offset);
                         else if(back[i]=='2')loadrun(user[1].size,user[1].head,user[1].cylinder,user[1].sector,user[1].offset);
                         else if(back[i]=='3')loadrun(user[2].size,user[2].head,user[2].cylinder,user[2].sector,user[2].offset);
                         else if(back[i]=='4')loadrun(user[3].size,user[3].head,user[3].cylinder,user[3].sector,user[3].offset);
                         else if(back[i]=='5')loadrun2(user[4].size,user[4].head,user[4].cylinder,user[4].sector,user[4].offset);
                         else if(back[i]=='6')loadrun2(user[5].size,user[5].head,user[5].cylinder,user[5].sector,user[5].offset);
                         //else if(back[i]=='7')loadrun(user[6].size,user[6].head,user[6].cylinder,user[6].sector,user[6].offset);
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
        else if(strcmp(first,commands[6])==0)//runall
            {
                
                int flag=1;
                int flag124[6];
                for(int i=0;i<6;i++)flag124[i]=0;
                for(int i=0;i<backlen;i++)
                {
                    if(isnum124(back[i])!=1&&back[i]!=' '){flag=0;break;}
                    
                }
                if(flag==1)
                {
                    for(int i=0;i<backlen;i++)
                     {
                         if(back[i]=='1'&&flag124[0]==0)
                         {
                             flag124[0]=1;
                            loadm(user[0].size, user[0].head,user[0].cylinder,user[0].sector,user[0].offset);
                            pcb_table[1].zhuangtai=1;
                            pcb_table[1].reg.cs=user[0].offset;
                            pcb_table[1].reg.ds=user[0].offset;
                            pcb_table[1].reg.es=user[0].offset;
                            pcb_table[1].reg.fs=user[0].offset;
                            pcb_table[1].reg.ss=user[0].offset;
                         }
                         
                         else if(back[i]=='2'&&flag124[1]==0)
                         {
                             flag124[1]=1;
                             loadm(user[1].size,user[1].head,user[1].cylinder,user[1].sector,user[1].offset);
                            pcb_table[2].zhuangtai=1;
                            pcb_table[2].reg.cs=user[1].offset;
                            pcb_table[2].reg.ds=user[1].offset;
                            pcb_table[2].reg.es=user[1].offset;
                            pcb_table[2].reg.fs=user[1].offset;
                            pcb_table[2].reg.ss=user[1].offset;
                         }
                         else if(back[i]=='3'&&flag124[2]==0)
                         {
                             flag124[2]=1;
                                loadm(user[2].size,user[2].head,user[2].cylinder,user[2].sector,user[2].offset);
                            pcb_table[3].zhuangtai=1;
                            pcb_table[3].reg.cs=user[2].offset;
                            pcb_table[3].reg.ds=user[2].offset;
                            pcb_table[3].reg.es=user[2].offset;
                            pcb_table[3].reg.fs=user[2].offset;
                            pcb_table[3].reg.ss=user[2].offset;
                         }
                         
                         else if(back[i]=='4'&&flag124[3]==0)
                         {
                             flag124[3]=1;
                                loadm(user[3].size,user[3].head,user[3].cylinder,user[3].sector,user[3].offset);
                             pcb_table[4].zhuangtai=1;
                            pcb_table[4].reg.cs=user[3].offset;
                            pcb_table[4].reg.ds=user[3].offset;
                            pcb_table[4].reg.es=user[3].offset;
                            pcb_table[4].reg.fs=user[3].offset;
                            pcb_table[4].reg.ss=user[3].offset;
                         }
                         else if(back[i]=='7'&&flag124[5]==0)
                         {
                             flag124[5]=1;
                                loadm(user[6].size,user[6].head,user[6].cylinder,user[6].sector,user[6].offset);
                             pcb_table[7].zhuangtai=1;
                            pcb_table[7].reg.cs=user[6].offset;
                            pcb_table[7].reg.ds=user[6].offset;
                            pcb_table[7].reg.es=user[6].offset;
                            pcb_table[7].reg.fs=user[6].offset;
                            pcb_table[7].reg.ss=user[6].offset;
                         }
                        
                        //timer_flag = 0;  // 禁止时钟中断处理多进程
                     }
                     t_flag = 1;  // 允许时钟中断处理多进程
                    for( int i=0;i<5000;i++ )
		                for(int  j=0;j<5000;j++ )
		                {
			                j++;
			                j--;
		                    }
                    t_flag = 0;
                     clearScreen();
                }
                else
                {
                    char* inf="wrong program name";
                    print(inf);
                    NEXTLINE;
                }             
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


