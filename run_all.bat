@echo off
setlocal

rem ---- Backend ----
pushd "%~dp0SnakeGuard_backend"
if exist venv (
    call venv\Scripts\activate.bat
)
start "Backend" cmd /k "uvicorn main:app --host 0.0.0.0 --port 8000 --reload"
popd

rem Wait for backend to start
timeout /t 5 >nul

rem ---- Frontend ----
pushd "%~dp0SnakeGuard_flutter"
rem Adjust FLUTTER_PATH if Flutter is installed elsewhere
set "FLUTTER_PATH=C:\src\flutter\bin"
set "PATH=%FLUTTER_PATH%;%PATH%"
start "Frontend" cmd /k "flutter run"
popd

exit /b


