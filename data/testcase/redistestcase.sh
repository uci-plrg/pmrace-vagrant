#!/bin/bash
if [[ $1 -eq 1 ]]
then
    echo "set x1 x1_v1"
    echo "set x1 x1_v2"
    echo "incr counter"
    echo "incr counter"
    echo "incr counter"
    echo "incr counter"
    echo "incr counter"
    echo "incr counter"
    echo "incr counter"
    echo "set x2 x2_v1"
    echo "ping"
    echo "incr counter"
    echo "set x3 x3_v1"
else
    echo "get x1"
    echo "get x2"
    echo "get counter"
    echo "incr counter"
    echo "incr counter"
    echo "incr counter"
    echo "set x1 x1_v3"
    echo "get x3"
    echo "get x1"
    echo "get x2"
    echo "shutdown save"
fi 
