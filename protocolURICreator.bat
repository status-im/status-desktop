:: ------- Self-elevating.bat --------------------------------------
@whoami /groups | find "S-1-16-12288" > nul && goto :admin
set "ELEVATE_CMDLINE=cd /d "%~dp0" & call "%~f0" %*"
findstr "^:::" "%~sf0">temp.vbs
cscript //nologo temp.vbs & del temp.vbs & exit /b

::: Set objShell = CreateObject("Shell.Application")
::: Set objWshShell = WScript.CreateObject("WScript.Shell")
::: Set objWshProcessEnv = objWshShell.Environment("PROCESS")
::: strCommandLine = Trim(objWshProcessEnv("ELEVATE_CMDLINE"))
::: objShell.ShellExecute "cmd", "/c " & strCommandLine, "", "runas"
:admin -------------------------------------------------------------

@echo off
echo Running as elevated user.
echo Script file : %~f0
echo Arguments   : %*
echo Working dir : %cd%
echo.
:: administrator commands here
:: e.g., run shell as admin

REG ADD HKEY_CLASSES_ROOT\status-im /ve /t REG_SZ /d "URL:status-im protocol"
REG ADD HKEY_CLASSES_ROOT\status-im /v "URL Protocol" /t REG_SZ /d ""

REG ADD HKEY_CLASSES_ROOT\status-im\DefaultIcon /ve /t REG_SZ /d "Status.exe,1"

REG ADD HKEY_CLASSES_ROOT\status-im\shell

:: TODO Get path to user bin
REG ADD HKEY_CLASSES_ROOT\status-im\shell\open\command /ve /t REG_SZ /d "%cd%\Status.exe --url=\"%%1""

exit

cmd /k

exit