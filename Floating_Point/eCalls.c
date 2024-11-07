#include <stdio.h>

extern float factorial(float);
extern float exponential(float, int);

int main() {
	while(1) {
		printf("Enter 0(n!), 1(x^n), or 2(e^x)");
		int d = -1;
		scanf("%d",&d);
		if d == 0
		{
			float x = 0.0;
			printf("Enter n: ");
			scanf("%f",&x);
			x = factorial(x);
			printf("%f\n", x);
		} else if d == 1 {
			float x = 0.0;
			float n = 0.0;
			printf("Enter n: ");
			scanf("%f",&x);
			x = exponential(x);
			printf("%f\n", x);
		else if d ==2 {
			float x = 0.0;
			printf("Enter n: ");
			scanf("%f",&x);
			printf("Calculate e^x. Enter x: ");
			scanf("%f", &x);
			float exp = 1 + exponential(x, 2) / factorial(2) + (exponential(x, 3) / factorial(3)) + (exponential(x, 4) / factorial(4)) + (exponential(x, 5) / factorial(5));
			printf("%f\n", exp);
		}
	}
	return(0);
}
