tg = require 'etc.api'

=>
  @api = tg { norun: true }
  @cmds = {}

  print 'Client initialization...'

  @_ev = (ev, ...) -> @\ev ...
  @api._ev = (_, t, i, n, ...) ->
    @._ev _, t, i, n, @api, ...

  @\load 'events'

  @api\login @config.token, ->
    print "Logged on as @#{@api.info.username}"
    @config.token = nil
    @api\emit 'ready'
    return

  offs, o = 0
  @api.runs = true
  @\on 'ready', ->
    while @api.runs
      @\emit 'tick'

      o = @api\_getUpd 1, offs, 0
      offs = o and o or offs

    @api\getUpdates 1, offs, 0
    return
  return
