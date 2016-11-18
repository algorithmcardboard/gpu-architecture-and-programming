/*
 *  Please write your name and net ID below
 *  
 *  Last name: Anirudhan
 *  First name: Rajagopalan
 *  Net ID: ajr619
 * 
 */

#include <cuda.h>
#include <stdlib.h>
#include <stdio.h>
#include <time.h> 
#include <math.h> 

typedef int TYPE;

TYPE* find_primes(unsigned int);
void do_gpu_seieve(TYPE*, unsigned int);
void fill_zeros(TYPE*, unsigned int);

int main(int argc, char * argv[]){
    unsigned int N;

    if(argc != 2){
        printf("Invoke with just one argument (N) that says the maximum value till which to generate primes.\n");
        return 0;
    }

    N = atoi(argv[1]);

    find_primes(N);
}

__host__ __device__
void fill_zeros(TYPE* arr, unsigned int N){
    unsigned int i = 0;
    for(i= 0; i < N; i++){
        arr[i] = 0;
    }
}

int* findAllPrimes(unsigned int N){
}

__host__
TYPE* find_primes(unsigned int N){
    unsigned int i  = 0;
    TYPE* arr = (TYPE*) malloc(N * sizeof(TYPE));
    fill_zeros(arr);
    int* primes = find_all_primes(sqrt(N));
    // Find all primes till sqrt(n)

    // Call threads with two lists.  One with array of numbers.  The other with all primes till sqrt(n).
}

__global__
void do_gpu_seieve(TYPE* arr, unsigned int N){
}
