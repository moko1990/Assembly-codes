@echo off
echo Compiling BCD Addition Program...
echo.

REM Compile with MASM
if exist masm.exe (
    echo Using MASM...
    masm bcd_addition.asm;
    if errorlevel 1 (
        echo Compilation failed!
        pause
        exit /b 1
    )
    
    echo Linking...
    link bcd_addition.obj;
    if errorlevel 1 (
        echo Linking failed!
        pause
        exit /b 1
    )
    
    echo.
    echo Compilation successful! Running program...
    echo.
    bcd_addition.exe
    
) else if exist tasm.exe (
    echo Using TASM...
    tasm bcd_addition.asm
    if errorlevel 1 (
        echo Compilation failed!
        pause
        exit /b 1
    )
    
    echo Linking...
    tlink bcd_addition.obj
    if errorlevel 1 (
        echo Linking failed!
        pause
        exit /b 1
    )
    
    echo.
    echo Compilation successful! Running program...
    echo.
    bcd_addition.exe
    
) else (
    echo Error: Neither MASM nor TASM found in PATH!
    echo Please make sure MASM or TASM is installed and in your PATH.
    echo.
    echo Manual compilation steps:
    echo 1. masm bcd_addition.asm;
    echo 2. link bcd_addition.obj;
    echo 3. bcd_addition.exe
    echo.
    echo Or for TASM:
    echo 1. tasm bcd_addition.asm
    echo 2. tlink bcd_addition.obj
    echo 3. bcd_addition.exe
)

echo.
pause
