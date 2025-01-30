from asm import *

xor(REG_1, REG_ZERO, REG_ZERO)
xor(REG_2, REG_ZERO, REG_ZERO)
xor(REG_3, REG_ZERO, REG_ZERO)
nop()
nop()
nop()
nop()
nop()

set_low(REG_2, 1)
set_low(REG_3, 1024)
nop()
nop()
nop()
nop()
nop()

loop = current_pc()
add(REG_1, REG_1, REG_2)
nop()
nop()
nop()
nop()
nop()

ltu(REG_4, REG_1, REG_3)
nop()
nop()
nop()
nop()
nop()

branch (REG_4, twos_comp(loop - current_pc() - 1, 2))

nop()
nop()
nop()
nop()
nop()

halt()

for _ in range(32):
    nop()


# print_program()
save_program("test.bin")