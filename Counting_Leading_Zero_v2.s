.data
    testcases: .word 0x3, 0xFFFFFFFF, 0x3321675
    answers:   .word 30, 0, 6
    str_pass:  .string "pass\n"
    str_fail:  .string "fail\n"
.text
main:
    li t4, 3         # test loop counter (set 3 for 3 testcases) 
    la s0, testcases # load testcases
    la s1, answers   # load answers
    
test_loop:
    lw a0, 0(s0)     # load the testcase 
    jal ra, my_clz   # perform clz
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
        
    andi t0, a0, 0x3f # x & 0x3f
    li   t1, 32
    sub  a0, t1, t0   # 32 - (x & 0x3f)
    
    ret