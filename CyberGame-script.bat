REM 
REM     THE CYBERGAME (v1.0)
REM     ------------------------------------------------------------------------------
REM 
REM     A small word-based game written in Batch.
REM     The goal is to find the right word related to the cybersecurity field.
REM 
REM     Script written for learning purposes only.
REM     © 2025 Sacha Meurice

@echo off & title The CyberGame v1.0
mode con: lines=21 cols=70




REM ----------------------------------------------------------------------------------
REM                                GAME INITIALIZATION
REM ----------------------------------------------------------------------------------


:init
    set dataFile=data.txt

    if not exist %dataFile% (
        echo ERROR: File %dataFile% is missing.
        pause & exit
    )


    REM Count the number of lines in the file.
    FOR /F %%L IN ('find "" /v /c ^< %dataFile%') DO SET /a lines=%%L

    if %lines% LSS 2 (
        echo ERROR: File %dataFile% is most likely empty or corrupted.
        pause & exit
    )


    REM Get file's size.
    FOR /F "usebackq" %%A IN ('%dataFile%') DO set fileSize=%%~zA

    if %fileSize% LSS 10 (
        echo ERROR: File %dataFile% is most likely empty or corrupted.
        pause & exit
    )


    REM ASCII escape char followed by [
    REM Starting chars of a control sequence.
    set e=[

    REM Game variables
    set feedback=%e%32m First round!
    set screen=NEWGAME
    set /a score=0
goto :updateScreen




REM ----------------------------------------------------------------------------------
REM                                    GAME INPUTS
REM ----------------------------------------------------------------------------------


:procClose
REM Process user input from screens that can only be closed.
    if "%userCmd%"=="CLOSE" set screen=%prevScreen%
goto :procScreen


:procNewGame
REM Process user input from the start screen.
    if "%userCmd%"=="START" goto :start
goto :procScreen


:procScreen
REM Process user input on any screen.
    if "%userCmd%"=="STOP" exit
    if "%userCmd%"=="EXIT" exit
    if "%userCmd%"=="HELP" goto :help

    if "%screen%"=="MAIN" if not "%userCmd%"=="CLOSE" goto :checkInput
goto :updateScreen


:procInput
REM Process user input command.
    if not defined userCmd goto :updateScreen
    CALL :upperText userCmd

    if "%screen%"=="HELP" goto :procClose
    if "%screen%"=="NEWGAME" goto :procNewGame
goto :procScreen


:checkInput
REM Check if player's answer is correct.
    if "%userCmd%"=="%word%" (
        set /a score=%score% + 1
        set feedback=%e%32m Correct! You got 1 point!
    ) else (
        set feedback=%e%31m Wrong! The answer was: %word%.
    )
goto :nextWord


:upperText
REM Transform lowercase letters to uppercase ones.
    FOR %%i IN ("a=A" "b=B" "c=C" "d=D" "e=E" "f=F" "g=G" "h=H" "i=I" "j=J" "k=K"^
          "l=L" "m=M" "n=N" "o=O" "p=P" "q=Q" "r=R" "s=S" "t=T" "u=U" "v=V" "w=W"^
     "x=X" "y=Y" "z=Z") DO CALL SET "%1=%%%1:%%~i%%"
goto :eof




REM ----------------------------------------------------------------------------------
REM                               GAME'S DATA MANAGEMENT
REM ----------------------------------------------------------------------------------


:getLine
REM Return a specified line from the %dataFile% file.
    set /a line=%1 - 1

    FOR /F "tokens=1-2" %%A IN ('type %dataFile% ^| more +%line%') DO (
        set "%2=%%A"
        set "%3=%%B"
        exit /b
    )
goto :eof


:addSpaces
REM Add one space between each char of the given string.
    set res=
    set loc=%1
    :loop
        if not "%loc%"=="" set res=%res% %loc:~0,1%& set loc=%loc:~1%& goto :loop
    set %2=%res%
goto :eof


:nextWord
REM Fetch and process the next word.
    set word= & set hword=
    set /a fileLine=%fileLine% + 1

    CALL :getLine %fileLine% word hword
    if not defined hword goto :end

    CALL :addSpaces %hword% hword
goto :updateScreen




REM ----------------------------------------------------------------------------------
REM                                    GAME SCREENS
REM ----------------------------------------------------------------------------------


:updateScreen
REM Refresh or display the current screen.
    cls
    CALL :showHeader

    if "%screen%"=="HELP" (
        CALL :showHelp
    )

    if "%screen%"=="NEWGAME" (
        CALL :showRules
    )

    if "%screen%"=="MAIN" (
        CALL :showMainGame
    )

    if "%screen%"=="ENDSCREEN" (
        CALL :showEndScreen
    )
goto :showInput


:showHeader
REM Global screens's header

echo %e%33m          ______      __              ______                          %e%0m
echo %e%33m         / ____/_  __/ /_  ___  _____/ ____/___ _____ ___  ___        %e%0m
echo %e%33m        / /   / / / / __ \/ _ \/ ___/ / __/ __ `/ __ `__ \/ _ \       %e%0m
echo %e%33m       / /___/ /_/ / /_/ /  __/ /  / /_/ / /_/ / / / / / /  __/       %e%0m
echo %e%33m       \____/\__, /_.___/\___/_/   \____/\__,_/_/ /_/ /_/\___/        %e%0m
echo %e%33m            /____/                                                    %e%0m
echo.
if "%screen%"=="NEWGAME" (
echo %e%33m                   Let's see how cyber-cool you are!                  %e%0m
)
if "%screen%"=="HELP" (
echo %e%33m                         ---- Help screen ----                        %e%0m
)
if "%screen%"=="MAIN" (
echo %e%33m                                       Word: %e%34m%fileLine%/%lines%%e%0m^
  %e%33mCurrent score: %e%34m%score%%e%0m
)
echo %e%33m----------------------------------------------------------------------%e%0m
exit /b


:showRules
REM Rules of the game

echo %e%32m Welcome in the CyberGame!                                            %e%0m
echo.
echo %e%36m Your goal is to find %lines% words related to cybersecurity.         %e%0m
echo %e%36m Good answers give 1 point, wrong ones don't give any.                %e%0m
echo %e%36m Let's see how many points you can have!                              %e%0m
echo.
echo %e%37m Type START to start a new game, or HELP to show the help screen.     %e%0m
echo %e%33m----------------------------------------------------------------------%e%0m
exit /b


:showHelp
REM Game's help screen

echo %e%32m A few tips when you're playing:                                      %e%0m
echo.
echo %e%36m    - Your inputs are case-insensitive.                               %e%0m
echo %e%36m    - At any time, type HELP to show this help screen.                %e%0m
echo %e%36m    - Good answers give 1 point, wrong ones don't give any.           %e%0m
echo %e%36m    - Type STOP or EXIT to exit the game at any time                  %e%0m
echo.
echo %e%37m Type CLOSE to close this screen.                                     %e%0m
echo %e%33m----------------------------------------------------------------------%e%0m
exit /b


:showEndScreen
REM Game's end screen

echo %e%32m Congratulations, you finished the game!                              %e%0m
echo.
echo %e%36m    Your final score: %score%                                         %e%0m
echo %e%36m    Thank you for playing!                                            %e%0m
echo.
echo %e%37m Type EXIT to close this application.                                 %e%0m
echo %e%33m----------------------------------------------------------------------%e%0m
exit /b


:showMainGame
REM Main game's screen

echo %feedback%                %e%0m
echo.
echo %e%33m Try to guess the word: %e%36m%hword%     %e%0m
echo %e%33m----------------------------------------------------------------------%e%0m
exit /b


:showInput
REM Show input command line

    if "%screen%"=="NEWGAME" (
        echo %e%33m                                             Made by: Sacha M.%e%0m
    ) else (
        echo.
    )

    set userCmd=
    set /p userCmd=%e%35mcyber@game%e%37m~%e%32m$ %e%0m
goto :procInput




REM ----------------------------------------------------------------------------------
REM                                SMALL PROCEDURES
REM ----------------------------------------------------------------------------------


:help
    if not "%screen%"=="HELP" set prevScreen=%screen%
    set screen=HELP
goto :updateScreen


:start
    set screen=MAIN
goto :nextWord


:end
    set screen=ENDSCREEN
goto :updateScreen
