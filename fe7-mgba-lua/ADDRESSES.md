# FE7 RAM Address Map — Verified Live

All addresses verified directly from the running game using mGBA 0.10.5 Scripting console.  
ROM: Fire Emblem USA/Australia | MD5: `f1a1b9742fcd467a531dd4314c4e7d19`

---

## Unit Table

| Property | Value |
|---|---|
| Base address (Slot 1) | `0x0202BD58` |
| Size per unit (CHAR_SIZE) | `0x48` bytes |
| Max slots | 12 |
| Slot N base | `0x0202BD58 + (N-1) * 0x48` |

### How to calculate any slot

```
Slot 1: 0x0202BD58
Slot 2: 0x0202BDA0
Slot 3: 0x0202BDE8
Slot 4: 0x0202BE30
...
Slot N: 0x0202BD58 + (N-1) * 0x48
```

---

## Unit Struct Offsets

All offsets are relative to the slot base address.

| Offset | Field | Notes |
|---|---|---|
| `0x00` | Level | 1–20 unpromoted, 1–20 promoted |
| `0x01` | EXP | 0–99 |
| `0x0A` | HP Max | Cap: 20 / 30 promoted |
| `0x0B` | HP Current | Should not be written directly |
| `0x0C` | Strength | Cap: 20 / 30 |
| `0x0D` | Skill | Cap: 20 / 30 |
| `0x0E` | Speed | Cap: 20 / 30 |
| `0x0F` | Defense | Cap: 20 / 30 |
| `0x10` | Resistance | Cap: 20 / 30 |
| `0x11` | Luck | Cap: 20 / 30 |
| `0x12` | Constitution | Cap: 20 / 30 |

---

## Verification method

Addresses were found using live RAM search in the mGBA Scripting console:

```lua
-- Search for a known value (e.g. EXP = 30)
for i=0x02020000,0x0202FFFF do
    if emu:read8(i)==30 then
        console:log(string.format("0x%08X", i))
    end
end

-- Cross-reference after value changes (e.g. EXP = 31)
for i=0x02020000,0x0202FFFF do
    if emu:read8(i)==31 then
        console:log(string.format("0x%08X", i))
    end
end
-- Address appearing in both lists = confirmed EXP address
```

Base address `0x0202BD58` was confirmed when Level=3 and EXP=20 were found at offsets 0x00 and 0x01.  
CHAR_SIZE `0x48` was calculated as the difference between Lyn's base (`0x0202BD58`) and Sain's base (`0x0202BDA0`).

---

## Notes on incorrect addresses found online

The commonly cited base address `0x0202BD44` (found in CodeBreaker FAQs from 2004) does **not** match this ROM dump.  
Using it causes writes to wrong memory regions and crashes the game.

