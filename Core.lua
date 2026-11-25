local _, Buddy = ...
local B = {}
Buddy.Bars = B

function B.Public(v) return not (issecretvalue and issecretvalue(v)) end
function B.Number(v) return B.Public(v) and type(v)=="number" and v==v end
function B.Text(v) return B.Public(v) and type(v)=="string" and v~="" end
function B.Table(v) return B.Public(v) and type(v)=="table" end
function B.Call(fn,...)
    if type(fn)~="function" then return nil end
    local ok,a,b,c=pcall(fn,...)
    if ok and B.Public(a) and B.Public(b) and B.Public(c) then return a,b,c end
end

local macroBase
function B.MacroBase()
    if macroBase then return macroBase end
    local base=B.Number(MAX_ACCOUNT_MACROS) and MAX_ACCOUNT_MACROS
    local constants=Constants
    if not base and B.Table(constants) and B.Table(constants.MacroConsts) then
        local value=constants.MacroConsts.MAX_ACCOUNT_MACROS
        if B.Number(value) then base=value end
    end
    if base and base>=1 then macroBase=base;return base end
end

local function macroName(index)
    local api=C_Macro
    if B.Table(api) and type(api.GetMacroName)=="function" then
        local ok,name=pcall(api.GetMacroName,index)
        if ok and B.Text(name) then return name end
    end
    if type(GetMacroInfo)~="function" then return end
    local ok,name=pcall(GetMacroInfo,index)
    if ok and B.Text(name) then return name end
end

function B.MacroLookup(name)
    if not B.Text(name) then return end
    local base=B.MacroBase()
    local account,character=B.Call(GetNumMacros)
    if not base or not B.Number(account) or not B.Number(character) then return nil,"api" end
    local found
    for n=1,character do
        local index=base+n
        if macroName(index)==name then
            if found then return nil,"ambiguous" end
            found=index
        end
    end
    if found then return found,"character" end
    for n=1,math.min(account,base) do
        if macroName(n)==name then return nil,"account" end
    end
    return nil,"missing"
end
