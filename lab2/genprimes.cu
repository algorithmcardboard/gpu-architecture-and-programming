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

typedef unsigned int TYPE;

#define BLOCK_WIDTH 1024;

TYPE* find_primes(unsigned int);
void do_seieve(TYPE*, unsigned int);
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

__host__
TYPE* find_primes(unsigned int N){
    unsigned int i  = 0;
    TYPE* arr = (TYPE*) malloc(N * sizeof(TYPE));
    fill_zeros(arr);

    int* primes = find_all_primes(sqrt(N));

	TYPE *d_arr;

	cudaMalloc((void **) &d_arr, N*sizeof(TYPE));

	cudaMemcpy(d_arr, arr, N*sizeof(TYPE), cudaMemcpyHostToDevice);

	dim3 gridDimension(ceil(N/(float)BLOCK_WIDTH), 1, 1);
	dim3 blockDimension(BLOCK_WIDTH, 1, 1);

    unsigned int nextPrime = 1;
    unsigned int stopValue = (N+1)/2 + 1;

    do{
    }while(nextPrime < (N+1)/2);
}

__global__
void do_seieve(TYPE* arr, unsigned int N){
}
