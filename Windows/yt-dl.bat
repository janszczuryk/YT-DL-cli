@echo off
title YT-DL cli

REM CONFIGURATION:
set EDITOR=notepad++
set DOWNLOADED=.\downloaded
set BINARY=yt-dlp.exe

:menu
cls
echo     YT-DL cli
echo.
echo 1) Search the song (Title)
echo 2) Download the song (URL)
echo 3) Download the songs from list (URLs)
echo 4) Edit list of URLs
echo 5) Open downloaded directory
echo 6) Update the youtube-dl
echo 7) Quit
choice /n /c:1234567 /M "> "
GOTO menuoption-%ERRORLEVEL%

:menuoption-1
echo Searching by title ...
set /p search=Video title: 
%BINARY% -o "%DOWNLOADED%\%%(title)s.%%(ext)s" -x --audio-format mp3 --audio-quality 0 --default-search "ytsearch" "%search%"
set search=
echo.
pause
goto menu

:menuoption-2
echo Downloading by URL ...
set /p vid=URL\Video ID: 
%BINARY% -o "%DOWNLOADED%\%%(title)s.%%(ext)s" -x --audio-format mp3 --audio-quality 0 "%vid%"
set vid=
echo.
pause
goto menu

:menuoption-3
echo Downloading list from links.txt ...
%BINARY% -o "%DOWNLOADED%\%%(title)s.%%(ext)s" -x --audio-format mp3 --audio-quality 0 --batch-file list.txt
echo.
pause
goto menu

:menuoption-4
start %EDITOR% list.txt
goto menu

:menuoption-5
explorer.exe %DOWNLOADED%
goto menu

:menuoption-6
echo Updating Youtube-DL ...
%BINARY% -U
echo.
pause
goto menu

:menuoption-7
cls
exit
