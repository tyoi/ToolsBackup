@echo off


::定义变量
::lua文件存储的路径
set SCRIPT_DIR=%~dp0..\scripts\
::luajit生成文件的存储路径
set B_SCRIPT=%~dp0..\bScript\
::ANDROID工程路径
set DIR=%~dp0
set APP_ROOT=%DIR%..\
set APP_ANDROID_ROOT=%DIR%
::set ANDROID_NDK_ROOT=E:\android\android\android-ndk-r9d
::NDK变量
set NDK_DEBUG=1
::时间d=date t=time
set d=%date:~0,10%
::set d=%d:-=%
set d=%d:/=%
set t=%time:~0,5%
set t=%t::=%
::apk文件的存放路径
set APK_DIR=E:\doc_ship\apk\


echo - config:
echo   ANDROID_NDK_ROOT    = %ANDROID_NDK_ROOT%
echo   QUICK_COCOS2DX_ROOT = %QUICK_COCOS2DX_ROOT%
echo   COCOS2DX_ROOT       = %COCOS2DX_ROOT%
echo   APP_ROOT            = %APP_ROOT%
echo   APP_ANDROID_ROOT    = %APP_ANDROID_ROOT%
echo   SCRIPT_DIR    	   = %SCRIPT_DIR%
echo   B_SCRIPT    		   = %B_SCRIPT%


cd %DIR%
::echo f|xcopy /s /q "%DIR%bin\WorldshipLocal-release.apk" "%APK_DIR%WorldshipLocal-%d%-%t%.apk"
echo y|xcopy /s /q "%DIR%bin\WorldshipLocal-release.apk" "E:\Program Files (x86)\Jenkins\workspace\worldship_local\WorldshipLocal-release.apk"

echo "pack end ok"

pause
