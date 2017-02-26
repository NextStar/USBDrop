@ECHO OFF
SETLOCAL
REM Copyright 2017 USBDrop.com
REM 
REM Permission is hereby granted, free of charge, to any person obtaining a copy of
REM this software and associated documentation files (the "Software"), to deal in
REM the Software without restriction, including without limitation the rights to
REM use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies
REM of the Software, and to permit persons to whom the Software is furnished to do
REM so, subject to the following conditions:
REM 
REM The above copyright notice and this permission notice shall be included in all
REM copies or substantial portions of the Software.
REM 
REM THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
REM IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
REM FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
REM AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
REM LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
REM OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
REM SOFTWARE.


REM *** Load the version number from version.txt
set /p BuildVersion=<version.txt
set BuildVersion=%BuildVersion: =%

REM *** Create a 7-zip self extracting archive
"%ProgramFiles%\7-Zip\7z" a -sfx7z.sfx release\USBDropSelfExtractor-%BuildVersion%.exe  -mx9 icons/*.ico setup.exe readme.md license.txt 

REM *** Cleanup our mess
if exist USBDrop.bak (
    del USBDrop.au3
    ren USBDrop.bak USBDrop.au3
)

REM *** Remove the stripped file
del USBDrop_stripped.au3

REM *** Remove the BackUp folder
rmdir /S /Q BackUp

REM *** Remove the temporary files with compiler directives
del FileVersion.au3
del ProductVersion.au3


