set ANDROID_NDK_ROOT=E:\android\android\android-ndk-r9d
set QUICK_COCOS2DX_ROOT=E:\worldshipsclient\trunk\quick-cocos2d-x
set COCOS2DX_ROOT=E:\worldshipsclient\trunk\quick-cocos2d-x\lib\cocos2d-x
::NDK变量
set NDK_DEBUG=1

rem echo Using prebuilt externals
"%ANDROID_NDK_ROOT%\ndk-build" -j4 %ANDROID_NDK_BUILD_FLAGS% NDK_DEBUG=%NDK_DEBUG% %NDK_BUILD_FLAGS% -C %APP_ANDROID_ROOT% NDK_MODULE_PATH=%QUICK_COCOS2DX_ROOT%;%COCOS2DX_ROOT%;%COCOS2DX_ROOT%\cocos2dx\platform\third_party\android\prebuilt