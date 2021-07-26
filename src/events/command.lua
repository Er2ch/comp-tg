return function(C, api, msg)
  local cmd = C.cmds[msg.cmd]
  local owner = msg.from.id == C.config.owner

  if cmd == nil then
    api:send(msg, C.locale:get('error', 'inv_cmd'))

  elseif type(cmd.run) ~= 'function' then
    api:send(msg, C.locale:get('error', 'cmd_run'))

  elseif cmd.private and not owner then
    api:send(msg, C.locale:get('error', 'adm_cmd'))

  else
    msg.loc = C.locale:get('cmds', msg.cmd)
    local succ, err = pcall(cmd.run, C, msg, owner)
    if not succ then
      print(err)
      local cid = C.config.owner
      api:forward(cid, msg.chat.id, msg.message_id, false)
      api:send(cid, err)
      api:reply(msg, msg.locale.error.not_suc)
    end
  end
end