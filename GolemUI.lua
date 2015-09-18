-- Lorelle
-- 160530
-- print("Hello " .. UnitName("player"));
--MinimapCluster:ClearAllPoints()
--MinimapCluster:SetPoint("CENTER", 100, -50)
local users = {}
local userID = 0

local timer = 5

local eventHandlers = {}
function eventHandlers.CHAT_MSG_CHANNEL(msg, sender, ...)
	
	if users[sender] == nil then
		local u = {...}
		u.user = sender
		u.msg = msg
		u.time = GetTime()
		u.id = userID
		u.frame = CreateFrame("Button", "$parentEntry"..userID, GolemUI_List, "GolemUI_List_Entry_Template")--GolemUI_Main_Frame, "GolemUI_List_Entry_Template")
		u.frame:SetID(userID)
		u.frame:SetPoint("TOPLEFT", 11, -12 - userID * 24)
		--if userID == 0 then
		--	u.frame:SetPoint("TOPLEFT", GolemUI_List, "TOPLEFT", 0, -4)
	--	else
--			u.frame:SetPoint("TOPLEFT", "$parentEntry"..(userID - 1), "BOTTOMLEFT", 0, 0)
		--end
		getglobal(u.frame:GetName().."Text"):SetText(sender)
		UIFrameFadeIn(u.frame, 1.34);
		--u.frame:Show()

		--GolemUI_List:ClearAllPoints()
		--GolemUI_List:SetPoint("TOP", u.frame
		
		users[sender] = u
		userID = userID + 1
		--table.insert(users, u)
		--print(event)
		--print(sender)
		--print(msg)
		
	else
		--print (sender.. " already in list")
	end
	if 24 * (GolemUI_List:GetNumChildren() + 1) > GolemUI_List:GetHeight() then
		GolemUI_List:SetHeight(24 * (GolemUI_List:GetNumChildren() + 1))
		--GolemUI_List_Scroll:SetMinMaxValues(1, 24 * GolemUI_List:GetNumChildren())
	end
	print (GolemUI_List:GetNumChildren() .. " " .. GolemUI_List:GetNumRegions() )
	--print (GolemUI_List:GetMaxResize())
	--print (GolemUI_List:GetSize())
	--print ("COUNT:"..userID)
	--print(event, sender, msg, GetTime());
end

local function ScanChatEventHandler(self, event, ...)
	return eventHandlers[event](...);
end

local function AddonEnable()
	-- Показываем фрейм
	UIFrameFadeIn(GolemUI_Main_Frame, 1.34);
	-- Регистрируем событие появления сообщения в общем чате
	GolemUI_Main_Frame:RegisterEvent("CHAT_MSG_CHANNEL");
	-- Задаем обработчик
	GolemUI_Main_Frame:SetScript("OnEvent", ScanChatEventHandler);
	GolemUI_Main_Frame:Show();
	print (ADDON_TITLE .. " " .. " Enabled");
end

local function AddonDisable()
	-- Показываем фрейм
	UIFrameFadeOut(GolemUI_Main_Frame, 1.34);
	-- Регистрируем событие появления сообщения в общем чате
	GolemUI_Main_Frame:UnregisterEvent("CHAT_MSG_CHANNEL");
	-- Задаем обработчик
	GolemUI_Main_Frame:SetScript("OnEvent", nil);
	GolemUI_Main_Frame:Hide();
	print (ADDON_TITLE .. " " .. " Disabled");
end


SLASH_GOLEM_STATUS1 = "/golem";
SlashCmdList["GOLEM_STATUS"] = function(msg)
	print(msg)
	if msg == "update" then
		print "update"
		timer = 5
	end
--	if GolemUI_Main_Frame:IsVisible() then
--		AddonDisable();
--	else
--		AddonEnable();
--	end
	--print ("status", msg)
	
end

--local users = {}

-- "Ничтожество"
-- PlaySoundFile("Sound/Creature/Illidan/BLACK_Illidan_09.wav")
-- "Ненависть десяти тысяч лет"
-- PlaySoundFile("Sound/Creature/Illidan/BLACK_Illidan_08.wav")
-- "Сила истинного демона"
-- PlaySoundFile("Sound/Creature/Illidan/BLACK_Illidan_13.wav")
-- "Вы не готовы"
-- PlaySoundFile("Sound/Creature/Illidan/BLACK_Illidan_04.wav")
--GolemUI_Main_Frame:Show()


AddonEnable();


local total = 0
function onUpdate(self, elapsed)
	total = total + elapsed
	if total >= 1 and timer > 0 then
		DEFAULT_CHAT_FRAME:AddMessage(timer)
		timer = timer - 1
		total = 0
		if timer == 0 then
			DEFAULT_CHAT_FRAME:AddMessage("DONE")
			GolemUI_Main_Frame:SetScript("OnUpdate", nil)
		end
	end
end

--GolemUI_Main_Frame:SetScript("OnUpdate", onUpdate)

--StaticPopupDialogs["TEST"] = {
--	text = "Hellos pip",
--	button1 = "OKAY",
--	timeout = 5
--}
--StaticPopup_Show("TEST")


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




--parent frame
local frame = CreateFrame("Frame", "MyFrame", UIParent)
frame:SetSize(200, 200)
frame:SetPoint("CENTER")
local texture = frame:CreateTexture()
texture:SetAllPoints()
texture:SetTexture(0, 0, 0, 0.5)
frame.background = texture

--scrollframe
scrollframe = CreateFrame("ScrollFrame", nil, frame)
scrollframe:SetPoint("TOPLEFT", 10, -10)
scrollframe:SetPoint("BOTTOMRIGHT", -10, 10)
scrollframe:SetSize(200, 200)
local texture = scrollframe:CreateTexture()
texture:SetAllPoints()
--texture:SetTexture(.5,.5,.5,1)
scrollframe:SetBackdrop(backdrop)
frame.scrollframe = scrollframe

--scrollbar
scrollbar = CreateFrame("Slider", "GolemUI_List_Scroll", scrollframe, "UIPanelScrollBarTemplate")
scrollbar:SetPoint("TOPLEFT", frame, "TOPRIGHT", 4, -16)
scrollbar:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", 4, 16)
scrollbar:SetMinMaxValues(1, 1)
scrollbar:SetValueStep(1)
scrollbar.scrollStep = 1
scrollbar:SetValue(0)
scrollbar:SetWidth(16)
scrollbar:SetScript("OnValueChanged",
function (self, value)
self:GetParent():SetVerticalScroll(value)
end)
local scrollbg = scrollbar:CreateTexture(nil, "BACKGROUND")
scrollbg:SetAllPoints(scrollbar)
scrollbg:SetTexture(0, 0, 0, 0.4)
frame.scrollbar = scrollbar

--content frame
local content = CreateFrame("Frame", "GolemUI_List", scrollframe)
content:SetSize(180, 50)
--local texture = content:CreateTexture()
--texture:SetAllPoints()
--texture:SetTexture("Interface\\GLUES\\MainMenu\\Glues-BlizzardLogo")
--content.texture = texture
content:SetBackdrop(backdrop)
scrollframe.content = content

scrollframe:SetScrollChild(content) 
--GolemUI_List:SetResizable(enabled)
