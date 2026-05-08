@echo off
REM install.bat — Installa le skill e gli agenti Claude Code aziendali
REM Compatibile con Windows

setlocal enabledelayedexpansion

set "SKILLS_DIR=%USERPROFILE%\.claude\skills"
set "AGENTS_DIR=%USERPROFILE%\.claude\agents"
set "SOURCE_SKILLS=%~dp0skills"
set "SOURCE_AGENTS=%~dp0agents"

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

REM Crea le directory se non esistono
if not exist "%SKILLS_DIR%" mkdir "%SKILLS_DIR%"
if not exist "%AGENTS_DIR%" mkdir "%AGENTS_DIR%"

set INSTALLED=0
set SKIPPED=0

REM Installa le skill (directory)
echo Installazione skill...
for /D %%d in ("%SOURCE_SKILLS%\*") do (
    set "skill_name=%%~nxd"
    set "dest=%SKILLS_DIR%\%%~nxd"

    if exist "!dest!" (
        set /p "answer=  La skill '!skill_name!' esiste gia'. Sovrascrivere? [s/N] "
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

REM Installa le skill file singoli (es. init-project.md)
for %%f in ("%SOURCE_SKILLS%\*.md") do (
    set "skill_name=%%~nxf"
    set "dest=%SKILLS_DIR%\%%~nxf"

    if exist "!dest!" (
        set /p "answer=  La skill '!skill_name!' esiste gia'. Sovrascrivere? [s/N] "
        if /i "!answer!"=="s" (
            copy /Y "%%f" "!dest!" >nul
            echo   OK !skill_name! ^(aggiornata^)
            set /a INSTALLED+=1
        ) else (
            echo   - !skill_name! ^(saltata^)
            set /a SKIPPED+=1
        )
    ) else (
        copy /Y "%%f" "!dest!" >nul
        echo   OK !skill_name! ^(installata^)
        set /a INSTALLED+=1
    )
)

REM Installa gli agenti
echo.
echo Installazione agenti...
for %%f in ("%SOURCE_AGENTS%\*.md") do (
    set "agent_name=%%~nxf"
    set "dest=%AGENTS_DIR%\%%~nxf"

    if exist "!dest!" (
        set /p "answer=  L'agente '!agent_name!' esiste gia'. Sovrascrivere? [s/N] "
        if /i "!answer!"=="s" (
            copy /Y "%%f" "!dest!" >nul
            echo   OK !agent_name! ^(aggiornato^)
            set /a INSTALLED+=1
        ) else (
            echo   - !agent_name! ^(saltato^)
            set /a SKIPPED+=1
        )
    ) else (
        copy /Y "%%f" "!dest!" >nul
        echo   OK !agent_name! ^(installato^)
        set /a INSTALLED+=1
    )
)

echo.
echo Installazione completata: %INSTALLED% installati, %SKIPPED% saltati.
echo.
echo Skill disponibili in Claude Code:
echo   /commit-push-pr [--no-push] [--draft-pr] [--squash]
echo   /java-spring-reviewer ^<percorso-file^>
echo   /test-reviewer ^<percorso-file^>
echo   /init-project
echo.
pause
