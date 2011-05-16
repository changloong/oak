#!/bin/sh

dmd *.d node/*.d filter/*.d ../../util/*.d  -version=JADE_TEST -ofjade2test -g -debug
#-O -inline -release

