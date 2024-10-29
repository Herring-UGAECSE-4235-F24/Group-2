
#include <stdio.h>

extern int deblock();

int main() {
    int input = 0;
    char output[] = "xxxx\n";

    while (1) {
        scanf("%d", &input);
        int ret = deblock(input);
        printf("%s", output);
    }
    

    return(0);
}

