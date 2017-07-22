--登录系统
-- Author: Ma Chao
-- Date: 2014-04-16 10:46:49
--
require("app.ui.panel.building.ServerChoosePanel")

LoginSystem = class("LoginSystem")

UNIQUECODE 		= "UniqueCodeKey"
OPENID 			= "OpenIdKey"
CHANNEL_CUR 	= "Channel_cur" --"1"华清，"2"facebook
ISBIND_CUR 		= "IsBInd_cur"--"1"已绑定，“0”未绑定
REGION 			= "RegionKey"
REGIONNAME		= "RegionNameKey"
REGIONSTATE		= "RegionStateKey"
ACCOUNT			= "AccountKey"
TOKEN_UNIQUE 	= "token_unique"

--openid列表
OPENID_LIST 	= "openid_list"
ACCOUNT_LIST 	= "AccountKey_list"
CHANNEL_LIST 	= "Channel_list" --渠道列表
ISBIND_LIST 	= "IsBind_list" --是否绑定按钮
--游客
OPENID_VISITOR 			= "OpenIdKey_visitor"
ACCOUNT_VISITOR			= "AccountKey_visitor"
CHANNEL_VISITOR 		= "Channel_visitor"
ISBIND_VISITOR 			= "IsBind_visitor"
DEVICE_ACCOUNT_VISITER 	= "DeviceAccount_visitor" -- web根据设备号返回的游客账号


REGION_ID     = "RegionId_"
REGION_NAME   = "RegionName_"
REGION_STATE  = "RegionState_"
REGION_ROLE_NAME = "RegionRoleName_"
REGION_ROLE_HEAD = "RegionRoleHead_"
REGION_KEY 	  = "_Key"

COOLPAD_CHANGEUSER = "CoolPad_ChangeUser"

---test code ----
LoginSystem.testUid = nil


--
-- json 
--
local json = {}
local cjson = require("cjson")

local isInit = false

function json.encode(var)
    local status, result = pcall(cjson.encode, var)
    if status then return result end
    if DEBUG > 1 then
        echoError("json.encode() - encoding failed: %s", tostring(result))
    end
end

function json.decode(text)
    local status, result = pcall(cjson.decode, text)
    if status then return result end
    if DEBUG > 1 then
        echoError("json.decode() - decoding failed: %s", tostring(result))
    end
end
json.null = cjson.null

--去掉空格
--@param  str   字符串
function SpaceTrim(str)
    str = string.gsub(str, " ", "")
    return str
end

--去掉下划线
--@param  str   字符串
function UnderlineTrim(str)
    str = string.gsub(str, "_", "")
    return str
end

--去掉逗号
--@param  str   字符串
function CommaTrim(str)
    str = string.gsub(str, ",", "")
    return str
end

--长度限制
--@param  str   字符串
function CountLimit(str)
    str = string.sub(str, 1, 20)
    return str
end

--&符号限制
--@param  str   字符串
function Comma_2Trim(str)
    str = string.gsub(str, "&", "")
    return str
end

--？限制
--@param  str   字符串
function QuestionLimit(str)
    str = string.gsub(str, "?", "")
    return str
end
local function Split(szFullString, szSeparator)  
	local nFindStartIndex = 1  
	local nSplitIndex = 1  
	local nSplitArray = {}  
	while true do  
   		local nFindLastIndex = string.find(szFullString, szSeparator, nFindStartIndex)  
   		if not nFindLastIndex then  
    		local str = string.sub(szFullString, nFindStartIndex, string.len(szFullString))
   			if string.len(str) ~= 0 then
   				nSplitArray[nSplitIndex] =  str
   			end 
    		break  
   		end  
   		local str = string.sub(szFullString, nFindStartIndex, nFindLastIndex - 1)
   		if string.len(str) ~= 0 then
   			nSplitArray[nSplitIndex] =  str
   		end 
   		nFindStartIndex = nFindLastIndex + string.len(szSeparator)  
   		nSplitIndex = nSplitIndex + 1  
	end  
	return nSplitArray  
end 
--获得openid列表
function LoginSystem.getOpenIdList()
	local openidList = CCUserDefault:sharedUserDefault():getStringForKey(OPENID_LIST)
	openidList = openidList or ""
	local openidArray = Split(openidList, "|")
	return openidArray
end
--获得用户名列表
function LoginSystem.getUserNameList()
	local openidList = CCUserDefault:sharedUserDefault():getStringForKey(ACCOUNT_LIST)
	openidList = openidList or ""
	local openidArray = Split(openidList, "|")
	return openidArray
end
--获得渠道列表
function LoginSystem.getChannelList()
	local openidList = CCUserDefault:sharedUserDefault():getStringForKey(CHANNEL_LIST)
	openidList = openidList or ""
	local openidArray = Split(openidList, "|")
	return openidArray
end
--获得绑定状态
function LoginSystem.getIsBindList()
	local openidList = CCUserDefault:sharedUserDefault():getStringForKey(ISBIND_LIST)
	openidList = openidList or ""
	local openidArray = Split(openidList, "|")
	return openidArray
end
--添加帐号
function LoginSystem.addOpenIdToUserList(openid, username,isVisitor, channel, isBInd)
	if isVisitor then
		CCUserDefault:sharedUserDefault():setStringForKey(OPENID_VISITOR, openid)
		CCUserDefault:sharedUserDefault():setStringForKey(OPENID, openid)
		local str = Config_LocaleText.lang("panel_login_mian_text_1")
		-- 游客登录修改 --------------------------
		if username == nil or string.len(username) == 0 then
			-- 旧游客
			str = str..string.sub(openid, 1, 7)
		else
			-- 新游客
			if string.find(username, str) ~= 1 then
				str = str..tostring(username)
			else
				str = username
			end
		end
		------------------------------------------
		CCUserDefault:sharedUserDefault():setStringForKey(ACCOUNT, str)
		CCUserDefault:sharedUserDefault():setStringForKey(ACCOUNT_VISITOR, str)
		CCUserDefault:sharedUserDefault():setStringForKey(CHANNEL_VISITOR, channel)
		CCUserDefault:sharedUserDefault():setStringForKey(ISBIND_VISITOR, isBInd)
		CCUserDefault:sharedUserDefault():setStringForKey(CHANNEL_CUR, channel)
		CCUserDefault:sharedUserDefault():setStringForKey(ISBIND_CUR, isBInd)
	else
		local openidList = CCUserDefault:sharedUserDefault():getStringForKey(OPENID_LIST)
		local userNameList = CCUserDefault:sharedUserDefault():getStringForKey(ACCOUNT_LIST)
		local channelList = CCUserDefault:sharedUserDefault():getStringForKey(CHANNEL_LIST)
		local isBindList = CCUserDefault:sharedUserDefault():getStringForKey(ISBIND_LIST)
		openidList = openidList or ""
		userNameList = userNameList or ""
		channelList = channelList or ""
		isBindList = isBindList or ""
		local openidArray = Split(openidList, "|")
		local userNameArray = Split(userNameList, "|")
		local channelArray = Split(channelList, "|")
		local isBindArray = Split(isBindList, "|")
		for i,v in ipairs(openidArray) do
			if v == openid then
				table.remove(openidArray, i)
				table.remove(userNameArray, i)
				table.remove(channelArray, i)
				table.remove(isBindArray, i)
				break
			end
		end
		--[[for i,v in ipairs(userNameArray) do
							if v == username then
								table.remove(userNameArray, i)
								break
							end
						end]]
		table.insert(openidArray, 1, openid)
		table.insert(userNameArray, 1, username)
		table.insert(channelArray, 1, channel)
		table.insert(isBindArray, 1, isBInd)
		openidList = ""
		for i,v in ipairs(openidArray) do
			openidList = openidList.. v.."|"
		end
		userNameList = ""
		for i,v in ipairs(userNameArray) do
			userNameList = userNameList.. v.."|"
		end
		channelList = ""
		for i,v in ipairs(channelArray) do
			channelList = channelList.. v.."|"
		end
		isBindList = ""
		for i,v in ipairs(isBindArray) do
			isBindList = isBindList.. v.."|"
		end
		CCUserDefault:sharedUserDefault():setStringForKey(OPENID_LIST, openidList)
		CCUserDefault:sharedUserDefault():setStringForKey(OPENID, openid)
		CCUserDefault:sharedUserDefault():setStringForKey(ACCOUNT_LIST, userNameList)
		CCUserDefault:sharedUserDefault():setStringForKey(ACCOUNT, username)
		CCUserDefault:sharedUserDefault():setStringForKey(CHANNEL_LIST, channelList)
		CCUserDefault:sharedUserDefault():setStringForKey(CHANNEL_CUR, channel)
		CCUserDefault:sharedUserDefault():setStringForKey(ISBIND_LIST, isBindList)
		CCUserDefault:sharedUserDefault():setStringForKey(ISBIND_CUR, isBInd)
	end
end
--删除帐号
function LoginSystem.deleteOpenIdToUserList(openid, username,isVisitor)
	if isVisitor then
		CCUserDefault:sharedUserDefault():setStringForKey(OPENID_VISITOR, "")
		CCUserDefault:sharedUserDefault():setStringForKey(ACCOUNT_VISITOR, "")
		CCUserDefault:sharedUserDefault():setStringForKey(CHANNEL_VISITOR, "")
		CCUserDefault:sharedUserDefault():setStringForKey(ISBIND_VISITOR, "")
		-- 游客登录修改 -------------------------
		CCUserDefault:sharedUserDefault():setStringForKey(DEVICE_ACCOUNT_VISITER, "")
		-----------------------------------------
	else
		local openidList = CCUserDefault:sharedUserDefault():getStringForKey(OPENID_LIST)
		local userNameList = CCUserDefault:sharedUserDefault():getStringForKey(ACCOUNT_LIST)
		local channelList = CCUserDefault:sharedUserDefault():getStringForKey(CHANNEL_LIST)
		local isBindList = CCUserDefault:sharedUserDefault():getStringForKey(ISBIND_LIST)
		openidList = openidList or ""
		userNameList = userNameList or ""
		channelList = channelList or ""
		isBindList = isBindList or ""
		local openidArray = Split(openidList, "|")
		local userNameArray = Split(userNameList, "|")
		local channelArray = Split(channelList, "|")
		local isBindArray = Split(isBindList, "|")
		for i,v in ipairs(openidArray) do
			if v == openid then
				table.remove(openidArray, i)
				table.remove(userNameArray, i)
				table.remove(channelArray, i)
				table.remove(isBindArray, i)
				break
			end
		end
		--[[for i,v in ipairs(userNameArray) do
							if v == username then
								table.remove(userNameArray, i)
								break
							end
						end]]
		openidList = ""
		for i,v in ipairs(openidArray) do
			openidList = openidList.. v.."|"
		end
		userNameList = ""
		for i,v in ipairs(userNameArray) do
			userNameList = userNameList.. v.."|"
		end
		channelList = ""
		for i,v in ipairs(channelArray) do
			channelList = channelList.. v.."|"
		end
		isBindList = ""
		for i,v in ipairs(isBindArray) do
			isBindList = isBindList.. v.."|"
		end
		CCUserDefault:sharedUserDefault():setStringForKey(OPENID_LIST, openidList)
		CCUserDefault:sharedUserDefault():setStringForKey(ACCOUNT_LIST, userNameList)
		CCUserDefault:sharedUserDefault():setStringForKey(CHANNEL_LIST, channelList)
		CCUserDefault:sharedUserDefault():setStringForKey(ISBIND_LIST, isBindList)
	end
	--CCUserDefault:sharedUserDefault():setStringForKey(ACCOUNT, username)
end
--通过索引获得帐号
--索引5为游客
function LoginSystem.getOpenIdFromUserListByIndex(index)
	if inedx == 5 then--游客
		local openid = CCUserDefault:sharedUserDefault():getStringForKey(OPENID_VISITOR)
		return openid
	else
		local openidList = CCUserDefault:sharedUserDefault():getStringForKey(OPENID_LIST)
		openidList = openidList or ""
		local openidArray = Split(openidList, "|")
		return openidArray[index]
	end
end

local _is_new     = false
local _is_windows = false
local _platform = "unknown"
local _model = "unknown"
local _openID = CCUserDefault:sharedUserDefault():getStringForKey(OPENID)
local _uniqueCode = CCUserDefault:sharedUserDefault():getStringForKey(UNIQUECODE)
local target = CCApplication:sharedApplication():getTargetPlatform()
local _account = nil

if target == kTargetWindows then
	_platform           = "windows"
	_is_windows         = true
	_is_new = true
	if not _openID or #_openID == 0 then
    	--判断是否存贮了设备唯一码
    	if not _uniqueCode or #_uniqueCode == 0 then
    		print("_uniqueCode init")
    		_uniqueCode = tostring(os.time()) 
    		print(_uniqueCode)
    	end
	end
elseif target == kTargetMacOS then
    _platform = "mac"
elseif target == kTargetAndroid then
    _platform = "android"
    local ok
    ok,_model   = CCLuaJavaBridge.callStaticMethod("com/sincetimes/games/worldship/Worldship", "getDeviceName", {}, "()Ljava/lang/String;")
    _model = SpaceTrim(_model)
    _model = UnderlineTrim(_model)
    _model = CommaTrim(_model)
    _model = Comma_2Trim(_model)
    _model = QuestionLimit(_model)
    _model = CountLimit(_model)
    --判断是否是老用户，存在OpenID
    if not _openID or #_openID == 0 then
    	--判断是否存贮了设备唯一码
    	if not _uniqueCode or #_uniqueCode == 0 then
    		local ok
		    ok, _uniqueCode = CCLuaJavaBridge.callStaticMethod("com/sincetimes/games/worldship/Worldship", "getUUID", {}, "()Ljava/lang/String;")
		    CCUserDefault:sharedUserDefault():setStringForKey(UNIQUECODE, _uniqueCode)
    	end
    	_is_new = true
	end
elseif target == kTargetIphone or target == kTargetIpad then
    _platform = "ios"
    local ok
    ok,_model   = CCLuaObjcBridge.callStaticMethod("OpenUDIDIOS", "getDeviceName", nil)
    _model = SpaceTrim(_model)
    _model = UnderlineTrim(_model)
    _model = CommaTrim(_model)
    _model = Comma_2Trim(_model)
    _model = QuestionLimit(_model)
    _model = CountLimit(_model)
    --判断是否是老用户，存在OpenID
    if not _openID or #_openID == 0 then
    	--判断是否存贮了设备唯一码
    	if not _uniqueCode or #_uniqueCode == 0 then
	    local ok
		    ok, _uniqueCode = CCLuaObjcBridge.callStaticMethod("OpenUDIDIOS", "_generateFreshOpenUDID", nil)
		    CCUserDefault:sharedUserDefault():setStringForKey(UNIQUECODE, _uniqueCode)
    	end
    	_is_new = true
	end
end

function LoginSystem.getDeviceName()
	return _model
end
function LoginSystem.getUniqueCode()
	return _uniqueCode
end

--@param regionid     服务器ID
--@param regionname   服务器名字
--@param regionstate  服务器状态
function LoginSystem.DelServer(regionid,regionname,regionstate)
	--最近登录服务器列表（6个）
	local ServerList = {}
	for i=1,6 do
		local tabel = {}
		tabel.id = CCUserDefault:sharedUserDefault():getStringForKey(REGION_ID..i..REGION_KEY)
		tabel.name = CCUserDefault:sharedUserDefault():getStringForKey(REGION_NAME..i..REGION_KEY)
		tabel.state = CCUserDefault:sharedUserDefault():getStringForKey(REGION_STATE..i..REGION_KEY)
		table.insert(ServerList,tabel)
	end

	--判断是否在最近登录服务器内
	for k,v in ipairs(ServerList) do
		if tonumber(v.id) == tonumber(regionid) then
			table.remove(ServerList,k)
			table.insert(ServerList,1,{id = "", name = "",state = ""})
			break
		end
	end
	
	--重新转化成文件里的内容
	for i=1,6 do
		CCUserDefault:sharedUserDefault():setStringForKey(REGION_ID..i..REGION_KEY, ServerList[i].id)
		CCUserDefault:sharedUserDefault():setStringForKey(REGION_NAME..i..REGION_KEY, ServerList[i].name)
		CCUserDefault:sharedUserDefault():setStringForKey(REGION_STATE..i..REGION_KEY, ServerList[i].state)
	end

	ServerList = {}
end

--@param regionid     服务器ID
--@param regionname   服务器名字
--@param regionstate  服务器状态
function LoginSystem.AddServer(regionid,regionname,regionstate)
	--最近登录服务器列表（6个）
	local ServerList = {}
	for i=1,6 do
		local tabel = {}
		tabel.id = CCUserDefault:sharedUserDefault():getStringForKey(REGION_ID..i..REGION_KEY)
		tabel.name = CCUserDefault:sharedUserDefault():getStringForKey(REGION_NAME..i..REGION_KEY)
		tabel.state = CCUserDefault:sharedUserDefault():getStringForKey(REGION_STATE..i..REGION_KEY)
		table.insert(ServerList,tabel)
	end

	--判断是否在最近登录服务器内
	local i = 1
	while i <= #ServerList do
		if tonumber(ServerList[i].id) == tonumber(regionid) then
			table.remove(ServerList,i)
		else
			i = i + 1
		end
	end

	for j = 1,6 - #ServerList  do
		table.insert(ServerList,{id = "", name = "",state = ""})
	end
	
	--添加到第一个服务器
	table.insert(ServerList,1,{id = regionid, name = regionname,state = regionstate})

	--重新转化成文件里的内容
	for i=1,6 do
		CCUserDefault:sharedUserDefault():setStringForKey(REGION_ID..i..REGION_KEY, ServerList[i].id)
		CCUserDefault:sharedUserDefault():setStringForKey(REGION_NAME..i..REGION_KEY, ServerList[i].name)
		CCUserDefault:sharedUserDefault():setStringForKey(REGION_STATE..i..REGION_KEY, ServerList[i].state)
	end
	ServerList = {}
end

function LoginSystem.AddRoleInfo(regionid,roleHead,roleName)
	--最近登录服务器列表（6个）
	
	local ServerRoleList = {}
	for i=1,6 do
		local tabel = {}
		tabel.id = CCUserDefault:sharedUserDefault():getStringForKey(REGION_ID..i..REGION_KEY)
		tabel.head = CCUserDefault:sharedUserDefault():getStringForKey(REGION_ROLE_HEAD..tabel.id..REGION_KEY)
		tabel.name = CCUserDefault:sharedUserDefault():getStringForKey(REGION_ROLE_NAME..tabel.id..REGION_KEY)
		table.insert(ServerRoleList,tabel)
	end

	--判断是否在最近登录服务器内
	local i = 1
	while i <= #ServerRoleList do
		if tonumber(ServerRoleList[i].id) == tonumber(regionid) then
			table.remove(ServerRoleList,i)
		else
			i = i + 1
		end
	end

	for j = 1,6 - #ServerRoleList  do
		table.insert(ServerRoleList,{id = "", head = "",name = ""})
	end
	
	--添加到第一个服务器
	table.insert(ServerRoleList,1,{id = regionid, head = roleHead,name = roleName})

	--重新转化成文件里的内容
	for i=1,6 do
		CCUserDefault:sharedUserDefault():setStringForKey(REGION_ROLE_HEAD..ServerRoleList[i].id..REGION_KEY, ServerRoleList[i].head)
		CCUserDefault:sharedUserDefault():setStringForKey(REGION_ROLE_NAME..ServerRoleList[i].id..REGION_KEY, ServerRoleList[i].name)
	end
	ServerList = {}
end

--登陆通信
local function Login()
	print("test# Login begin")
	if isInit == true then
		return
	end
	if LoginSystem.testUid then
		IODefines.uid = LoginSystem.testUid
		IODefines.secret = "8613910246800"
	end
	isInit = true
    --通信协议初始化
    local protomgr = ProtocolMgr.new()
    Transport.new(protomgr:GetPkgMap(), IODefines.server_ip, IODefines.server_port)
    BasicWatcher.getInstance()
    Transport.Connect()
    local scheduler = require(cc.PACKAGE_NAME .. ".scheduler")
    scheduler.scheduleGlobal(Transport.step, 0.1, false)
    print("test# Login end")
    --主逻辑初始化
    -- MainSystem.init()
 	
 	-- 广告活跃统计
    AdsupportSystem.Active()
    
	-- vicky 2015.12.11 ios talkingData 统计注册 
	if __isClickRegister == true then 
		IosTalkingDataHelper.register()
		__isClickRegister = false
	end 
    -- vicky 2015.12.11 ios talkingData 统计登录
    IosTalkingDataHelper.login()
end

function GameLogin()
	print("test# GameLogin")
	Login()
end

--web返回错误信息提示功能函数
local function WebErrorMessageShow(code)
--[[
错误码
	0	正确
	1	密码错误
	2	账号存在
	3	平台验证失败
	4	参数空
	5	参数错误
	6	异常
	7 	未从服务器获得数据
	8	Web错误
	9	停服更新
	16  服务器维护
	]]
	if code == 1 then
		GlobalSystem.Wind_Words(panel,Config_LocaleText.lang("login_txt_web_error_1"),255,255,255,0,0)
	elseif code == 2 then
		GlobalSystem.Wind_Words(panel,Config_LocaleText.lang("login_txt_web_error_2"),255,255,255,0,0)
	elseif code == 3 then
		GlobalSystem.Wind_Words(panel,Config_LocaleText.lang("login_txt_web_error_3"),255,255,255,0,0)
	elseif code == 4 then
		GlobalSystem.Wind_Words(panel,Config_LocaleText.lang("login_txt_web_error_10",tostring(code)),255,255,255,0,0)
	elseif code == 5 then
		GlobalSystem.Wind_Words(panel,Config_LocaleText.lang("login_txt_web_error_10",tostring(code)),255,255,255,0,0)	
	elseif code == 6 then
		GlobalSystem.Wind_Words(panel,Config_LocaleText.lang("login_txt_web_error_10",tostring(code)),255,255,255,0,0)
	elseif code == 7 then
		GlobalSystem.Wind_Words(panel,Config_LocaleText.lang("login_txt_web_error_10",tostring(code)),255,255,255,0,0)
	elseif code == 8 then
		GlobalSystem.Wind_Words(panel,Config_LocaleText.lang("login_txt_web_error_10",tostring(code)),255,255,255,0,0)
	elseif code == 9 then
		GlobalSystem.Wind_Words(panel,Config_LocaleText.lang("login_txt_web_error_9"),255,255,255,0,0)
	elseif code == 10 then
		GlobalSystem.Wind_Words(panel,Config_LocaleText.lang("login_txt_web_error_11"),255,255,255,0,0)
	elseif code == 16 then
		GlobalSystem.Wind_Words(panel,Config_LocaleText.lang("login_txt_web_error_16"),255,255,255,0,0)
	else
		GlobalSystem.Wind_Words(panel,Config_LocaleText.lang("login_txt_web_error_10",tostring(code)),255,255,255,0,0)
	end
end
function CallWebErrorMessageShow(code)
	WebErrorMessageShow(code)
end

local function StartRequestCallBack(event)
	local request = event.request
	--print("state:"..request:getState().."  statresponseecode:"..request:getResponseStatusCode().."  code:"..request:getErrorCode())
	if request:getErrorCode() ~= 0 then
		LoadingFrame_Hide()
		GlobalSystem.Wind_Words(panel,Config_LocaleText.lang("login_txt_error",tostring(request:getErrorCode())),255,255,255,0,0)
		print("#===StartRequestCallBack===ERROR!")
		return
	end
	local parseStr =  request:getResponseString()
	local responseData = json.decode(parseStr)
	print("===parseStr===:"..parseStr)
	if responseData ~= nil then
		if 0 == responseData.code then
			if responseData.content.regionId ~= 0 then
				CCUserDefault:sharedUserDefault():setStringForKey(REGION, responseData.content.regionId)
				CCUserDefault:sharedUserDefault():setStringForKey(REGIONNAME, responseData.content.regionName)
				CCUserDefault:sharedUserDefault():setStringForKey(REGIONSTATE, responseData.content.regionState)
				LoginUI.update()
			else
				CCUserDefault:sharedUserDefault():setStringForKey(REGION, "1")
				LoginUI.update()
			end
		else
			LoadingFrame_Hide()
			WebErrorMessageShow(responseData.code)
		end
	else
		LoadingFrame_Hide()
		GlobalSystem.Wind_Words(panel,Config_LocaleText.lang("login_txt_error_3"),255,255,255,0,0)
		print("#===responseData=nil====ERROR!")
		print("#===StartRequestCallBack===ERROR!")
		return
	end
end

function LoginSystem.StartRequest()
	if _is_new == true then
		local url = SERVER_ADDRESS.."region/".."get"
		print("url = "..url)
		local request = CCHTTPRequest:createWithUrl(StartRequestCallBack, url, kCCHTTPRequestMethodPOST)
		request:start()
	else
		LoginUI.update()
	end
end


-- vikcy 2015.12.22 
-- 检测是不是新用户
-- 1：新增
-- 0：老用户
-- -1或者nil：没有此用户 或者 老玩家 没有此字段
local function checkIsNewUser(isnew)
	if isnew ~= nil and tonumber(isnew) == 1 then
	    -- 广告注册统计
	    AdsupportSystem.Register()
	end 
end 


local function LoginNoOpenIdRequestCallBack(event)
	local request = event.request
	--print("state:"..request:getState().."  statresponseecode:"..request:getResponseStatusCode().."  code:"..request:getErrorCode())
	if request:getErrorCode() ~= 0 then
		print("#===LoginNoOpenIdRequestCallBack===ERROR!")
		LoadingFrame_Hide()
		GlobalSystem.Wind_Words(panel,Config_LocaleText.lang("login_txt_error",tostring(request:getErrorCode())),255,255,255,0,0)
		LoginUI.new()
		return
	end
	local parseStr =  request:getResponseString()
	print("===parseStr===:"..parseStr)
	local responseData = json.decode(parseStr)
	if responseData ~= nil then
		print("LoginRequestCallBack Login msg:".. parseStr)
		if 0 == responseData.code then
			print("#===LoginNoOpenIdRequestCallBack==SUCCESE")
			if #responseData.content > 1 then
				--合服之后的处理-- 服务器角色选择
				LoginChoosePanel.new(responseData.content)
			else
				LoginSystem.addOpenIdToUserList(responseData.content[1].openid, nil, true, "1", "0")
				CCUserDefault:sharedUserDefault():setStringForKey(TOKEN_UNIQUE, responseData.content[1].openid)
				CCUserDefault:sharedUserDefault():setStringForKey(UNIQUECODE, _uniqueCode)
				IODefines.server_ip = tostring(responseData.content[1].server)
				IODefines.server_port = tonumber(responseData.content[1].port)
				IODefines.secret = tostring(responseData.content[1].secret)
				IODefines.uid = tostring(responseData.content[1].uid)
				IODefines.openid = tostring(responseData.content[1].openid)

				checkIsNewUser(responseData.content[1].isnew)

				LoginSystem.AddServer(CCUserDefault:sharedUserDefault():getStringForKey(REGION),CCUserDefault:sharedUserDefault():getStringForKey(REGIONNAME),CCUserDefault:sharedUserDefault():getStringForKey(REGIONSTATE))
				Login()
			end
		else
			LoadingFrame_Hide()
			WebErrorMessageShow(responseData.code)
		end
	else
		LoadingFrame_Hide()
		GlobalSystem.Wind_Words(panel,Config_LocaleText.lang("login_txt_error_3"),255,255,255,0,0)
		print("#===responseData=nil====ERROR!")
		print("#===LoginNoOpenIdRequestCallBack===ERROR!")
		return
	end
end

local function LoginRequestCallBack(event)
	local request = event.request
	--print("state:"..request:getState().."  statresponseecode:"..request:getResponseStatusCode().."  code:"..request:getErrorCode())
	if request:getErrorCode() ~= 0 then
		print("#===LoginRequestCallBack===ERROR!")
		LoadingFrame_Hide()
		GlobalSystem.Wind_Words(panel,Config_LocaleText.lang("login_txt_error",tostring(request:getErrorCode())),255,255,255,0,0)
		LoginUI.new()
		return
	end
	local parseStr =  request:getResponseString()
	local responseData = json.decode(parseStr)
	if responseData ~= nil then
		print("LoginRequestCallBack Login msg:".. parseStr)
		if 0 == responseData.code then
			print("#===LoginRequestCallBack==SUCCESE")
			if #responseData.content > 1 then
				--合服之后的处理-- 服务器角色选择
				LoginChoosePanel.new(responseData.content)
			else
				CCUserDefault:sharedUserDefault():setStringForKey(OPENID, responseData.content[1].openid)
				CCUserDefault:sharedUserDefault():setStringForKey(TOKEN_UNIQUE, responseData.content[1].openid)
				CCUserDefault:sharedUserDefault():setStringForKey(UNIQUECODE, _uniqueCode)
				IODefines.server_ip = tostring(responseData.content[1].server)
				IODefines.server_port = tonumber(responseData.content[1].port)
				IODefines.secret = tostring(responseData.content[1].secret)
				IODefines.uid = tostring(responseData.content[1].uid)
				IODefines.openid = tostring(responseData.content[1].openid)
				IODefines.region = tostring(responseData.content[1].region)
				CCUserDefault:sharedUserDefault():setStringForKey(REGION, IODefines.region)

				checkIsNewUser(responseData.content[1].isnew)

				LoginSystem.AddServer(IODefines.region,CCUserDefault:sharedUserDefault():getStringForKey(REGIONNAME),CCUserDefault:sharedUserDefault():getStringForKey(REGIONSTATE))
				Login()			
			end
		else
			LoadingFrame_Hide()
			WebErrorMessageShow(responseData.code)
		end
	else
		print("#===responseData=nil====ERROR!")
		print("#===LoginRequestCallBack===ERROR!")
		LoadingFrame_Hide()
		GlobalSystem.Wind_Words(panel,Config_LocaleText.lang("login_txt_error_3"),255,255,255,0,0)
		return
	end
end

-----------------------------------------------------登陆平台相关----------------------------------------------------------
--PP助手平台登陆回调
local function LoginForPPRequestCallBack(event)
	local request = event.request
	if request:getErrorCode() ~= 0 then
		print("#===LoginForPPRequestCallBack===ERROR!")
		LoadingFrame_Hide()
		GlobalSystem.Wind_Words(panel,Config_LocaleText.lang("login_txt_error",tostring(request:getErrorCode())),255,255,255,0,0)
		return
	end
	local parseStr =  request:getResponseString()
	local responseData = json.decode(parseStr)
	if responseData ~= nil then
		if 0 == responseData.code then
			print("#===LoginForPPRequestCallBack==SUCCESE")
			if #responseData.content > 1 then
				--合服之后的处理-- 服务器角色选择
			else
				CCUserDefault:sharedUserDefault():setStringForKey(TOKEN_UNIQUE, responseData.content[1].openid)
				CCUserDefault:sharedUserDefault():setStringForKey(OPENID, responseData.content[1].openid)
				CCUserDefault:sharedUserDefault():setStringForKey(UNIQUECODE, _uniqueCode)
				IODefines.server_ip = tostring(responseData.content[1].server)
				IODefines.server_port = tonumber(responseData.content[1].port)
				IODefines.secret = tostring(responseData.content[1].secret)
				IODefines.uid = tostring(responseData.content[1].uid)
				IODefines.openid = tostring(responseData.content[1].openid)
				IODefines.region = tostring(responseData.content[1].region)
				CCUserDefault:sharedUserDefault():setStringForKey(REGION, IODefines.region)
				
				LoginSystem.AddServer(IODefines.region,CCUserDefault:sharedUserDefault():getStringForKey(REGIONNAME),CCUserDefault:sharedUserDefault():getStringForKey(REGIONSTATE))
				Login()			
			end
		else
			LoadingFrame_Hide()
			WebErrorMessageShow(responseData.code)
		end
	else
		print("#===responseData=nil====ERROR!")
		print("#===LoginForPPRequestCallBack===ERROR!")
		LoadingFrame_Hide()
		GlobalSystem.Wind_Words(panel,Config_LocaleText.lang("login_txt_error_3"),255,255,255,0,0)
		return
	end
end

--PP助手平台登陆
function LoginRequestForPP(tmpStr)
	if tmpStr == nil then
		--LoadingFrame_Hide()
	end

	local _region 		= CCUserDefault:sharedUserDefault():getStringForKey(REGION)
	if not _region or #_region == 0 then
		_region = IODefines.region
	end
	local url = SERVER_ADDRESS.."platform/common/login?channel="..LOGIN_CHANNEL.."&region=".._region
	if __IDFA ~= nil then 
		url = url .. "&idfa=" .. __IDFA
	end
	url = url .. "&deviceType=".._model.."&token="..tmpStr .. "&origin=" .. __active
	print("url = "..url)
    print("****************LoginRequestForPP****************")
	local request = CCHTTPRequest:createWithUrl(LoginForPPRequestCallBack, url, kCCHTTPRequestMethodPOST)
	request:start()
	LoadingFrame_Show()
end

--PP助手平台登陆
function LogoutRequestForPP()
	GlobalSystem.restart()
end

--应用宝平台登陆回调
local function LoginForQQRequestCallBack(event)
	local request = event.request
	if request:getErrorCode() ~= 0 then
		print("#===LoginForQQRequestCallBack===ERROR!")
		LoadingFrame_Hide()
		GlobalSystem.Wind_Words(panel,Config_LocaleText.lang("login_txt_error",tostring(request:getErrorCode())),255,255,255,0,0)
		return
	end
	local parseStr =  request:getResponseString()
	local responseData = json.decode(parseStr)
	if responseData ~= nil then
		if 0 == responseData.code then
			print("#===LoginForQQRequestCallBack==SUCCESE")
			print(tostring(#responseData.content))
			if #responseData.content > 1 then
				--合服之后的处理-- 服务器角色选择
				LoginChoosePanel.new(responseData.content)
			else
				print("to do login")
				CCUserDefault:sharedUserDefault():setStringForKey(OPENID, responseData.content[1].openid)
				CCUserDefault:sharedUserDefault():setStringForKey(UNIQUECODE, _uniqueCode)
				IODefines.server_ip = tostring(responseData.content[1].server)
				IODefines.server_port = tonumber(responseData.content[1].port)
				IODefines.secret = tostring(responseData.content[1].secret)
				IODefines.uid = tostring(responseData.content[1].uid)
				IODefines.openid = tostring(responseData.content[1].openid)
				IODefines.region = tostring(responseData.content[1].region)
				CCUserDefault:sharedUserDefault():setStringForKey(REGION, IODefines.region)
				print("addserver")
				LoginSystem.AddServer(IODefines.region,CCUserDefault:sharedUserDefault():getStringForKey(REGIONNAME),CCUserDefault:sharedUserDefault():getStringForKey(REGIONSTATE))
				print("login")
				Login()
				print("Login end")			
			end
		else
			LoadingFrame_Hide()
			WebErrorMessageShow(responseData.code)
		end
	else
		print("#===responseData=nil====ERROR!")
		print("#===LoginForQQRequestCallBack===ERROR!")
		LoadingFrame_Hide()
		GlobalSystem.Wind_Words(panel,Config_LocaleText.lang("login_txt_error_3"),255,255,255,0,0)
		return
	end
end
local ten_Channel = "1" --应用宝登录方式 “1”QQ，“2”微信
local ten_token = ""--应用宝token
function LoginSystem.setTenChannel(type)
	ten_Channel = type
end
function LoginSystem.getTeninfo()
	return ten_Channel, ten_token
end
--应用宝平台登陆
local function LoginRequestForQQ()
	-- body
	print("************************LoginRequestForQQ***********************")

	local _region 		= CCUserDefault:sharedUserDefault():getStringForKey(REGION)
	if not _region or #_region == 0 then
		_region = IODefines.region
	end
	--获取token（区分正式和测试）
	local pf_openid = LoginForQQPanel:getLoginData()--CCUserDefault:sharedUserDefault():getStringForKey(TOKEN_UNIQUE)
	local openid = ""
	local token = ""
	local pos = string.find(pf_openid, "|")
    if pos then
    	openid = string.sub(pf_openid, 1, pos - 1)
        token = string.sub(pf_openid, pos + 1, -1)
    end
    ten_token = token
	CCUserDefault:sharedUserDefault():setStringForKey(TOKEN_UNIQUE, openid)
	local url = SERVER_ADDRESS.."platform/login?channel="..LOGIN_CHANNEL.."&region=".._region.."&deviceType=".._model.."&pf_openid="..openid.."&token="..token.."&authType="..ten_Channel .. "&origin=" .. __active .. "&uniqueCode=" .. _uniqueCode
	local ok, imei = CCLuaJavaBridge.callStaticMethod("com/sincetimes/games/worldship/Worldship", "getUserDeviceId", {}, "()Ljava/lang/String;")
	if ok then
		url = url.."&idfa="..imei
	end
	print("url = "..url)
    print("****************LoginRequestForQQ****************")
	local request = CCHTTPRequest:createWithUrl(LoginForQQRequestCallBack, url, kCCHTTPRequestMethodPOST)
	request:start()
end

--UC平台登陆回调
local function LoginForUCRequestCallBack(event)
	local request = event.request
	if request:getErrorCode() ~= 0 then
		print("#===LoginForUCRequestCallBack===ERROR!")
		LoadingFrame_Hide()
		GlobalSystem.Wind_Words(panel,Config_LocaleText.lang("login_txt_error",tostring(request:getErrorCode())),255,255,255,0,0)
		return
	end
	local parseStr =  request:getResponseString()
	local responseData = json.decode(parseStr)
	if responseData ~= nil then
		if 0 == responseData.code then
			print("#===LoginForUCRequestCallBack==SUCCESE")
			if #responseData.content > 1 then
				--合服之后的处理-- 服务器角色选择
			else
				--保存token（区分正式和测试）
				CCUserDefault:sharedUserDefault():setStringForKey(TOKEN_UNIQUE, responseData.content[1].openid)
				CCUserDefault:sharedUserDefault():setStringForKey(OPENID, responseData.content[1].openid)
				CCUserDefault:sharedUserDefault():setStringForKey(UNIQUECODE, _uniqueCode)
				IODefines.server_ip = tostring(responseData.content[1].server)
				IODefines.server_port = tonumber(responseData.content[1].port)
				IODefines.secret = tostring(responseData.content[1].secret)
				IODefines.uid = tostring(responseData.content[1].uid)
				IODefines.openid = tostring(responseData.content[1].openid)
				local uniquecode = tostring(responseData.content[1].uniquecode)
				--CCUserDefault:sharedUserDefault():setStringForKey(TOKEN_UNIQUE, uniquecode)
				print(uniquecode)
				print(responseData.content[1].uniquecode)
				IODefines.region = tostring(responseData.content[1].region)
				CCUserDefault:sharedUserDefault():setStringForKey(REGION, IODefines.region)
				
				LoginSystem.AddServer(IODefines.region,CCUserDefault:sharedUserDefault():getStringForKey(REGIONNAME),CCUserDefault:sharedUserDefault():getStringForKey(REGIONSTATE))
				Login()			
			end
		else
			LoadingFrame_Hide()
			WebErrorMessageShow(responseData.code)
		end
	else
		print("#===responseData=nil====ERROR!")
		print("#===LoginForUCRequestCallBack===ERROR!")
		LoadingFrame_Hide()
		GlobalSystem.Wind_Words(panel,Config_LocaleText.lang("login_txt_error_3"),255,255,255,0,0)
		return
	end
end

--UC平台登陆
local function LoginRequestForUC(token)
	print("LoginRequestForUC")
	local len = string.len(token)
	print(len)
	if len ~= 1 then
		-- body
		local _region 		= CCUserDefault:sharedUserDefault():getStringForKey(REGION)
		local pf_openid
		if not _region or #_region == 0 then
			_region = IODefines.region
		end
		--保存token（区分正式和测试）
		CCUserDefault:sharedUserDefault():setStringForKey(TOKEN_UNIQUE, token)
		local url = SERVER_ADDRESS.."platform/common/login?channel="..LOGIN_CHANNEL.."&region=".._region.."&deviceType=".._model.."&token="..token .. "&origin=" .. __active .. "&uniqueCode=" .. _uniqueCode
		print("url = "..url)
    	print("****************LoginRequestForUC****************")
		local request = CCHTTPRequest:createWithUrl(LoginForUCRequestCallBack, url, kCCHTTPRequestMethodPOST)
		request:start()
	else
		LoadingFrame_Hide()
	end
	
end

--COOLPAD平台登陆回调
local function LoginForCOOLPADRequestCallBack(event)
	local request = event.request
	if request:getErrorCode() ~= 0 then
		print("#===LoginForCOOLPADRequestCallBack===ERROR!")
		LoadingFrame_Hide()
		GlobalSystem.Wind_Words(panel,Config_LocaleText.lang("login_txt_error",tostring(request:getErrorCode())),255,255,255,0,0)
		return
	end
	local parseStr =  request:getResponseString()
	local responseData = json.decode(parseStr)
	if responseData ~= nil then
		if 0 == responseData.code then
			print("#===LoginForCOOLPADRequestCallBack==SUCCESE")
			if #responseData.content > 1 then
				--合服之后的处理-- 服务器角色选择
			else
				--保存token（区分正式和测试）
				CCUserDefault:sharedUserDefault():setStringForKey(TOKEN_UNIQUE, responseData.content[1].openid)
				CCUserDefault:sharedUserDefault():setStringForKey(OPENID, responseData.content[1].openid)
				CCUserDefault:sharedUserDefault():setStringForKey(UNIQUECODE, _uniqueCode)
				IODefines.server_ip = tostring(responseData.content[1].server)
				IODefines.server_port = tonumber(responseData.content[1].port)
				IODefines.secret = tostring(responseData.content[1].secret)
				IODefines.uid = tostring(responseData.content[1].uid)
				IODefines.openid = tostring(responseData.content[1].openid)
				local uniquecode = tostring(responseData.content[1].uniquecode)
				IODefines.region = tostring(responseData.content[1].region)
				CCUserDefault:sharedUserDefault():setStringForKey(REGION, IODefines.region)
				LoginSystem.AddServer(IODefines.region,CCUserDefault:sharedUserDefault():getStringForKey(REGIONNAME),CCUserDefault:sharedUserDefault():getStringForKey(REGIONSTATE))
				Login()			
			end
		else
			LoadingFrame_Hide()
			WebErrorMessageShow(responseData.code)
		end
	else
		print("#===responseData=nil====ERROR!")
		print("#===LoginForCOOLPADRequestCallBack===ERROR!")
		LoadingFrame_Hide()
		GlobalSystem.Wind_Words(panel,Config_LocaleText.lang("login_txt_error_3"),255,255,255,0,0)
		return
	end
end

--COOLPAD平台登陆
local function LoginRequestForCOOLPAD(authcode)
	-- body
	print("LoginRequestForCOOLPAD")
	local len = string.len(authcode)
	print(len)
	if len ~= 1 then
		-- body
		local _region 		= CCUserDefault:sharedUserDefault():getStringForKey(REGION)
		if not _region or #_region == 0 then
			_region = IODefines.region
		end
		local url = SERVER_ADDRESS.."platform/common/login?channel="..LOGIN_CHANNEL.."&region=".._region.."&deviceType=".._model.."&token="..authcode .. "&origin=" .. __active .. "&uniqueCode=" .. _uniqueCode
		print("url = "..url)
    	print("****************LoginRequestForCOOLPAD****************")
		local request = CCHTTPRequest:createWithUrl(LoginForCOOLPADRequestCallBack, url, kCCHTTPRequestMethodPOST)
		request:start()
	else
		LoadingFrame_Hide()
	end
end

--COOLPAD平台注册切换账号函数
local function LoginChangeFuncForCOOLPAD()
	CCUserDefault:sharedUserDefault():setStringForKey(COOLPAD_CHANGEUSER, "YES")
	--重启游戏
    GlobalSystem.restart()
end

--游戏基地平台登陆回调
local function LoginForANDGAMERequestCallBack(event)
	local request = event.request
	if request:getErrorCode() ~= 0 then
		print("#===LoginForANDGAMERequestCallBack===ERROR!")
		LoadingFrame_Hide()
		GlobalSystem.Wind_Words(panel,Config_LocaleText.lang("login_txt_error",tostring(request:getErrorCode())),255,255,255,0,0)
		return
	end
	local parseStr =  request:getResponseString()
	local responseData = json.decode(parseStr)
	if responseData ~= nil then
		if 0 == responseData.code then
			print("#===LoginForANDGAMERequestCallBack==SUCCESE")
			if #responseData.content > 1 then
				--合服之后的处理-- 服务器角色选择
			else
				--保存token（区分正式和测试）
				CCUserDefault:sharedUserDefault():setStringForKey(TOKEN_UNIQUE, responseData.content[1].openid)
				CCUserDefault:sharedUserDefault():setStringForKey(OPENID, responseData.content[1].openid)
				CCUserDefault:sharedUserDefault():setStringForKey(UNIQUECODE, _uniqueCode)
				IODefines.server_ip = tostring(responseData.content[1].server)
				IODefines.server_port = tonumber(responseData.content[1].port)
				IODefines.secret = tostring(responseData.content[1].secret)
				IODefines.uid = tostring(responseData.content[1].uid)
				IODefines.openid = tostring(responseData.content[1].openid)
				local uniquecode = tostring(responseData.content[1].uniquecode)
				IODefines.region = tostring(responseData.content[1].region)
				CCUserDefault:sharedUserDefault():setStringForKey(REGION, IODefines.region)
				LoginSystem.AddServer(IODefines.region,CCUserDefault:sharedUserDefault():getStringForKey(REGIONNAME),CCUserDefault:sharedUserDefault():getStringForKey(REGIONSTATE))
				Login()			
			end
		else
			LoadingFrame_Hide()
			WebErrorMessageShow(responseData.code)
		end
	else
		print("#===responseData=nil====ERROR!")
		print("#===LoginForCOOLPADRequestCallBack===ERROR!")
		LoadingFrame_Hide()
		GlobalSystem.Wind_Words(panel,Config_LocaleText.lang("login_txt_error_3"),255,255,255,0,0)
		return
	end
end

--游戏基地平台登陆
local function LoginRequestForANDGAME(authcode)
	-- body
	print("LoginRequestForANDGAME")
	-- authcode = "1590269263"
	local len = string.len(authcode)
	print(len)
	-- if len ~= 1 then
		-- body
		local _region 		= CCUserDefault:sharedUserDefault():getStringForKey(REGION)
		if not _region or #_region == 0 then
			_region = IODefines.region
		end
		local url = SERVER_ADDRESS.."platform/common/login?channel="..LOGIN_CHANNEL.."&region=".._region.."&deviceType=".._model.."&token="..authcode .."&pf_openid="..authcode .. "&origin=" .. __active .. "&uniqueCode=" .. _uniqueCode
		print("url = "..url)
    	print("****************LoginRequestForANDGAME****************")
		local request = CCHTTPRequest:createWithUrl(LoginForANDGAMERequestCallBack, url, kCCHTTPRequestMethodPOST)
		request:start()
	-- else
	-- 	LoadingFrame_Hide()
	-- end
end

------------------------------------------------------------------登陆平台相关结束--------------------------------------------------------------------------


-- 游客登录修改 ----------------
-- 获取游客账号回调
local function VisitorAccountRequestCallback(event)
	local request = event.request
	print("-------VisitorAccountRequestCallback---------")

	print("state:"..request:getState().."  code:"..request:getErrorCode())
	if request:getErrorCode() ~= 0 then
		print("#===VisitorAccountRequestCallback===ERROR!")
		LoadingFrame_Hide()
		--GlobalSystem.Wind_Words(panel,Config_LocaleText.lang("login_txt_error",tostring(request:getErrorCode())),255,255,255,0,0)
		return
	end
	local parseStr =  request:getResponseString()
	print("VisitorAccountRequestCallback : response "..tostring(parseStr))
	local responseData = json.decode(parseStr)
	if responseData ~= nil then
		if responseData.content and responseData.content.openid and string.len(responseData.content.openid) ~= 0 then
			local openid = responseData.content.openid
			local account = responseData.content.tag
			local _region = CCUserDefault:sharedUserDefault():getStringForKey(REGION)
    		LoginSystem.addOpenIdToUserList(openid, account, true, "1", "0") -- ADD visitor
			CCUserDefault:sharedUserDefault():setStringForKey(DEVICE_ACCOUNT_VISITER, account)
    		local url = SERVER_ADDRESS.."login".."?openid="..openid.."&region=".._region.."&channel="..LOGIN_CHANNEL .. "&origin=" .. __active .. "&uniqueCode=".._uniqueCode.."&deviceType=".._model
    		-- idfa统计
    		local platform = CCApplication:sharedApplication():getTargetPlatform()
    		if platform == kTargetAndroid then
	    		local ok, imei = CCLuaJavaBridge.callStaticMethod("com/sincetimes/games/worldship/Worldship", "getUserDeviceId", {}, "()Ljava/lang/String;")
				if ok then
					url = url.."&idfa="..imei
				end
			end
			------------
    		print("url = "..url)
			local request = CCHTTPRequest:createWithUrl(LoginRequestCallBack, url, kCCHTTPRequestMethodPOST)
			request:start()
		else
			LoadingFrame_Hide()
			WebErrorMessageShow(responseData.code)
		end
	else
		print("#===responseData=nil====ERROR!")
		print("#===VisitorAccountRequestCallback===ERROR!")
		LoadingFrame_Hide()
		--GlobalSystem.Wind_Words(panel,Config_LocaleText.lang("login_txt_error_3"),255,255,255,0,0)
		return
	end
end

--------------------------------

function LoginSystem.LoginRequest()
	--统计点击登录
	GlobalSystem.clickLogin()
	--渠道区分
	if LOGIN_CHANNEL == PP_SERVER then
		--进入pp平台
		LoadingFrame_Hide()
		CCLuaObjcBridge.callStaticMethod("PPSystem", "showPPLogin", nil)
		print("to do ask PP_SERVER")
	elseif LOGIN_CHANNEL == TENCETN_SERVER then
		--进入腾讯应用宝
		LoginRequestForQQ()
		--local ok
		--ok = CCLuaJavaBridge.callStaticMethod("com/sincetimes/games/worldship/TencentHelper", "login", {LoginRequestForQQ},"(I)V")
		--print("call TencentHelper login result: %d",ok)
    elseif LOGIN_CHANNEL == UC_SERVER then
		--进入UC平台
		local ok
    	ok = CCLuaJavaBridge.callStaticMethod("com/sincetimes/games/worldship/UCHelper", "ucSdkLogin", {LoginRequestForUC},"(I)V")
    	print("call UCHelper ucSdkLogin result: %d",ok)
    elseif LOGIN_CHANNEL == MI_SERVER then
		--进入小米平台
		local ok
    	ok = CCLuaJavaBridge.callStaticMethod("com/sincetimes/games/worldship/MIHelper", "login", {LoginRequestForMI},"(I)V")
    elseif LOGIN_CHANNEL == VIVO_SERVER then
		--进入vivo平台
		local ok
    	ok = CCLuaJavaBridge.callStaticMethod("com/sincetimes/games/worldship/MIHelper", "login", {LoginRequestForVivo},"(I)V")
    elseif LOGIN_CHANNEL == XUNLEI_SERVER then
		--进入迅雷平台
		local ok
    	ok = CCLuaJavaBridge.callStaticMethod("com/sincetimes/games/worldship/MIHelper", "login", {LoginRequestForXunLei},"(I)V")
    elseif LOGIN_CHANNEL == M360_SERVER then
    	PlatformQiHoo360.LoginRequestForQiHoo360()
    elseif LOGIN_CHANNEL == BAIDU_SERVER then
    	--进入百度平台
    	platformBaidu.LoginRequest(WebErrorMessageShow, Login)
    elseif LOGIN_CHANNEL == WANDOU_SERVER then
    	--进入豌豆荚平台
    	local ok
    	ok = CCLuaJavaBridge.callStaticMethod("com/sincetimes/games/worldship/WandoujiaHelper", "login", {LoginRequestForWdj},"(I)V")
    	print("call WDJHelper ucSdkLogin result: %d",ok)
    	-- 注册切换账号退出回调 -------------------
        ok = CCLuaJavaBridge.callStaticMethod("com/sincetimes/games/worldship/WandoujiaHelper", "setRestartCallback", {wdjLogoutAndRestart},"(I)V")
        -------------------------------------------
    elseif LOGIN_CHANNEL == DANGLE_SERVER then
    	--todo
    	--进入当乐平台
		local ok
    	ok = CCLuaJavaBridge.callStaticMethod("com/sincetimes/games/worldship/DLHelper", "login", {LoginRequestForDL},"(I)V")
    elseif LOGIN_CHANNEL == HUAWEI_SERVER then
    	--进入华为平台
    	log("going to huawei platform login")
    	platformHuawei.LoginRequest(WebErrorMessageShow, Login)
    elseif LOGIN_CHANNEL == LENOVO_SERVER then
    	PlatformLenovo.LoginRequestForLenovoX()
    	--todo
    elseif LOGIN_CHANNEL == JINLO_SERVER then
    	--进入金立平台
    	local ok
    	ok = CCLuaJavaBridge.callStaticMethod("com/sincetimes/games/worldship/JinliHelper", "login", {LoginRequestForJinli},"(I)V")
    	print("call WDJHelper ucSdkLogin result: %d",ok)
    elseif LOGIN_CHANNEL == OPPO_SERVER then
    	--进入华为平台
    	log("going to oppo platform login")
    	platformOppo.LoginRequest(WebErrorMessageShow, Login)
    elseif LOGIN_CHANNEL == YYH_SERVER then
    	--进入应用汇平台
    	log("going to yyh")
    	require("app.game.login.PlatformYYH")
    	PlatformYYH.LoginRequestForYYH()
    elseif LOGIN_CHANNEL == DTHA_SERVER then
    	-- 进入妙智门平台
    	log("going to dtha")
    	require("app.game.login.PlatformDtha")
    	PlatformDtha.LoginRequestForDtha()
    elseif LOGIN_CHANNEL == KS_SERVER then
    	--进入KS平台
    	log("going to KS")
    	require("app.game.login.PlatformKS")
    	PlatformKS.LoginRequestForKS()
    elseif LOGIN_CHANNEL == ANZHI_SERVER then
    	--进入安智平台
    	log("going to AnZhi")
    	require("app.game.login.LoginCallBackFunForAnZ")
		LoadingFrame_Hide()
    	local ok
    	ok = CCLuaJavaBridge.callStaticMethod("com/sincetimes/games/worldship/AnZHelper", "setRestartCallBack", {SwitchAnZCallBack},"(I)V")
    	ok = CCLuaJavaBridge.callStaticMethod("com/sincetimes/games/worldship/AnZHelper", "login", {LoginRequestForAnz},"(I)V")
    elseif LOGIN_CHANNEL == MEIZU_SERVER then
    	--进入Meizu平台
    	log("going to Meizu")
    	require("app.game.login.PlatformMeizu")
    	PlatformMeizu.LoginRequestForMeizu()
    elseif LOGIN_CHANNEL == MUZHIWAN_SERVER then
    	--进入拇指玩平台
    	log("going to MuZhiWan")
    	require("app.game.login.LoginCallBackFunForMzW")
    	local ok
    	ok = CCLuaJavaBridge.callStaticMethod("com/sincetimes/games/worldship/MZWHelper", "login", {LoginRequestForMzW},"(I)V")
    elseif LOGIN_CHANNEL == HTC_SERVER then
    	--进入htc
    	log("going to htc")
    	require("app.game.login.PlatformHTC")
    	PlatformHTC.LoginRequestForHTC()
    elseif LOGIN_CHANNEL == YOUKU_SERVER then
    	--进入youku
    	log("going to youku")
    	require("app.game.login.PlatformYouKu")
    	PlatformYouKu.LoginRequestForYouKu()
    elseif KUAIFA_SERVER[LOGIN_CHANNEL] then
    	log("going to kuaifa")
    	require("app.game.login.PlatformKF")
    	PlatformKF.LoginRequest()
    elseif HQFY_SERVER[LOGIN_CHANNEL] then
    	log("going to hqfy")
    	require("app.game.login.PlatformHQFY")
    	PlatformHQFY.LoginRequest()
    elseif LOGIN_CHANNEL == SOGOU_SERVER then
    	--进入sogou
    	log("going to sogou")
    	require("app.game.login.PlatformSogou")
    	PlatformSogou.LoginRequestForSogou()
    elseif LOGIN_CHANNEL == SOGOU_ZZSJ_SERVER then
    	--进入sogou
    	log("going to sogou zzsj")
    	require("app.game.login.PlatformSogouZzsj")
    	PlatformSogouZzsj.LoginRequestForSogou()
    elseif LOGIN_CHANNEL == OUPENG_SERVER then
    	--进入oupeng
    	log("going to oupeng")
    	require("app.game.login.PlatformOuPeng")
    	PlatformOuPeng.LoginRequestForOuPeng()
    elseif LOGIN_CHANNEL == PPW_SERVER then
    	--ppw
    	log("goint to ppw")
    	require("app.game.login.PlatformPPW")
    	PlatformPPW.LoginRequestForPPW()
    elseif LOGIN_CHANNEL == IOS91_SERVER then
    	--进入IOS91平台
    	log("going to IOS91")
    	PlatformIOS91.LoginRequest(WebErrorMessageShow, Login)
    elseif LOGIN_CHANNEL == IOSITOOLS_SERVER then
    	--进入IOS ITools平台
    	log("going to ITools")
    	PlatformIOSItools.LoginRequest(WebErrorMessageShow, Login)
    elseif LOGIN_CHANNEL == KY_SERVER then
		--进入快用平台
		CCLuaObjcBridge.callStaticMethod("KyHelper", "login", nil)
		print("to do ask KY_SERVER")
	elseif LOGIN_CHANNEL == TB_SERVER then
		--进入同步推平台
		CCLuaObjcBridge.callStaticMethod("TbHelper", "login", nil)
		print("to do ask TB_SERVER")
	elseif LOGIN_CHANNEL == COOLPAD_SERVER then
		--进入酷派平台
		local ok
		--判断是否是切换账号还是登陆
		local _coolpadchangeuser = CCUserDefault:sharedUserDefault():getStringForKey(COOLPAD_CHANGEUSER)
		ok = CCLuaJavaBridge.callStaticMethod("com/sincetimes/games/worldship/CoolpadHelper", "SetCoolPadChangeFunc", {LoginChangeFuncForCOOLPAD},"(I)V")
		if _coolpadchangeuser then
			if _coolpadchangeuser == "YES" then
    			ok = CCLuaJavaBridge.callStaticMethod("com/sincetimes/games/worldship/CoolpadHelper", "loginOut", {LoginRequestForCOOLPAD},"(I)V")
    		else
    			ok = CCLuaJavaBridge.callStaticMethod("com/sincetimes/games/worldship/CoolpadHelper", "login", {LoginRequestForCOOLPAD},"(I)V")
    		end
		else
			ok = CCLuaJavaBridge.callStaticMethod("com/sincetimes/games/worldship/CoolpadHelper", "login", {LoginRequestForCOOLPAD},"(I)V")
			
		end
		CCUserDefault:sharedUserDefault():setStringForKey(COOLPAD_CHANGEUSER, "NO")
		print("to do ask COOLPAD_SERVER")
	elseif LOGIN_CHANNEL == ANDGAME_SERVER then
    	--进入游戏基地
    	local ok
    	ok = CCLuaJavaBridge.callStaticMethod("com/sincetimes/games/worldship/AndgameHelper", "login", {LoginRequestForANDGAME},"(I)V")
		print("to do ask ANDGAME_SERVER")
	elseif LOGIN_CHANNEL == IAPPLE_SERVER then
		log("going to iapple")
		require("app.game.login.PlatformIApple")
		PlatformIApple.LoginRequestForIApple()
	elseif LOGIN_CHANNEL == AS_SERVER then
		log("going to as")
		require("app.game.login.PlatformAS")
		PlatformAS.LoginRequestForAS()
	elseif LOGIN_CHANNEL == XYIOS_SERVER then
		log("going to xy")
		require("app.game.login.PlatformXY")
		PlatformXY.LoginRequestForXY()
	elseif LOGIN_CHANNEL == SHENZHANWEISHI_SERVER then
    	--进入百度平台
    	platformBaidu.LoginRequest(WebErrorMessageShow, Login)
	elseif LOGIN_CHANNEL == PPS_SERVER then
		require("app.game.login.PlatformPPS")
		PlatformPPS.LoginForPPS()
	elseif LOGIN_CHANNEL == YYANDROID_SERVER then
		log("going to yy android")
		require("app.game.login.PlatformYYAndroid")
		PlatformYYAndroid.Login()
	elseif LOGIN_CHANNEL == YYIOS_SERVER then
		log("going to yy ios")
		require("app.game.login.PlatformYYIOS")
		PlatformYYIOS.Login()
	elseif LOGIN_CHANNEL == LBIOS_SERVER then
		log("going to lb ios")
		require("app.game.login.PlatformLBIOS")
		PlatformLBIOS.Login()
	elseif LOGIN_CHANNEL == HAIMA_NEW_SERVER then
		log("going to hm ios")
		require("app.game.login.PlatformHaiMa")
		PlatformHM.Login()
	elseif LOGIN_CHANNEL == MP_IOS_SERVER then
		log("going to mp ios")
		require("app.game.login.PlatformMoPin")
		PlatformMoPin.Login()
	else
		local _region 		= CCUserDefault:sharedUserDefault():getStringForKey(REGION)
		local _openID 		= CCUserDefault:sharedUserDefault():getStringForKey(OPENID)
		print("&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&000000000000000000000" .. LOGIN_CHANNEL)
		print("&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&&000000000000000000000" .. type(LOGIN_CHANNEL))
		--PC登陆情况默认值
		if target == kTargetWindows or target == kTargetMacOS then
			if not _openID or #_openID == 0 then
				--_openID = IODefines.openid
				print("=========:_openID:" .. tostring(_openID))
			end
		end
		if not _region or #_region == 0 then
			_region = IODefines.region
		end
		if not _uniqueCode or #_uniqueCode == 0 then
			_uniqueCode = os.date("%c")
			SpaceTrim(_uniqueCode) 
		end
		--pc匹配
		-- if target == kTargetWindows or target == kTargetMacOS then
		-- 	_uniqueCode = IODefines.openid
		-- end
		--判断是否是老用户，存在OpenID
    	if not _openID or #_openID == 0 then
    		-- 游客登录修改 -------------------

    		-- 兼容老包
    		if not __VISITOR_IMEI or string.len(__VISITOR_IMEI) == 0 then
    			local url = SERVER_ADDRESS.."login".."?region=".._region.."&uniqueCode=".._uniqueCode.."&deviceType=".._model.."&channel="..LOGIN_CHANNEL .. "&origin=" .. __active 
	    		--local url = SERVER_ADDRESS.."login".."?region=".._region.."&uniqueCode=".._uniqueCode.."&deviceType=".._model
	    		--测试用
	    		--local url = SERVER_ADDRESS.."login/test".."?region=".._region.."&uniqueCode=".._uniqueCode.."&deviceType=".._model.."&serverId=1"
	    		local platform = CCApplication:sharedApplication():getTargetPlatform()
	    		if platform == kTargetIphone or platform == kTargetIpad then 
	    			if __IDFA ~= nil then 
		    			url = url .. "&idfa=" .. __IDFA
		    		end
	    		end

	    		-- idfa统计
	    		if platform == kTargetAndroid then
		    		local ok, imei = CCLuaJavaBridge.callStaticMethod("com/sincetimes/games/worldship/Worldship", "getUserDeviceId", {}, "()Ljava/lang/String;")
					if ok then
						url = url.."&idfa="..imei
					end
				end
				------------
				
	    		print("url = "..url)
				local request = CCHTTPRequest:createWithUrl(LoginNoOpenIdRequestCallBack, url, kCCHTTPRequestMethodPOST)
				request:start()
				return
			end

			-- 游客首先请求获取游客账号，回调中调用原login with openid接口
			local url = SERVER_ADDRESS.."quick/createtag?channel="..LOGIN_CHANNEL.."&imei="..__VISITOR_IMEI
			print("create visitor url = "..tostring(url))
			local request = CCHTTPRequest:createWithUrl(VisitorAccountRequestCallback, url, kCCHTTPRequestMethodPOST)
			request:start()

			-----------------------------------
		else
    		local url = SERVER_ADDRESS.."login".."?openid=".._openID.."&region=".._region.."&channel="..LOGIN_CHANNEL .. "&origin=" .. __active .. "&uniqueCode=".._uniqueCode.."&deviceType=".._model
    		--local url = SERVER_ADDRESS.."login".."?openid=".._openID.."&region=".._region
    		--测试用
    		--local url = SERVER_ADDRESS.."login/test".."?openid=".._openID.."&region=".._region.."&serverId=1"
    		local platform = CCApplication:sharedApplication():getTargetPlatform()
			if platform == kTargetIphone or platform == kTargetIpad then 
    			if __IDFA ~= nil then 
	    			url = url .. "&idfa=" .. __IDFA
	    		end
    		end
    		-- idfa统计
    		if platform == kTargetAndroid then
	    		local ok, imei = CCLuaJavaBridge.callStaticMethod("com/sincetimes/games/worldship/Worldship", "getUserDeviceId", {}, "()Ljava/lang/String;")
				if ok then
					url = url.."&idfa="..imei
				end
			end
			------------

    		print("url = "..url)
			local request = CCHTTPRequest:createWithUrl(LoginRequestCallBack, url, kCCHTTPRequestMethodPOST)
			request:start()
    	end
    end
end

local function ServerChooseRequestCallBack(event)
	local request = event.request
	print("state:"..request:getState().."  code:"..request:getErrorCode())
	if request:getErrorCode() ~= 0 then
		print("#===ServerChooseRequestCallBack===ERROR!")
		LoadingFrame_Hide()
		GlobalSystem.Wind_Words(panel,Config_LocaleText.lang("login_txt_error",tostring(request:getErrorCode())),255,255,255,0,0)
		return
	end
	local parseStr =  request:getResponseString()
	local responseData = json.decode(parseStr)
	if responseData ~= nil then
		if 0 == responseData.code then
			if WorldBattleSystem.serverIsHave == false then
				WorldBattleSystem.serverIsHave = true
				WorldBattleSystem.serveList = responseData.content
			else
				LoadingFrame_Hide()
				ServerChoosePanel.new(responseData.content)
			end
		else
			LoadingFrame_Hide()
			WebErrorMessageShow(responseData.code)
		end
	else
		print("#===responseData=nil====ERROR!")
		print("#===ServerChooseRequestCallBack===ERROR!")
		LoadingFrame_Hide()
		GlobalSystem.Wind_Words(panel,Config_LocaleText.lang("login_txt_error_3"),255,255,255,0,0)
		return
	end
end

function LoginSystem.ServerChooseRequest()
	local url = SERVER_ADDRESS.."region/".."find"
	print("url = "..url)
	local request = CCHTTPRequest:createWithUrl(ServerChooseRequestCallBack, url, kCCHTTPRequestMethodPOST)
	request:start()
end

--绑定并登陆回调
local function BindLoginRequestCallBack(event)
	local request = event.request
	print("state:"..request:getState().."  code:"..request:getErrorCode())
	if request:getErrorCode() ~= 0 then
		print("#===BindLoginRequestCallBack===ERROR!")
		LoadingFrame_Hide()
		GlobalSystem.Wind_Words(panel,Config_LocaleText.lang("login_txt_error",tostring(request:getErrorCode())),255,255,255,0,0)
		return
	end
	local parseStr =  request:getResponseString()
	local responseData = json.decode(parseStr)
	if responseData ~= nil then
		if 0 == responseData.code then
			LoginSystem.addOpenIdToUserList(_openID, _account, nil, "1", "0")
			CCUserDefault:sharedUserDefault():setStringForKey(ACCOUNT,_account)
			CCUserDefault:sharedUserDefault():setStringForKey(OPENID_VISITOR,"")
			-- 游客登录修改 -------------------------
			CCUserDefault:sharedUserDefault():setStringForKey(DEVICE_ACCOUNT_VISITER,"")
			GlobalSystem.Wind_Words(panel,Config_LocaleText.lang("visitor_txt_web_binded"),255,255,255,0,0)
			-----------------------------------------
			PasswordLoginPanel.Close()
			LoadingFrame_Hide()
		else
			LoadingFrame_Hide()
			WebErrorMessageShow(responseData.code)
		end
	else
		print("#===responseData=nil====ERROR!")
		print("#===BindLoginRequestCallBack===ERROR!")
		LoadingFrame_Hide()
		GlobalSystem.Wind_Words(panel,Config_LocaleText.lang("login_txt_error_3"),255,255,255,0,0)
		return
	end
end

--绑定并登陆
--@param account    账号
--@param password   密码
--@param phone    	电话号码
function LoginSystem.BindLoginRequest(account,password,phone)
	_account = account
	phone = phone or ""
	password = LoginSystem.Encryption(password)
	local region = CCUserDefault:sharedUserDefault():getStringForKey(REGION)
	_openID 		= CCUserDefault:sharedUserDefault():getStringForKey(OPENID_VISITOR)
	local url = SERVER_ADDRESS.."account".."?openid=".._openID.."&account="..account.."&token="..password.."&email="..phone .. "&origin=" .. __active .. "&region=" .. region .."&channel="..LOGIN_CHANNEL.. "&uniqueCode=" .. _uniqueCode.."&deviceType=".._model
	print("url = "..url)
	local request = CCHTTPRequest:createWithUrl(BindLoginRequestCallBack, url, kCCHTTPRequestMethodPOST)
	request:start()
end


--注册并登陆回调
local function RegisterLoginRequestCallBack(event)
	local request = event.request
	print("state:"..request:getState().."  code:"..request:getErrorCode())
	if request:getErrorCode() ~= 0 then
		print("#===RegisterLoginRequestCallBack===ERROR!")
		LoadingFrame_Hide()
		GlobalSystem.Wind_Words(panel,Config_LocaleText.lang("login_txt_error",tostring(request:getErrorCode())),255,255,255,0,0)
		return
	end
	local parseStr =  request:getResponseString()
	local responseData = json.decode(parseStr)
	if responseData ~= nil then
		if 0 == responseData.code then
			LoginSystem.addOpenIdToUserList(responseData.content.openid, _account, nil, "1", "0")
			
			CCUserDefault:sharedUserDefault():setStringForKey(UNIQUECODE, _uniqueCode)
			PasswordLoginPanel.Close()
			LoadingFrame_Hide()
			--LoginSystem.LoginRequest()
			__isClickRegister = true 
		else
			LoadingFrame_Hide()
			WebErrorMessageShow(responseData.code)
		end
	else
		print("#===responseData=nil====ERROR!")
		print("#===RegisterLoginRequestCallBack===ERROR!")
		LoadingFrame_Hide()
		GlobalSystem.Wind_Words(panel,Config_LocaleText.lang("login_txt_error_3"),255,255,255,0,0)
		return
	end
end

--注册并登陆
--@param account    账号
--@param password   密码
--@param phone    	电话号码
function LoginSystem.RegisterLoginRequest(account,password,phone)
	_account = account
	phone = phone or ""
	password = LoginSystem.Encryption(password)
	local url = SERVER_ADDRESS.."account".."?account="..account.."&token="..password.."&type=register".."&deviceType=".._model.."&email="..phone.."&channel="..LOGIN_CHANNEL .. "&origin=" .. __active .. "&uniqueCode=" .. _uniqueCode.."&deviceType=".._model
	print("url = "..url)
	local request = CCHTTPRequest:createWithUrl(RegisterLoginRequestCallBack, url, kCCHTTPRequestMethodPOST)
	request:start()
end


--用户名密码登陆回调函数
local function AccountPasswordLoginRequestCallBack(event)
	local request = event.request
	print("state:"..request:getState().."  code:"..request:getErrorCode())
	if request:getErrorCode() ~= 0 then
		print("#===AccountPasswordLoginRequestCallBack===ERROR!")
		LoadingFrame_Hide()
		GlobalSystem.Wind_Words(panel,Config_LocaleText.lang("login_txt_error",tostring(request:getErrorCode())),255,255,255,0,0)
		return
	end
	local parseStr =  request:getResponseString()
	local responseData = json.decode(parseStr)
	if responseData ~= nil then
		if 0 == responseData.code then
			LoginSystem.addOpenIdToUserList(responseData.content.openid, _account, nil, "1", "0")
			CCUserDefault:sharedUserDefault():setStringForKey(UNIQUECODE, _uniqueCode)
			LoadingFrame_Hide()
			PasswordLoginPanel.Close()
			--LoginSystem.LoginRequest()
		else
			LoadingFrame_Hide()
			WebErrorMessageShow(responseData.code)
		end
	else
		print("#===responseData=nil====ERROR!")
		print("#===AccountPasswordLoginRequestCallBack===ERROR!")
		LoadingFrame_Hide()
		GlobalSystem.Wind_Words(panel,Config_LocaleText.lang("login_txt_error_3"),255,255,255,0,0)
		return
	end
end

--用户名密码登陆
--@param account    账号
--@param password   密码
function LoginSystem.AccountPasswordLoginRequest(account,password)
	_account = account
	password = LoginSystem.Encryption(password)
	local url = SERVER_ADDRESS.."account".."?account="..account.."&token="..password .."&type=login".. "&origin=" .. __active.."&channel="..LOGIN_CHANNEL .. "&origin=" .. __active .. "&uniqueCode=" .. _uniqueCode.."&deviceType=".._model
	
	-- idfa统计
	local platform = CCApplication:sharedApplication():getTargetPlatform()
	if platform == kTargetAndroid then
		local ok, imei = CCLuaJavaBridge.callStaticMethod("com/sincetimes/games/worldship/Worldship", "getUserDeviceId", {}, "()Ljava/lang/String;")
		if ok then
			url = url.."&idfa="..imei
		end
	end
	------------

	print("url = "..url)
	local request = CCHTTPRequest:createWithUrl(AccountPasswordLoginRequestCallBack, url, kCCHTTPRequestMethodPOST)
	request:start()
	----------------------直接输入uid------------------
	-- IODefines.uid = account
	-- LoadingFrame_Hide()
	-- PasswordLoginPanel.Close()

	-- Login()
	----------------------------------------------------
end

--绑定邮箱
--@param account    账号
--@param password   密码
--@param email  	邮箱
function LoginSystem.AccountBindEmail(account,password,email,response)
	_account = account
	local url = SERVER_ADDRESS.."mail/bind".."?channel="..LOGIN_CHANNEL.."&account="..account..
			"&password="..LoginSystem.Encryption(password) .."&mail="..email.."&uid="..IODefines.uid
	print("url = "..url)
	local request = CCHTTPRequest:createWithUrl(response, url, kCCHTTPRequestMethodPOST)
	request:start()
end

--修改密码
--@param account    账号
--@param oldPassword   原始密码
--@param newPassword  	新密码
function LoginSystem.AccountChangePwd(account,oldPassword,newPassword,response)
	_account = account
	local url = SERVER_ADDRESS.."password/modify".."?channel="..LOGIN_CHANNEL.."&account="..account..
				"&oldPassword="..LoginSystem.Encryption(oldPassword) ..
				"&newPassword="..LoginSystem.Encryption(newPassword)
	print("url = "..url)
	local request = CCHTTPRequest:createWithUrl(response, url, kCCHTTPRequestMethodPOST)
	request:start()
end

--找回密码
--@param account    账号
--@param email  	邮箱
function LoginSystem.AccountFindBack(account,email,response)
	_account = account
	local url = SERVER_ADDRESS.."password/find".."?channel="..LOGIN_CHANNEL.."&account="..account.."&mail="..email
	print("url = "..url)
	local request = CCHTTPRequest:createWithUrl(response, url, kCCHTTPRequestMethodPOST)
	request:start()
end

--判断是否绑定邮箱
--@param account    账号
function LoginSystem.checkBindMail(account,response)
	_account = account
	local url = SERVER_ADDRESS.."mail/bind/check".."?channel="..LOGIN_CHANNEL.."&account="..account
	print("url = "..url)
	local request = CCHTTPRequest:createWithUrl(response, url, kCCHTTPRequestMethodPOST)
	request:start()
end

--注册并绑定邮箱
--@param account    账号
function LoginSystem.registBindEmail(account,pwd,email,response)
	_account = account
	local password = LoginSystem.Encryption(pwd)
	local openid = CCUserDefault:sharedUserDefault():getStringForKey(OPENID_VISITOR)
	local url = SERVER_ADDRESS.."accountAndMail/bind".."?channel="..LOGIN_CHANNEL.."&account="..account
		.."&password="..password.."&mail="..email.."&openid="..openid.."&uid="..IODefines.uid
	print("url = "..url)
	local request = CCHTTPRequest:createWithUrl(response, url, kCCHTTPRequestMethodPOST)
	request:start()
end

--输入框字母数字check
--@parma  editbox   输入框
--@parma  result    结果
function LoginSystem.EditBoxStrNumCheck(editbox)
	local result = true
	--长度check
	local LengthCheck = true
	if string.len(editbox:getText()) < 6 and string.len(editbox:getText()) ~= 0 then
		editbox:getParent():getParent().getChild("txt_comment"):setString(Config_LocaleText.lang("panel_passwordlogin_txt_error_comment"))
		editbox:getParent():getParent().getChild("txt_comment"):setColor(ccc3(255, 0, 0))
		LengthCheck = false
		result = false
		return result
	end

	if string.len(editbox:getText()) == 0 then
		editbox:getParent():getParent().getChild("txt_comment"):setString(Config_LocaleText.lang("panel_passwordlogin_txt_account_comment"))
		editbox:getParent():getParent().getChild("txt_comment"):setColor(ccc3(155, 163, 163))
		LengthCheck = false
		result = nil
		return result
	end
	--文字内容check
	if LengthCheck == true then
		if  string.find(editbox:getText(),"%W") ~= nil then
			editbox:getParent():getParent().getChild("txt_comment"):setString(Config_LocaleText.lang("panel_passwordlogin_txt_error_comment"))
			editbox:getParent():getParent().getChild("txt_comment"):setColor(ccc3(255, 0, 0))
			result = false
			return result
		else
			editbox:getParent():getParent().getChild("txt_comment"):setString(Config_LocaleText.lang("panel_passwordlogin_txt_account_comment"))
			editbox:getParent():getParent().getChild("txt_comment"):setColor(ccc3(155, 163, 163))
			return result
		end
	end
end

--输入框数字check
--@parma  editbox   输入框
function LoginSystem.EditBoxPhoneNumCheck(editbox)
	local result = true
	--长度check
	local LengthCheck = true
	if string.len(editbox:getText()) > 50 then
		editbox:getParent():getParent().getChild("txt_comment"):setString(Config_LocaleText.lang("panel_passwordlogin_txt_error_comment"))
		editbox:getParent():getParent().getChild("txt_comment"):setColor(ccc3(255, 0, 0))
		LengthCheck = false
		result = false
		return result
	end

	if string.len(editbox:getText()) == 0 then
		editbox:getParent():getParent().getChild("txt_comment"):setString(Config_LocaleText.lang("panel_registerlogin_txt_phone_comment"))
		editbox:getParent():getParent().getChild("txt_comment"):setColor(ccc3(155, 163, 163))
		LengthCheck = false
		result = nil
		return result
	end

	--文字内容check
	if LengthCheck == true then
		if  string.find(editbox:getText(),"@") ~= nil then
			local strbegin , strend = string.find(editbox:getText(),"@")
			local strstemp = string.sub(editbox:getText(),1,strend - 1)
			if string.find(strstemp,"%W") ~= nil then
				editbox:getParent():getParent().getChild("txt_comment"):setString(Config_LocaleText.lang("panel_passwordlogin_txt_error_comment"))
				editbox:getParent():getParent().getChild("txt_comment"):setColor(ccc3(255, 0, 0))
				result = false
				return result
			else

			end
			local strstemp_2 = string.gsub(string.sub(editbox:getText(),strend + 1),".","")
			if strstemp_2 ~= nil then
				if string.find(strstemp_2,"%W") ~= nil then
					editbox:getParent():getParent().getChild("txt_comment"):setString(Config_LocaleText.lang("panel_passwordlogin_txt_error_comment"))
					editbox:getParent():getParent().getChild("txt_comment"):setColor(ccc3(255, 0, 0))
					result = false
					return result
				else
					editbox:getParent():getParent().getChild("txt_comment"):setString(Config_LocaleText.lang("panel_registerlogin_txt_phone_comment"))
					editbox:getParent():getParent().getChild("txt_comment"):setColor(ccc3(155, 163, 163))
					return result
				end
			end
		else
			editbox:getParent():getParent().getChild("txt_comment"):setString(Config_LocaleText.lang("panel_passwordlogin_txt_error_comment"))
			editbox:getParent():getParent().getChild("txt_comment"):setColor(ccc3(255, 0, 0))
			result = false
			return result
		end
	end
	--[[
	--长度check
	local LengthCheck = true
	if string.len(editbox:getText()) ~= 11 and string.len(editbox:getText()) ~= 0 then
		editbox:getParent():getParent().getChild("txt_comment"):setString(Config_LocaleText.lang("panel_passwordlogin_txt_error_comment"))
		editbox:getParent():getParent().getChild("txt_comment"):setColor(ccc3(255, 0, 0))
		LengthCheck = false
		result = false
		return result
	end

	if string.len(editbox:getText()) == 0 then
		editbox:getParent():getParent().getChild("txt_comment"):setString(Config_LocaleText.lang("panel_registerlogin_txt_phone_comment"))
		editbox:getParent():getParent().getChild("txt_comment"):setColor(ccc3(155, 163, 163))
		LengthCheck = false
		result = nil
		return result
	end

	--文字内容check
	if LengthCheck == true then
		if  string.find(editbox:getText(),"%D") ~= nil then
			editbox:getParent():getParent().getChild("txt_comment"):setString(Config_LocaleText.lang("panel_passwordlogin_txt_error_comment"))
			editbox:getParent():getParent().getChild("txt_comment"):setColor(ccc3(255, 0, 0))
			result = false
			return result
		else
			editbox:getParent():getParent().getChild("txt_comment"):setString(Config_LocaleText.lang("panel_registerlogin_txt_phone_comment"))
			editbox:getParent():getParent().getChild("txt_comment"):setColor(ccc3(155, 163, 163))
			return result
		end
	end
	]]
end

--输入框角色名check
--@parma  editbox   输入框
function LoginSystem.EditBoxPersonNameCheck(editbox)
	local result = true
	--长度check
	if String.length(editbox:getText()) < 2 and String.length(editbox:getText()) ~= 0 then
		result = false
	end

	local num = 0 
	for m in string.gmatch(editbox:getText(),"[\128-\254]+") do
		num = num + string.len(m) / 3
	end

	if string.len(editbox:getText()) - num * 3 + num * 2 > 16 then
		editbox:setText("")
		result = false
	end 

	if String.length(editbox:getText()) == 0 then
		result = false
	end

	--不能包含空格
	if string.find(editbox:getText()," ") ~= nil then
		result = false
	end 

	--其他特殊字符check
	if string.find(editbox:getText(),"[ %[ %, %! %] %$ %? %( %) %* %^ %% ]") ~= nil then
		result = false
	end 

	--非法字符check
	if result ~= false then
		if NameCheckDataLib.check(editbox:getText()) ~= false then
			result = 1
		end
	end
	
	return result
end

--输入框舰船名check
--@parma  editbox   输入框
function LoginSystem.EditBoxShipNameCheck(editbox)
	local result = true
	--长度check
	if String.length(editbox:getText()) < 2 and String.length(editbox:getText()) ~= 0 then
		editbox:setText(tostring(editbox:getPlaceHolder()))
		result = false
	end

	local num = 0 
	for m in string.gmatch(editbox:getText(),"[\128-\254]+") do
		num = num + string.len(m) / 3
	end

	if string.len(editbox:getText()) - num * 3 + num * 2 > 16 then
		editbox:setText(tostring(editbox:getPlaceHolder()))
		result = false
	end 

	if String.length(editbox:getText()) == 0 then
		editbox:setText(tostring(editbox:getPlaceHolder()))
		result = false
	end

	--不能包含空格
	if string.find(editbox:getText()," ") ~= nil then
		result = false
	end 
	
	--其他特殊字符check
	if string.find(editbox:getText(),"[ %[ %, %! %] %$ %? %( %) %* %^ %% ]") ~= nil then
		result = false
	end 

	--非法字符check
	if result ~= false then
		if NameCheckDataLib.check(editbox:getText()) ~= false then
			result = 1
		end
	end
	
	return result
end

--获得设备类型
function LoginSystem.GetModel()
	return _model
end
--获得_uniqueCode
function LoginSystem.GetUniqueCode()
	return _uniqueCode
end

--合服处理回调函数
function LoginSystem.HefuFunction(item)
	CCUserDefault:sharedUserDefault():setStringForKey(OPENID, item.openid)
	CCUserDefault:sharedUserDefault():setStringForKey(UNIQUECODE, _uniqueCode)
	IODefines.server_ip = tostring(item.server)
	IODefines.server_port = tonumber(item.port)
	IODefines.secret = tostring(item.secret)
	IODefines.uid = tostring(item.uid)
	IODefines.openid = tostring(item.openid)
	IODefines.region = tostring(item.region)
	CCUserDefault:sharedUserDefault():setStringForKey(REGION, IODefines.region)
	LoginSystem.AddServer(IODefines.region,CCUserDefault:sharedUserDefault():getStringForKey(REGIONNAME),CCUserDefault:sharedUserDefault():getStringForKey(REGIONSTATE))
	Login()
end


--密码加密算法
encryption_tab = 
     {  a="0", b="1", c="2", d="3", e="4", f="5", g="6", h="7", i="8", j="9", 
        k="A", l="B", m="C", n="D", o="E", p="F", q="G", r="H", s="I", t="J",
        u="K", v="L", w="M", x="N", y="O", z="P", A="Q", B="R", C="S", D="T",
        E="U", F="V", G="W", H="X", I="a", J="b", K="c", L="d", M="e", N="f",
        O="g", P="h", Q="i", R="j", S="k", T="l", U="m", V="n", W="o", X="p",
        Y="q", Z="r", ["0"]="s", ["1"]="t", ["2"]="u", ["3"]="v", ["4"]="w",
        ["5"]="x", ["6"]="y", ["7"]="z", ["8"]="Y", ["9"]="Z",}
   

function LoginSystem.Encryption(value)
	local t = type(value)
	if t~="string" then
		return nil
	end

	local tab = {}
	local ret = value
	local idx = 1
	while idx < string.len(ret) do
		table.insert(tab, string.sub(ret,idx,idx))
		idx = idx + 1
	end

	table.insert(tab, string.sub(ret, idx, -1))

	ret = ""
	for i,v in pairs(tab) do
		if v==nil then
			ret = ret .. v
		else
			ret = ret .. encryption_tab[v]
		end
	end

	return ret
end

decryption_tab = 
     {  ["0"]="a", ["1"]="b", ["2"]="c", ["3"]="d", ["4"]="e", ["5"]="f", ["6"]="g",
     	["7"]="h", ["8"]="i", ["9"]="j", A="k", B="l", C="m", D="n", E="o", F="p", G="q", 
     	H="r", I="s", J="t",K="u", L="v", M="w", N="x", O="y", P="z", Q="A", R="B", S="C",
     	T="D", U="E", V="F", W="G", X="H", a="I", b="J", c="K", d="L", e="M", f="N",
        g="O", h="P", i="Q", j="R", k="S", l="T", m="U", n="V", o="W", p="X",
        q="Y", r="Z", s="0", t="1", u="2", v="3", w="4", x="5", y="6", z="7", Y="8", Z="9",} 
        
function LoginSystem.Decryption(value)
	local t =type(value)
	if t~="string" then
		return nil
	end

		local tab = {}
	local ret = value
	local idx = 1
	while idx < string.len(ret) do
		table.insert(tab, string.sub(ret,idx,idx))
		idx = idx + 1
	end

	table.insert(tab, string.sub(ret, idx, -1))

	ret = ""
	for i,v in pairs(tab) do
		if v==nil then
			ret = ret .. v
		else
			ret = ret .. decryption_tab[v]
		end
	end

	return ret
end


-- 判断是否是游客
function LoginSystem.checkVisitor()
	local openid_visitor = CCUserDefault:sharedUserDefault():getStringForKey(OPENID_VISITOR)
	local openid = CCUserDefault:sharedUserDefault():getStringForKey(OPENID)
	if openid_visitor == openid then
		return true
	else
		return false
	end
end

--注册+绑定邮箱
function LoginSystem.registeAndBindEmail()
	--是否是游客
	if LoginSystem.checkVisitor() then
		local str = "panel_passwordlogin_txt_bind_email_tip3"
        local title = Config_LocaleText.lang(str)
		RegistBindEmailPanel.new(title)
	else
		--判断是否绑定邮箱
		local acc_userName = CCUserDefault:sharedUserDefault():getStringForKey(ACCOUNT)
	    LoginSystem.checkBindMail(acc_userName,function(event)
	    	local request = event.request
			print("state:"..request:getState().."  code:"..request:getErrorCode())
			if request:getErrorCode() ~= 0 then
				return
			end
			local parseStr =  request:getResponseString()
			local responseData = json.decode(parseStr)
			if responseData ~= nil then
				--没有绑定邮箱
				if responseData.code == 20 then
					BindEmailPanel.new()
				elseif responseData.code == 21 then
				elseif responseData.code == 10 then
				end
			else
				return
			end
		end
	    )
	end
end

return LoginSystem

