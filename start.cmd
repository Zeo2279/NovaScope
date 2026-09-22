@echo off
setlocal
pushd "%~dp0" || exit /b 1
if not defined EFINITY_HOME goto from_path
if not exist "%EFINITY_HOME%\bin\efx_run.bat" goto missing
call "%EFINITY_HOME%\bin\efx_run.bat" Ti60_Demo.xml
goto done
:from_path
where efx_run.bat >nul 2>&1
if errorlevel 1 goto missing
call efx_run.bat Ti60_Demo.xml
goto done
:missing
echo Efinity not found. Set EFINITY_HOME to its installation directory or add bin to PATH.
popd
exit /b 1
:done
set "BUILD_RESULT=%ERRORLEVEL%"
popd
exit /b %BUILD_RESULT%
