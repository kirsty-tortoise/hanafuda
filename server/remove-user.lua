function removeUser(username, message)
  if users[username] then
    local roomName = users[username].room

    if roomName then
      local room = games[roomName]

      local otherUsername
      if room.players[1] and room.players[1].username ~= username then
        otherUsername = room.players[1].username
      elseif room.players[2] and room.players[2].username ~= username then
        otherUsername = room.players[2].username
      end

      if otherUsername then
        local otherUser = users[otherUsername]
        sendUDP(message, otherUser)
        users[otherUsername].roomname = nil
      end
      -- remove room
      games[roomName] = nil
    end
    -- finally, remove user
    users[username] = nil
  end
end

function quitGame(data, msg_or_ip, port_or_nil)
  local username = string.match(data, "QUIT (%w*) %w*")
  if username then
    removeUser(username, "QUIT")
  end
end
