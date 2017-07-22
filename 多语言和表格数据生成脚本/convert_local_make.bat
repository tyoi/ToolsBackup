@echo off


::定义变量
::记录当前路径
set TARGETFILE=%~dp0configLocalText.txt
::原静态文件存储的路径
set BASEFILE_DIR=%~dp0config\
::目标文件存储的路径，分别是win32模拟器,ios,android
set TARGETFILE_WIN=E:\worldshipsclient\trunk\worldship\res\normal\localization\cn\configLocalText.txt
set TARGETFILE_IOS=E:\worldshipsclient\trunk\worldship\res\normal\ios\localization\cn\configLocalText.txt
set TARGETFILE_ANDROID=E:\worldshipsclient\trunk\worldship\res\normal\ios\android\localization\cn\configLocalText.txt

::删除上一次生成的文件
del /s /q "%TARGETFILE%"

::更新
:: TortoiseProc.exe /command:update /path:"%BASEFILE_DIR%" /closeonend:1

::调用python生成目标文件
convert_local.py

::将文件复制到指定路径
echo y|xcopy /s /q "%TARGETFILE%" "%TARGETFILE_WIN%"
echo y|xcopy /s /q "%TARGETFILE%" "%TARGETFILE_IOS%"
echo y|xcopy /s /q "%TARGETFILE%" "%TARGETFILE_ANDROID%"

pause