{
  run: (msg) =>
    t = os.time!
    ps, ls = t - msg.date, t - @loaded
    lm = ls / 60
    lh = lm / 60
    ld = lh / 24
    @api\send msg, msg.loc.pat\format ps, ld, lh, lm, ls
    return
}
