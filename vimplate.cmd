@echo off

REM Windows Script to run vimplate
REM please see: http://www.vim.org/scripts/scripts.php?script_id=1311
REM or :help vimplate
REM
REM +--------------------------------------------------------------------------+
REM |Changelog                                                                 |
REM +--------------------------------------------------------------------------+
REM |2007-02-25                                                                |
REM |           Updated script to use the %HOMEPATH% environment variable in   |
REM |           the event that %HOME% is unavailable.  Also enclosed variables |
REM |           in 'if' statements in quotation marks, because otherwise it    |
REM |           will fail if there are any spaces in the variable.             |
REM |                                                                     -Jay |
REM +--------------------------------------------------------------------------+
REM |                                                                          |
REM +--------------------------------------------------------------------------+
REM

if "%HOME%x" == "x" goto sethome
goto runscript


:sethome
  SET HOME=%HOMEDRIVE%%HOMEPATH%
  if "%HOME%x" == "x" goto nohome
  goto runscript


:runscript
  perl "%HOME%\vimfiles\vimplate.pl" "%1" "%2" "%3" "%4" "%5" "%6" "%7" "%8" "%9"
  goto end


:nohome
  echo Variable HOME isn't set!
  echo Please read the documentation.
  goto end


pause
:end
