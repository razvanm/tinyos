#!/bin/bash

DIRS="
  nesc
  platforms/avr/avarice
  platforms/avr/avrdude
  platforms/avr/avrdude-legacy
  platforms/avr/toolchain
  platforms/avr/toolchain-legacy
  platforms/mica/uisp
  platforms/msp430/mspdebug
  platforms/msp430/toolchain
  platforms/msp430/toolchain-legacy
"

for i in ${DIRS}
do
    echo ${i}
    (
	cd ${i}
	./build.sh clean
	time ./build.sh rpm
	./build.sh veryclean
    ) &> $(echo ${i} | tr '/' '-').log
done
