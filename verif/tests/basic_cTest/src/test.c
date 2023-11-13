#include <stdio.h>

// Function to calculate factorial
unsigned int factorial(int n) {
    if (n == 0 || n == 1) {
        return 1; // Factorial of 0 and 1 is 1
    } else {
        return n * factorial(n - 1); // Recursive calculation for n > 1
    }
}

int main() {
   int num = 5;    
   int res = factorial(num); //Expected 120

   return (res == 120) ? 0 : 1;
}
