from asm import * 

def pad(amount=5):
    for i in range(amount):
        nop()

set_low(REG_1, 1) # index = 0
set_low(REG_2, 0) # a = 0
set_low(REG_3, 1) # b = 1
set_low(REG_10, 1) # INCREMENT = 1
set_low(REG_11, 40) # LIMIT = 40
pad()

loop = current_pc()
add(REG_4, REG_2, REG_3) # c = a + b
pad()

or_(REG_2, REG_3, REG_ZERO) # a = b
or_(REG_3, REG_4, REG_ZERO) # b = c
add(REG_1, REG_1, REG_10) # index += 1
pad()

ltu(REG_5, REG_1, REG_11) # cond = index < LIMIT
pad()

branch(REG_5, twos_comp(loop - current_pc() - 1, 2))
pad()

halt()
pad(amount=50)

save_program("fib.bin")