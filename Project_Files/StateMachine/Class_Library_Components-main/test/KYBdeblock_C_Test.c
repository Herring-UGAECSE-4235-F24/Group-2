#include <stdio.h>
#include <stdlib.h>
#include "E4235.h"

int main() {
    char input[4]; // variable to hold keyboard input
    while (1) {
        scanf("%s", &input); // gets command input
        if (input[0] == 'b') E4235_KYBdeblock(0); // sets blocking
        else if (input[0] == 'd') E4235_KYBdeblock(1); // sets nonblocking
        else if (input[0] == 'q') exit(0); // quits
        printf("hello there general kenobi\n");
    } // while
} // main
