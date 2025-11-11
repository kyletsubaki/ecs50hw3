#include <stdlib.h>
#include "combs.h"

int** get_combs(int* items, int k, int len) {
    int combs = num_combs(len, k);
    int** result = (int**)malloc(combs*sizeof(int));
    int index = 0;
    while(len > k)  {
        if(k == 1) {
        int i;
        for(i = 0; i < len; i++) {
            result[i] = (int*)malloc(k*sizeof(int));
            result[i][0] = items[i];
        }
        return result;
    }
        int first = items[0];
        items = items + 1;
        len--;
        int** last = get_combs(items, k-1,len);
        int num_last = num_combs(len,k-1);
        int y;
        for(y = 0; y < num_last; y++) {
            result[index] = (int*)malloc(k*sizeof(int));
            result[index][0] = first;
            int x;
            for(x = 0; x < k-1; x++) {
                result[index][x+1] = last[y][x];
            }
            index++;
        } 
    }
    result[index] = (int*)malloc(k*sizeof(int));
    int i;
    for(i = 0; i < k; i++) {
        result[index][i] = items[i];
    }	
    return result;
}