#!/bin/sh
../../assembler.sh -f ./test.txt -o ./default.out > loga.txt
../../assembler.sh -d -f ./default.out -o ./disassembly.txt > logd.txt