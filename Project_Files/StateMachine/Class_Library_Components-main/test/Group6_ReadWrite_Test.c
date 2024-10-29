#include <stdio.h>
#include <stdlib.h>
extern void gPIOwrite(int, int);
extern int gPIOread(int, int);
extern void gPIOselect(int, int);
#define WRITE 0
#define READ 1
#define LOW 0
#define HIGH 1
int main()
{
    gPIOwrite(20, LOW);
    int a = gPIOread(2,HIGH);
    printf("Returned value:%d\n", a);
    return(0);
}