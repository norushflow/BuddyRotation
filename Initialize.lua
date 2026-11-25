local addon, Buddy = ...
local events = CreateFrame("Frame")
events:RegisterEvent("ADDON_LOADED")
events:RegisterEvent("PLAYER_LOGIN")
events:SetScript("OnEvent", function(self, event, name)
    if event == "ADDON_LOADED" then
        if name ~= addon then return end
        self:UnregisterEvent(event)
        local db = BuddyRotationCharDB or {}
        BuddyRotationCharDB = db
        Buddy.char = db
        db.rotations = db.rotations or {}
        local legacy = ForeverbuddyCharDB
        if legacy then
            if not db.imported then
                local known = {}
                for _, record in ipairs(db.rotations) do known[record.key] = true end
                for _, record in ipairs(legacy.rotations or {}) do
                    if not known[record.key] then
                        db.rotations[#db.rotations + 1] = record
                        known[record.key] = true
                    end
                end
                db.imported = true
            end
            -- Older ForeverBuddy versions still own the editor at PLAYER_LOGIN.
            -- Share the list before they restore their secure buttons.
            legacy.rotations = db.rotations
            db.rotationSerial = math.max(db.rotationSerial or 0, legacy.rotationSerial or 0)
            legacy.rotationSerial = db.rotationSerial
        end
    elseif event == "PLAYER_LOGIN" then
        self:UnregisterEvent(event)
        if SlashCmdList.BUDDYROTATION then
            self:RegisterEvent("PLAYER_LOGOUT")
        else
            Buddy.InitializeRotation()
        end
    elseif event == "PLAYER_LOGOUT" then
        Buddy.char.rotationSerial = ForeverbuddyCharDB.rotationSerial
    end
end)
