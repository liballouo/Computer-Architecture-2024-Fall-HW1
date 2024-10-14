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
    li   t0, 0          # count = 0
    li   t1, 31         # t1 = 31
clz_loop:
    li   t2, 1 
    sll  t2, t2, t1    # (1U << i)
    and  t3, a0, t2    # x & (1U << i)
    bnez t3, clz_done # if (x & (1U << i)) break loop
    addi t0, t0, 1    # count = count + 1
    addi t1, t1, -1   # i = i - 1
    bgez t1, clz_loop # if (i>=0) continue loop
clz_done:
    addi a0, t0, 0    # set result to a0
    ret