return {
  hide = true,
  run = function(C, msg)
    C.api:reply(msg, msg.loc.msg)
  end
}
