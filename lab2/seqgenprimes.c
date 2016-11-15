#include<stdio.h>
#include<stdlib.h>

typedef int TYPE;

int findNextPrime(TYPE* arr, int length, int lastPrime){
    int i = lastPrime + 1;
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

    int N = atoi(argv[1]);
    TYPE* arr = (TYPE*)calloc(N*(sizeof(TYPE)), 1);
    arr[0] = 1;

    int lastPrime = 1;
    do{
        int prime = findNextPrime(arr, N, lastPrime);
        //printf("prime is %d", prime);
        for(int i = prime * 2; i <= N; i = i + prime){
            arr[i - 1] = 1;
            //printf("prime is %d. Index is %d.  Value is %d\n", prime, i, arr[i-1]);
        }
        lastPrime = prime;
    }while(lastPrime < (N+1)/2);

    for(int i = 0; i < N; i++){
        if(arr[i] == 0){
            printf("%d ", i+1);
        }
    }
}
