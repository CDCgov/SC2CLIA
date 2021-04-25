#!/bin/bash

cd $1

Rscript $2 -a $3 -r $4 -s $5 > /dev/null
