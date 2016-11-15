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
    TYPE* arr = (TYPE*)calloc(N, sizeof(TYPE));
    arr[0] = 1;

    unsigned int lastPrime = 1;
    unsigned int stopValue = (N+1)/2 + 1;
    while(lastPrime < stopValue){
        unsigned int prime = findNextPrime(arr, N, lastPrime);
        for(unsigned int i = prime * prime; i <= N; i = i + prime){
            arr[i - 1] = 1;
            //printf("prime is %d. Index is %d.  Value is %d\n", prime, i, arr[i-1]);
        }
        lastPrime = prime;
    }while(lastPrime < (N+1)/2);

    for(unsigned int i = 0; i < N; i++){
        if(arr[i] == 0){
            printf("%d ", i+1);
        }
    }
}
