@echo off
cd /d %~dp0

set install_dir=%LOCALAPPDATA%\Programs\batch-rename

rmdir /S /Q "%install_dir%"

reg delete "HKEY_CURRENT_USER\Software\Classes\*\shell\BatchRename" /f
reg delete "HKEY_CURRENT_USER\Software\Classes\Directory\shell\BatchRename" /f
reg delete "HKEY_CURRENT_USER\Software\Classes\Directory\Background\shell\BatchRename" /f
