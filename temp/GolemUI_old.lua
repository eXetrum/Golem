-- Lorelle
-- 160530
-- Kotblky2
-- 312478qwerty



GolemUI_antiSpamDB = GolemUI_antiSpamDB or {}
settings = GolemUI_antiSpamDB
--for var,value in pairs(defaults) do
--settings[var] = settings[var]==nil and value or settings[var]
--end



print("|c0000ff00 Hello " .. UnitName("player") .. "|r");

GolemUI_Main_Frame:SetFrameStrata("DIALOG")

local users = {}
local userID = 0

local timer = 5

local eventHandlers = {}
local maxMessages = 0
local messageFrames = {}

local antispam = _G["Antispam"]

local backdrop = {
  -- path to the background texture
  bgFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background",  
  -- path to the border texture
  edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",
  -- true to repeat the background texture to fill the frame, false to scale it
  tile = true,
  -- size (width or height) of the square repeating background tiles (in pixels)
  tileSize = 32,
  -- thickness of edge segments and square size of edge corners (in pixels)
  edgeSize = 32,
  -- distance from the edges of the frame to those of the background texture (in pixels)
  insets = {
    left = 11,
    right = 12,
    top = 12,
    bottom = 11
  }
}

local statusFrame = CreateFrame("Frame", "Entry_Status", GolemUI_Main_Frame, "TitleTemplate")
statusFrame:SetPoint("TOPLEFT", GolemUI_Main_Frame, "TOPRIGHT", -640, 0)
statusFrame:SetPoint("BOTTOMLEFT", GolemUI_Main_Frame, "BOTTOMRIGHT", -400, 0)
statusFrame:SetWidth(400)
--statusFrame:SetHeight(276)
statusFrame:SetBackdrop(backdrop)
statusFrame:Hide()

function OnShowFrame(self)
	print("ALARM")
	local user_entry = nil
	for k, v in pairs(users) do	
		if v.frame.selected then
			user_entry = v
		end
	end	
	
	print("USER: "..user_entry.frame.username..", MSG_COUNT: "..user_entry.msg_count)
	if user_entry ~= nil then
		
		for k, v in pairs(user_entry.messages) do
			--print (k, v.msg, v.time)
		end
	end
	
end

--scrollframe
scrollframe = CreateFrame("ScrollFrame", nil, statusFrame)
scrollframe:SetPoint("TOPLEFT", statusFrame, "TOPLEFT", 12, -12)
--scrollframe:SetPoint("BOTTOMRIGHT", statusFrame, "BOTTOMRIGHT", 0, 1)
scrollframe:SetWidth(376)
scrollframe:SetHeight(287)
--local texture = scrollframe:CreateTexture()
--texture:SetAllPoints()
--texture:SetTexture(.5,.5,.5,1)
--scrollframe.texture = texture
--scrollframe:SetBackdrop(backdrop)
statusFrame.scrollframe = scrollframe

--scrollbar
scrollbar = CreateFrame("Slider", "GolemUI_Message_List_ScrollBar", scrollframe, "UIPanelScrollBarTemplate")
scrollbar:SetPoint("TOPLEFT", statusFrame, "TOPRIGHT", 4, -16)
scrollbar:SetPoint("BOTTOMLEFT", statusFrame, "BOTTOMRIGHT", 4, 16)
scrollbar:SetMinMaxValues(1, 1)
scrollbar:SetValueStep(1)
scrollbar.scrollStep = 1
scrollbar:SetValue(0)
scrollbar:SetWidth(16)
scrollbar:SetScript("OnValueChanged",
function (self, value)
--self:GetParent():SetVerticalScroll(value)
	--print ("value: " .. value)
	local n = value % MESSAGE_BTN_SIZE;
	self:GetParent():SetVerticalScroll(value)--n * 25)
end)
local scrollbg = scrollbar:CreateTexture(nil, "BACKGROUND")
scrollbg:SetAllPoints(scrollbar)
scrollbg:SetTexture(0, 0, 0, 0.4)
statusFrame.scrollbar = scrollbar
--content frame
local content = CreateFrame("Frame", "GolemUI_Message_List", scrollframe, "ListScrollFrameTemplate")
content:SetPoint("TOPLEFT", scrollframe, "TOPLEFT", 10, 0)
--content:SetPoint("BOTTOMRIGHT", scrollframe, "BOTTOMRIGHT", 0, 0)
--content:SetHeight(200)
content:SetWidth(376)
content:SetHeight(287)
--content:SetBackdrop(backdrop)
scrollframe.content = content

scrollframe:SetScrollChild(content) 


function mysplit(inputstr, sep)
	if sep == nil then
			sep = "%s"
	end
	local t={} ; i=1
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
			t[i] = str
			i = i + 1
	end
	return t
end


function SelectButton(self, ...)
	if self.selected == true then
		--print("DESELECT NOW")
		self:UnlockHighlight()
		self.selected = false
		statusFrame:Hide()
	else
		--print("SELECT")
		print("FRAME COUNT: "..#messageFrames)
		print("SELECTED USER: "..self.username..", MSG_COUNT: "..users[self.username].msg_count)
		
		if users[self.username].msg_count > 6 then
			GolemUI_Message_List_ScrollBar:SetMinMaxValues(0, users[self.username].msg_count * MESSAGE_BTN_SIZE - 287)
		else
			GolemUI_Message_List_ScrollBar:SetMinMaxValues(0, 0)
		end
		
		for i = 1, #messageFrames do
			messageFrames[i]:Hide()
		end
		
		
		
		for k,v in pairs(users[self.username].messages) do
			--print (k, v.msg, v.time)
			-- Split messsage into words
			local words = mysplit(v.msg)
			local s = "["..v.sec.."]|c00ff0000[" .. v.timestamp .. "]|r "..v.msg
			getglobal(messageFrames[k]:GetName().."Text"):SetText(s)
			messageFrames[k]:Show()
			--getglobal(GolemUI_Message_List_Message_..i):Hide()
		end
		
		
		local u = nil
		
		for k, v in pairs(users) do	
			v.frame:UnlockHighlight()
			v.frame.selected = false
		end	
		self:LockHighlight()
		self.selected = true
		
		getglobal(Entry_Status:GetName().."Text"):SetText(self.username)
		statusFrame:Show()
	end	
end

function RefreshStatusFrame(sender)
	if users[sender].msg_count > 6 then
		GolemUI_Message_List_ScrollBar:SetMinMaxValues(0, (users[sender].msg_count - 1) * MESSAGE_BTN_SIZE - 287)
	else
		GolemUI_Message_List_ScrollBar:SetMinMaxValues(0, 0)
	end
	local u = users[sender]
	local s = "["..u.messages[u.msg_count].sec.."]|c00ff0000[" .. u.messages[u.msg_count].timestamp .. "]|r "..u.messages[u.msg_count].msg
	getglobal(messageFrames[u.msg_count]:GetName().."Text"):SetText(s)
	messageFrames[u.msg_count]:Show()
end


function eventHandlers.CHAT_MSG_SAY(msg, sender, ...)
	Logs(msg, sender, ...)
end

function eventHandlers.CHAT_MSG_CHANNEL(msg, sender, ...)
	Logs(msg, sender, ...)
end


function eventHandlers.CHAT_MSG_WHISPER(msg, sender, ...)
	Logs(msg, sender, ...)
end



--GolemUI_Main_Frame:RegisterEvent("UI_ERROR_MESSAGE")
--GolemUI_Main_Frame:RegisterEvent("UI_INFO_MESSAGE")


function Logs(msg, sender, ...)
	-- �� ����� ����� ����� �� ������ ����
	if sender == UnitName("player") then
		--return
	end
	-- ���� ���� ��� �� �������� � ������� ����������
	if users[sender] == nil then
		-- ������� ������� - �������� ��� ������ ������������
		local u = {...}		
		-- ������� ������ ������������
		u.ID = userID
		-- ������� ��������� �������� ������������
		u.messages = {}
		-- �.�. ������ ������ ��������� - ��������� ��� ������ ������������
		u.msg_count = 1
		-- ������� ������� - �������� ��� ���������
		local m = {...}
		-- ��������� ���������
		m.msg = msg
		-- ������� ����� ������������� ���������
		m.timestamp = date("%d.%m.%y %H:%M:%S")
		-- ������� "������" ����� ���������
		m.sec = GetTime()
		-- ������� ������ ��� ����������� ���������
		if maxMessages == 0 then
			msgFrame = CreateFrame("Button", "$parent_Message_"..maxMessages, GolemUI_Message_List, "GolemUI_Message_List_Template")
			msgFrame:SetPoint("TOPLEFT", 0, 0)
			maxMessages = 1
			table.insert(messageFrames, msgFrame)				
		end
		-- ��������� ��������� � ������� ��������� �������� ������������
		table.insert(u.messages, m)
		-- ������� ����� - ������ ������������
		u.frame = CreateFrame("Button", "$parent_Entry_"..userID, GolemUI_Entry_List, "GolemUI_Entry_List_Template")
		-- ������ ID ������
		u.frame:SetID(userID)
		-- ���������� ���
		u.frame.username = sender
		-- ���� ������������ ������ � ������
		if userID == 0 then
			-- ������������ ����� � �������������
			u.frame:SetPoint("TOPLEFT", GolemUI_Entry_List, "TOPLEFT", 0, 0)			
		else
			-- ����� ������������ � ����������� ������ (����)
			u.frame:SetPoint("TOPLEFT", "$parent_Entry_"..(userID - 1), "BOTTOMLEFT", 0, 0)			
		end
		-- ������ ����� ������
		getglobal(u.frame:GetName().."Text"):SetText(userID.. ". "..sender)		
		-- ��������� ��������� ������
		UIFrameFadeIn(u.frame, 1.34);
		-- ��������� ������������ � ������� �������������
		users[sender] = u
		-- ��������� � ����. ��������������
		userID = userID + 1
		-- ���� ������� ���� ���������� ���������
		if u.frame.selected then
			-- ��������� ���� ������ ����������
			RefreshStatusFrame(sender)
		end
	-- ���� ������������ ��� ���� � ������� - ��������� ��������� � ��� ������ ���������
	else
		-- ����������� ���������� ���������
		users[sender].msg_count = users[sender].msg_count + 1
		-- ������� �������� ��� ���������
		local m = {...}
		-- �������� ����
		m.msg = msg
		m.timestamp = date("%d.%m.%y %H:%M:%S")
		m.sec = GetTime()
		-- ������� �������������� ����� � ���� ���������� ��������, ���� ��� ��������� �� ����������
		if users[sender].msg_count > maxMessages then			
			msgFrame = CreateFrame("Button", "$parent_Message_"..maxMessages, GolemUI_Message_List, "GolemUI_Message_List_Template")
			msgFrame:SetPoint("TOPLEFT", "$parent_Message_"..(maxMessages - 1), "BOTTOMLEFT", 0, 0)			
			table.insert(messageFrames, msgFrame)
			-- ��������� ����� ��������
			if MESSAGE_BTN_SIZE * (GolemUI_Message_List:GetNumChildren() + 1) > GolemUI_Message_List:GetHeight() then
				GolemUI_Message_List:SetHeight(MESSAGE_BTN_SIZE * GolemUI_Message_List:GetNumChildren())
			end
			-- ������������ ���������� ������� ������ ����� ������������� ���������� ��������� �� ���� �������������
			maxMessages = users[sender].msg_count
		end
		-- ��������� ����������� ��������� � ������� ��������� ������������
		table.insert(users[sender].messages, m)
		-- ���� ������� ���� ���������� ���������
		if users[sender].frame.selected then
			-- ��������� ���� ������ ����������
			RefreshStatusFrame(sender)
		end
	end

	
	-- ��������� � ���� ���������� - ��������� ����� ����������� ������ ���� �������������
	if USER_BTN_SIZE * (GolemUI_Entry_List:GetNumChildren() + 1) > GolemUI_Entry_List:GetHeight() then
		GolemUI_Entry_List:SetHeight(USER_BTN_SIZE * (GolemUI_Entry_List:GetNumChildren() + 1))
		if GolemUI_Entry_List:GetNumChildren() > 11 then
			local n = GolemUI_Main_Frame:GetHeight() % USER_BTN_SIZE;
			GolemUI_Entry_List_ScrollBar:SetMinMaxValues(0, (GolemUI_Entry_List:GetNumChildren() - n) * USER_BTN_SIZE)
		end
	end
	
	-- ��������� ��������� ������������
	table.insert(GolemUI_antiSpamDB, sender)
	print(#GolemUI_antiSpamDB)
	--f = loadfile("GolemUI.lua")
	
	
	--local mycode = "table.insert("..GolemUI_antiSpamDB..", "..sender..")"
	--f = loadstring("print('test');")
	--local f = loadstring(mycode)
	--RunScript(f())
	--local retExpr = '"Hello " .. UnitName("target")';
	--RunScript("function My_GetGreeting() return " .. retExpr .. ";end");
	
	--for k, v in pairs(GolemUI_antiSpamDB) do
		--print(k, ' ', v)
	--end
	--antispam.MessageCheck(users[sender])
end
-- ������ ����������� �������
local function ScanChatEventHandler(self, event, ...)
	return eventHandlers[event](...);
end
-- ��� ����
local function AddonEnable()
	-- ���������� �����
	UIFrameFadeIn(GolemUI_Main_Frame, 1.34);
	-- ������������ ������� ��������� ��������� � ����� ����
	GolemUI_Main_Frame:RegisterEvent("CHAT_MSG_CHANNEL");
	GolemUI_Main_Frame:RegisterEvent("CHAT_MSG_SAY");
	
	GolemUI_Main_Frame:RegisterEvent("CHAT_MSG_WHISPER");
	-- ������ ����������
	GolemUI_Main_Frame:SetScript("OnEvent", ScanChatEventHandler);
	GolemUI_Main_Frame:Show();
	print ("|c00ff00ff"..ADDON_TITLE .. " " .. " Enabled");
end
-- ���� ����
local function AddonDisable()
	-- ���������� �����
	UIFrameFadeOut(GolemUI_Main_Frame, 1.34);
	-- ������������ ������� ��������� ��������� � ����� ����
	GolemUI_Main_Frame:UnregisterEvent("CHAT_MSG_CHANNEL");
	GolemUI_Main_Frame:UnregisterEvent("CHAT_MSG_SAY");
	GolemUI_Main_Frame:UnregisterEvent("CHAT_MSG_WHISPER");
	-- ������ ����������
	GolemUI_Main_Frame:SetScript("OnEvent", nil);
	GolemUI_Main_Frame:Hide();
	print ("|c00ff00ff"..ADDON_TITLE .. " " .. " Disabled");
end
-- ��������� ���� ������� ��� ���/���� �����
SLASH_GOLEM_STATUS1 = "/golem";
SlashCmdList["GOLEM_STATUS"] = function(msg)
	if GolemUI_Main_Frame:IsVisible() then
		AddonDisable();
	else
		AddonEnable();
	end	
end

----------------------------------------------------------------------------
----------------------------------------------------------------------------
AddonEnable();
----------------------------------------------------------------------------
----------------------------------------------------------------------------

local frame = GolemUI_Main_Frame

--scrollframe
scrollframe = CreateFrame("ScrollFrame", nil, frame)
scrollframe:SetPoint("TOPLEFT", 10, -25)
scrollframe:SetPoint("BOTTOMRIGHT", -10, 10)
scrollframe:SetSize(200, 200)
--local texture = scrollframe:CreateTexture()
--texture:SetAllPoints()
--texture:SetTexture(.5,.5,.5,1)
--scrollframe:SetBackdrop(backdrop)
frame.scrollframe = scrollframe

--scrollbar
scrollbar = CreateFrame("Slider", "GolemUI_Entry_List_ScrollBar", scrollframe, "UIPanelScrollBarTemplate")
scrollbar:SetPoint("TOPLEFT", frame, "TOPRIGHT", 4, -16)
scrollbar:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", 4, 16)
scrollbar:SetMinMaxValues(1, 1)
scrollbar:SetValueStep(1)
scrollbar.scrollStep = 1
scrollbar:SetValue(0)
scrollbar:SetWidth(16)
scrollbar:SetScript("OnValueChanged",
function (self, value)
--self:GetParent():SetVerticalScroll(value)
	--print ("value: " .. value)
	local n = value % 25;
	self:GetParent():SetVerticalScroll(value)--n * 25)
	--self:GetParent():SetScrollOffset(select(2, self:GetMinMaxValues()) - value)
end)
local scrollbg = scrollbar:CreateTexture(nil, "BACKGROUND")
scrollbg:SetAllPoints(scrollbar)
scrollbg:SetTexture(0, 0, 0, 0.4)
frame.scrollbar = scrollbar
--content frame
local content = CreateFrame("Frame", "GolemUI_Entry_List", scrollframe)
content:SetSize(200, 50)
content:SetAllPoints()
--local texture = content:CreateTexture()
--texture:SetAllPoints()
--texture:SetTexture("Interface\\GLUES\\MainMenu\\Glues-BlizzardLogo")
--content.texture = texture
--content:SetBackdrop(backdrop)
scrollframe.content = content

scrollframe:SetScrollChild(content)
----------------------------------------------------------