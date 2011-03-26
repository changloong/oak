@echo off

%~d0
cd %~p0
set scss_dir=%cd%
cd util
@rem e:\projects\goldie\bin\goldie-grmc.exe %scss_dir%\util\scss.grm 

genx.exe

@rem cd ..
@rem cd ..
@rem cd ..
@rem set oak_dir=%cd%
@rem e:
@rem cd \projects\goldie
@rem .\bin\goldie-grmc.exe %scss_dir%\util\scss.grm 
@rem .\bin\goldie-dumpcgt.exe scss.cgt > %scss_dir%\scss.txt
@rem .\bin\goldie-staticlang scss.cgt -dir:%oak_dir% -pack:oak.langs.scss.gscss
@rem %~d0
@rem cd %~p0
@rem dir vendor\*.d

pause