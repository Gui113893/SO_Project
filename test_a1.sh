#!/bin/bash
# test_a1.sh

testName=test_a1

#test results
if ./spacecheck.sh -a $testName | tail -n +2 | head -4 | awk '{print $1 " " $2}' | diff - ${testName}.out > /dev/null 2>/dev/null
then
    echo OK
else
    echo ERRO
fi
