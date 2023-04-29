
local ini = {}

local function parseValue(raw)
  return tonumber(raw) or raw:sub(2, -2)
end

function ini.decode(data)
  local out = {}
  local currentSection = nil

  -- Loop over all the lines in the file.
  for line in data:gmatch("([^\n]+)") do
    local firstChar = line:sub(1,1)
    if firstChar == ";" then
      -- Ignore the line.
    elseif firstChar == "[" then
      -- Set the section name.
      currentSection = line:match("[^%[%]]+")
    else -- The line is probably a key
      local key = line:match("^([%w]+) ?=")
      local value = line:match("= ?([%w%p \"]+)")
      if key and value then
        -- Allow global values.
        if currentSection then
          -- I wish there was a better way.
          out[currentSection] = out[currentSection] or {}
          out[currentSection][key] = parseValue(value)
        else
          out[key] = parseValue(value)
        end
      end
    end
  end

  return out
end

function ini.encode(tbl)
  -- Using a table to avoid string concatenation.
  local out = setmetatable({}, {
    ["__concat"] = function(self, val)
      self[#self + 1] = val
      return self
    end
  })
  
  for k, v in pairs(tbl) do
    out = out .. ("[%s]"):format(k)
    for k1, v1 in pairs(v) do
      local val = v1
      if type(val) == "string" then
        val = ('"%s"'):format(val)
      end
      out = out .. ("%s = %s"):format(k1, val)
    end
  end

  return table.concat(out, "\n")
end

return ini
