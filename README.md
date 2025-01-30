# Projekt Mikrorechner

To use assembler with default parameters run:

```
./assembler.sh
```

It will use main.txt as default input and default.out as default output.

Syntax:

```
./assembler.sh -f inputFile -o outputFile
```

To run include example run following command in the root directory of the project:

```
./assembler.sh -f ./src/examples/includes/test.txt -o ./src/examples/includes/default.out
```

# Implemented instructions:

# Instructions

- [x] Arithmetic
    - [x] add
    - [x] sub
    - [x] and
    - [x] or
    - [x] xor
    - [x] shl
    - [x] sal
    - [x] shr
    - [x] sar
    - [x] not
    - [x] lts
    - [x] gts
    - [x] ltu
    - [x] gtu
    - [x] eq
    - [x] ne
- [x] Set High
- [x] Set Low
- [x] Load
- [x] Store
- [x] Branch
- [x] Jump Register
- [x] Jump Relative
- [x] Nop

## Syntax

``R29`` is reserved for use by the assembler. Any values stored in there WILL be overridden.
Using it WILL NOT break the assembled program.

``RSP`` or ``R30`` is the Stack Pointer.
``RBP`` or ``R31`` is the Base Pointer.
Registers can be specified using a ``$`` instead of ``R``.

The assembler does NOT warn as of now when trying to write to fixed value registers:

- ``R0`` with value ``0``
- ``R1`` with value ``1``

Arithmetic Syntax: ``ìnstruction $d, $s, $t, shamt``.\
Funct is mapped to the named instruction.\
Syntax example: ``add R0, R0, R1``  R0 will contain the value ``2`` \
Syntax example: ``add ,,R1``  will do the same. \
Spaces do not matter except to separate instruction from parameters and ``R0`` is the default.

I-Instructions Syntax: ``ìnstruction $s,$t,i``.\
If some of those registers are not used for the instruction they still have to be specified,
or at least represented by a ",".\
Syntax example: ``llo ,R29,1`` which is the same as ``llo R0, R29,1``\
Values for i bigger than 16 bits will be cut of.

# Macros

- [x] #include
    - Syntax: ``#include filepath``
    - Filepath is relative to the sourcefile
    - Included file may contain further includes, with a path relative to their location
    - Filepath cannot contain spaces
- [x] Label
    - Syntax: ``labelname:``
    - Will error if same label is used twice
- [x] Jump label
    - Syntax: ``jl labelname``
    - Forward and Backward is both possible
- [x] Branch label
    - Syntax: ``jl conditionRegister, labelname``
    - Will branch if conditionRegister != 0
- [x] Return
    - Syntax: ``ret``
    - Loads returnaddress and StackFrameBase from stack and jumps to returnaddress
    - does not zero free'd stack memory
- [x] Call
    - Syntax: ``call labelname``
    - Creates a new Stackframe, saves return address and Base onto Stack and jumps to labelname
- [x] push
    - Syntax: ``push reg``
    - will put the value in reg at the memory address the StackPointer points to and increment
      StackPointer
- [x] pop
    - Syntax: ``pop reg``
    - will decrement StackPointer and put the value StackPointer now points to into reg
- [x] Halt
    - Syntax: ``halt``
    - Will forever jump onto the same line where halt was
- [ ] Load Const
    - Zero Register, Load Low Value
- [ ] l32 to load 32 bits in one macro instruction
- [ ] lfloat to load the parameter as a float
    - calculations on floats will have to include something instead
- [ ] noop4 a macro for creating 4 consecutive noops
    - call it noooop?
    - or n88p?
- [ ] macro to get the address of a label