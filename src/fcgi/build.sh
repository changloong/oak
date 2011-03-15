#!/bin/sh
dmd *.d -version=FCGI_TEST ../util/*.d -version=OAK_PCRE -offcgi_text
