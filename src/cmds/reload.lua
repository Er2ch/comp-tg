return {
  private = true,
  run = function(C, msg)
    local cat, sub = table.unpack(msg.args)
    if not (cat and sub) then
      return C.api:reply(msg, '/reload cmds ping')
    end

    local path = 'src.'..cat..'.'..sub
    package.loaded[path] = nil
    local err, m = pcall(require, path)

    if not err then return C.api:reply(msg, 'Reload failed. ' .. m)
    elseif cat == 'events' then C.api:off(m); C.api:on(sub, m)
    elseif cat == 'cmds'   then C.cmds[sub] = m
    elseif cat == 'parts'  then m(C)
    end

    C.api:reply(msg, 'Reloaded. ' .. tostring(m))
  end
}
