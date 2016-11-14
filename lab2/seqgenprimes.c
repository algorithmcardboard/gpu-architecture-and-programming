#include<stdio.h>
#include<stdlib.h>

int main(int argc, char** argv){
    if(argc != 2){
        printf("not enough arguments");
        exit(0);
    }

    int N = atoi(argv[1]);
    printf("Input n is %d \n", N);
}
