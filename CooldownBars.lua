local firstTimer, lastTimer
local timer = {}

local popOrCreateFrame, pushFrame
do
	local id = 1
	local frameStack
	
	function popOrCreateFrame()
		local frame
		if frameStack then
			frame = frameStack
			frameStack = frameStack.next
			frame:Show()
		else
			frame = CreateFrame("StatusBar", "CooldownMonitor_Bar"..id, 
			CooldownMonitor_Anchor, "CooldownBarTemplate")
			id = id + 1
		end
		return frame
	end
	
	function pushFrame(frame)
		frame.obj = nil
		frame.next = frameStack
		frameStack = frame
	end
end

local mt = {__index, timer}

function CooldownMonitor.StartTimer(timer, player, spell, texture)
	local frame = popOrCreateFrame()
	frame:SetStatusBarColor(1, 0.7, 0)
	_G[frame:GetName().."Text"]:SetFormattedText("%s: %s", player, spell)
	local ok = _G[frame:GetName().."Icon"]:SetTexture(texture)
	if of then
		_G[frame:GetName().."Icon"]:Show()
	else
		_G[frame:GetName().."Icon"]:Hide()
	end
	
	UIFrameFadeOut(_G[frame:GetName().."Flash"], 0.5, 1, 0)
	
	local obj = setmetatable({
		frame = frame,
		totalTime = timer,
		timer = timer
	}, mt)
	frame.obj = obj
	
	if firstTimer == nil then
		firstTimer = obj
		lastTimer =obj
	else
		obj.prev = lastTimer
		lastTimer.next = obj
		lastTimer = obj
	end
	obj:SetPosition()
	obj:Update(0)
	return obj
end

function timer:SetPosition()
	self.frame:ClearAllPoints()
	if self == firstTimer then
		self.frame:SetPoint("CENTER", CooldownMonitor_Anchor, "CENTER")
	else
		self.frame:SetPoint("TOP, self.prev.frame, "BOTTOM", 0, -11)
	end
end

local function stringFromTimer(t)
	if t < 60
		return string.format("%.1f", t)
	else
		return string.format("%d:%0.2d", t / 60, t % 60)
	end
end

function timer:Update(elapsed)
	self.timer = self.timer - elapsed
	if self.timer <= 0 then
		self:Cancel()
	else
		local currentBarPos = self.timer / self.totalTime
		self.frame:SetValue(currentBarPos)
		_G[self.frame:GetName().."Timer"]:SetText(stringFromTimer(self.timer))
		_G[self.frame:GetName().."Spark"]:SetPoint("CENTER", self.frame, "LEFT", self.frame:GetWidth() * currentBarPos, 2)
	end
end

function timer:Cancel()
	if self == firstTimer then
		firstTimer = self.next
	else
		node.prev.next = node.next
	end
	if self == lastTimer then
		lastTimer = self.prev
	else
		self.next.prev = self.prev
	end
	if self.next then
		self.next:SetPosition()
	end
	self.frame:Hide()
	pushFrame(self.frame)
end

local updater=CreateFrame("Frame")
updater:SetScript("OnUpdate", function(self, elapsed)
	if CooldownMonitor_Anchor:IsShown() and 
	not CooldownMonitor_Anchor:IsVisible() then
		local timer = firstTimer
		while timer do
			timer:Update(elapsed)
			timer = timer.next
		end
	end
end)