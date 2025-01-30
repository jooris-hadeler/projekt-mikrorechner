from asm import * 

def pad(amount=5):
    for i in range(amount):
        nop()

index = REG_2        
limit = REG_3
a = REG_4
b = REG_5
c = REG_6
cond = REG_7

set_low(index, 1)                  # index = 0
set_low(a, 0)                      # a = 0
set_low(b, 1)                      # b = 1
set_low(limit, 47)                 # LIMIT = 47
pad()

loop = current_pc()                # loop:
add(c, a, b)                       # c = a + b
pad()

or_(a, b, REG_ZERO)                # a = b
or_(b, c, REG_ZERO)                # b = c
add(index, index, REG_ONE)         # index += 1
pad()

ltu(cond, index, limit)            # cond = index < LIMIT
pad()

branch(cond, loop - current_pc())  # branch loop
pad()

halt()                             # halt
pad(amount=50)

# print_program()
save_program("fib.bin")