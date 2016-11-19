#include<stdio.h>
#include<stdlib.h>

typedef int TYPE;

unsigned int findNextPrime(TYPE* arr, unsigned int length, unsigned int lastPrime){
    unsigned int i = lastPrime + 1;
    for(; i < length; i++){
        if(arr[i-1] == 0){
            break;
        }
    }
    //printf("Returning %d\n", i);
    return i;
}

int main(int argc, char** argv){
    if(argc != 2){
        printf("not enough arguments");
        exit(0);
    }

    unsigned int N = atoi(argv[1]);
    unsigned int i;
    int count = 0;
    TYPE* arr = (TYPE*)calloc(N, sizeof(TYPE));
    arr[0] = 1;

    unsigned int lastPrime = 1;
    do{
        unsigned int prime = findNextPrime(arr, N, lastPrime);
        for(unsigned int i = prime * 2; i <= N; i = i + prime){
            arr[i - 1] = 1;
            //printf("prime is %d. Index is %d.  Value is %d\n", prime, i, arr[i-1]);
        }
        lastPrime = prime;
    }while(lastPrime < (N+1)/2);

    char buf[12];
    sprintf(buf, "%d.txt", N);
    FILE *fp = fopen(buf,"a");
    if(fp == NULL){
        printf("error opening file");
        return 0;
    }
    for(i = 0; i < N; i++){
        if(arr[i] == 0){
            fprintf(fp, "%d ", i + 1);
            count = count + 1;
        }
    }
    printf("Count is %d\n", count);
}
