os.loadAPI("ui")

pinScreen = class.class(ui.screen, function(self, monitor, validPins, foundValidPin)
			ui.screen.init(self, monitor)
			self.pin = ""
			self.pinDisplayText = "----"
			
			self.validPins = validPins
			self.foundValidPin = foundValidPin
			
			local buttons = {}
			buttons[0] = {"0", 2,15}
			buttons[1] = {"1", 2,11}
			buttons[2] = {"2", 9,11}
			buttons[3] = {"3",16,11}
			buttons[4] = {"4", 2, 7}
			buttons[5] = {"5", 9, 7}
			buttons[6] = {"6",16, 7}
			buttons[7] = {"7", 2, 3}
			buttons[8] = {"8", 9, 3}
			buttons[9] = {"9",16, 3}
			for i, v in pairs(buttons) do
				local button = ui.button(v[1], function(button) self:pinClickEvent(button) end, i)
				button:setPos(v[2], v[3]):setSize(5, 3)
				self:addControl(button)
			end
			
			self.pinDisplay = ui.text("PIN: ----", 22, 3)
			self:addControl(self.pinDisplay)
		end)
		
function pinScreen:pinClickEvent(button)
	self.pin = self.pin .. button.tag
	local pinLength = string.len(self.pin)
	if pinLength == 4 then
		self:validatePin()
	else
		self.pinDisplayText = string.rep("*", pinLength-1) .. button.tag .. string.rep("-", 4-pinLength)
	end
end

function pinScreen:draw()
	self.pinDisplay:setText("PIN: ".. self.pinDisplayText)
	self._base.draw(self)
	
end

function pinScreen:onFoundValidPin(pin)
	if self.foundValidPin ~= nil then
		self.foundValidPin(pin)
	end
end

function pinScreen:validatePin()
	local isValid = false
	for i,v in ipairs(self.validPins) do
		if(v == self.pin) then
			isValid = true
			self:onFoundValidPin(v)
			break
		end
	end
	
	if not isValid then
		self.pin = ""
		self.pinDisplayText = ""
	end
end