#include <stdio.h>
#include <stdlib.h>
extern void e4235_MultiGPIOWrite(char [], int);
extern int e4235_MultiGPIORead(char []);
#define LOW 0
#define HIGH 1
int main()
{
    char *input = "5 6";
    e4235_MultiGPIOWrite(input, HIGH);
    char *inputTwo = "2-3";
    int output = e4235_MultiGPIORead(inputTwo);
    printf("%d\n", output);
    if( 0b11 == output)
        printf("Pins are High\n");
    else 
        printf("Pins are low\n");
    return(0);
}
