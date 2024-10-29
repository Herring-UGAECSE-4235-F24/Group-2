#include <stdio.h>
#include <stdint.h>

//multigpio(int array, int length, int value);
extern uint16_t E4235_multiread(int[], int);
extern int E4235_multiwrite(int[], int, uint16_t);

int arrin[] = {22, 6};
int arrout[] = {23, '-', 25, 26};

int main() {

  E4235_multiwrite(arrin, 2, 0x0002);
  uint16_t bin = E4235_multiread(arrout, 4);

  printf("%d\n", bin);
  return (0);
}
