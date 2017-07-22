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
set ANDROID_NDK_ROOT=E:\android\android\android-ndk-r9d
set QUICK_COCOS2DX_ROOT=E:\worldshipsclient\trunk\quick-cocos2d-x
set COCOS2DX_ROOT=E:\worldshipsclient\trunk\quick-cocos2d-x\lib\cocos2d-x
::NDK变量
set NDK_DEBUG=1
::时间d=date t=time
set d=%date:~0,10%
::set d=%d:-=%
set d=%d:/=%
set t=%time:~0,5%
set t=%t::=%
::apk文件的存放路径
set APK_DIR=D:\workspace\worldshipLocal

rem echo - config:
rem echo   ANDROID_NDK_ROOT    = %ANDROID_NDK_ROOT%
rem echo   QUICK_COCOS2DX_ROOT = %QUICK_COCOS2DX_ROOT%
rem echo   COCOS2DX_ROOT       = %COCOS2DX_ROOT%
rem echo   APP_ROOT            = %APP_ROOT%
rem echo   APP_ANDROID_ROOT    = %APP_ANDROID_ROOT%
rem echo   SCRIPT_DIR    	   = %SCRIPT_DIR%
rem echo   B_SCRIPT    		   = %B_SCRIPT%

::处理资源文件
echo STEP 1.Update resources

echo clean: %APP_ANDROID_ROOT%bin
if exist "%APP_ANDROID_ROOT%bin" rmdir /s /q "%APP_ANDROID_ROOT%bin"
mkdir "%APP_ANDROID_ROOT%bin"

rem goto pack

::更新资源的方式
if {%1} == {cleanRes} goto cleanRes

::增量更新
:updateRes

echo updateRes
copy "%APP_ROOT%res\framework_precompiled.zip" "%APP_ANDROID_ROOT%assets\res\framework_precompiled.zip"
cd %DIR%
call pack_check_changed_file.bat

goto script

:cleanRes

echo cleanRes
echo clean %APP_ANDROID_ROOT%assets
if exist "%APP_ANDROID_ROOT%assets" rmdir /s /q "%APP_ANDROID_ROOT%assets"
mkdir "%APP_ANDROID_ROOT%assets"

echo - copy resources
mkdir "%APP_ANDROID_ROOT%assets\res"
mkdir "%APP_ANDROID_ROOT%assets\res\config"
mkdir "%APP_ANDROID_ROOT%assets\res\normal"

mkdir "%APP_ANDROID_ROOT%assets\res\normal\audio"
mkdir "%APP_ANDROID_ROOT%assets\res\normal\fnt"
mkdir "%APP_ANDROID_ROOT%assets\res\normal\font"
mkdir "%APP_ANDROID_ROOT%assets\res\normal\layout"
mkdir "%APP_ANDROID_ROOT%assets\res\normal\particle"
mkdir "%APP_ANDROID_ROOT%assets\res\normal\video"

copy "%APP_ROOT%res\framework_precompiled.zip" "%APP_ANDROID_ROOT%assets\res\framework_precompiled.zip"
xcopy /s /q "%APP_ROOT%res\config\*.*" "%APP_ANDROID_ROOT%assets\res\config"
xcopy /s /q "%APP_ROOT%res\normal\ios\android\*.*" "%APP_ANDROID_ROOT%assets\res\normal"
xcopy /s /q "%APP_ROOT%res\normal\audio\*.*" "%APP_ANDROID_ROOT%assets\res\normal\audio"
xcopy /s /q "%APP_ROOT%res\normal\fnt\*.*" "%APP_ANDROID_ROOT%assets\res\normal\fnt"
xcopy /s /q "%APP_ROOT%res\normal\font\*.*" "%APP_ANDROID_ROOT%assets\res\normal\font"
xcopy /s /q "%APP_ROOT%res\normal\layout\*.*" "%APP_ANDROID_ROOT%assets\res\normal\layout"
xcopy /s /q "%APP_ROOT%res\normal\particle\*.*" "%APP_ANDROID_ROOT%assets\res\normal\particle"
xcopy /s /q "%APP_ROOT%res\normal\video\*.*" "%APP_ANDROID_ROOT%assets\res\normal\video"

cd %DIR%
call pack_create_all_dict.bat

:script
echo STEP 1.Finish!


::处理脚本文件
echo STEP 2.Update scripts

if {%2} == {cleanScript} goto cleanScript

:updateScript
echo updateScript

cd %DIR%
call pack_check_changed_script.bat

goto pack

:cleanScript
echo cleanScript
::转到lua文件路径
cd %SCRIPT_DIR%

::清理生成文件路径
echo "cleaning dest dir:%B_SCRIPT%"
rmdir /s /q "%B_SCRIPT%"
echo "dest dir clear"

::创建目标路径，并复制脚本
echo "copy file from %SCRIPT_DIR% to %B_SCRIPT%"
mkdir "%B_SCRIPT%"
xcopy /s /q "%SCRIPT_DIR%*.*" "%B_SCRIPT%"

::使用luajit进行生成
echo "start generate luajit files"
cd %B_SCRIPT%
for /r %%v in (*.lua) do luajit -b %%v %%v 
echo "generation complete!"

echo - copy scripts
echo clean %APP_ANDROID_ROOT%assets/scripts
if exist "%APP_ANDROID_ROOT%assets/scripts" rmdir /s /q "%APP_ANDROID_ROOT%assets/scripts"
mkdir "%APP_ANDROID_ROOT%assets/scripts"

mkdir "%APP_ANDROID_ROOT%assets\scripts"
xcopy /s /q "%APP_ROOT%bScript\*.*" "%APP_ANDROID_ROOT%assets\scripts\"

cd %DIR%

call pack_create_script_dict.bat

:pack

echo STEP 2.Finish!


::生成直连或web包
echo STEP 3.Generate Config File

cd %DIR%

set apksuffix=

if {%3} == {server} (
	if {%6} == {input} (
		call pack_generate_iodefines.bat %3 %7 %8 %9
		set apksuffix=server-%7-%8-%9
	) else (  
		call pack_generate_iodefines.bat %3 %6 %8 %9
		set apksuffix=server-%6-%8-%9
	)

	if {%4} == {input} (
		call pack_generate_platform.bat %5
	) else (
		call pack_generate_platform.bat %4
	)

	luajit -b %APP_ANDROID_ROOT%pack_temp_server_WorldShip.lua %APP_ANDROID_ROOT%assets\scripts\app\WorldShip.lua
) else (
	call pack_generate_iodefines.bat web

	if {%3} == {uidweb} (
		luajit -b %APP_ANDROID_ROOT%pack_temp_LoginSystem.lua %APP_ANDROID_ROOT%assets\scripts\app\game\controlers\LoginSystem.lua
		luajit -b %APP_ANDROID_ROOT%pack_temp_NoticePanel.lua %APP_ANDROID_ROOT%assets\scripts\app\ui\panel\building\NoticePanel.lua
	)

	if {%4} == {input} (
		call pack_generate_platform.bat %5

		if {%3} == {uidweb} (
			set apksuffix=uid-web-%5
		) else (
			set apksuffix=web-%5
		)
		
	) else (
		call pack_generate_platform.bat %4

		if {%3} == {uidweb} (
			set apksuffix=uid-web-%4
		) else (
			set apksuffix=web-%4
		)
	)

	luajit -b %SCRIPT_DIR%app\WorldShip.lua %APP_ANDROID_ROOT%assets\scripts\app\WorldShip.lua
)

set apksuffix=%apksuffix:/=-%
set apksuffix=%apksuffix::=-%
echo "%apksuffix%"
luajit -b %APP_ANDROID_ROOT%pack_temp_platform.lua %APP_ANDROID_ROOT%assets\res\platform.lua
luajit -b %APP_ANDROID_ROOT%pack_temp_IODefines.lua %APP_ANDROID_ROOT%assets\scripts\app\game\core\io\IODefines.lua

rem echo Using prebuilt externals
rem "%ANDROID_NDK_ROOT%\ndk-build" -j4 %ANDROID_NDK_BUILD_FLAGS% NDK_DEBUG=%NDK_DEBUG% %NDK_BUILD_FLAGS% -C %APP_ANDROID_ROOT% NDK_MODULE_PATH=%QUICK_COCOS2DX_ROOT%;%COCOS2DX_ROOT%;%COCOS2DX_ROOT%\cocos2dx\platform\third_party\android\prebuilt

call pack_ndk_build.bat

::复制更新文件
copy "%DIR%\update.zip" "%DIR%\assets\update.zip"

echo STEP 3.Finish!

::打包
echo STEP 4.packing apk

call pack_call_ant.bat
echo "pack end"
echo STEP 4.Finish!

::拷贝apk文件

cd %DIR%

if not exist "%APK_DIR%%d%" mkdir "%APK_DIR%%d%"

echo f|xcopy /s /q "%DIR%bin\WorldshipLocal-release.apk" "%APK_DIR%\%d%\worldshipLocal-%d%-%t%-%apksuffix%.apk"

echo "pack end ok"

pause
