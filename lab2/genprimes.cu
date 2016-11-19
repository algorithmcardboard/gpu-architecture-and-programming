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
#include <cuda_profiler_api.h>

typedef unsigned int TYPE;

#define BLOCK_WIDTH 1024
#define PRIME_SIZE 2046

TYPE* find_primes(unsigned int, int);
__global__
void do_seieve(TYPE*, unsigned int*, unsigned int, int);
void fill_zeros(TYPE*, unsigned int);

int main(int argc, char * argv[]){
    unsigned int N;
    int i = 0;

    if(argc != 2){
        printf("Invoke with just one argument (N) that says the maximum value till which to generate primes.\n");
        return 0;
    }

    N = atoi(argv[1]);

    //printf("N is %d\n", N);

    unsigned int count = 0;

    TYPE* arr = find_primes(N, N>10240?PRIME_SIZE:4);

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

void fill_zeros(TYPE* arr, unsigned int N){
    unsigned int i = 0;
    for(i= 0; i < N; i++){
        arr[i] = 0;
    }
    //printf("Filling zeros");
}

unsigned int* find_next_primes(unsigned int* arr, unsigned int* primes, unsigned int last_prime, int k, unsigned int N){
    int i = 0;
    int j = last_prime + 1;
    for(; j < N && i < k; j++){
        if(arr[j] == 0){
            primes[i++] = j;
        }
    }
    //printf("\n");

    return primes;
}

__host__
TYPE* find_primes(unsigned int N, int k){
    TYPE* arr = (TYPE*) malloc(N * sizeof(TYPE));
    unsigned int* primes = (unsigned int*)malloc(k*sizeof(int));
    unsigned int last_prime = 0;

    fill_zeros(arr, N);
    arr[0] = 1;

    cudaProfilerStart();
	TYPE *d_arr, *d_primes;

	cudaMalloc((void **) &d_arr, N*sizeof(TYPE));
	cudaMalloc((void **) &d_primes, k*sizeof(int));
    //printf("allocated device memory \n");

	cudaMemcpy(d_arr, arr, N*sizeof(TYPE), cudaMemcpyHostToDevice);;

    //printf("Copied to device \n");

	dim3 gridDimension(ceil(N/(float)BLOCK_WIDTH), 1, 1);
	dim3 blockDimension(BLOCK_WIDTH, 1, 1);

    int i = 0;

    do{
        find_next_primes(arr, primes, last_prime, k, N);
        for(i = 0; i < k; i++){
            if(*(primes + i) > last_prime){
                last_prime = *(primes + i);
            }
        }
        //printf("primes is %d.  Last prime is %d\n", primes[0], last_prime);
        cudaMemcpy(d_primes, primes, k*sizeof(int), cudaMemcpyHostToDevice);
        do_seieve<<<gridDimension, blockDimension>>>(d_arr, d_primes, N, k);
        cudaMemcpy(arr, d_arr, N*sizeof(TYPE), cudaMemcpyDeviceToHost);
    }while(last_prime < (N+1)/2);

    cudaMemcpy(arr, d_arr, N*sizeof(TYPE), cudaMemcpyDeviceToHost);
    cudaProfilerStop();
    return arr;
}

__global__
void do_seieve(TYPE* d_arr, unsigned int* d_primes, unsigned int N, int k){

    int i, id = blockIdx.x * blockDim.x + threadIdx.x + 1;

    if(id > N || d_arr[id-1] == 1 || id < d_primes[0]+1){
        return;
    }


    for(i = 0; i < k; i++){
        if(id != (d_primes[i]+1) && (id % (d_primes[i]+1) == 0)){
            d_arr[id -1] = 1;
            break;
            //printf("id is %d. prime is %d\n", id, d_primes[i]+1);
        }
    }
}
