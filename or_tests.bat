@echo off
setlocal

:: attempt to add defalt Cygwin paths to Windows path
path C:\cygwin\bin;%PATH%
path C:\cygwin64\bin;%PATH%

:: allow Windows new lines in shell scripts with Cygwin
set SHELLOPTS=igncr

set ORTEST_TEMP_DIR=C:\temp
IF NOT EXIST %ORTEST_TEMP_DIR% mkdir %ORTEST_TEMP_DIR%

set DBNAME=%1
bash or_tests.bash %DBNAME%

endlocal
