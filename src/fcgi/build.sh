#!/bin/sh
dmd  *.d -L-lfcgi -version=FCGI_TEST -O -release -inline -offcgi4d
