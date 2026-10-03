@echo off
cd /d "%~dp0"
if not exist Slay_original.exe (echo No backup found - nothing to undo. & pause & exit /b 1)
copy /y Slay_original.exe Slay.exe >nul || (echo Could not write Slay.exe - right-click Uninstall.bat and choose "Run as administrator". & pause & exit /b 1)
echo Original Slay.exe restored.
pause
