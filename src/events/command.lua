return function(C, api, msg)
  local cmd = C.cmds[msg.cmd]
  local owner = msg.from.id == C.config.owner
  local l = msg.from.language_code

  msg.l = l

  if cmd == nil then
    api:send(msg, C.locale:get('error', 'inv_cmd', l))

  elseif type(cmd.run) ~= 'function' then
    api:send(msg, C.locale:get('error', 'cmd_run', l))

  elseif cmd.private and not owner then
    api:send(msg, C.locale:get('error', 'adm_cmd', l))

  else
    if cmd.useQArgs then msg.args = api.parseArgs(api.unparseArgs(msg.args)) end
    msg.loc = C.locale:get('cmds', msg.cmd, l)
    local succ, err = pcall(cmd.run, C, msg, owner)
    if not succ then
      print(err)
      local cid = C.config.owner
      api:forward(cid, msg.chat.id, msg.message_id, false)
      api:send(cid, err)
      api:reply(msg, C.locale:get('error', 'not_suc', l))
    end
  end
end
