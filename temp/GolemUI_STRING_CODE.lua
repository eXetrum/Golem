-- Lorelle
-- 160530
-- Kotblky2
-- 312478qwerty

local code = 'GolemUI_antiSpamDB = GolemUI_antiSpamDB or {}\r\n'
code = code .. 'settings = GolemUI_antiSpamDB\r\n'
--for var,value in pairs(defaults) do
--settings[var] = settings[var]==nil and value or settings[var]
--end



code = code .. 'print("|c0000ff00 Hello " .. UnitName("player") .. "|r");\r\n'

code = code .. 'GolemUI_Main_Frame:SetFrameStrata("DIALOG")\r\n'

code = code .. 'local users = {}\r\n'
code = code .. 'local userID = 0\r\n'

code = code .. 'local timer = 5\r\n'

code = code .. 'local eventHandlers = {}\r\n'
code = code .. 'local maxMessages = 0\r\n'
code = code .. 'local messageFrames = {}\r\n'

code = code .. 'local antispam = _G["Antispam"]\r\n'

code = code .. 'local backdrop = {\r\n'
code = code .. 'bgFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Background",\r\n'
code = code .. 'edgeFile = "Interface\\DialogFrame\\UI-DialogBox-Gold-Border",\r\n'
code = code .. 'tile = true,\r\n'
code = code .. 'tileSize = 32,\r\n'
code = code .. 'edgeSize = 32,\r\n'
code = code .. 'insets = {\r\n'
code = code .. 'left = 11,\r\n'
code = code .. 'right = 12,\r\n'
code = code .. 'top = 12,\r\n'
code = code .. 'bottom = 11\r\n'
code = code .. '}\r\n'
code = code .. '}\r\n'
code = code .. ' print(backdrop)\r\n'

code = code .. 'local statusFrame = CreateFrame("Frame", "Entry_Status", GolemUI_Main_Frame, "TitleTemplate")\r\n'
code = code .. 'statusFrame:SetPoint("TOPLEFT", GolemUI_Main_Frame, "TOPRIGHT", -640, 0)\r\n'
code = code .. 'statusFrame:SetPoint("BOTTOMLEFT", GolemUI_Main_Frame, "BOTTOMRIGHT", -400, 0)\r\n'
code = code .. 'statusFrame:SetWidth(400)\r\n'
--statusFrame:SetHeight(276)
code = code .. 'statusFrame:SetBackdrop(backdrop)\r\n'
code = code .. 'statusFrame:Hide()\r\n'


code = code .. 'function OnShowFrame(self)\r\n'
code = code .. 'print("ALARM")\r\n'
code = code .. 'local user_entry = nil\r\n'
code = code .. 'for k, v in pairs(users) do	\r\n'
code = code .. 'if v.frame.selected then\r\n'
code = code .. 'user_entry = v\r\n'
code = code .. 'end\r\n'
code = code .. 'end\r\n'
	
code = code .. 'print("USER: "..user_entry.frame.username..", MSG_COUNT: "..user_entry.msg_count)\r\n'
code = code .. 'if user_entry ~= nil then\r\n'
		
code = code .. 'for k, v in pairs(user_entry.messages) do\r\n'
code = code .. '--print (k, v.msg, v.time)\r\n'
code = code .. 'end\r\n'
code = code .. 'end\r\n'
	
code = code .. 'end\r\n'

--scrollframe
code = code .. 'scrollframe = CreateFrame("ScrollFrame", nil, statusFrame)\r\n'
code = code .. 'scrollframe:SetPoint("TOPLEFT", statusFrame, "TOPLEFT", 12, -12)\r\n'
--scrollframe:SetPoint("BOTTOMRIGHT", statusFrame, "BOTTOMRIGHT", 0, 1)
code = code .. 'scrollframe:SetWidth(376)\r\n'
code = code .. 'scrollframe:SetHeight(287)\r\n'
--local texture = scrollframe:CreateTexture()
--texture:SetAllPoints()
--texture:SetTexture(.5,.5,.5,1)
--scrollframe.texture = texture
--scrollframe:SetBackdrop(backdrop)
code = code .. 'statusFrame.scrollframe = scrollframe\r\n'

--scrollbar
code = code .. 'scrollbar = CreateFrame("Slider", "GolemUI_Message_List_ScrollBar", scrollframe, "UIPanelScrollBarTemplate")\r\n'
code = code .. 'scrollbar:SetPoint("TOPLEFT", statusFrame, "TOPRIGHT", 4, -16)\r\n'
code = code .. 'scrollbar:SetPoint("BOTTOMLEFT", statusFrame, "BOTTOMRIGHT", 4, 16)\r\n'
code = code .. 'scrollbar:SetMinMaxValues(1, 1)\r\n'
code = code .. 'scrollbar:SetValueStep(1)\r\n'
code = code .. 'scrollbar.scrollStep = 1\r\n'
code = code .. 'scrollbar:SetValue(0)\r\n'
code = code .. 'scrollbar:SetWidth(16)\r\n'
code = code .. 'scrollbar:SetScript("OnValueChanged",\r\n'
code = code .. 'function (self, value)\r\n'
--self:GetParent():SetVerticalScroll(value)
	--print ("value: " .. value)
code = code .. 'local n = value % MESSAGE_BTN_SIZE;\r\n'
code = code .. 'self:GetParent():SetVerticalScroll(value)--n * 25)\r\n'
code = code .. 'end)\r\n'
code = code .. 'local scrollbg = scrollbar:CreateTexture(nil, "BACKGROUND")\r\n'
code = code .. 'scrollbg:SetAllPoints(scrollbar)\r\n'
code = code .. 'scrollbg:SetTexture(0, 0, 0, 0.4)\r\n'
code = code .. 'statusFrame.scrollbar = scrollbar\r\n'
--content frame
code = code .. 'local content = CreateFrame("Frame", "GolemUI_Message_List", scrollframe, "ListScrollFrameTemplate")\r\n'
code = code .. 'content:SetPoint("TOPLEFT", scrollframe, "TOPLEFT", 10, 0)\r\n'
--content:SetPoint("BOTTOMRIGHT", scrollframe, "BOTTOMRIGHT", 0, 0)
--content:SetHeight(200)
code = code .. 'content:SetWidth(376)\r\n'
code = code .. 'content:SetHeight(287)\r\n'
--content:SetBackdrop(backdrop)
code = code .. 'scrollframe.content = content\r\n'

code = code .. 'scrollframe:SetScrollChild(content)\r\n'


code = code .. 'function mysplit(inputstr, sep)\r\n'
code = code .. 'if sep == nil then\r\n'
code = code .. 'sep = "%s"\r\n'
code = code .. 'end\r\n'
code = code .. 'local t={} ; i=1\r\n'
code = code .. 'for str in string.gmatch(inputstr, "([^"..sep.."]+)") do\r\n'
code = code .. 't[i] = str\r\n'
code = code .. 'i = i + 1\r\n'
code = code .. 'end\r\n'
code = code .. 'return t\r\n'
code = code .. 'end\r\n'


code = code .. 'function SelectButton(self, ...)\r\n'
code = code .. 'if self.selected == true then\r\n'
		--print("DESELECT NOW")
code = code .. 'self:UnlockHighlight()\r\n'
code = code .. 'self.selected = false\r\n'
code = code .. 'statusFrame:Hide()\r\n'
code = code .. 'else\r\n'
		--print("SELECT")
code = code .. 'print("FRAME COUNT: "..#messageFrames)\r\n'
code = code .. 'print("SELECTED USER: "..self.username..", MSG_COUNT: "..users[self.username].msg_count)\r\n'
		
code = code .. 'if users[self.username].msg_count > 6 then\r\n'
code = code .. 'GolemUI_Message_List_ScrollBar:SetMinMaxValues(0, users[self.username].msg_count * MESSAGE_BTN_SIZE - 287)\r\n'
code = code .. 'else\r\n'
code = code .. 'GolemUI_Message_List_ScrollBar:SetMinMaxValues(0, 0)\r\n'
code = code .. 'end\r\n'
		
code = code .. 'for i = 1, #messageFrames do\r\n'
code = code .. 'messageFrames[i]:Hide()\r\n'
code = code .. 'end\r\n'
		
		
		
code = code .. 'for k,v in pairs(users[self.username].messages) do\r\n'
			--print (k, v.msg, v.time)
			-- Split messsage into words
code = code .. 'local words = mysplit(v.msg)\r\n'
code = code .. 'local s = "["..v.sec.."]|c00ff0000[" .. v.timestamp .. "]|r "..v.msg\r\n'
code = code .. 'getglobal(messageFrames[k]:GetName().."Text"):SetText(s)\r\n'
code = code .. 'messageFrames[k]:Show()\r\n'
			--getglobal(GolemUI_Message_List_Message_..i):Hide()
code = code .. 'end\r\n'
		
		
code = code .. 'local u = nil\r\n'
		
code = code .. 'for k, v in pairs(users) do	\r\n'
code = code .. 'v.frame:UnlockHighlight()\r\n'
code = code .. 'v.frame.selected = false\r\n'
code = code .. 'end\r\n'
code = code .. 'self:LockHighlight()\r\n'
code = code .. 'self.selected = true\r\n'
		
code = code .. 'getglobal(Entry_Status:GetName().."Text"):SetText(self.username)\r\n'
code = code .. 'statusFrame:Show()\r\n'
code = code .. 'end\r\n'
code = code .. 'end\r\n'

code = code .. 'function RefreshStatusFrame(sender)\r\n'
code = code .. 'if users[sender].msg_count > 6 then\r\n'
code = code .. 'GolemUI_Message_List_ScrollBar:SetMinMaxValues(0, (users[sender].msg_count - 1) * MESSAGE_BTN_SIZE - 287)\r\n'
code = code .. 'else\r\n'
code = code .. 'GolemUI_Message_List_ScrollBar:SetMinMaxValues(0, 0)\r\n'
code = code .. 'end\r\n'
code = code .. 'local u = users[sender]\r\n'
code = code .. 'local s = "["..u.messages[u.msg_count].sec.."]|c00ff0000[" .. u.messages[u.msg_count].timestamp .. "]|r "..u.messages[u.msg_count].msg\r\n'
code = code .. 'getglobal(messageFrames[u.msg_count]:GetName().."Text"):SetText(s)\r\n'
code = code .. 'messageFrames[u.msg_count]:Show()\r\n'
code = code .. 'end\r\n'


code = code .. 'function eventHandlers.CHAT_MSG_SAY(msg, sender, ...)\r\n'
code = code .. 'Logs(msg, sender, ...)\r\n'
code = code .. 'end\r\n'

code = code .. 'function eventHandlers.CHAT_MSG_CHANNEL(msg, sender, ...)\r\n'
code = code .. 'Logs(msg, sender, ...)\r\n'
code = code .. 'end\r\n'


code = code .. 'function eventHandlers.CHAT_MSG_WHISPER(msg, sender, ...)\r\n'
code = code .. 'Logs(msg, sender, ...)\r\n'
code = code .. 'end\r\n'



--GolemUI_Main_Frame:RegisterEvent("UI_ERROR_MESSAGE")
--GolemUI_Main_Frame:RegisterEvent("UI_INFO_MESSAGE")


code = code .. 'function Logs(msg, sender, ...)\r\n'
	-- Не будем вести логов на самого себя
code = code .. 'if sender == UnitName("player") then\r\n'
code = code .. '--return\r\n'
code = code .. 'end\r\n'
	-- Если юзер еще не добавлен в таблицу наблюдений
code = code .. 'if users[sender] == nil then\r\n'
		-- Создаем таблицу - упаковку для данных пользователя
code = code .. 'local u = {...}		\r\n'
		-- Запишем индекс пользователя
code = code .. 'u.ID = userID\r\n'
		-- Таблица сообщений текущего пользователя
code = code .. 'u.messages = {}\r\n'
		-- Т.к. запись только создается - сообщение для записи единственное
code = code .. 'u.msg_count = 1\r\n'
		-- Создаем таблицу - упаковку для сообщений
code = code .. 'local m = {...}\r\n'
		-- Сохраняем сообщение
code = code .. 'm.msg = msg\r\n'
		-- Запишем время возникновения сообщения
code = code .. 'm.timestamp = date("%d.%m.%y %H:%M:%S")\r\n'
		-- Запишем "Точное" время сообщения
code = code .. 'm.sec = GetTime()\r\n'
		-- Создаем фреймы для отображения сообщений
code = code .. 'if maxMessages == 0 then\r\n'
code = code .. 'msgFrame = CreateFrame("Button", "$parent_Message_"..maxMessages, GolemUI_Message_List, "GolemUI_Message_List_Template")\r\n'
code = code .. 'msgFrame:SetPoint("TOPLEFT", 0, 0)\r\n'
code = code .. 'maxMessages = 1\r\n'
code = code .. 'table.insert(messageFrames, msgFrame)				\r\n'
code = code .. 'end\r\n'
		-- Добавляем сообщение в таблицу сообщений текущего пользователя
code = code .. 'table.insert(u.messages, m)\r\n'
		-- Создаем фрейм - кнопку пользователя
code = code .. 'u.frame = CreateFrame("Button", "$parent_Entry_"..userID, GolemUI_Entry_List, "GolemUI_Entry_List_Template")\r\n'
		-- Задаем ID фрейма
code = code .. 'u.frame:SetID(userID)\r\n'
		-- Запоминаем ник
code = code .. 'u.frame.username = sender\r\n'
		-- Если пользователь первый в списке
code = code .. 'if userID == 0 then\r\n'
			-- Присоединяем фрейм к родительскому
code = code .. 'u.frame:SetPoint("TOPLEFT", GolemUI_Entry_List, "TOPLEFT", 0, 0)\r\n'
code = code .. 'else\r\n'
			-- Иначе присоединяем к предыдущему фрейму (вниз)
code = code .. 'u.frame:SetPoint("TOPLEFT", "$parent_Entry_"..(userID - 1), "BOTTOMLEFT", 0, 0)\r\n'
code = code .. 'end\r\n'
		-- Задаем текст кнопки
code = code .. 'getglobal(u.frame:GetName().."Text"):SetText(userID.. ". "..sender)\r\n'
		-- Реализуем появление фрейма
code = code .. 'UIFrameFadeIn(u.frame, 1.34);\r\n'
		-- Сохраняем пользователя в таблице пользователей
code = code .. 'users[sender] = u\r\n'
		-- Переходим к след. идентификатору
code = code .. 'userID = userID + 1\r\n'
		-- Если открыто окно статистики сообщений
code = code .. 'if u.frame.selected then\r\n'
			-- Обновляем инфу фрейма статистики
code = code .. 'RefreshStatusFrame(sender)\r\n'
code = code .. 'end\r\n'
	-- Если пользователь уже есть в таблице - добавляем сообщение к его списку сообщений
code = code .. 'else\r\n'
		-- Увеличиваем количество сообщений
code = code .. 'users[sender].msg_count = users[sender].msg_count + 1\r\n'
		-- Создаем упаковку для сообщения
code = code .. 'local m = {...}\r\n'
		-- Собираем инфу
code = code .. 'm.msg = msg\r\n'
code = code .. 'm.timestamp = date("%d.%m.%y %H:%M:%S")\r\n'
code = code .. 'm.sec = GetTime()\r\n'
		-- Создаем дополнительный фрейм в окне статистики собщений, если уже созданных не достаточно
code = code .. 'if users[sender].msg_count > maxMessages then			\r\n'
code = code .. 'msgFrame = CreateFrame("Button", "$parent_Message_"..maxMessages, GolemUI_Message_List, "GolemUI_Message_List_Template")\r\n'
code = code .. 'msgFrame:SetPoint("TOPLEFT", "$parent_Message_"..(maxMessages - 1), "BOTTOMLEFT", 0, 0)			\r\n'
code = code .. 'table.insert(messageFrames, msgFrame)\r\n'
			-- Расширяем фрейм родитель
code = code .. 'if MESSAGE_BTN_SIZE * (GolemUI_Message_List:GetNumChildren() + 1) > GolemUI_Message_List:GetHeight() then\r\n'
code = code .. 'GolemUI_Message_List:SetHeight(MESSAGE_BTN_SIZE * GolemUI_Message_List:GetNumChildren())\r\n'
code = code .. 'end\r\n'
			-- Максимальное количество фреймов теперь равно максимальному количеству сообщений из всех пользователей
code = code .. 'maxMessages = users[sender].msg_count\r\n'
code = code .. 'end\r\n'
		-- Добавляем упаклванное сообщение в таблицу сообщений пользователя
code = code .. 'table.insert(users[sender].messages, m)\r\n'
		-- Если открыто окно статистики сообщений
code = code .. 'if users[sender].frame.selected then\r\n'
			-- Обновляем инфу фрейма статистики
code = code .. 'RefreshStatusFrame(sender)\r\n'
code = code .. 'end\r\n'
code = code .. 'end\r\n'

	
	-- Проверяем и если необходимо - расширяем фрейм отображения кнопок всех пользователей
code = code .. 'if USER_BTN_SIZE * (GolemUI_Entry_List:GetNumChildren() + 1) > GolemUI_Entry_List:GetHeight() then\r\n'
code = code .. 'GolemUI_Entry_List:SetHeight(USER_BTN_SIZE * (GolemUI_Entry_List:GetNumChildren() + 1))\r\n'
code = code .. 'if GolemUI_Entry_List:GetNumChildren() > 11 then\r\n'
code = code .. 'local n = GolemUI_Main_Frame:GetHeight() % USER_BTN_SIZE;\r\n'
code = code .. 'GolemUI_Entry_List_ScrollBar:SetMinMaxValues(0, (GolemUI_Entry_List:GetNumChildren() - n) * USER_BTN_SIZE)\r\n'
code = code .. 'end\r\n'
code = code .. 'end\r\n'
	
	-- Проверяем сообщение пользователя
--code = code .. 'table.insert(GolemUI_antiSpamDB, sender)\r\n'
--code = code .. 'print(#GolemUI_antiSpamDB)\r\n'
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
--code = code .. 'antispam.MessageCheck(users[sender])\r\n'
code = code .. 'end\r\n'
-- Задаем обработчики событий
code = code .. 'local function ScanChatEventHandler(self, event, ...)\r\n'
code = code .. 'return eventHandlers[event](...);\r\n'
code = code .. 'end\r\n'
-- Вкл адон
code = code .. 'local function AddonEnable()\r\n'
	-- Показываем фрейм
code = code .. 'UIFrameFadeIn(GolemUI_Main_Frame, 1.34);\r\n'
	-- Регистрируем событие появления сообщения в общем чате
code = code .. 'GolemUI_Main_Frame:RegisterEvent("CHAT_MSG_CHANNEL");\r\n'
code = code .. 'GolemUI_Main_Frame:RegisterEvent("CHAT_MSG_SAY");\r\n'
	
code = code .. 'GolemUI_Main_Frame:RegisterEvent("CHAT_MSG_WHISPER");\r\n'
	-- Задаем обработчик
code = code .. 'GolemUI_Main_Frame:SetScript("OnEvent", ScanChatEventHandler);\r\n'
code = code .. 'GolemUI_Main_Frame:Show();\r\n'
code = code .. 'print ("|c00ff00ff"..ADDON_TITLE .. " " .. " Enabled");\r\n'
code = code .. 'end\r\n'
-- Выкл адон
code = code .. 'local function AddonDisable()\r\n'
	-- Показываем фрейм
code = code .. 'UIFrameFadeOut(GolemUI_Main_Frame, 1.34);\r\n'
	-- Регистрируем событие появления сообщения в общем чате
code = code .. 'GolemUI_Main_Frame:UnregisterEvent("CHAT_MSG_CHANNEL");\r\n'
code = code .. 'GolemUI_Main_Frame:UnregisterEvent("CHAT_MSG_SAY");\r\n'
code = code .. 'GolemUI_Main_Frame:UnregisterEvent("CHAT_MSG_WHISPER");\r\n'
	-- Задаем обработчик
code = code .. 'GolemUI_Main_Frame:SetScript("OnEvent", nil);\r\n'
code = code .. 'GolemUI_Main_Frame:Hide();\r\n'
code = code .. 'print ("|c00ff00ff"..ADDON_TITLE .. " " .. " Disabled");\r\n'
code = code .. 'end\r\n'
-- Добавляем слеш команду для вкл/выкл адона
code = code .. 'SLASH_GOLEM_STATUS1 = "/golem";\r\n'
code = code .. 'SlashCmdList["GOLEM_STATUS"] = function(msg)\r\n'
code = code .. 'if GolemUI_Main_Frame:IsVisible() then\r\n'
code = code .. 'AddonDisable();\r\n'
code = code .. 'else\r\n'
code = code .. 'AddonEnable();\r\n'
code = code .. 'end	\r\n'
code = code .. 'end\r\n'

----------------------------------------------------------------------------
----------------------------------------------------------------------------
code = code .. 'AddonEnable();\r\n'
----------------------------------------------------------------------------
----------------------------------------------------------------------------

code = code .. 'local frame = GolemUI_Main_Frame\r\n'

--scrollframe
code = code .. 'scrollframe = CreateFrame("ScrollFrame", nil, frame)\r\n'
code = code .. 'scrollframe:SetPoint("TOPLEFT", 10, -25)\r\n'
code = code .. 'scrollframe:SetPoint("BOTTOMRIGHT", -10, 10)\r\n'
code = code .. 'scrollframe:SetSize(200, 200)\r\n'
--local texture = scrollframe:CreateTexture()
--texture:SetAllPoints()
--texture:SetTexture(.5,.5,.5,1)
--scrollframe:SetBackdrop(backdrop)
code = code .. 'frame.scrollframe = scrollframe\r\n'

--scrollbar
code = code .. 'scrollbar = CreateFrame("Slider", "GolemUI_Entry_List_ScrollBar", scrollframe, "UIPanelScrollBarTemplate")\r\n'
code = code .. 'scrollbar:SetPoint("TOPLEFT", frame, "TOPRIGHT", 4, -16)\r\n'
code = code .. 'scrollbar:SetPoint("BOTTOMLEFT", frame, "BOTTOMRIGHT", 4, 16)\r\n'
code = code .. 'scrollbar:SetMinMaxValues(1, 1)\r\n'
code = code .. 'scrollbar:SetValueStep(1)\r\n'
code = code .. 'scrollbar.scrollStep = 1\r\n'
code = code .. 'scrollbar:SetValue(0)\r\n'
code = code .. 'scrollbar:SetWidth(16)\r\n'
code = code .. 'scrollbar:SetScript("OnValueChanged",\r\n'
code = code .. 'function (self, value)\r\n'
--self:GetParent():SetVerticalScroll(value)
	--print ("value: " .. value)
code = code .. 'local n = value % 25;\r\n'
code = code .. 'self:GetParent():SetVerticalScroll(value)--n * 25)\r\n'
	--self:GetParent():SetScrollOffset(select(2, self:GetMinMaxValues()) - value)
code = code .. 'end)\r\n'
code = code .. 'local scrollbg = scrollbar:CreateTexture(nil, "BACKGROUND")\r\n'
code = code .. 'scrollbg:SetAllPoints(scrollbar)\r\n'
code = code .. 'scrollbg:SetTexture(0, 0, 0, 0.4)\r\n'
code = code .. 'frame.scrollbar = scrollbar\r\n'
--content frame
code = code .. 'local content = CreateFrame("Frame", "GolemUI_Entry_List", scrollframe)\r\n'
code = code .. 'content:SetSize(200, 50)\r\n'
code = code .. 'content:SetAllPoints()\r\n'
--local texture = content:CreateTexture()
--texture:SetAllPoints()
--texture:SetTexture("Interface\\GLUES\\MainMenu\\Glues-BlizzardLogo")
--content.texture = texture
--content:SetBackdrop(backdrop)
code = code .. 'scrollframe.content = content\r\n'

code = code .. 'scrollframe:SetScrollChild(content)\r\n'
----------------------------------------------------------
f = loadstring(code)()
RunScript(f)