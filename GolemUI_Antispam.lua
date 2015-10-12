Antispam = {...}
-- Таблица: сокр. название наказания = команда для выполнения
Antispam.PunishOptions = {
	["prod.gold"]			= ".ban pla %s -1d prod.gold",
	["peklama"]				= ".ban pla %s -1d speklama",
	["moshennik"]			= ".ban pla %s -1d moshennik",
	["komm.d"]				= ".ban pla %s 30d komm.d",
	["raspr.bagov"]			= ".ban pla %s 30d raspr.bagov",
	["Ockadm/servera"]		= ".ban pla %s 30d Ockadm/servera",
	["OckPod"]				= ".ban pla %s 30d OckPod",
	["Ock po nacpriznaky"]	= ".ban pla %s 30d Ock po nacpriznaky",
	["Obmen/prodaja2.3"]	= ".ban pla %s 14d Obmen/prodaja2.3",
	
	
	["mat"]					= ".mute %s 200 mat",
	["flood"]				= ".mute %s 200 flood",	
	["caps"]				= ".mute %s 60 caps",	
	["caps+flood"]			= ".mute %s 260 caps+flood",
	["caps+mat"]			= ".mute %s 260 caps+mat",	
	["flood+mat"]			= ".mute %s 400 flood+mat",
	["caps+flood+mat"]		= ".mute %s 460 caps+flood+mat",
	
	
	["zav.mat"]				= ".mute %s 60 zav.mat",
	["OckIgr"]				= ".mute %s 400 OckIgr",
	["polit.propaganda"]	= ".mute %s 400 polit.propaganda",
 }
 
 
 Antispam.BadWords = {
	"хуй",
	"нахуй",
	"пизда", 
	"джигурда",
	"лох",
	"сука",
	"паскуда",
	"уебок",
	"уебывай",
	"уебан",
	"ебал",
	"заебал",
	"выебал",
	"ебля",
	"бля",
}

Antispam.Sellers = {
	"club91913726",
	"club50642399",
	"club99832475",
	"club102765330",
	"vk.com/wow.gold60",
	"isgold.ru",
	"newsalecircle.besaba.com",
	"vk.com/wowcirclegameslolz",
	"vk.com/gold_751",
	"vk.com/itemshopc",
	"Fraksol",
	"The_beacp_ep",
	"dima.fedosov96",
	"Goldmen322",
	"ro_m_an-s",
	"pandagold"
}

Antispam.Advertisers = {
	"Quantumwow",
	"aiveka.com",
	"SKREAMWOW.RU",
	"River.Rise.ru",
	"riverrise.ru",
	"wowbaks.ru",
	"ms-w/ow.ru"
}

Antispam.AbuseText = {
	"енот est kompot",
	"salo ежа"
}

Antispam.replaceTable = {
	"{звезда}", 		--желтая звезда
	"{круг}", 			--оранжевый круг
	"{ромб}", 			--розовый ромб
	"{треугольник}", 	--зелёный треугольник
	"{полумесяц}",		--светло-голубой полумесяц
	"{квадрат}",		--синий квадрат
	"{крест}",			--красный квадрат
	"{череп}"			--белый череп
}

local sound = {
	-- "Сгииинь, в вечных муках"
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
}

local function chsize(char)
    if not char then
        return 0
    elseif char > 240 then
        return 4
    elseif char > 225 then
        return 3
    elseif char > 192 then
        return 2
    else
        return 1
    end
end

local function utf8sub(str, startChar, numChars)
  local startIndex = 1
  while startChar > 1 do
      local char = string.byte(str, startIndex)
      startIndex = startIndex + chsize(char)
      startChar = startChar - 1
  end
 
  local currentIndex = startIndex
 
  while numChars > 0 and currentIndex <= #str do
    local char = string.byte(str, currentIndex)
    currentIndex = currentIndex + chsize(char)
    numChars = numChars -1
  end
  return str:sub(startIndex, currentIndex - 1)
end

function utf8split(str)
 local utf8table = {}
 str:gsub("([^\128-\191][\128-\191]*)",function(char) 
 local leadbyte = strbyte(char, 1)
 local length = -1
 
 if leadbyte < 248 then
 if leadbyte >= 240 then length = 4
 elseif leadbyte >= 224 then length = 3
 elseif leadbyte >= 192 then length = 2
 elseif leadbyte < 128 then length = 1
 end
 end

 tinsert(utf8table, (length == #char) and char)
 end)
 return utf8table
end
function inTable(t, s)
	for k, v in pairs(t) do
		if v == s then return true end
	end
	return false
end
mask = utf8split("abcdefghijklmnopqrstuvwxyzrабвгдеёжзийклмнопрстуфхцчшщъьыэюяABCDEFGHIJKLMNOPQRSTUVWXYZRАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЬЫЭЮЯ")

local function IsCaps(str)
	local sz = strlenutf8(str)
	if sz < CAPS_MIN_MSG_LEN then return false end
	local c = 0
	local n = 0
	for i = 1, sz do
		s = utf8sub(str, i, 1 );
		u = string.upper(s)			
		if inTable(mask, s) then
			n = n + 1
			if s == u then c = c + 1 end
		end
	end
	return (c / n * 100) >= CAPS_PERCENT, c, n
end

local function ContainBadWords(message)
	for word in string.gmatch(message, "[1234567890abcdefghijklmnopqrstuvwxyzrабвгдеёжзийклмнопрстуфхцчшщъьыэюяABCDEFGHIJKLMNOPQRSTUVWXYZRАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЬЫЭЮЯ]+") do
		if inTable(Antispam.BadWords, string.lower(word)) then return true, word end
	end
	return false, nil
end

function utf8find(str, ch, k)

	k = k or 1
	
	for i = k, strlenutf8(str) do
		local si = utf8sub(str, i, 1)
		if strbyte(si) == strbyte(ch) then return i end
	end	
	return nil
end
-- Тестовая функция определения возможности построения заданного слова из набора символов сообщения
function CanConstruct(message, word)	
	for i = 1, #Antispam.replaceTable do
		message = string.gsub(message, Antispam.replaceTable[i], " ")
	end
	
	msgSize = strlenutf8(message)
	wordSize = strlenutf8(word)
	if msgSize < wordSize then return false end
	
	--msgTable = utf8split(message)
	local k = 1
	local pos = -1
	for i = 1, wordSize do
		s = utf8sub(word, i, 1)
		--print(i.." " .. s)
		--pos = string.find(message, s, k)
		pos = utf8find(message, s, k)
		
		--print("s: [" ..s.. "] k: ".. k.. " pos: " .. tostring(pos))
		
		if (pos == nil) or (pos < k) then return false end
		--local n = pos - k - 1
		--local sep = utf8sub(message, k + 1, n)
		--items = utf8split( sep )
		--flags = {}
		--local unique_chars = 0
		--local unique_mask_chars = 0
		--for j = 1, #items do
		--	if not flags[items[j]] then
		--		flags[items[j]] = true
		--		if inTable(mask, items[j]) then unique_mask_chars = unique_mask_chars + 1 end
		--		unique_chars = unique_chars + 1
		--	end
		--end
		
		--print("char: ["..s.."], sep: " .. sep .. ", unique_chars: " .. unique_chars.. ", unique_mask_chars: " .. unique_mask_chars)
		--print("separator chars: " .. utf8sub(message, k + 1, n))--tostring(pos - k - 1))
		
		--if unique_mask_chars > COMPOUND_SENSETIVITY then return false end
		k = pos
	end
	return true
end

function Antispam.MessageCheck(usr)
	text = usr.messages[usr.msg_count].msg
	for i = 1, #Antispam.replaceTable do
		text = string.gsub(text, Antispam.replaceTable[i], "")
	end
	-- Prodavci
	for i, seller in pairs(Antispam.Sellers) do
		--if CanConstruct(msg, v) then
		if string.find(text, seller) ~= nil then
			Screenshot();
			PlaySoundFile(sound[math.random(1, #sound)])
			print("|c00ff0000 [Seller detected] |r")
			print(string.format("|c0000ff00 %-22s:|r|c000000ff %-32s|r", "Игрок", usr.frame.username))				
			SendChatMessage(string.format(Antispam.PunishOptions["prod.gold"], usr.frame.username), "SAY", nil, nil);
			return;
		end
	end
	-- Reklama
	for i, advertiser in pairs(Antispam.Advertisers) do
		--if CanConstruct(msg, v) then
		if string.find(text, advertiser) ~= nil then
			Screenshot();
			PlaySoundFile(sound[math.random(1, #sound)])
			print("|c00ff0000 [Advertiser detected] |r")
			print(string.format("|c0000ff00 %-22s:|r|c000000ff %-32s|r", "Игрок", usr.frame.username))				
			SendChatMessage(string.format(Antispam.PunishOptions["reklama"], usr.frame.username), "SAY", nil, nil);				
			return;
		end
	end
	-- Polnoe predlojenie
	for i, j in pairs(Antispam.AbuseText) do
		if usr.messages[usr.msg_count].msg == j then
			Screenshot();
			PlaySoundFile(sound[math.random(1, #sound)])
			print("|c00ff0000 [AbuseText detected] |r")
			print(string.format("|c0000ff00 %-22s:|r|c000000ff %-32s|r", "Игрок", usr.frame.username))				
			---------------------------------------------------------------------------------------------
			---------------------------------------------------------------------------------------------
			---------------------------------------------------------------------------------------------
			---------------------------------------------------------------------------------------------
			SendChatMessage("Чето пизданул ["..usr.frame.username.."] не то", "SAY", nil, nil);			
			---------------------------------------------------------------------------------------------
			---------------------------------------------------------------------------------------------
			---------------------------------------------------------------------------------------------
			---------------------------------------------------------------------------------------------			
			--SendChatMessage(string.format(Antispam.PunishOptions["reklama"], usr.frame.username), "SAY", nil, nil);				
			return;
		end
	end
	
	-- Проверяем на капс
	caps, c, n = IsCaps(usr.messages[usr.msg_count].msg)
	-- Проверяем на содержание запрещенных слов
	mat, w = ContainBadWords(usr.messages[usr.msg_count].msg)	
	
	if caps and mat then
		Screenshot();
		PlaySoundFile(sound[math.random(1, #sound)])
		print("|c00ff0000 [CAPS + MAT] detected |r")
		print(string.format("|c0000ff00 %-22s:|r|c000000ff %-32s|r", "Игрок", usr.frame.username))
		print(string.format("|c0000ff00 %-17s:|r|c000000ff %-32s|r", "Total len", n))
		print(string.format("|c0000ff00 %-16s:|r|c000000ff %-32s|r", "Capitalized", c))
		print(string.format("|c0000ff00 %-13s:|r|c000000ff %-32s|r", "CAPS percent", (c / n * 100)))
		print(string.format("|c0000ff00 %-18s:|r|c00ff0000 %-32s|r", "MAT", w))
		SendChatMessage(string.format(Antispam.PunishOptions["caps+mat"], usr.frame.username), "SAY", nil, nil);						
		--SendChatMessage(string.format(Antispam.PunishOptions["caps+mat"], usr.frame.username), "CHANNEL", nil, GetChannelName("all"));
		return;
	end
	if caps then
		Screenshot();
		PlaySoundFile(sound[math.random(1, #sound)])
		print("|c00ff0000 [CAPS] detected |r")
		print(string.format("|c0000ff00 %-22s:|r|c000000ff %-32s|r", "Игрок", usr.frame.username))
		print(string.format("|c0000ff00 %-17s:|r|c000000ff %-32s|r", "Total len", n))
		print(string.format("|c0000ff00 %-16s:|r|c000000ff %-32s|r", "Capitalized", c))
		print(string.format("|c0000ff00 %-13s:|r|c000000ff %-32s|r", "CAPS percent", (c / n * 100)))
		SendChatMessage(string.format(Antispam.PunishOptions["caps"], usr.frame.username), "SAY", nil, nil);		
		--SendChatMessage(string.format(Antispam.PunishOptions["caps"], usr.frame.username), "CHANNEL", nil, GetChannelName("all"));
		return;
	end
	if mat then
		Screenshot();
		PlaySoundFile(sound[math.random(1, #sound)])
		print("|c00ff0000 [MAT] detected |r")
		print(string.format("|c0000ff00 %-22s:|r|c000000ff %-32s|r", "Игрок", usr.frame.username))
		print(string.format("|c0000ff00 %-17s:|r|c00ff0000 %-32s|r", "MAT", w))
		SendChatMessage(string.format(Antispam.PunishOptions["mat"], usr.frame.username), "SAY", nil, nil);		
		--SendChatMessage(string.format(Antispam.PunishOptions["mat"], usr.frame.username), "CHANNEL", nil, GetChannelName("all"));
		return
	end
	-- Секция проверки флуда
	if usr.msg_count < 3 then return end
	
	if (usr.messages[usr.msg_count].sec - usr.messages[usr.msg_count - 2].sec ) < MAX_MSG_TIME and
		usr.messages[usr.msg_count].msg == usr.messages[usr.msg_count - 1].msg and
		usr.messages[usr.msg_count].msg == usr.messages[usr.msg_count - 2].msg then
		
		Screenshot();
		PlaySoundFile(sound[math.random(1, #sound)])
		--TakeScreenshot();
		--isConnected = UnitIsConnected("unit")		
		local sz = usr.msg_count;
		local m = usr.messages;
		
		print("|c00ff0000 [flood detected] |r")
		print("|c0000ff00 Игрок: |r|c000000ff"..usr.frame.username.."|r")
		print("|c0000ff00 Время между сообщениями: "..(usr.messages[usr.msg_count].sec - usr.messages[usr.msg_count - 2].sec).."|r" )		
		print("|c00ff0000 Лог сообщений: |r")
		print("|c00ff0000 ["..m[sz - 2].sec.."]["..m[sz - 2].timestamp.."]"..m[sz - 2].msg.."|r")
		print("|c00ff0000 ["..m[sz - 1].sec.."]["..m[sz - 1].timestamp.."]"..m[sz - 1].msg.."|r")
		print("|c00ff0000 ["..m[sz].sec.."]["..m[sz].timestamp.."]"..m[sz].msg.."|r")
		
		SendChatMessage(string.format(Antispam.PunishOptions["flood"], usr.frame.username), "SAY", nil, nil);		
		--SendChatMessage(string.format(Antispam.PunishOptions["flood"], usr.frame.username), "CHANNEL", nil, GetChannelName("all"));
	end
end