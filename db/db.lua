local mp = require 'db.mp'

local tools = {
  isFile = function(path)
    local f = io.open(path, 'r')
    if not f then return false end
    f:close()
    return true
  end,
  isDir = function(path)
    path = (path .. '/'):gsub('//', '/')
    local o, _, c = os.rename(path, path)
    return o or c == 13
  end,

  loadPg = function(db, k)
    local f = io.open(db._path .. '/' .. k, 'rb')
    if not f then return end

    local res = mp.unpack(f:read '*a')
    f:close()
    return res
  end,

  savePg = function(db, k, page)
    if type(k) == 'string' and k:sub(1, 1) == '_' then return '_' end
    local f = io.open(db._path .. '/' .. k, 'wb')
    if type(page) ~= 'table' or not f then return false end

    f:write(mp.pack(page))
    f:close()
    return true
  end,
}

local dbInt = {
  save = function(db, p)
    if p then
      if type(p) ~= 'string' or type(db[p]) ~= 'table' then return false end
      return tools.savePg(db, p, db[p])
    end
    for p, con in pairs(db) do
      if not tools.savePg(db, p, con) then return false end
    end
    return true
  end,
}

local _db = {
  __index = function(db, k)
    if dbInt[k] then return dbInt[k] end
    if tools.isFile(db._path .. '/' .. k) then
      db[k] = tools.loadPg(db, k)
    end
    return rawget(db, k)
  end,
  __newindex = function(db, k, v)
    if type(k) ~= 'string' or type(v) == 'function' then return end
    if k:sub(1, 1) == '_' then return end
    return rawset(db, k, v)
  end
}

return setmetatable({}, {
  __mode = 'kv',
  __call = function(self, path)
    assert(tools.isDir(path), path .. ' is not a directory')
    if self[path] then return self[path] end
    local db = setmetatable({_path = path}, _db)
    self[path] = db
    return db
  end
})
