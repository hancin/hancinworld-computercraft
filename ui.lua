os.loadAPI("class")

-- Screen
screen = class.class(function(self, monitor)
			self.monitor = monitor
			self.drawables = {}
			self.clickables = {}
		end)

function screen:addDrawable(component)
	if component == nil then
		class.debug("[Screen] Not adding nil drawable.")
		return self
	end
	local i = #self.drawables + 1
	self.drawables[i] = component
	
	return self
end

function screen:addClickable(component)
	if component == nil then
		class.debug("[Screen] Not adding nil clickable.")
		return self
	end
	local i = #self.clickables + 1
	self.clickables[i] = component
	
	return self
end

function screen:addControl(component)
	self:addDrawable(component)
	self:addClickable(component)
	return self
end

function screen:handleClickEvent(x, y)
	local arrLength = #self.clickables
	local handled = false
	for i=1, arrLength do
		handled = self.clickables[i]:handleClickEvent(x, y)
		if handled then
			break
		end
	end
	
	return handled
end

function screen:draw()
	local arrLength = #self.drawables
	for i=1, arrLength do
		self.drawables[i]:draw(self.monitor)
	end
end

-- Program 
program = class.class(function(self, monitor)
			self.screen = nil
			self.monitor = monitor
		end)

function program:screen()
	return self.screen
end

function program:setScreen(value)
	self.screen = value
	return self
end

function program:draw()
	self.monitor.setBackgroundColor(colors.black)
	self.monitor.setTextColor(colors.white)
	self.monitor.clear()
	if self.screen ~= nil then
		self.screen:draw()
	end
end
function program:waitEvent()
	local e,side,x,y = os.pullEvent("monitor_touch")
	local handled = false
	if self.screen ~= nil then
		handled = self.screen:handleClickEvent(x,y)
	end
	if not handled then
		class.debug(string.format("[Program] Unhandled click event at %d, %d", x, y))
	end
end

-- Button
button = class.class(function(self, text, clickEvent, tag)
            self.text = text
			self.x = 0
			self.y = 0
			self.width = 1
			self.height = 1
			self.paddedText = text
			self.emptyRow = ""
			self.tag = tag
			self.clickEvent = clickEvent
			self.isDisabled = false
		end)

function button:pos()
	return self.x, self.y
end

function button:tag()
	return self.tag
end

function button:setTag(value)
	self.tag = value
	return self
end

function button:isDisabled()
	return self.isDisabled
end

function button:setIsDisabled(value)
	self.isDisabled = value
	return self
end

function button:handleClickEvent(x, y)
	local hitX = x >= self.x and x <= self.x + self.width
	local hitY = y >= self.y and y <= self.y + self.height
	if hitX and hitY then
		class.debug(string.format("[Button] Button with name %q at position %d, %d was clicked!", self.text, self.x, self.y))
		if self.isDisabled == false and self.clickEvent ~= nil then
			local data = {}
			data.x = x
			data.y = y
			self.clickEvent(self, data)
		end
		return true
	end
	
	return false
end

function button:text()
	return self.text
end

function button:setText(text)
	self.text = text
	self:updateTextData()
	return self
end

function button:setPos(x, y)
	self.x = x
	self.y = y
	return self
end

function button:updateTextData()
	local missingLength = self.width - string.len(self.text);
	if missingLength < 0 then
		self.paddedText = self.text
		class.debug("[Button] Error, text too big for button")
	else
		local beg = math.floor(missingLength / 2)
		self.paddedText = string.rep(" ", beg) .. self.text .. string.rep(" ", missingLength - beg)
	end
	if self.height > 1 then
		self.emptyRow = string.rep(" ", self.width)
	end
end

function button:setSize(width, height)
	if width < 1 or height < 1 then
		class.debug("[Button] Error, invalid size")
		return self;
	end
	self.width = width
	self.height = height
	
	self:updateTextData()
	
	return self
end

function button:draw(mon)
	if self.isDisabled then
		mon.setBackgroundColor(colors.gray)
		mon.setTextColor(colors.lightGray)
	else
		mon.setBackgroundColor(colors.red)
		mon.setTextColor(colors.white)
	end
	local yText = math.floor(self.height / 2 + self.y)
	
	for y = self.y, self.y+self.height-1 do
		mon.setCursorPos(self.x, y)
		if y == yText then
			mon.write(self.paddedText)
		else
			mon.write(self.emptyRow)
		end
	end
	
	return self
end

-- Text
text = class.class(function(self, text, x, y)
			self.x = x
			self.y = y
			self.text = text
		end)

function text:text()
	return self.text
end

function text:setText(value)
	self.text = value
	return self
end

function text:pos()
	return self.x, self.y
end

function text:setPos(x, y)
	self.x = x
	self.y = y
	return self
end

function text:handleClickEvent(x, y)
	return false
end

function text:draw(mon)
	mon.setBackgroundColor(colors.black)
	mon.setTextColor(colors.white)
	mon.setCursorPos(self.x, self.y)
	mon.write(self.text)
end