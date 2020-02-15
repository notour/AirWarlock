REM Create a local config local/config file with the config var WowPath="%%"
SETLOCAL EnableDelayedExpansion

if exist "%~dp0/local.config" (
    for /f "delims== tokens=1,2" %%G in (%~dp0/local.config) do set %%G=%%H
) else (
    for /f "delims== tokens=1,2" %%G in (%~dp0/default.config) do set %%G=%%H
)

if exist "%WowAddonPath%" (
    xcopy "%~dp0..\*" "%WowAddonPath%/AirWarlock/*" /Y /E
    rmdir /S /Q "%WowAddonPath%/AirWarlock/.vscode/"
    rmdir /S /Q "%WowAddonPath%/AirWarlock/.*"
    del /F "%WowAddonPath%/AirWarlock/.gitignore"
) else (
    print "Wow Folder Path missing : %WowAddonPath%"
)