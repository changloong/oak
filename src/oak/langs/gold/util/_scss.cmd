@echo off

%~d0
cd %~p0
set scss_dir=%cd%
del gscss\*.d
del *.exe
cd ..
cd ..
cd ..
set oak_dir=%cd%

e:
cd \projects\goldie
.\bin\goldie-grmc.exe %scss_dir%\scss.grm
@rem .\bin\goldie-dumpcgt.exe scss.cgt > %scss_dir%\scss.txt
@rem .\bin\goldie-staticlang scss.cgt -dir:%oak_dir% -pack:oak.langs.scss.gscss

copy scss.cgt %scss_dir%
del scss.cgt
 
%~d0
cd %~p0
dir vendor\*.d

pause