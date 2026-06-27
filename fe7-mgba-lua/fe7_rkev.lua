-- ============================================================
-- Fire Emblem 7 (USA/Australia) - PRODUCTION READY
-- Verificado en vivo: BASE=0x0202BD58, CHAR_SIZE=0x48
-- mGBA 0.10.5
-- ============================================================
-- FUNCIONES:
--   1. EXP forzada a 99 (para automaticamente en nivel 20)
--   2. +1 a todas las stats al subir de nivel (cap 20/30)
--   3. Detecta promocion automaticamente (cap sube a 30)
--   4. Solo actua dentro de capitulos activos (no mapa mundo)
-- ============================================================

local CFG = {
    BASE        = 0x0202BD58,
    CHAR_SIZE   = 0x48,
    SLOTS       = 12,
    MAX_LVL     = 20,
    CAP_NORMAL  = 20,
    CAP_PROMO   = 30,
}

local OFF = {
    LEVEL = 0x00,
    EXP   = 0x01,
    HP    = 0x0A,
    STR   = 0x0C,
    SKL   = 0x0D,
    SPD   = 0x0E,
    DEF   = 0x0F,
    RES   = 0x10,
    LCK   = 0x11,
    CON   = 0x12,
}

local STAT_OFFS = {
    OFF.HP, OFF.STR, OFF.SKL, OFF.SPD,
    OFF.DEF, OFF.RES, OFF.LCK, OFF.CON
}

local STAT_NAMES = {
    [OFF.HP]  = "HP",  [OFF.STR] = "Str", [OFF.SKL] = "Skl",
    [OFF.SPD] = "Spd", [OFF.DEF] = "Def", [OFF.RES] = "Res",
    [OFF.LCK] = "Lck", [OFF.CON] = "Con"
}

-- Estado por slot
local state = {}
for i = 1, CFG.SLOTS do
    state[i] = { prev_lvl = 0, promoted = false, capped = false }
end

local function base(slot)
    return CFG.BASE + (slot - 1) * CFG.CHAR_SIZE
end

local function r(addr)   return emu:read8(addr)      end
local function w(addr,v) emu:write8(addr, v)         end

local function cap(slot)
    return state[slot].promoted and CFG.CAP_PROMO or CFG.CAP_NORMAL
end

local function allCapped(slot)
    local b = base(slot)
    local c = cap(slot)
    for _, o in ipairs({OFF.STR, OFF.SKL, OFF.SPD, OFF.DEF, OFF.RES, OFF.LCK}) do
        if r(b + o) < c then return false end
    end
    return true
end

local function levelUp(slot, lvl)
    local b = base(slot)
    local c = cap(slot)
    console:log(string.format("[+] Slot%d Lv%d | cap=%d", slot, lvl, c))
    for _, o in ipairs(STAT_OFFS) do
        local cur = r(b + o)
        if cur < c then
            w(b + o, cur + 1)
            console:log(string.format("    %s %d->%d", STAT_NAMES[o], cur, cur+1))
        end
    end
end

local function inChapter()
    -- Hay personaje valido en slot 1
    local lvl = r(CFG.BASE + OFF.LEVEL)
    return lvl > 0 and lvl <= 30
end

callbacks:add("frame", function()
    if not inChapter() then
        for i = 1, CFG.SLOTS do state[i].prev_lvl = 0 end
        return
    end

    for slot = 1, CFG.SLOTS do
        local b   = base(slot)
        local lvl = r(b + OFF.LEVEL)
        local s   = state[slot]

        if lvl > 0 and lvl <= 30 then
            -- Detectar promocion (nivel baja de >5 a <=5)
            if s.prev_lvl > 5 and lvl <= 5 then
                s.promoted = true
                s.capped   = false
                console:log(string.format("[^] Slot%d promovido! cap=30", slot))
            end

            -- Verificar si todas las stats llegaron al cap
            if not s.capped and allCapped(slot) and lvl >= CFG.MAX_LVL then
                s.capped = true
                console:log(string.format("[=] Slot%d stats en cap, EXP pausada", slot))
            end

            -- Forzar EXP en 99
            if not s.capped and lvl < CFG.MAX_LVL then
                w(b + OFF.EXP, 99)
            end

            -- Detectar level up y aplicar +1
            if s.prev_lvl > 0 and lvl > s.prev_lvl then
                levelUp(slot, lvl)
            end

            s.prev_lvl = lvl
        else
            s.prev_lvl = 0
            s.capped   = false
        end
    end
end)

console:log("============================================")
console:log(" FE7 Script v3.0 — rkev")
console:log(string.format(" BASE=0x%X | CHAR=0x%X | SLOTS=%d",
    CFG.BASE, CFG.CHAR_SIZE, CFG.SLOTS))
console:log(" EXP->99 | LvUp+1 | AutoPromo | SafeGuard")
console:log("============================================")
