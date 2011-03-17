#!/bin/sh
gdmd *.d ../*.d ../filter/*.d ../node/*.d ../../util/*.d -version=OAK_PCRE -I../../ -ofdmd_xtpl -L-lpcre  -fPIC
gcc -shared -o dmd_xtpl.so dmd_xtpl.o -fPIC 
# -L-lpcre -L-lgphobos -L-lgdruntime
