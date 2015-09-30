-- Lorelle
-- 160530

-- print("Hello " .. UnitName("player"));

--local addonName, addonTable = ...;
--print(_G["antispamTable"])
--table.foreach(_G["antispamTable"], print)

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

--statusFrame:RegisterEvent("OnEvent")
--statusFrame:SetScript("OnShow", tess)



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
function Logs(msg, sender, ...)
	-- Не будем вести логов на самого себя
	if sender == UnitName("player") then
		--return
	end
	-- Если юзер еще не добавлен в таблицу наблюдений
	if users[sender] == nil then
		-- Создаем таблицу - упаковку для данных пользователя
		local u = {...}
		
		u.msgLine = DEFAULT_CHAT_FRAME:GetCurrentLine();
		
		-- Запишем индекс пользователя
		u.ID = userID
		-- Таблица сообщений текущего пользователя
		u.messages = {}
		-- Т.к. запись только создается - сообщение для записи единственное
		u.msg_count = 1
		-- Создаем таблицу - упаковку для сообщений
		local m = {...}
		-- Сохраняем сообщение
		m.msg = msg
		-- Запишем время возникновения сообщения
		m.timestamp = date("%d.%m.%y %H:%M:%S")
		-- Запишем "Точное" время сообщения
		m.sec = GetTime()
		-- Создаем фреймы для отображения сообщений
		if maxMessages == 0 then
			msgFrame = CreateFrame("Button", "$parent_Message_"..maxMessages, GolemUI_Message_List, "GolemUI_Message_List_Template")
			msgFrame:SetPoint("TOPLEFT", 0, 0)
			maxMessages = 1
			table.insert(messageFrames, msgFrame)				
		end
		-- Добавляем сообщение в таблицу сообщений текущего пользователя
		table.insert(u.messages, m)
		-- Создаем фрейм - кнопку пользователя
		u.frame = CreateFrame("Button", "$parent_Entry_"..userID, GolemUI_Entry_List, "GolemUI_Entry_List_Template")
		-- Задаем ID фрейма
		u.frame:SetID(userID)
		-- Запоминаем ник
		u.frame.username = sender
		-- Если пользователь первый в списке
		if userID == 0 then
			-- Присоединяем фрейм к родительскому
			u.frame:SetPoint("TOPLEFT", GolemUI_Entry_List, "TOPLEFT", 0, 0)			
		else
			-- Иначе присоединяем к предыдущему фрейму (вниз)
			u.frame:SetPoint("TOPLEFT", "$parent_Entry_"..(userID - 1), "BOTTOMLEFT", 0, 0)			
		end
		-- Задаем текст кнопки
		getglobal(u.frame:GetName().."Text"):SetText(userID.. ". "..sender)		
		-- Реализуем появление фрейма
		UIFrameFadeIn(u.frame, 1.34);
		-- Сохраняем пользователя в таблице пользователей
		users[sender] = u
		-- Переходим к след. идентификатору
		userID = userID + 1
		-- Если открыто окно статистики сообщений
		if u.frame.selected then
			-- Обновляем инфу фрейма статистики
			RefreshStatusFrame(sender)
		end
	-- Если пользователь уже есть в таблице - добавляем сообщение к его списку сообщений
	else
		-- Увеличиваем количество сообщений
		users[sender].msg_count = users[sender].msg_count + 1
		-- Создаем упаковку для сообщения
		local m = {...}
		-- Собираем инфу
		m.msg = msg
		m.timestamp = date("%d.%m.%y %H:%M:%S")
		m.sec = GetTime()
		-- Создаем дополнительный фрейм в окне статистики собщений, если уже созданных не достаточно
		if users[sender].msg_count > maxMessages then			
			msgFrame = CreateFrame("Button", "$parent_Message_"..maxMessages, GolemUI_Message_List, "GolemUI_Message_List_Template")
			msgFrame:SetPoint("TOPLEFT", "$parent_Message_"..(maxMessages - 1), "BOTTOMLEFT", 0, 0)			
			table.insert(messageFrames, msgFrame)
			-- Расширяем фрейм родитель
			if MESSAGE_BTN_SIZE * (GolemUI_Message_List:GetNumChildren() + 1) > GolemUI_Message_List:GetHeight() then
				GolemUI_Message_List:SetHeight(MESSAGE_BTN_SIZE * GolemUI_Message_List:GetNumChildren())
			end
			-- Максимальное количество фреймов теперь равно максимальному количеству сообщений из всех пользователей
			maxMessages = users[sender].msg_count
		end
		-- Добавляем упаклванное сообщение в таблицу сообщений пользователя
		table.insert(users[sender].messages, m)
		-- Если открыто окно статистики сообщений
		if users[sender].frame.selected then
			-- Обновляем инфу фрейма статистики
			RefreshStatusFrame(sender)
		end
	end

	
	-- Проверяем и если необходимо - расширяем фрейм отображения кнопок всех пользователей
	if USER_BTN_SIZE * (GolemUI_Entry_List:GetNumChildren() + 1) > GolemUI_Entry_List:GetHeight() then
		GolemUI_Entry_List:SetHeight(USER_BTN_SIZE * (GolemUI_Entry_List:GetNumChildren() + 1))
		if GolemUI_Entry_List:GetNumChildren() > 11 then
			local n = GolemUI_Main_Frame:GetHeight() % USER_BTN_SIZE;
			GolemUI_Entry_List_ScrollBar:SetMinMaxValues(0, (GolemUI_Entry_List:GetNumChildren() - n) * USER_BTN_SIZE)
		end
	end
	
	-- Проверяем не флудит ли пользователь
	antispam.CheckFlood(users[sender])
	-- Проверяем сообщение на спам
	--antispam.CheckSpam(sender, msg)
end
-- Задаем обработчики событий
local function ScanChatEventHandler(self, event, ...)
	return eventHandlers[event](...);
end
-- Вкл адон
local function AddonEnable()
	-- Показываем фрейм
	UIFrameFadeIn(GolemUI_Main_Frame, 1.34);
	-- Регистрируем событие появления сообщения в общем чате
	GolemUI_Main_Frame:RegisterEvent("CHAT_MSG_CHANNEL");
	GolemUI_Main_Frame:RegisterEvent("CHAT_MSG_SAY");
	-- Задаем обработчик
	GolemUI_Main_Frame:SetScript("OnEvent", ScanChatEventHandler);
	GolemUI_Main_Frame:Show();
	print ("|c00ff00ff"..ADDON_TITLE .. " " .. " Enabled");
end
-- Выкл адон
local function AddonDisable()
	-- Показываем фрейм
	UIFrameFadeOut(GolemUI_Main_Frame, 1.34);
	-- Регистрируем событие появления сообщения в общем чате
	GolemUI_Main_Frame:UnregisterEvent("CHAT_MSG_CHANNEL");
	-- Задаем обработчик
	GolemUI_Main_Frame:SetScript("OnEvent", nil);
	GolemUI_Main_Frame:Hide();
	print ("|c00ff00ff"..ADDON_TITLE .. " " .. " Disabled");
end
-- Добавляем слеш команду для вкл/выкл адона
SLASH_GOLEM_STATUS1 = "/golem";
SlashCmdList["GOLEM_STATUS"] = function(msg)
	if GolemUI_Main_Frame:IsVisible() then
		AddonDisable();
	else
		AddonEnable();
	end	
end


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

