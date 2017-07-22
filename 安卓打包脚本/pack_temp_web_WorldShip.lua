--
--------------------------------------------------------------------------------
--  DESCRIPTION:	主程序控制
--	AUTHOR:			Z.O.E
--  COMPANY:		Sincetimes
--  CREATED:		2013年11月27日
--------------------------------------------------------------------------------
--
CCLuaLoadChunksFromZIP("res/framework_precompiled.zip")

require("config")
require("framework.init")
require("framework.shortcodes")
require("framework.cc.init")
require("app.game.includes")

local WorldShip = class("WorldShip", cc.mvc.AppBase)
local instance = nil

function WorldShip:ctor()
    WorldShip.super.ctor(self)
    instance = self
end

--启动
function start()
    --配置文件加载
    LibraryManager.init()
    --主场景初始化
    instance:enterScene("MainScene")

    --平台调试
    local platform = CCApplication:sharedApplication():getTargetPlatform()
    if (platform == kTargetWindows or platform == kTargetMacOS) and IODefines.conectNet == true then
        --windows调试用
        --通信协议初始化
        local protomgr = ProtocolMgr.new()
        Transport.new(protomgr:GetPkgMap(), IODefines.server_ip, IODefines.server_port)
        BasicWatcher.getInstance()
        -- require("app.game.UidList")
        -- IODefines.uid = UidListList[UidListNum]
        Transport.Connect()
        local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
        scheduler.scheduleGlobal(Transport.step, 0.1, false)
        --主逻辑初始化
           --MainSystem.init()
    else
        log("####################init")
        --SceneSystem.initLoginScene()
        SceneSystem.initLoginScene()
    end
end


function WorldShip:run()
    --帧数
    CCDirector:sharedDirector():setAnimationInterval(1.0 / 30)

    --更新路径
    CCFileUtils:sharedFileUtils():addSearchPath(CCFileUtils:sharedFileUtils():getWritablePath() .. "res/")

    --资源路径
    CCFileUtils:sharedFileUtils():addSearchPath("res/")
    --本地化处理
    Config_LocaleText.init()
    --注册启动事件
    EventManager.addEventListener(EventDefines.GAME_START, start)
    --模块管理
    YYActivitySystem.init()
    --在线更新
    require("app.startup")
    --本地推送
    --目前开放IOS
    local platform = CCApplication:sharedApplication():getTargetPlatform()
    -- if platform == kTargetIphone or platform == kTargetIpad then
        AlarmSystem.Send_12_1230_18()
    -- end
end

return WorldShip
