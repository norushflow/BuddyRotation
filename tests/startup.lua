local handler
local frame = {
    RegisterEvent = function() end, UnregisterEvent = function() end,
    SetScript = function(_, _, fn) handler = fn end,
}
function CreateFrame() return frame end
local starts = 0
local buddy = {InitializeRotation = function() starts = starts + 1 end}
local function login(legacy, embedded)
    ForeverbuddyCharDB = legacy
    SlashCmdList = {BUDDYROTATION = embedded}
    assert(loadfile("Initialize.lua"))("BuddyRotation", buddy)
    handler(frame, "ADDON_LOADED", "BuddyRotation")
    handler(frame, "PLAYER_LOGIN")
end
local legacy = {rotations = {{key = "BuddyRot4"}}, rotationSerial = 4}
login(legacy, function() end)
assert(starts == 0 and buddy.char.rotations[1].key == "BuddyRot4")
legacy.rotations[2] = {key = "BuddyRot5"}
legacy.rotationSerial = 5
handler(frame, "PLAYER_LOGOUT")
login(nil)
assert(starts == 1 and #buddy.char.rotations == 2 and buddy.char.rotationSerial == 5)
table.remove(buddy.char.rotations, 1)
login({rotations = {{key = "BuddyRot4"}}})
assert(starts == 2 and #buddy.char.rotations == 1 and buddy.char.rotations[1].key == "BuddyRot5")
