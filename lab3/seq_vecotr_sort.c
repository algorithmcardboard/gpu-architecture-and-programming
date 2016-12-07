/*
 *  Name:  Anirudhan J. Rajagopalan
 *  NetId: ajr619
 *  N-no:  N18824115
 *  Time: 0m0.008s
 *
 */

#include <stdio.h>
#include <stdlib.h>
#include <math.h>

int* populateRandomNumbers(int*, unsigned int, const int);
void bitonic_sort(int*, int*, int);
void kernel(int*, int, int, int);
void sort(int*, int);

int main(int argc, char** argv) {
    int i;
    const int LIST_SIZE = 1024;

    int seed = time(NULL);
    srand(seed);
    int RANGE = 10000;

    int *A = (int*)malloc(sizeof(int)*LIST_SIZE);
    int *B = (int*)malloc(sizeof(int)*LIST_SIZE);

    A = populateRandomNumbers(A, LIST_SIZE, RANGE);

    for(i = 0; i < LIST_SIZE; i++){
        B[i] = A[i];
    }

    /*
    * bitonic_sort(A, B, LIST_SIZE);
    */

    sort(B, LIST_SIZE);

    for(i = 0; i < LIST_SIZE; i++){
        printf("%d: %d  -> %d \n", (i+1), A[i], B[i]);
    }

    printf("\n");

}

void sort(int* src, int length){
    int i, j, min_ind, temp;
    for (i = 0; i < (length - 1); i++){
        min_ind = i;
        for(j = i+1; j < length; j++){
            if(*(src + j) < *(src + min_ind)){
                min_ind = j;
            }
        }
        temp = *(src + i);
        *(src + i) = *(src + min_ind);
        *(src + min_ind) =  temp;
    }
}

void bitonic_sort(int* src, int* dest, int length){
    int i, j;
    int logn = 0;
    for(i = 0; i < length; i++){
        dest[i] = src[i];
    }

    logn = log((double)length)/log((double)2);

    for(i=0; i<logn; i++){
        for(j=0; j<=i; j++){
            kernel(dest, length, i, j);
        }
    }
}

void kernel(int* arr, int length, int p, int q){
    int d = 1 << (p-q);
    int i, up, t;
    for(i=0; i< length; i++) {
        up = ((i >> p) & 2) == 0;
        if ((i & d) == 0 && (arr[i] > arr[i | d]) == up) {
            t = arr[i]; 
            arr[i] = arr[i | d]; 
            arr[i | d] = t;
        }
    }
}

int* populateRandomNumbers(int* A, unsigned int N, const int RANGE){
    int i;
    int *elements = malloc(sizeof(int)*RANGE);

    // inizialize
    for (i = 0; i < RANGE; ++i){
        elements[i] = i;
    }

    for (i = RANGE - 1; i > 0; --i) {
        int w = rand()%i;
        int t = elements[i];
        elements[i] = elements[w];
        elements[w] = t;
    }

    for(i = 0; i < N; i++){
        A[i] = elements[i];
    }

    return A;
}
