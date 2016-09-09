availableRooms = {}

function lobbySetup(data)
  availableRooms = {}
  for roomname, username in string.gmatch(data, "#(%w+)@(%w+)") do
    table.insert(availableRooms, {username = username, roomname = roomname})
  end
end
