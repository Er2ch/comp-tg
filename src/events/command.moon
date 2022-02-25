(api, msg) =>
  l = msg.from.language_code
  owner = msg.from.id == @config.owner
  cmd = @cmds[msg.cmd]

  msg.l = l

  if not cmd
    api\send msg, @locale\get 'error', 'inv_cmd', l

  elseif type(cmd.run) ~= 'function'
    api\send msg, @locale\get 'error', 'cmd_run', l

  elseif cmd.private and not owner
    api\send msg, @locale\get 'error', 'adm_cmd', l

  else
    msg.args = api.parseArgs api.unparseArgs msg.args if cmd.useQArgs
    msg.loc = @locale\get 'cmds', msg.cmd, l

    suc, err = pcall cmd.run, @, msg, owner
    if not suc
      -- whoops
      print err
      api\forward @config.owner, msg.chat.id, msg.message_id, false
      api\send    @config.owner, err
      api\reply msg, @locale\get 'error', 'not_suc', l
  return
