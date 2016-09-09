login = {}
username = ""

function login.draw()
  love.graphics.setColor(0,0,0)
  love.graphics.setFont(largefont)
  love.graphics.printf("Please enter a username!",100,100,love.graphics.getWidth()-200,"center")
  love.graphics.printf(username,100,300,love.graphics.getWidth()-200,"center")
  love.graphics.setFont(midfont)
  love.graphics.printf(errormsg,100,500,love.graphics.getWidth()-200,"center")
  return login
end

function login.textinput(t)
  username = username .. t
  return login
end

function login.keypressed(key)
  if key == "backspace" then
    local byteoffset = utf8.offset(username, -1)
    if byteoffset then
      username = string.sub(username, 1, byteoffset - 1)
    end
  elseif key == "return" then
    udp:send("@"..username)
  end
  return login
end

function login.acceptMessage(data, msg)
  if string.sub(data,1,1) == "@" then
    errormsg = "Username already used or no valid username entered"
  elseif string.sub(data, 1, 1) == "#" then
    return chooseRoom
  end
  return login
end
