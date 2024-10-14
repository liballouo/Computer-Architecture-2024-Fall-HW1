#include <stdio.h>
#include <stdint.h>

int my_clz(uint32_t x)
{
    x |= (x >> 1);
    x |= (x >> 2);
    x |= (x >> 4);
    x |= (x >> 8);
    x |= (x >> 16);

    x = popcount(x);

    return (32 - (x & 0x3f));
}

int popcount(uint32_t x){
    /* count ones (population count) */
    x -= ((x >> 1) & 0x55555555);
    x =  ((x >> 2) & 0x33333333) + (x & 0x33333333);
    x =  ((x >> 4) + x) & 0x0f0f0f0f;
    x += (x >> 8);
    x += (x >> 16);
    
    return x;
}

int ilog2(uint32_t num){
    return 31 - my_clz(num);
}

uint32_t helper(uint32_t num) {
    for(int i=1; i<32; i++){
        // Find the rightmost 0
        if(!((1 << i) & num)){
            // Change the 1 on the right of the rightmost 0 to 0
            num ^= (1 << (i - 1));
            break;
        }
    }
    return num;
}

uint32_t minBitwiseNum(uint32_t num) {
    // Input:  num
    // Output: ans
    uint32_t ans;
    
    // case: 2
    if(num == 2){
        ans = -1;
    }
    // case: all 1s (2^n-1)
    else if(ilog2(num) + 1 == popcount(num)){
        ans = num >> 1;
    }
    // case: others
    else{
        ans = helper(num);
    }
    
    return ans;
}

int main() {
    
    int nums[] = {2, 3, 5, 7, 31, 307, 383, 5039};
    uint32_t answers[] = {-1, 1, 4, 3, 15, 305, 319, 5031};
    
    for(int i=0; i < 8; i++){
        int num = nums[i];
        int ans;
        
        // case: 2
        if(num == 2){
            ans = -1;
        }
        // case: all 1s
        else if(ilog2(num) + 1 == popcount(num)){
            ans = num >> 1;
        }
        // case: others
        else{
            ans = helper(num);
        }
        
        // check the answer is correct or not
        if(ans == answers[i]){
            printf("pass\n");
        }
        else{
            printf("fail\n");
        }
    }
    
    return 0;
}