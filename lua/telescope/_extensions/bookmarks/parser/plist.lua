---plist parser (https://codea.io/talk/discussion/1269/code-plist-parser)
---version 1.01
---
---based on an XML parser by Roberto Ierusalimschy at:
---lua-users.org/wiki/LuaXml
---
---Takes a string-ified .plist file as input, and outputs a table. Nested
---dictionaries and arrays are parsed into subtables. Table structure will
---match the structure of the .plist file
---
---Usage:
---```lua
---local plist_str = <string-ified plist file>
---local plist_table = plist.parse(plist_str)
---```
---
---CHANGELOG:
---25/04/2021:
---  Fix pattern for `string.find` in the `plist_parse` function.
---  An optional '?/!' is required at the start of the line.
---  Pattern: "<([%w:]+)(.-)>"  ->  "<[?!]?([%w:]+)(.-)>"

local plp = {}

function plp.next_tag(s, i)
  return string.find(s, "<(%/?)([%w:]+)(%/?)>", i)
end

function plp.array(s, i)
  local arr, next_tag, array, dictionary =
    {}, plp.next_tag, plp.array, plp.dictionary
  local ni, j, c, label, empty

  while true do
    ni, j, c, label, empty = next_tag(s, i)
    assert(ni)

    if c == "" then
      local _
      if empty == "/" then
        if label == "dict" or label == "array" then
          arr[#arr + 1] = {}
        else
          arr[#arr + 1] = (label == "true") and true or false
        end
      elseif label == "array" then
        arr[#arr + 1], _, j = array(s, j + 1)
      elseif label == "dict" then
        arr[#arr + 1], _, j = dictionary(s, j + 1)
      else
        i = j + 1
        ni, j, _, label, _ = next_tag(s, i)

        local val = string.sub(s, i, ni - 1)
        if label == "integer" or label == "real" then
          arr[#arr + 1] = tonumber(val)
        else
          arr[#arr + 1] = val
        end
      end
    elseif c == "/" then
      assert(label == "array")
      return arr, j + 1, j
    end

    i = j + 1
  end
end

function plp.dictionary(s, i)
  local dict, next_tag, array, dictionary =
    {}, plp.next_tag, plp.array, plp.dictionary
  local ni, j, c, label, empty, _

  while true do
    ni, j, c, label = next_tag(s, i)
    assert(ni)

    if c == "" then
      if label == "key" then
        i = j + 1
        ni, j, c, label = next_tag(s, i)
        assert(c == "/" and label == "key")

        local key = string.sub(s, i, ni - 1)

        i = j + 1
        _, j, _, label, empty = next_tag(s, i)

        if empty == "/" then
          if label == "dict" or label == "array" then
            dict[key] = {}
          else
            dict[key] = (label == "true") and true or false
          end
        else
          if label == "dict" then
            dict[key], _, j = dictionary(s, j + 1)
          elseif label == "array" then
            dict[key], _, j = array(s, j + 1)
          else
            i = j + 1
            ni, j, _, label, _ = next_tag(s, i)

            local val = string.sub(s, i, ni - 1)
            if label == "integer" or label == "real" then
              dict[key] = tonumber(val)
            else
              dict[key] = val
            end
          end
        end
      end
    elseif c == "/" then
      assert(label == "dict")
      return dict, j + 1, j
    end

    i = j + 1
  end
end

local function parse(s)
  if type(s) == "nil" or s == "" then
    return nil
  end

  local i = 0
  local ni, label, empty, _

  while label ~= "plist" do
    ni, i, label, _ = string.find(s, "<[?!]?([%w:]+)(.-)>", i + 1)
    assert(ni)
  end

  _, i, _, label, empty = plp.next_tag(s, i)

  if empty == "/" then
    return {}
  elseif label == "dict" then
    return plp.dictionary(s, i + 1)
  elseif label == "array" then
    return plp.array(s, i + 1)
  end
end

return { parse = parse }
