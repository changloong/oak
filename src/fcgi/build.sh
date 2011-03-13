#!/bin/sh
dmd  *.d ../util/*.d -L-lfcgi -version=FCGI_TEST -O -release -inline -offcgi4d
