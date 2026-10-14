#include <cstdio>
#include <cstdlib>
#include <climits>
#include "moving_max.h"

#define PASS_STATUS 0
#define ERR_STATUS 1

int main() {
    int in[N_SAMPLES], out[N_SAMPLES];
    for (int i = 0; i < N_SAMPLES; i++) in[i] = (rand() % 201) - 100;

    moving_max(in, out);

    for (int n = 0; n < N_SAMPLES; n++) {
        int ref = INT_MIN;
        for (int k = (n >= WINDOW - 1 ? n - WINDOW + 1 : 0); k <= n; k++)
            if (in[k] > ref) ref = in[k];
        if (out[n] != ref) {
            printf("ERR n=%d: got %d, expected %d\n", n, out[n], ref);
            return ERR_STATUS;
        }
    }
    printf("PASS\n");
    return PASS_STATUS;
}