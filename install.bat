@echo off
REM install.bat — Installa le skill Claude Code aziendali
REM Compatibile con Windows

setlocal enabledelayedexpansion

set "SKILLS_DIR=%USERPROFILE%\.claude\skills"
set "SOURCE_DIR=%~dp0skills"

echo === Installazione skill Claude Code aziendali ===
echo.

REM Verifica che Claude Code sia installato
where claude >nul 2>&1
if errorlevel 1 (
    echo ATTENZIONE: il comando 'claude' non e' stato trovato nel PATH.
    echo Assicurati di aver installato Claude Code prima di procedere.
    echo https://docs.anthropic.com/it/docs/claude-code/getting-started
    echo.
)

REM Crea la directory skills se non esiste
if not exist "%SKILLS_DIR%" (
    echo Creazione directory %SKILLS_DIR% ...
    mkdir "%SKILLS_DIR%"
)

set INSTALLED=0
set SKIPPED=0

REM Installa ogni skill
for /D %%d in ("%SOURCE_DIR%\*") do (
    set "skill_name=%%~nxd"
    set "dest=%SKILLS_DIR%\%%~nxd"

    if exist "!dest!" (
        set /p "answer=La skill '!skill_name!' esiste gia'. Sovrascrivere? [s/N] "
        if /i "!answer!"=="s" (
            xcopy /E /I /Y "%%d" "!dest!" >nul
            echo   OK !skill_name! ^(aggiornata^)
            set /a INSTALLED+=1
        ) else (
            echo   - !skill_name! ^(saltata^)
            set /a SKIPPED+=1
        )
    ) else (
        xcopy /E /I /Y "%%d" "!dest!" >nul
        echo   OK !skill_name! ^(installata^)
        set /a INSTALLED+=1
    )
)

echo.
echo Installazione completata: %INSTALLED% installate, %SKIPPED% saltate.
echo.
echo Skill disponibili in Claude Code:
echo   /architettura-progetto ^<root-progetto^>
echo   /gestione-test ^<percorso-file^>
echo   /revisione-codice ^<percorso-file^>
echo.
pause
