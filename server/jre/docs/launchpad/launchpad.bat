@echo off
REM Licensed Materials - Property of IBM
REM 5648-F10 (C) Copyright International Business Machines Corp. 2005, 2007
REM All Rights Reserved
REM US Government Users Restricted Rights- Use, duplication or disclosure
REM restricted by GSA ADP Schedule Contract with IBM Corp.

SETLOCAL enabledelayedexpansion 
    SET LaunchPadTemp=
    CALL "%~dp0GetShortName.bat" "%~dp0" LaunchPadBatchPath
	
:setEnvFromArgs
	REM Read arguments from command line, setting environment variables
    IF "%~1" == "" GOTO :setEnvFromLaunchpadEnv
    IF "%~2" == "" GOTO :setEnvFromLaunchpadEnv
	set %~1=%~2
	shift
	shift
	GOTO :setEnvFromArgs
	
:setEnvFromLaunchpadEnv
    REM If the launchpadEnv file exists, process it
    IF exist "%LaunchPadBatchPath%\launchpadEnv" FOR /F "tokens=1,2* delims=" %%a in (%LaunchPadBatchPath%\launchpadEnv) DO CALL :setOneEnvironmentVariable %%a "%%b"
:setEnvFromJavaProperties
    REM If the java properties file exists, process it
	IF EXIST "%LaunchPadBatchPath%\java.properties" FOR /F "eol=# tokens=1,* delims==" %%a in (%LaunchPadBatchPath%\java.properties) DO CALL :setOneEnvironmentVariable %%a "%%b"
	
:setEnvDefaults
	REM Set content dir, launchpad temp, and architecture
    IF {%LaunchPadContentDirectory%} == {} SET LaunchPadContentDirectory=content\
    CALL "%LaunchPadBatchPath%\setTmp.bat"
    CALL "%LaunchPadBatchPath%\SetArchitecture.bat"

:copyScriptLauncher
    REM Copy the dosinator to temp so it can be used from within the launchpad
    COPY "%LaunchPadBatchPath%\ScriptLauncher.exe" %LaunchPadTemp%
    COPY "%LaunchPadBatchPath%\callback.bat" %LaunchPadTemp%
    COPY "%LaunchPadBatchPath%\changeDirectory.bat" %LaunchPadTemp%

:determineBrowser
	CALL "%LaunchPadBatchPath%\setBrowser.bat"
	
:setUAC
    CALL "%LaunchPadBatchPath%\readRegistry.bat" "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Policies\System" EnableLUA uac LaunchPadUACValue > nul
	
    SET LaunchPadUACValue=%LaunchPadUACValue: =%
    SET LaunchPadUACValue=%LaunchPadUACValue:"=%

:tryJRE
	REM Determine whether to use JRE or browser
	IF EXIST "%LaunchPadBatchPath%\jclp.bat" CALL "%LaunchPadBatchPath%\jclp.bat" :start

:tryBrowser
	REM Try starting with browser if JRE did not start
    IF {%LaunchPadDefaultBrowser%} == {Mozilla} "%LaunchPadBatchPath%\Mozilla.bat"
    IF {%LaunchPadDefaultBrowser%} == {Firefox} "%LaunchPadBatchPath%\Firefox.bat"
    IF {%LaunchPadDefaultBrowser%} == {SeaMonkey} "%LaunchPadBatchPath%\SeaMonkey.bat"
    "%LaunchPadBatchPath%\IExplore.bat"


REM This subroutine sets an environment variable
REM %~1 is the key
REM %~2 is the value
:setOneEnvironmentVariable

    REM Check that both %~1 and %~2 have a value
    IF "%~1" == "" GOTO :EOF
    IF "%~2" == "" GOTO :EOF

    REM Check to see that the variable isn't already set, we don't want to override preset env vars
	IF {!%~1!} == {} SET %~1=%~2
    goto :EOF
REM --------------   End setOneEnvironmentVariable ----------------------

ENDLOCAL

