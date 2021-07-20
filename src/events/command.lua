return function(C, api, msg)
  local cmd = C.cmds[msg.cmd]
  local owner = msg.from.id == C.config.owner
  if cmd == nil then
    api:send(msg, 'Invaid command provided.')

  elseif type(cmd.run) ~= 'function' then
    api:send(msg, 'Command cannot be executed.')

  elseif cmd.private and not owner then
    api:send(msg, 'You can\'t execute private commands!')

  else
    local succ, err = pcall(cmd.run, C, msg, owner)
    if not succ then
      api:reply(msg, 'Произошла ошибочка, которая была отправлена создателю')
      print(err)
      local cid = C.config.owner
      api:forward(cid, msg.chat.id, msg.message_id, false)
      api:send(cid, err)
    end
  end
end