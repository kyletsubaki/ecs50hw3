#include <stdlib.h>
#include "combs.h"

int** get_combs(int* items, int k, int len) {
    int combs = num_combs(len, k);
    int** result = (int**)malloc(combs * sizeof(int*));
    int index = 0;

    if (k == 1) {
        for (int i = 0; i < len; i++) {
            result[i] = (int*)malloc(k * sizeof(int));
            result[i][0] = items[i];
        }
        return result;
    }

    while(len > k) {
        int first = *items;
        items++;
        len--;
        int** last = get_combs(items, k - 1, len);
        int num_last = num_combs(len, k - 1);

        for (int y = 0; y < num_last; y++) {
            result[index] = (int*)malloc(k * sizeof(int));
            result[index][0] = first;
            for (int x = 0; x < k - 1; x++) {
                result[index][x + 1] = last[y][x];
            }
            index++;
        }
    }

    result[index] = (int*)malloc(k * sizeof(int));
    for (int i = 0; i < k; i++) {
        result[index][i] = items[i];
    }

    return result;
}