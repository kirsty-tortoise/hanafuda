function sendStartingGameState(firstPlayer, game)
  -- Format:
  -- !handaschars!playareaaschars!numberofcardsopponenthas!
  -- All cards are one digit long, so the client just gets a string of them.
  local nhand = 0
  local nopponent = 0
  local handchars = ''
  local playchars = ''
  local user
  if firstPlayer then
    nhand = #game.hand1
    nopponent = #game.hand2
    handchars = handAsChars(game.hand1,nhand)
    user = game.players[1]
  else
    nhand = #game.hand2
    nopponent = #game.hand1
    handchars = handAsChars(game.hand2,nhand)
    user = game.players[2]
  end
  nplay = #game.playArea
  playchars = handAsChars(game.playArea, nplay)
  sendUDP("!"..handchars.."!"..playchars.."!"..nopponent.."!", user)
end

function createNewGame(roomname, users)
  -- Set up a game
  local h1 = {}
  local h2 = {}
  local p = {}
  local d = {}
  -- Flatten the deck.
  for i=1,12 do
    for j=1,4 do
      table.insert(d,cards[i][j])
    end
  end
  d = randSort(d) -- Okay, deck is randomised.
  for i=1,8 do
    table.insert(h1, table.remove(d,1))
    table.insert(h2, table.remove(d,1))
    table.insert(p, table.remove(d,1))
  end
  games[roomname] = {roomname = roomname, deck = d, hand1 = h1, hand2 = h2, playArea = p, score1 = {}, score2 = {},  players = users, mode="h1", lastScore = {0, 0}, multipliers = {1, 1}}
end

function processNewUser(data, msg_or_ip, port_or_nil)
  local username = string.match(data, "@(%w+)")
  if username and not users[username] then
    users[username] = {username = username, ip = msg_or_ip, port = port_or_nil}
    sendUDP("#", users[username])
  else
    sendUDP("@", {ip = msg_or_ip, port = port_or_nil})
  end
end

function processRoomChoice(data, msg_or_ip, port_or_nil)
  -- Create a new room.
  -- Here, get the username and roomname from data (#roomname@username), and do the right stuff. Then we win?
  local newroomname, newusername = string.match(data,"^#(%w+)@(%w+)$")
  local istaken = false
  if not (newroomname and newusername) then
    -- if the message is just not right, send them back to try again
    if string.match(data, "^#(.*)@(%w+)$") then -- proper username, no room
      sendUDP("#", {ip = msg_or_ip, port = port_or_nil})
      print("Roomname not correct")
    else
      sendUDP("@", {ip = msg_or_ip, port = port_or_nil})
    end
    istaken = true
  elseif not users[newusername] then
    -- they somehow haven't registered yet
    sendUDP("@", {ip = msg_or_ip, port = port_or_nil})
  elseif games[newroomname] then
    local game = games[newroomname]
    if #(game.players) == 1 then
      users[newusername].room = newroomname
      table.insert(game.players, users[newusername])
      -- Tell player 1 to leave waiting area
      sendStartingGameState(true, game)
      -- Tell player 2 they were successful
      sendStartingGameState(false, game)
    else
      print("Room too full")
      sendUDP("#", {ip = msg_or_ip, port = port_or_nil})
    end
  else
    -- create a new game
    users[newusername].room = newroomname
    createNewGame(newroomname, {users[newusername]})
    sendUDP("&", users[newusername])
  end
end

function handAsChars(cards, number)
  local chars = ''
  for i=1,number do
    chars = chars .. cards[i].charVal
  end
  return chars
end
