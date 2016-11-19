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

#define BLOCK_WIDTH 1024

TYPE* find_primes(unsigned int, int);
__global__
void do_seieve(TYPE*, unsigned int*, unsigned int, int);
void fill_zeros(TYPE*, unsigned int);

int main(int argc, char * argv[]){
    unsigned int N;

    if(argc != 2){
        printf("Invoke with just one argument (N) that says the maximum value till which to generate primes.\n");
        return 0;
    }

    N = atoi(argv[1]);

    find_primes(N, 1);
}

void fill_zeros(TYPE* arr, unsigned int N){
    unsigned int i = 0;
    for(i= 0; i < N; i++){
        arr[i] = 0;
    }
}

unsigned int* find_next_primes(unsigned int* arr, unsigned int* primes, unsigned int last_prime, int k, unsigned int N){
    int i = 0;
    int j = last_prime;
    for(j = last_prime; j < N && i < k; j++){
        if(arr[j] == 0){
            primes[i++] = j + 1;
        }
    }

    return primes;
}

__host__
TYPE* find_primes(unsigned int N, int k){
    TYPE* arr = (TYPE*) malloc(N * sizeof(TYPE));
    fill_zeros(arr, N);

	TYPE *d_arr, *d_primes;

	cudaMalloc((void **) &d_arr, N*sizeof(TYPE));
	cudaMalloc((void **) &d_primes, k*sizeof(int));

	cudaMemcpy(d_arr, arr, N*sizeof(TYPE), cudaMemcpyHostToDevice);;

	dim3 gridDimension(ceil(N/(float)BLOCK_WIDTH), 1, 1);
	dim3 blockDimension(BLOCK_WIDTH, 1, 1);

    int i = 0;
    d_arr[0] = 1;

    unsigned int last_prime = 1;
    unsigned int* primes = (unsigned int*)malloc(k*sizeof(int));

    do{
        primes = find_next_primes(arr, primes, last_prime, k, N);
        for(i = 0; i < k; i++){
            if(*(primes + i) > last_prime){
                last_prime = *(primes + i);
            }
        }
        cudaMemcpy(d_primes, primes, N*sizeof(int), cudaMemcpyHostToDevice);
        do_seieve<<<gridDimension, blockDimension>>>(d_arr, d_primes, N, k);
    }while(last_prime < (N+1)/2);

    cudaMemcpy(arr, d_arr, N*sizeof(TYPE), cudaMemcpyDeviceToHost);
    return arr;
}

__global__
void do_seieve(TYPE* d_arr, unsigned int* d_primes, unsigned int N, int k){
	int id = blockIdx.x * blockDim.x + threadIdx.x;

    int i = 0;
    for(i = 0; i < k; i++){
        if(id % d_primes[k] == 0){
            d_arr[id] = 1;
        }
    }
}
