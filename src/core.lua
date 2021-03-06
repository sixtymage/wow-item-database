ItemDatabase = {}

local title = "Item Database"
local items = {}
local eventFrame
local maxItemId = 50000
local itemsPerTick = 500
local reportingInterval = 10
local maxActualItemId = 0

local function IsNilOrEmpty(value)
  if value == nil or value == '' then
    return true
  end
  
  return false
end

local function LoadItems(startItemId, endItemId)
  for itemId = startItemId, endItemId do
    local itemName, _, _, _, _, _, _, _ = GetItemInfo(itemId)
      
    if not IsNilOrEmpty(itemName) then
      items[itemName] = itemId
      if itemId > maxActualItemId then
        maxActualItemId = itemId
      end
    end
  end
end

local function OnNextItem(itemId)
  local endItemId = itemId+itemsPerTick-1
  LoadItems(itemId, endItemId)

  if endItemId < maxItemId then
    C_Timer.After(0.1, function() OnNextItem(endItemId+1) end)
  else
    print (string.format("%s: Done (maxActualItemId: %d)", title, maxActualItemId))
  end 

  if endItemId % (itemsPerTick * reportingInterval) == 0 then
    print (string.format("%s: Loaded %d item(s)", title, endItemId+1))
  end 

end

local function Load()
  print (string.format("%s: Loading items (itemsPerTick=%d)", title, itemsPerTick))
  C_Timer.After(0, function() OnNextItem(0) end)
end

local function Show(match)
  local matched = 0
  local total = 0

  for name,_ in pairs(items) do
    if IsNilOrEmpty(match) or string.find (name, match) then
      print (string.format("%s: [%s] = (%d)", title, name, ItemDatabase:GetItemId(name)))
      matched = matched + 1
    end
    total = total + 1
  end

  print (string.format("%s: Matched %d of %d item(s)", title, matched, total))
end

local function Commands(msg, editbox)
  local _, _, cmd, args = string.find(msg, "%s?(%w+)%s?(.*)")

  if cmd == "load" then
    Load()
  end

  if cmd == "show" then
    Show(args)
  end
end

local function OnLoad(name)
  if name == title then
    Commands("load", nil)
  end
end

local function OnEvent(self, event, ...)
  if event == "ADDON_LOADED" then
    OnLoad(...)
  end
end

SLASH_IDB1 = "/items"

local function Init()
  eventFrame = CreateFrame("FRAME", "ItemDatabaseFrame")
  -- eventFrame:RegisterEvent("ADDON_LOADED");
  eventFrame:SetScript("OnEvent", OnEvent)

  SlashCmdList["IDB"] = Commands
end

Init()

function ItemDatabase:GetItemId(itemName)
  if items[itemName] == nil then
    return -1
  end
  
  return items[itemName]
end
