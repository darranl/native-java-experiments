#include <stdio.h>

#include "simple-library.h"

int main(int, char**){
    printf("Hello, from simple-c-app!\n");

    int a  = 5;
    printf("add_one(%d) = %d\n", a, add_one(a));

    say_hello();
}
