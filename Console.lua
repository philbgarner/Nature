local Console = {
	x = 0
	,y = 0
	,w = 0
	,h = 0

	,titlebar = true
	,title = "Console"

	,lineheight = 15
	,linewidth = 0

	,textbuffer = {}
	,linebuffer = ""

	,close_scancode = "escape"
	,close_callback = function () return "" end

	,help_command = "help"
	,command_callback = function (command, args) return "No command controller callback has been set." end

	,cursor = {row = 1, col = 0}

	,background_col = {100, 100, 164, 126}
	,foreground_col = {241, 241, 241, 255}
	,color_red = {255, 0, 0, 255}
	,color_yellow = {255, 255, 0, 255}

	,font_size = 12
	,font = nil

	,anim_active = false
	,anim_x = 0
	,anim_y = 0

	,input_regexp = "[A-Za-z0-9., /\\{}()-=+|\"\'!@#$%^&*`~_<>?;:]"
}

function Console:create(closeCallback, commandCallback)

	Console.font = love.graphics.newFont("CourierCode-Roman.ttf", Console.font_size)

	Console.w = love.graphics.getWidth()
	Console.h = love.graphics.getHeight()
	Console.linewidth = Console.world

	if closeCallback ~= nil then Console.close_callback = closeCallback end
	if commandCallback ~= nil then Console.command_callback = commandCallback end

	return Console

end

function Console:newLine()
	Console.cursor.row = Console.cursor.row + 1
end

function Console:lineReturn()
	Console:newLine()
	Console.cursor.col = 1
end

function Console:lineFlush()

	local buff = Console.linebuffer

	table.insert(Console.textbuffer, {text = Console.linebuffer, color = Console.foreground_col})
	Console.linebuffer = ""
	Console:lineReturn()

	words = {}
	for word in string.gmatch(buff, "[a-zA-Z0-9_.]+") do table.insert(words, word) end

	args = {}
	for i=2, #words do table.insert(args, words[i]) end
	if words[1] ~= nil then
		local ret = Console.command_callback(words[1], args)
		if ret == nil then ret = "" end
		Console:write(ret)
	end

end

function Console:write(message, color)
	if color == nil then
		color = Console.foreground_col
	end
	table.insert(Console.textbuffer, {text = message, color = color})
	Console:newLine()
end

function Console:update(dt)
	

end

function Console:draw()

	local dy = 0

	love.graphics.setColor(Console.background_col[1], Console.background_col[2], Console.background_col[3], Console.background_col[4])
	love.graphics.rectangle("fill", Console.x, Console.y, Console.w, Console.h)
	
	local of = love.graphics.getFont()
	local nf = of
	if Console.font ~= nil then
		nf = Console.font
	end

	love.graphics.setFont(nf)
	for i=1, #Console.textbuffer do
		love.graphics.setColor(Console.foreground_col[1], Console.foreground_col[2], Console.foreground_col[3], Console.foreground_col[4])
		local line_no = string.format("%03d ", i)
		love.graphics.print(line_no, Console.x, dy)

		local line_no_width = nf:getWidth(line_no)
		love.graphics.setColor(Console.textbuffer[i].color[1], Console.textbuffer[i].color[2], Console.textbuffer[i].color[3], Console.textbuffer[i].color[4])
		local tx = Console.textbuffer[i].text
		if tx == nil then tx = "nil" end
		love.graphics.print(tx, Console.x + line_no_width, dy)
		local h = nf:getHeight(Console.textbuffer[i].text)
		dy = dy + h
	end

	love.graphics.setColor(Console.foreground_col[1], Console.foreground_col[2], Console.foreground_col[3], Console.foreground_col[4])
	local display = "~>" .. Console.linebuffer
	love.graphics.print(display, Console.x, dy)

	local cx = nf:getWidth(string.sub(display, 1, Console.cursor.col + 2))
	love.graphics.rectangle("line", cx + Console.x, dy + Console.lineheight, 2, -Console.lineheight)
	love.graphics.setFont(of)
end

function Console:mouseclick(x, y, button)



end

function Console:mousemove(x, y, button)

end

function Console:keyInput(key)

	if string.match(key, Console.input_regexp) then
		if #Console.linebuffer == Console.cursor.col then
			Console.linebuffer = Console.linebuffer .. key
		else
			Console.linebuffer = string.sub(Console.linebuffer, 1, Console.cursor.col) .. key .. string.sub(Console.linebuffer, Console.cursor.col + 1)
		end
		Console.cursor.col = Console.cursor.col + 1
	end

end

function Console:keypress(key, scancode)

	if scancode == "return" then
		Console:lineFlush()
	elseif scancode == "left" then
		Console.cursor.col = Console.cursor.col - 1
		if Console.cursor.col < 0 then Console.cursor.col = 0 end
	elseif scancode == "right" then
		Console.cursor.col = Console.cursor.col + 1
		if Console.cursor.col > #Console.linebuffer then Console.cursor.col = #Console.linebuffer end
	elseif scancode == "backspace" then
		if #Console.linebuffer == Console.cursor.col then
			Console.linebuffer = string.sub(Console.linebuffer, 1, Console.cursor.col - 1)
		else
			Console.linebuffer = string.sub(Console.linebuffer, 1, Console.cursor.col - 1) .. string.sub(Console.linebuffer, Console.cursor.col + 1)
		end

		Console.cursor.col = Console.cursor.col - 1
		if Console.cursor.col < 0 then Console.cursor.col = 0 end
	elseif scancode == Console.close_scancode then
		Console.close_callback()
	end

	return false

end

return Console