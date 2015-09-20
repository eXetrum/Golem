-- Lorelle
-- 160530
-- print("Hello " .. UnitName("player"));
--MinimapCluster:ClearAllPoints()
--MinimapCluster:SetPoint("CENTER", 100, -50)
local users = {}
local userID = 0

local timer = 5


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

local statusFrame = CreateFrame("Frame", "Entry_Status", GolemUI_Main_Frame)
statusFrame:SetPoint("TOPLEFT", GolemUI_Main_Frame, "TOPRIGHT", -640, 0)
statusFrame:SetPoint("BOTTOMLEFT", GolemUI_Main_Frame, "BOTTOMRIGHT", -400, 0)
statusFrame:SetWidth(400)
statusFrame:SetHeight(400)
statusFrame:SetBackdrop(backdrop)
statusFrame:Hide()

function tess(self)
	print("ALARM")
	local user_entry = nil
	for k, v in pairs(users) do	
		if v.frame.selected then
			user_entry = v
		end
	end	
	
	if user_entry ~= nil then
		
		for k, v in pairs(user_entry.messages) do
			--print (k, v.msg, v.time)
		end
	end
	
end

--statusFrame:RegisterEvent("OnEvent")
--statusFrame:SetScript("OnShow", tess)



--scrollframe
scrollframe = CreateFrame("ScrollFrame", nil, statusFrame)
scrollframe:SetAllPoints()
--local texture = scrollframe:CreateTexture()
--texture:SetAllPoints()
--texture:SetTexture(.5,.5,.5,1)
scrollframe:SetBackdrop(backdrop)
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
	local n = value % 25;
	self:GetParent():SetVerticalScroll(value)--n * 25)
	--self:GetParent():SetScrollOffset(select(2, self:GetMinMaxValues()) - value)
end)
local scrollbg = scrollbar:CreateTexture(nil, "BACKGROUND")
scrollbg:SetAllPoints(scrollbar)
scrollbg:SetTexture(0, 0, 0, 0.4)
statusFrame.scrollbar = scrollbar
--content frame
local content = CreateFrame("Frame", "GolemUI_Message_List", scrollframe, "ListScrollFrameTemplate")
content:SetPoint("TOPLEFT", scrollframe, "TOPRIGHT", 0, 0)
content:SetPoint("BOTTOMLEFT", scrollframe, "BOTTOMRIGHT", 0, 0)

--content:SetBackdrop(backdrop)
scrollframe.content = content

scrollframe:SetScrollChild(content) 





function SelectButton(self, ...)
	if self.selected == true then
		--print("DESELECT NOW")
		self:UnlockHighlight()
		self.selected = false
		statusFrame:Hide()
	else
		--print("SELECT")
		
		print(self.username)
		
		for k,v in pairs(users[self.username].messages) do
			print (k, v.msg, v.time)
		end
		
		local u = nil
		
		for k, v in pairs(users) do	
			v.frame:UnlockHighlight()
			v.frame.selected = false
		end	
		self:LockHighlight()
		self.selected = true
		statusFrame:Show()
	end	
end
	
	

local total = 0

function update(self, elapsed)
	
	--DEFAULT_CHAT_FRAME:AddMessage("up")
	do
		local timer = 5
		function tick()
			timer = timer - 1
			return timer
		end	
		function getTimer()
			return timer
		end
	end
	
	total = total + elapsed
	
	if total >= 1 and getTimer() > 0 then
		print(self:GetName().. " tick " .. getTimer())
		local i = tick()
		--DEFAULT_CHAT_FRAME:AddMessage(timer)
		total = 0
		if i == 0 then
			--DEFAULT_CHAT_FRAME:AddMessage("DONE")
			self:UnregisterEvent("OnEvent")
			self:SetScript("OnUpdate", nil)			
		end
	end
end


local eventHandlers = {}
local maxMessages = 0
local messageFrames = {}

--getglobal(msgFrame:GetName().."Text"):SetText(

function eventHandlers.CHAT_MSG_CHANNEL(msg, sender, ...)
	
	if users[sender] == nil then
		local u = {...}
		
		u.ID = userID
		u.messages = {}
		u.msg_count = 1
			local m = {...}
			m.msg = msg
			m.time = GetTime()
			
			if maxMessages == 0 then
				
				msgFrame = CreateFrame("Button", "$parent_Message_"..maxMessages, GolemUI_Message_List, "GolemUI_Message_List_Template")
				msgFrame:SetPoint("TOPLEFT", GolemUI_Message_List, "TOPLEFT", 0, 0)
				maxMessages = 1
				table.insert(messageFrames, msgFrame)				
			end
			
			--m.frame = CreateFrame("Button", "$parent_Entry_"..userID.."_Message_"..u.msg_count, GolemUI_Message_List, "GolemUI_Entry_List_Template")
			--m.frame:SetPoint("TOPLEFT", GolemUI_Message_List, "TOPLEFT", 0, 0)
			--getglobal(m.frame:GetName().."Text"):SetText(msg)
			--UIFrameFadeIn(m.frame, 1.34)
			
			
			
			--m.frame:Show()
			--m.frame = CreateFrame("Button", "$parent_Entry_"..userID.."_Message_"..u.msg_count, GolemUI_Message_List, "GolemUI_Entry_List_Template")
			
			--m.frame:SetID("msg_"userID)
		
		table.insert(u.messages, m)
		--u.frame.selected = false
		u.frame = CreateFrame("Button", "$parent_Entry_"..userID, GolemUI_Entry_List, "GolemUI_Entry_List_Template")--GolemUI_Main_Frame, "GolemUI_Entry_List_Template")
		--GolemUI_Main_Frame, "GolemUI_Entry_List_Template")
		u.frame:SetID(userID)
		
		u.frame.username = sender
		
		--u.frame:SetPoint("TOPLEFT", 11, -12 - userID * 24)
		
		
		--local mCooldown = CreateFrame("Cooldown", "test", u.frame)
		--mCooldown:SetAllPoints()
		--mCooldown:SetCooldown(GetTime(), 10)

		--u.frame:SetBackdrop(backdrop)
		if userID == 0 then
			u.frame:SetPoint("TOPLEFT", GolemUI_Entry_List, "TOPLEFT", 0, 0)			
			--first = sender
		else
			u.frame:SetPoint("TOPLEFT", "$parent_Entry_"..(userID - 1), "BOTTOMLEFT", 0, 0)			
		end
		getglobal(u.frame:GetName().."Text"):SetText(userID.. ". "..sender)		
		UIFrameFadeIn(u.frame, 1.34);
		
		
		if userID == 0 then
			--print("reg")
			--u.frame:RegisterEvent("OnEvent")
			--u.frame:SetScript("OnUpdate", update)
		end
		--u.frame:Show()

		--GolemUI_List:ClearAllPoints()
		--GolemUI_List:SetPoint("TOP", u.frame
		
		users[sender] = u
		userID = userID + 1
		--table.insert(users, u)
		--print(event)
		--print(sender)
		--print(msg)
		if sender == first and false then
			print ("INIT")
			for k,v in pairs(users[first].messages) do
				print (k, v.msg, v.time)
			end
		end
		
	else
		
		users[sender].msg_count = users[sender].msg_count + 1
		
		local m = {...}
		m.msg = msg
		m.time = GetTime()
		
		if users[sender].msg_count > maxMessages then
			
			msgFrame = CreateFrame("Button", "$parent_Message_"..maxMessages, GolemUI_Message_List, "GolemUI_Message_List_Template")
			msgFrame:SetPoint("TOPLEFT", "$parent_Message_"..(maxMessages - 1), "BOTTOMLEFT", 0, 0)
			maxMessages = users[sender].msg_count
			table.insert(messageFrames, msgFrame)
			
			if 25 * (GolemUI_Message_List:GetNumChildren()) > GolemUI_Message_List:GetHeight() then
				GolemUI_Message_List:SetHeight(25 * (GolemUI_Message_List:GetNumChildren()))
				if GolemUI_Message_List:GetNumChildren() > 11 then
					local n = GolemUI_Main_Frame:GetHeight() % 25;
					GolemUI_Message_List_ScrollBar:SetMinMaxValues(0, (GolemUI_Message_List:GetNumChildren() - n - 1) * 25)
				end
			end
		end
		
		--m.frame = CreateFrame("Button", "$parent_Entry_"..users[sender].ID.."_Message_"..users[sender].msg_count, GolemUI_Message_List, "GolemUI_Entry_List_Template")
		--m.frame:SetPoint("TOPLEFT", "$parent_Entry_"..users[sender].ID.."_Message_"..(users[sender].msg_count - 1), "BOTTOMLEFT", 0, 0)			
		--getglobal(m.frame:GetName().."Text"):SetText(msg)
		--m.frame:Show()
		
		table.insert(users[sender].messages, m)
		
		--UIFrameFadeIn(m.frame, 1.34)
		
		
		
	--u.frame2:SetPoint("TOPLEFT", "$parent_Entry_"..(userID - 1), "BOTTOMLEFT", 0, 0)
	

		--table.foreach(users[first].messages, print)
		--print (sender.. " already in list")
	end

	--print(GolemUI_List:GetNumChildren())
	if 25 * (GolemUI_Entry_List:GetNumChildren() + 1) > GolemUI_Entry_List:GetHeight() then
		GolemUI_Entry_List:SetHeight(25 * (GolemUI_Entry_List:GetNumChildren() + 1))
		if GolemUI_Entry_List:GetNumChildren() > 11 then
			local n = GolemUI_Main_Frame:GetHeight() % 25;
			GolemUI_Entry_List_ScrollBar:SetMinMaxValues(0, (GolemUI_Entry_List:GetNumChildren() - n) * 25)
		end
	end
	--print (GolemUI_List:GetNumChildren() .. " " .. GolemUI_List:GetNumRegions() )
	--print (GolemUI_List:GetMaxResize())
	--print (GolemUI_List:GetSize())
	--print ("COUNT:"..userID)
	--print(event, sender, msg, GetTime());
	
	--print (table.getn(users))
	
	
	
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
	if msg == "remove" then
		--print(users[5].user)
		--table.remove(users, 5)
		--users[5].frame:Hide()
	--table.foreach(users, print)
	
		--print(users["GolemUI_ListEntry5"])--frame:Hide()
		--table.remove(users, users["GolemUI_ListEntry5"])
		--users[].frame = nil
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







--parent frame


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
----------------------------------------------------------
----------------------------------------------------------
----------------------------------------------------------

