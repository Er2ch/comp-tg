return {
  run = function(C, msg)
    C.api:send(msg, msg.loc.pat:format(os.time() - msg.date))
  end
}