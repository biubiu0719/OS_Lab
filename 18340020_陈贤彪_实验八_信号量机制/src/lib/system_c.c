

void toupper_c(char* str) {
    int i=0;
    while(str[i]) {
        if (str[i] >= 'a' && str[i] <= 'z')  
        str[i] = str[i]-'a'+'A';
        i++;
    }
}

void tolower_c(char* str) {
    int i=0;
    while(str[i]) {
        if (str[i] >= 'A' && str[i] <= 'Z')  
        str[i] = str[i]-'A'+'a';
        i++;
    }
}
//字符串转数字
extern int strlen(char *);
int atoi_c(char *str) {
    int res = 0; // Initialize result 
 int len=strlen(str);
    for (int i = 0; i<len; ++i) {
        res = res*10 + str[i] - '0'; 
    }
    // return result. 
    return res; 
}
void reverse(char str[], int len)
{
	int start, end;
	char temp;
	for (start = 0, end = len - 1; start < end; start++, end--) {
		temp = *(str + start);
		*(str + start) = *(str + end);
		*(str + end) = temp;
	}
}
char* itoa_c(int num, int base, char* str)
{
	int i = 0;
	int isNegative = 0;
	if (num == 0) {
		str[i] = '0';
		str[i + 1] = '\0';
		return str;
	}
	if (num < 0 && base == 10) {
		isNegative =1;
		num = -num;
	}
	while (num != 0) {
		int rem = num % base;
		str[i++] = (rem > 9) ? (rem - 10) + 'A' : rem + '0';
		num = num / base;
	}
	if (isNegative==1) {
		str[i++] = '-';
	}
	str[i] = '\0';
	reverse(str, i);
	return str;
}