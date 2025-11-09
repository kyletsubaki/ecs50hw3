#include <stdlib.h> 

int** matMult(int** a, int num_rows_a, int num_cols_a, int** b, int num_rows_b, int num_cols_b) {
    // Allocate result matrix
    int **c = malloc(num_rows_a * sizeof(int*));
    for (int n = 0; n < num_rows_a; ++n) {
        c[n] = malloc(num_cols_b * sizeof(int));
    }

    // Initialize and compute matrix multiplication
    for (int i = 0; i < num_rows_a; ++i) {
        for (int j = 0; j < num_cols_b; ++j) {
            c[i][j] = 0;
            for (int k = 0; k < num_cols_a; ++k) {
                c[i][j] += a[i][k] * b[k][j];
            }
        }
    }
    return c;
}