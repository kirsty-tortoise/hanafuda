chooseRoom = {}
roomname = ""

function chooseRoom.draw()
  love.graphics.setColor(0,0,0)
  love.graphics.setFont(largefont)
  love.graphics.printf("Please enter a room name!",100,100,love.graphics.getWidth()-200,"center")
  love.graphics.printf(roomname,100,300,love.graphics.getWidth()-200,"center")
  love.graphics.setFont(midfont)
  love.graphics.printf(errormsg,100,500,love.graphics.getWidth()-200,"center")
  return chooseRoom
end

function chooseRoom.textinput(t)
  roomname = roomname .. t
  return chooseRoom
end

function chooseRoom.keypressed(key)
  if key == "backspace" then
    local byteoffset = utf8.offset(roomname, -1)
    if byteoffset then
      roomname = string.sub(roomname, 1, byteoffset - 1)
    end
  elseif key == "return" then
    udp:send("#"..roomname.."@"..username)
  end
  return chooseRoom
end

function chooseRoom.acceptMessage(data, msg)
  if data:sub(1,1) == "!" then
    setUpGame(data, false)
    return gameHandWait
  elseif data:sub(1,1) == "&" then
    return waiting
  elseif string.sub(data,1,1) == "@" then
    errormsg = "Username already used or no valid username entered"
    return login
  elseif string.sub(data,1,1) == "#" then
    errormsg = "Room in use or no valid room entered."
    return chooseRoom
  end
  return chooseRoom
end
