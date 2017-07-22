--
-- 公告界面
-- Author: sunhaoran
-- Date: 2014-06-23
--
--require("app.ui.panel.building.")
NoticePanel = class("NoticePanel", BasePanel)

--面板
local panel = nil

--关闭按钮
local btn_close = nil
local _isNothing = false

local target = CCApplication:sharedApplication():getTargetPlatform()

print("***** target : %s ********",target)

local function MusicRequestForANDGAME( flag )
    local music = true
    if flag == "1" then
        music = true
    else
        music = false
    end
    CCUserDefault:sharedUserDefault():setBoolForKey("Volume_bg_Open",music)
    CCUserDefault:sharedUserDefault():setBoolForKey("Volume_effect_Open",music)
    CCUserDefault:sharedUserDefault():flush()
end

function NoticePanel:ctor(isNothing)
    if panel ~= nil then
        return
    end
    NoticePanel.super.ctor(self, "panel_notice")
    self.isShadowClose = false
    panel = self
    panel:initPanel()
    if LOGIN_CHANNEL == ANDGAME_SERVER then
        --设置音效
        local ok
        ok = CCLuaJavaBridge.callStaticMethod("com/sincetimes/games/worldship/AndgameHelper", "SetMusic", {MusicRequestForANDGAME},"(I)V")
    end
    if isNothing then
        _isNothing = isNothing
    else
        _isNothing = false
    end
end

function NoticePanel.addTextField(node, str)
--用户名
    local txt_check 
    local txt_account = ui.newEditBox({
        image = "#comment_txt_bar.png",
        size = CCSize(295, 60),
        x = -3,
        y = 0,
        listener = function(event, editbox)
            if event == "began" then
            elseif event == "ended" then
                LoginSystem.testUid = editbox:getText()
            elseif event == "return" then
            elseif event == "changed" then
            else
                printf("EditBox event %s", tostring(event))
            end
        end
    })
    node:add(txt_account)
    --设置默认文字
    if str then
        txt_account:setPlaceHolder(str)
    end
    --设置最大位数
    txt_account:setMaxLength(30)
    --设置键盘类型
   --[[
    kKeyboardReturnTypeDefault:  默认使用键盘return 类型
    --kKeyboardReturnTypeDone:     默认使用键盘return类型为“Done”字样
    kKeyboardReturnTypeSend:     默认使用键盘return类型为“Send”字样
    kKeyboardReturnTypeSearch:   默认使用键盘return类型为“Search”字样
    kKeyboardReturnTypeGo:       默认使用键盘return类型为“Go”字样
    ]]
    txt_account:setReturnType(kKeyboardReturnTypeDefault)
    --设置输入类型
    --[[
    kEditBoxInputFlagPassword:  密码形式输入
    --kEditBoxInputFlagSensitive: 敏感数据输入、存储输入方案且预测自动完成
    kEditBoxInputFlagInitialCapsWord: 每个单词首字母大写,并且伴有提示
    kEditBoxInputFlagInitialCapsSentence: 第一句首字母大写,并且伴有提示
    kEditBoxInputFlagInitialCapsAllCharacters: 所有字符自动大写
    ]]
    txt_account:setInputFlag(kEditBoxInputFlagSensitive)
    --设置输入模式
    --[[
    kEditBoxInputModeAny:         开启任何文本的输入键盘,包括换行
    kEditBoxInputModeEmailAddr:   开启 邮件地址 输入类型键盘
    kEditBoxInputModeNumeric:     开启 数字符号 输入类型键盘
    kEditBoxInputModePhoneNumber: 开启 电话号码 输入类型键盘
    kEditBoxInputModeUrl:         开启 URL 输入类型键盘
    kEditBoxInputModeDecimal:     开启 数字 输入类型键盘，允许小数点
    --kEditBoxInputModeSingleLine:  开启任何文本的输入键盘,不包括换行
    ]]
    txt_account:setInputMode(kEditBoxInputModeNumeric)
    --设置文本的颜色
    txt_account:setFontColor(ccc3(255, 255, 255))
    --设置文本的字体
    txt_account:setFontName(Config.RES_FONT_UI_PATH)
    txt_account:setFontSize(20)
    return txt_account
end


function NoticePanel:initPanel()
    log("NoticePanel init")
    -----test Code ---
    local node = display.newNode()
    NoticePanel.addTextField(node, "uid")
    panel.layout:add(node)


    -- 华为7.1.1.300 sdk初始化
    if LOGIN_CHANNEL == HUAWEI_SERVER then
        platformHuawei.initHuaweiSDK()
    end


    --关闭按钮
    btn_close = panel.layout.getChild("btn").getChild("btn_yellow")
    btn_close:onButtonClicked(NoticePanel.onCloseBtnClicked)
    --panel.layout.getChild("label"):setString(Config_LocaleText.lang("panel_system_seting_text_gonggao"))
    panel.layout.getChild("btn").getChild("txt_name"):setString(Config_LocaleText.lang("alert_ok"))

    local noticeUrl = "http://"..SERVER_ADDRESS..NOTICE_ADDRESS..LOGIN_CHANNEL..".html"

    --[[if target == kTargetAndroid then
                local ok, result = CCLuaJavaBridge.callStaticMethod("com/sincetimes/games/worldship/Worldship", "openWebview", {noticeUrl},"(Ljava/lang/String;)V")
                print("call openWebview result :%d",ok)
            elseif target == kTargetIphone or target == kTargetIpad then
                local ok = CCLuaObjcBridge.callStaticMethod("FMUIWebViewBridge", "createWebView", {url = noticeUrl,offsetX = "0",offsetY = "5",width = "712",height = "472"})
                print("***** ok : %d ********",ok)
            end]]

    -- for i=15,40 do
    --     for j=1,10 do
    --         local label_for_size = ui.newTTFLabel({
    --                     text = tostring(j),
    --                     size = i,
    --                     align = ui.TEXT_ALIGN_LEFT,
    --                     font = fontName
    --                 })
    --             temp_size = label_for_size:getContentSize().width
    --             print("font:"..i..",width:"..temp_size)
    --     end
    -- end
end

function NoticePanel:closePanel()
    
    NoticePanel.super.closePanel(panel)
    panel = nil
end

function NoticePanel.onCloseBtnClicked()
    --2015.07.06 增加关服功能
    if IS_OPEN_CHANNEL == false then
        return
    end

    if target == kTargetAndroid then
        local ok, result = CCLuaJavaBridge.callStaticMethod("com/sincetimes/games/worldship/Worldship", "removeWebView", {},"()V")
        print("call removeWebView result :%d",ok)
    elseif target == kTargetIphone or target == kTargetIpad then
        local ok = CCLuaObjcBridge.callStaticMethod("FMUIWebViewBridge", "backClicked", nil)
        print("***** ok : %d ********",ok)
    end
    
    panel:closePanel()
    --在线更新
    if _isNothing == false then
        startup_startup()
    end
end

function NoticePanel.onTap(x,y)

end

return GuildJoinPanel
