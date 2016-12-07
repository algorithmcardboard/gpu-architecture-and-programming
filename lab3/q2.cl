__kernel void parallel_sort(__global int* A, __global int* B, uint n){
    uint id = get_global_id(0);
    int j, pos = 0;
    for(j = 0; j < n; j++){
          pos += (A[id] > A[j])?1:0;
    }
    B[pos] = A[id];
}
