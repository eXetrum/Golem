Antispam = {...}
-- Таблица: сокр. название наказания = команда для выполнения
Antispam.PunishOptions = {
	["prod.gold"]			= ".ban pla %s [-1d] %s",
	["peklama"]				= ".ban pla %username% [-1d] %reason%=peklama",
	["moshennik"]			= ".ban pla %username% [-1d] %reason%=moshennik",
	["komm.d"]				= ".ban pla %username% [30d] %reason%=komm.d",
	["raspr.bagov"]			= ".ban pla %username% [30d] %reason%=raspr.bagov",
	["Ockadm/servera"]		= ".ban pla %username% [30d] %reason%=Ockadm/servera",
	["Moshennik"]			= ".ban pla %username% [30d] %reason%=Moshennik",
	["OckPod"]				= ".ban pla %username% [30d] %reason%=OckPod",
	["Ock po nacpriznaky"]	= ".ban pla %username% [30d] %reason%=Ock po nacpriznaky",
	["Obmen/prodaja2.3"]	= ".ban pla %username% [14d] %reason%=Obmen/prodaja2.3",
	["flood"]				= ".mute %username% [200] %reason%=flood",
	["caps"]				= ".mute %username% [60] %reason%=caps",
	["caps+flood"]			= ".mute %username% [260] %reason%=caps+flood",
	["mat"]					= ".mute %username% [200] %reason%=mat",
	["zav.mat"]				= ".mute %username% [60] %reason%=zav.mat",
	["OckIgr"]				= ".mute %username% [400] %reason%=OckIgr",
	["polit.propaganda"]	= ".mute %username% [400] %reason%=polit.propaganda",
	["SkillFlood"]			= ".mute %username% [1000] %reason%=SkillFlood"
 }
 
  Antispam.DetectOptions = {
	["word"]				= CheckEachWord,
	["substr"]				= "",
	["word&substr"]			= ""
 }
 
 function CheckEachWord(a, b, c)
	print("CheckEachWord:", a)
 end
 


Antispam.Rules = {
	--[word]		[detect option]						[punish option]
	["allah"] =		{detect = "substr", 			punish = "Ock po nacpriznaky"},
	["monah"] = 	{detect = "word", 				punish = "Ock po nacpriznaky"}
 }
 
 
 
function Antispam.ApplySanctions(userName, forbiddenWord)
	SendChatMessage("Выдать пиздюлину "..userName.." за слово |c00ff00ff["..forbiddenWord.."]|r", "SAY", nil, nil);
	SendChatMessage(antispam[forbiddenWord])
end

function Antispam.CheckFlood(usr)
	if usr.msg_count < 3 then return end
	
	--print((usr.messages[usr.msg_count].sec - usr.messages[usr.msg_count - 2].sec) )
	
	if (usr.messages[usr.msg_count].sec - usr.messages[usr.msg_count - 2].sec ) < MAX_MSG_TIME and
		usr.messages[usr.msg_count].msg == usr.messages[usr.msg_count - 1].msg and
		usr.messages[usr.msg_count].msg == usr.messages[usr.msg_count - 2].msg then
		
		--print("PIZDEC TEBE: "..usr.frame.username)
		local sz = usr.msg_count;
		local m = usr.messages;
		print((usr.messages[usr.msg_count].sec - usr.messages[usr.msg_count - 2].sec) )
		print("|c00ff0000 ["..m[sz - 2].sec.."]["..m[sz - 2].timestamp.."]"..m[sz - 2].msg.."|r")
		print("|c00ff0000 ["..m[sz - 1].sec.."]["..m[sz - 1].timestamp.."]"..m[sz - 1].msg.."|r")
		print("|c00ff0000 ["..m[sz].sec.."]["..m[sz].timestamp.."]"..m[sz].msg.."|r")
		PlaySoundFile("Sound\\Creature\\LordMarrowgar\\IC_Marrowgar_Slay02.wav")
		SendChatMessage("[flood detected] ["..usr.frame.username.."]", "SAY", nil, nil);
		
		--SendChatMessage("[flood detected] ["..usr.frame.username.."]", "CHANNEL", nil, GetChannelName("all"));
		SendChatMessage(".mute "..usr.frame.username.." 1 test", "SAY", nil, nil);
		
	end
		
	
	for k, v in pairs(usr.messages) do
		--print(k..")["..v.sec.."]["..v.timestamp.."] "..v.msg)
		
			
		
	end
end

function Antispam.CheckSpam(user, message)
	--local s = Antispam.PunishTable["prod.gold"]
	--print(string.format(s, user))
	message = string.lower(message)
	
	
	
	-- Проверяем весь месседж на подстроки
	for word, options in pairs(Antispam.Rules) do
		if options["detect"] == "substr" then
			if strfind(message, word) ~= nil then
				print("Найдена подстрока: ["..word.."], punish: "..options["punish"])
				--local f = Antispam.SubStrings[k]
				--local punishMethod = Antispam.SubStringsTable[k]
				--PunishTable[punishMethod](user)
				
				--
				return
			end
		end
		
		--local w = Antispam.DetectOptions[punish["detect"]]
		--print(w(user, _, _))
		
		
	end
	
	
	
	for word in string.gmatch(message, "[1234567890abcdefghijklmnopqrstuvwxyzrабвгдеёжзийклмнопрстуфхцчшщъьыэюяABCDEFGHIJKLMNOPQRSTUVWXYZRАБВГДЕЁЖЗИЙКЛМНОПРСТУФХЦЧШЩЪЬЫЭЮЯ]+") do
		--if Antispam.WordsTable[word] ~= nil then
			--SendChatMessage(".st", "SAY", nil, nil);
			--local punishMethod = Antispam.WordsTable[word];
			--print("USER: "..user..", MSG: "..message)
			--print("WORD: "..word)
			--PunishTable[punishMethod](user)
			--print("PUNISH: "..)
			break
		--end
		--print(w)
	end
	
	
end