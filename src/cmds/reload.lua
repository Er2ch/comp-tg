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
    C.api:reply(msg, ('Reloaded. %s (%s)'):format(
      not err and 'Error:' or 'Result:',
      m
    ))
  end
}
