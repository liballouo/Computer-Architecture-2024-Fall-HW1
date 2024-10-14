.data
    testcases: .word 2, 3, 5, 7, 31, 307, 383, 5039
    answers:   .word -1, 1, 4, 3, 15, 305, 319, 5031
    str_pass:  .string "pass\n"
    str_fail:  .string "fail\n"
.text
main:
    li t4, 8         # test loop counter (set 8 for 8 testcases) 
    la s0, testcases # load testcases
    la s1, answers   # load answers
    
test_loop:
    lw a0, 0(s0)     # load the testcase 
    jal ra, min_bitwise_num  # perform clz
    lw t5, 0(s1)     # load the answer
    beq a0, t5, pass # pass
    la a0, str_fail  # fail
    j print_result   # print result
    
pass:
    la a0, str_pass  # load pass message
    j print_result   # print result
    
print_result:
    li a7, 4         # ecall for print string(a0)
    ecall            
    addi s0, s0, 4   # increment to the next testcase
    addi s1, s1, 4   # increment to the next answer
    addi t4, t4, -1  # decrement the loop counter
    bnez t4, test_loop # repeat if there are testcases
    
    li a7, 10        # ecall for exit
    ecall

# Input:  uint32_t a0
# Output: uint32_t a0
# t6: flag, 0 for ilog ; 1 for popcount

min_bitwise_num:
    addi sp, sp, -4
    sw   ra, 0(sp)
    li   t0, 2
    beq  a0, t0, case_2      # case: num == 2
    
    addi a1, a0, 0
    li   t6, 0               # flag for ilog / popcount
    jal  ra, ilog2           # do ilog2(num) and save the result in a2
    addi a0, a1, 0
    addi a2, a2, 1           # ilog2(num) + 1
    li   t6, 1               # flag for ilog / popcount
    jal  ra, popcount        # do popcount(num) and save the result in a3
    addi a0, a1, 0
    beq  a2, a3, case_all_1s # case: all 1s
    
    jal ra, helper           # case: others

case_2:
    li   a0, -1              # no possible value
    lw   ra, 0(sp)
    addi sp, sp, 4
    ret                      

my_clz:
    srli t0, a0, 1   # x >> 1
    or   a0, a0, t0  # x |= (x >> 1)
    srli t0, a0, 2   # x >> 2
    or   a0, a0, t0  # x |= (x >> 2)
    srli t0, a0, 4   # x >> 4
    or   a0, a0, t0  # x |= (x >> 4)
    srli t0, a0, 8   # x >> 8
    or   a0, a0, t0  # x |= (x >> 8)
    srli t0, a0, 16  # x >> 16
    or   a0, a0, t0  # x |= (x >> 16)
 
popcount:
    lui  t1, 0x55555
    ori  t1, t1, 0x555 # 0x55555555 (t1)
    srli t0, a0, 1   # x >> 1
    and  t2, t0, t1  # (x >> 1) & 0x55555555
    sub  a0, a0, t2  # x -= ((x >> 1) & 0x55555555)
    
    lui  t1, 0x33333
    ori  t1, t1, 0x333 # 0x33333333 (t1)
    srli t0, a0, 2   # x >> 2
    and  t2, t0, t1  # (x >> 2) & 0x33333333
    and  t3, a0, t1  # x & 0x33333333
    add  a0, t2, t3  # ((x >> 2) & 0x33333333) + (x & 0x33333333)
    
    lui  t1, 0x0f0f0
    ori  t1, t1, 0x70f
    addi t1, t1, 0x800 # 0x0f0f0f0f (t1)
    srli t0, a0, 4   # x >> 4
    add  t2, a0, t0  # (x >> 4) + x
    and  a0, t2, t1  # ((x >> 4) + x) & 0x0f0f0f0f
    
    srli t0, a0, 8   # x >> 8
    add  a0, a0, t0  # x += (x >> 8)
    
    srli t0, a0, 16  # x >> 16
    add  a0, a0, t0  # x += (x >> 16)
    beqz t6, clz_done 
    addi a3, a0, 0   # save the result in a3
    ret
    
clz_done:
    andi t0, a0, 0x3f # x & 0x3f
    li   t1, 32
    sub  a0, t1, t0  # 32 - (x & 0x3f)
    
    ret

ilog2:
    addi sp, sp, -4
    sw   ra, 0(sp)
    jal  ra  my_clz  # my_clz(num) and save the result in a0
    li   t2, 31
    sub  a2, t2, a0  # 31 - my_clz(num)
    lw   ra, 0(sp)
    addi sp, sp, 4
    ret

case_all_1s:
    srli a0, a0, 1   # ans = num >> 1
    lw   ra, 0(sp)
    addi sp, sp, 4
    ret

helper:
    li   t0, 32      # upper bound t0 = 32
    li   t1, 1       # loop start from 1, i(t1)
        
helper_loop:
    li   t2, 1       # t2 = 1
    sll  t2, t2, t1  # 1 << i 
    and  t3, a0, t2  # (1 << i) & num
    beqz t3, helper_done # correctly find the rightmost 0
    addi t1, t1, 1   # i += 1
    bne  t0, t1, helper_loop # do not find the rightmost 0 yet, continue the loop

helper_done:
    srli t2, t2, 1   # 1 << (i - 1)
    xor  a0, a0, t2  # num ^= (1 << (i - 1))
    lw   ra, 0(sp)
    addi sp, sp, 4
        
    ret 