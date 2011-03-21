@echo off

%~d0
cd %~p0
set scss_dir=%cd%
del vendor\*.d
del *.exe
cd ..
cd ..
cd ..
set oak_dir=%cd%

e:
cd \projects\goldie
.\bin\goldie-grmc.exe %scss_dir%\scss.grm
.\bin\goldie-staticlang scss.cgt -dir:%oak_dir% -pack:oak.langs.scss.vendor
del scss.cgt

%~d0
cd %~p0
dir vendor\*.d

pause