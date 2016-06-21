@echo off
python treecompiler.py
if errorlevel 1 goto exit
python indexbuilder.py
cd ..\Application
Application
cd ..\Compiler
:exit