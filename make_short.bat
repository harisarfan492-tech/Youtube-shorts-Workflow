@echo off
setlocal

set "ROOT=C:\n8n-content"
set "FFMPEG=C:\ffmpeg\bin\ffmpeg.exe"
set "SCRIPTFILE=%ROOT%\audio\script.txt"
set "AUDIO=%ROOT%\audio\voice.mp3"
set "SRT=%ROOT%\audio\captions.srt"
set "HOOK=%ROOT%\audio\hook.txt"
set "LASTFILE=%ROOT%\audio\last_clip.txt"

if not exist "%ROOT%\output" mkdir "%ROOT%\output"

echo ==========================================
echo       YOUTUBE SHORTS GENERATOR
echo ==========================================

if not exist "%SCRIPTFILE%" (
    echo ERROR: script.txt not found.
    exit /b 1
)

if not exist "%FFMPEG%" (
    echo ERROR: FFmpeg not found.
    exit /b 1
)

set "SCRIPT="
set /p "SCRIPT="<"%SCRIPTFILE%"

if not defined SCRIPT (
    echo ERROR: Narration file is empty.
    exit /b 1
)

REM Select a random gameplay clip
set /a CLIP=%RANDOM% %% 30 + 1
set "LAST="
if exist "%LASTFILE%" set /p "LAST="<"%LASTFILE%"
if "%CLIP%"=="%LAST%" set /a CLIP=CLIP %% 30 + 1

set "NUM=0%CLIP%"
if %CLIP% GEQ 10 set "NUM=%CLIP%"

set "VIDEO=%ROOT%\clips\clip_%NUM%.mp4"
set "TEMPVIDEO=%ROOT%\output\temp_%RANDOM%_%RANDOM%.mp4"
set "OUT=%ROOT%\output\short_%RANDOM%_%RANDOM%.mp4"

if not exist "%VIDEO%" (
    echo ERROR: Gameplay clip not found: %VIDEO%
    exit /b 1
)

echo %CLIP%>"%LASTFILE%"

echo.
echo Generating narration audio and captions...

py -m edge_tts --voice en-US-GuyNeural --text "%SCRIPT%" --write-media "%AUDIO%" --write-subtitles "%SRT%"

if errorlevel 1 (
    echo ERROR: Edge TTS failed.
    exit /b 1
)

if not exist "%AUDIO%" (
    echo ERROR: Voice audio missing.
    exit /b 1
)

if not exist "%SRT%" (
    echo ERROR: Captions file missing.
    exit /b 1
)

echo.
echo Removing the first caption block to avoid hook duplication...

powershell -NoProfile -ExecutionPolicy Bypass -Command "$p='%SRT%'; $s=Get-Content -LiteralPath $p -Raw; $blocks=@($s.Trim() -split '\r?\n\s*\r?\n'); if ($blocks.Count -gt 1) { $blocks=$blocks[1..($blocks.Count-1)]; [System.IO.File]::WriteAllText($p, (($blocks -join [Environment]::NewLine) + [Environment]::NewLine), [System.Text.UTF8Encoding]::new($false)) }"

if errorlevel 1 (
    echo ERROR: Could not update captions.
    exit /b 1
)

echo.
echo Creating opening hook...

powershell -NoProfile -ExecutionPolicy Bypass -File "%ROOT%\make_hook.ps1"

if errorlevel 1 (
    echo ERROR: Hook generation failed.
    exit /b 1
)

if not exist "%HOOK%" (
    echo ERROR: Hook file missing.
    exit /b 1
)

echo.
echo PASS 1: Rendering gameplay and narration captions...

"%FFMPEG%" -y -i "%VIDEO%" -i "%AUDIO%" -vf "scale=1080:1920:force_original_aspect_ratio=increase,crop=1080:1920,subtitles='C\:/n8n-content/audio/captions.srt'" -map 0:v:0 -map 1:a:0 -c:v libx264 -preset ultrafast -crf 23 -c:a aac -b:a 128k -pix_fmt yuv420p -shortest "%TEMPVIDEO%"

if errorlevel 1 (
    echo ERROR: Caption rendering failed.
    exit /b 1
)

if not exist "%TEMPVIDEO%" (
    echo ERROR: Temporary video was not created.
    exit /b 1
)

echo.
echo PASS 2: Adding hook for 3.5 seconds...

"%FFMPEG%" -y -i "%TEMPVIDEO%" -vf "drawtext=fontfile='C\:/Windows/Fonts/arialbd.ttf':textfile='C\:/n8n-content/audio/hook.txt':fontsize=48:fontcolor=yellow:borderw=4:bordercolor=black:x=(w-text_w)/2:y=220:line_spacing=12:enable='between(t\,0\,3.5)'" -map 0:v:0 -map 0:a:0 -c:v libx264 -preset ultrafast -crf 23 -c:a copy -pix_fmt yuv420p "%OUT%"

if errorlevel 1 (
    echo ERROR: Hook rendering failed.
    exit /b 1
)

if not exist "%OUT%" (
    echo ERROR: Final video was not created.
    exit /b 1
)

del "%TEMPVIDEO%" >nul 2>&1

echo.
echo ==========================================
echo SUCCESS! Your Short is ready:
echo %OUT%
echo ==========================================

endlocal
