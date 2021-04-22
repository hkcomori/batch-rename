@echo off
cd /d %~dp0

set install_dir=%LOCALAPPDATA%\Programs\batch-rename
if exist "%LOCALAPPDATA%\Programs\Git\bin\bash.exe" (
    set bash=%LOCALAPPDATA%\Programs\Git\bin\bash.exe
) else if exist "%PROGRAMFILES%\Git\bin\bash.exe" (
    set bash=%PROGRAMFILES%\Git\bin\bash.exe
) else (
    exit /b 1
)

if "%EDITOR%"=="" (
    setx EDITOR "code -w"
)

mkdir "%install_dir%"
copy /V /Y "src\batch-rename.sh" "%install_dir%"

reg add "HKEY_CURRENT_USER\Software\Classes\*\shell\BatchRename" /ve /t "REG_EXPAND_SZ" /d "&Rename with EDITOR" /f
reg add "HKEY_CURRENT_USER\Software\Classes\*\shell\BatchRename\command" /ve /t "REG_EXPAND_SZ" /d "\"%bash%\" \"%install_dir%\batch-rename.sh\" -nv -w 1 \"%%1\"" /f

reg add "HKEY_CURRENT_USER\Software\Classes\Directory\shell\BatchRename" /ve /t "REG_EXPAND_SZ" /d "&Rename with EDITOR" /f
reg add "HKEY_CURRENT_USER\Software\Classes\Directory\shell\BatchRename\command" /ve /t "REG_EXPAND_SZ" /d "\"%bash%\" \"%install_dir%\batch-rename.sh\" -nv -w 1 \"%%1\"" /f

reg add "HKEY_CURRENT_USER\Software\Classes\Directory\Background\shell\BatchRename" /ve /t "REG_EXPAND_SZ" /d "&Rename files with EDITOR" /f
reg add "HKEY_CURRENT_USER\Software\Classes\Directory\Background\shell\BatchRename\command" /ve /t "REG_EXPAND_SZ" /d "\"%bash%\" \"%install_dir%\batch-rename.sh\" -dnv \"%%V\"" /f
