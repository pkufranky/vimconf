@echo off

if "%HOME%x" == "x" goto homeset
goto run


:homeset
  SET HOME=%HOMEDRIVE%%HOMEPATH%


:run
  "%HOME%/vimfiles/vimplate.cmd" -createconfig


:end
pause


