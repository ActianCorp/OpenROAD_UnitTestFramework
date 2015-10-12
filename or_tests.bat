@echo off
setlocal

:: attempt to add defalt Cygwin paths to Windows path
path C:\cygwin\bin;%PATH%
path C:\cygwin64\bin;%PATH%

:: allow Windows new lines in shell scripts with Cygwin
set SHELLOPTS=igncr

:: TODO check and create C:\temp?

set DBNAME=%1
bash or_tests.bash %DBNAME%

endlocal
