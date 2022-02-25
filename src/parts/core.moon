config = require 'config'

Core =
  config: config
  loaded: 0

  load: (what) =>
    c = config[what]

    for i = 1, #c
      v = c[i]

      print "Loading #{what\sub 0, -2} (#{i} / #{#c}) #{v}..."
      -- Lint
      e, a = pcall require, "src.#{what}.#{v}"
      print e, a
      if e
        switch what
          when 'events' then @api\on v, a
          when 'cmds'   then @cmds[v] = a
          when 'parts'  then a @
      else print 'fail'
    print "Loaded #{#c} #{what}"
    @loaded = os.time!

  ev: (t, i, name, ...) =>
    v = t[i]
    if v.name == name
      suc, err = pcall v.fn, @, ...
      if not suc
        print "event \"#{name}\" was failed"
        print err
      table.remove t, i if v.type == 'once'

  init: =>
    @\load 'parts'

    export utf8 = require 'etc.utf8'

    print 'Done!'
    @\emit 'ready'
    return

  stop: =>
    @api\destroy!
    print 'Stopped'
    print "Uptime: #{os.time! - @loaded} seconds"
    return

require('etc.events')(Core) -- add events
Core\init!
return
