#!/bin/sh
gdmd *.d ../*.d ../filter/*.d ../node/*.d ../../util/*.d -version=OAK_PCRE -c dmd_xtpl.o
#-shared -o dmd_xtpl.so  -fPIC
