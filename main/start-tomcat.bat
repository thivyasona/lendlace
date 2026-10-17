@echo off
REM Local Tomcat launcher - loads secrets from .env at project root (never committed)
set "CATALINA_HOME=C:\Users\THIVYA SONA\Downloads\apache-tomcat-10.1.55-windows-x64\apache-tomcat-10.1.55"

REM --- load .env (KEY=VALUE lines; # comments skipped) ---
REM .env sits in the project ROOT (one level above this bat file)
if exist "%~dp0.env" set "ENVFILE=%~dp0.env"
if exist "%~dp0..\.env" set "ENVFILE=%~dp0..\.env"
if defined ENVFILE (
    for /f "usebackq eol=# tokens=1,* delims==" %%A in ("%ENVFILE%") do (
        if not "%%A"=="" if not "%%B"=="" set "%%A=%%B"
    )
)

call "%CATALINA_HOME%\bin\catalina.bat" run
