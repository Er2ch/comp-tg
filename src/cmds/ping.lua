return {
  run = function(C, msg)
    local t = os.time()
    local ps, ls, lm, lh, ld
    ps, ls = t - msg.date, t - C.loaded
    lm = ls / 60
    lh = lm / 60
    ld = lh / 24
    C.api:send(msg, msg.loc.pat:format(ps, ld, lh, lm, ls))
  end
}
