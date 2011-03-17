#!/bin/sh

gdmd *.d node/*.d filter/*.d ../../util/*.d  -version=JADE_TEST -ofjade2test -O -inline -release

