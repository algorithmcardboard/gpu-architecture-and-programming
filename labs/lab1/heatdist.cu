/*
 *  Please write your name and net ID below
 *  
 *  Last name: Anirudhan
 *  First name: Rajagopalan
 *  Net ID: ajr619
 * 
 */


/* 
 * This file contains the code for doing the heat distribution problem. 
 * You do not need to modify anything except starting  gpu_heat_dist() at the bottom
 * of this file.
 * In gpu_heat_dist() you can organize your data structure and the call to your
 * kernel(s) that you need to write too. 
 * 
 * You compile with:
 * 		nvcc -o heatdist heatdist.cu   
 */

#include <cuda.h>
#include <stdlib.h>
#include <stdio.h>
#include <time.h> 

/* To index element (i,j) of a 2D array stored as 1D */
#define index(i, j, N)  ((i)*(N)) + (j)

/* Block width definition */
//define BLOCK_WIDTH 16.0

/*****************************************************************/

// Function declarations: Feel free to add any functions you want.
void  seq_heat_dist(float *, unsigned int, unsigned int);
void  gpu_heat_dist(float *, unsigned int, unsigned int, unsigned int);
float  sum_playground(float *, unsigned int);
float* init_playground(unsigned int);
void do_heat_distribution(unsigned int, unsigned int, unsigned int);

/*****************************************************************/

int main(int argc, char * argv[])
{
	unsigned int N; /* Dimention of NxN matrix */
	unsigned int iterations = 0;
	unsigned int block_sizes[] = {8, 16, 32};

	if(argc != 4)
	{
		fprintf(stderr, "usage: heatdist num  iterations  who\n");
		fprintf(stderr, "num = dimension of the square matrix (50 and up)\n");
		fprintf(stderr, "iterations = number of iterations till stopping (1 and up)\n");
		fprintf(stderr, "who = 0: sequential code on CPU, 1: GPU execution\n");
		exit(1);
	}

	//type_of_device = atoi(argv[3]);
	N = (unsigned int) atoi(argv[1]);
	iterations = (unsigned int) atoi(argv[2]);

	printf("N \t cpu_time \t gpu_time \t cpu_sum \t gpu_sum");

	N = 100;
	while(N < 10 * 1000){
		for(int i = 0; i < 3; i++){
			do_heat_distribution(N, block_sizes[i], iterations);
		}
		N = N * 2;
	}

	return 0;
}

void do_heat_distribution(unsigned int N, unsigned int block_size, unsigned int iterations){
	float* playground;
	float gpu_sum = 0, cpu_sum = 0;

	// to measure time taken by a specific part of the code 
	double cpu_time, gpu_time;
	clock_t start, end;

	playground = init_playground(N);
	//printf("sum is %f \n", sum_playground(playground, N));
	start = clock();
	seq_heat_dist(playground, N, iterations);
	end = clock();

	cpu_time = ((double) (end - start));
	//printf("Time taken for %s is %lf\n", "CPU", cpu_time);

	cpu_sum = sum_playground(playground, N);
	//printf("Sum is %f\n", cpu_sum);

	free(playground);

	playground = init_playground(N);
	//printf("sum is %f \n", sum_playground(playground, N));
	start = clock();
	gpu_heat_dist(playground, N, iterations, block_size); 
	end = clock();    

	gpu_time = ((double) (end - start));
	//printf("Time taken for %s is %lf\n", "GPU", gpu_time);

	gpu_sum = sum_playground(playground, N);
	//printf("Sum is %f\n", gpu_sum);

	free(playground);

	printf("%d \t %lf \t %lf \t %f \t %f \n", N, cpu_time, gpu_time, cpu_sum, gpu_sum);

}

float* init_playground(unsigned int N){
	/* The 2D array of points will be treated as 1D array of NxN elements */
	float * playground; 

	int i;

	/* Dynamically allocate NxN array of floats */
	playground = (float *)calloc(N*N, sizeof(float));
	if( !playground )
	{
		fprintf(stderr, " Cannot allocate the %u x %u array\n", N, N);
		exit(1);
	}

	/* Initialize it: calloc already initalized everything to 0 */
	// Edge elements to 80F
	for(i = 0; i < N; i++){
		playground[index(0,i,N)] = 80;
	}

	for(i = 0; i < N; i++){
		playground[index(i,0,N)] = 80;
	}

	for(i = 0; i < N; i++){
		playground[index(i,N-1, N)] = 80;
	}

	for(i = 0; i < N; i++){
		playground[index(N-1,i,N)] = 80;
	}

	// from (0,10) to (0,30) inclusive are 150F
	for(i = 10; i <= 30 && i < N; i++){
		playground[index(i,0,N)] = 150;
	}
	
	return playground;
}

float  sum_playground(float* playground, unsigned int N){
	int i;
	float sum = 0.0;
	for(i = 0; i < N*N; i++){
		sum = sum + playground[i];
	}
	return sum;
}


/*****************  The CPU sequential version (DO NOT CHANGE THAT) **************/
void  seq_heat_dist(float * playground, unsigned int N, unsigned int iterations)
{
	// Loop indices
	int i, j, k;
	int upper = N-1;

	// number of bytes to be copied between array temp and array playground
	unsigned int num_bytes = 0;

	float * temp; 
	/* Dynamically allocate another array for temp values */
	/* Dynamically allocate NxN array of floats */
	temp = (float *)calloc(N*N, sizeof(float));
	if( !temp )
	{
		fprintf(stderr, " Cannot allocate temp %u x %u array\n", N, N);
		exit(1);
	}

	num_bytes = N*N*sizeof(float);

	/* Copy initial array in temp */
	memcpy((void *)temp, (void *) playground, num_bytes);

	for( k = 0; k < iterations; k++)
	{
		/* Calculate new values and store them in temp */
		for(i = 1; i < upper; i++)
			for(j = 1; j < upper; j++)
				temp[index(i,j,N)] = (playground[index(i-1,j,N)] + 
						playground[index(i+1,j,N)] + 
						playground[index(i,j-1,N)] + 
						playground[index(i,j+1,N)])/4.0;



		/* Move new values into old values */ 
		memcpy((void *)playground, (void *) temp, num_bytes);
	}

}

__global__
void calculate_temperature(float* d_playground, float* d_temp, int N){
	int row = blockIdx.y * blockDim.y + threadIdx.y;
	int col = blockIdx.x * blockDim.x + threadIdx.x;

	if(row < 1 || row >= N-1 || col < 1 || col >= N-1){
		return;
	}

	d_temp[index(row, col, N)] = (d_playground[index(row-1, col, N)] + 
					d_playground[index(row+1, col, N)] + 
					d_playground[index(row, col + 1, N)] + 
					d_playground[index(row, col-1, N)])/4.0;
}

/***************** The GPU version: Write your code here *********************/
__host__
void  gpu_heat_dist(float * playground, unsigned int N, unsigned int iterations, unsigned int BLOCK_WIDTH)
{
	// Loop indices
	//int i, j, k;
	//int upper = N-1;
	int iter = iterations;

	int size = N*N*sizeof(float);
	float *d_playground, *d_temp;

	cudaMalloc((void **) &d_playground, size);
	cudaMalloc((void **) &d_temp, size );

	cudaMemcpy(d_playground, playground, size, cudaMemcpyHostToDevice);
	cudaMemcpy(d_temp, playground, size, cudaMemcpyHostToDevice);

	dim3 dimGrid(ceil(N/(float)BLOCK_WIDTH), ceil(N/(float)BLOCK_WIDTH), 1);
	dim3 dimBlock(BLOCK_WIDTH, BLOCK_WIDTH, 1);

	while(iter > 0){
		calculate_temperature<<<dimGrid, dimBlock>>>(d_playground, d_temp, N);
		cudaMemcpy(d_playground, d_temp, size, cudaMemcpyDeviceToDevice);
		iter = iter -1;
	}
	cudaMemcpy(playground, d_playground, size, cudaMemcpyDeviceToHost);

	cudaFree(d_temp);
	cudaFree(d_playground);
}
