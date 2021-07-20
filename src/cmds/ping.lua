return {
  desc = 'ping pong',
  run = function(C, msg)
    C.api:send(msg, 'Pong! ' .. (os.time() - msg.date) .. 's')
  end
}