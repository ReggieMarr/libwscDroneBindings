#include <stdlib.h>
#include <stdio.h>
#include "Bebop2CtrlIF.h"
#ifdef __cplusplus
extern "C" {
#endif

    Bebop2CtrlIF* testIF(int callSign) { return new Bebop2CtrlIF(callSign); }

#ifdef __cplusplus
}
#endif

int main(){
    printf("Hello world");
    return 0;
}
