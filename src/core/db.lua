return function(Core)
local path = 'etc/db' -- from root
local time = 60 * 5   -- 5min

Core.db = require 'etc.db' (path)

local t = os.time()
Core:on('tick', function()
  if os.time() - t >= time then
    t = os.time()
    print 'saving...'
    Core.db:save()
  end
end)

end
