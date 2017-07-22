@echo off


::定义变量
::记录当前路径
rem set TARGETFILE=%~dp0configLocalText.txt
::原静态文件存储的路径
rem set BASEFILE_DIR=%~dp0config\
::目标文件存储的路径，分别是win32模拟器,ios,android
rem set TARGETFILE_WIN=E:\worldshipsclient\trunk\worldship\res\normal\localization\cn\configLocalText.txt
rem set TARGETFILE_IOS=E:\worldshipsclient\trunk\worldship\res\normal\ios\localization\cn\configLocalText.txt
rem set TARGETFILE_ANDROID=E:\worldshipsclient\trunk\worldship\res\normal\ios\android\localization\cn\configLocalText.txt

::删除上一次生成的文件
rem del /s /q "%TARGETFILE%"

::更新
:: TortoiseProc.exe /command:update /path:"%BASEFILE_DIR%" /closeonend:1

::调用python生成目标文件
copy_file.py

::将文件复制到指定路径
rem echo y|xcopy /s /q "%TARGETFILE%" "%TARGETFILE_WIN%"
rem echo y|xcopy /s /q "%TARGETFILE%" "%TARGETFILE_IOS%"
rem echo y|xcopy /s /q "%TARGETFILE%" "%TARGETFILE_ANDROID%"

pause