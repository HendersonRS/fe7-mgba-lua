# Crash History & Lessons Learned

Full documentation of every crash and bug encountered during development of this script.

---

## Crash 1 — Wrong API: `memory.read_u8`

**Error:**
```
[ERROR] attempt to index a nil value (global 'memory')
```

**Cause:**  
Used `memory.read_u8()` and `memory.write_u8()` which are VBA/BizHawk API functions. mGBA 0.10.5 does not have a `memory` global object.

**Fix:**  
Use `emu:read8(addr)` and `emu:write8(addr, val)` — the correct mGBA Lua API.

---

## Crash 2 — Wrong base address `0x0202BD44`

**Symptom:**  
Game black screens immediately after loading script. Characters disappear from the map.

**Cause:**  
Used `0x0202BD44` as the unit table base — this address is cited in CodeBreaker FAQs from 2004 but does not match this ROM dump. Writing to it corrupts unrelated game data.

**Fix:**  
Found the correct base `0x0202BD58` via live RAM search by cross-referencing EXP values.

---

## Crash 3 — Wrong CHAR_SIZE `0x90`

**Symptom:**  
EXP lock worked for Slot 1 (Lyn) and Slot 3 (Kent) but skipped Slot 2 (Sain) entirely.

**Cause:**  
Calculated CHAR_SIZE as `0x90` by comparing Lyn's base to Kent's base, accidentally skipping Sain in between.

**Fix:**  
Found Sain's base directly via RAM search. Correct CHAR_SIZE is `0x48` (difference between consecutive slots).

---

## Crash 4 — `emu:read16` does not exist

**Symptom:**  
Game crashes immediately on script load. Black screen.

**Cause:**  
Used `emu:read16()` and `emu:write16()` to read/write gold (4-byte value). These functions do not exist in mGBA 0.10.5 Lua API.

**Fix:**  
Write gold byte by byte using `emu:write8()` four times with the correct little-endian bytes.  
Example for 99999 (0x0001869F):
```lua
emu:write8(ADDR_GOLD,     0x9F)
emu:write8(ADDR_GOLD + 1, 0x86)
emu:write8(ADDR_GOLD + 2, 0x01)
emu:write8(ADDR_GOLD + 3, 0x00)
```

---

## Crash 5 — Item slot writes corrupting function pointers

**Error:**
```
Jumped to invalid address: 04A13A70
Jumped to invalid address: 01408160
```

**Symptom:**  
Game crashes on world map transition after chapter ends.

**Cause:**  
Writing to item slot offsets (`0x1E`–`0x27`) was corrupting adjacent memory used by the game engine as function pointers or event data. The offset range overlapped with game-critical data during transitions.

**Fix:**  
Removed all item slot writes from the script. Item manipulation via Lua is not safe without a complete verified item struct map.

---

## Crash 6 — Stat display showing negative values (e.g. `Str 20 -2`)

**Symptom:**  
Level up screen shows stats with negative arrows (e.g. `Str 20 -2`). Not a crash but a display bug.

**Cause:**  
Script was writing stats beyond the class stat cap (20 for unpromoted). The game's display calculates difference between new and old stat — if the script wrote 21 but the class cap is 20, the game shows it as -1.

**Fix:**  
Added `STAT_CAP` enforcement in the script. Stats are capped at 20 for unpromoted and 30 for promoted units. Script also stops forcing EXP when all stats reach cap to prevent further level ups from triggering the display bug.

---

## Crash 7 — Missing GBA BIOS

**Error:**
```
Jumped to invalid address: 01408160
Unimplemented BIOS call
```

**Symptom:**  
Game crashes on world map between chapters. fps drops to ~31.

**Cause:**  
mGBA without the official GBA BIOS cannot handle certain BIOS calls that FE7 makes during world map transitions and chapter loading. This is unrelated to the Lua script.

**Fix:**  
Install the official GBA BIOS (`gba_bios.bin`, MD5: `a860e8c0b6d573d191e4ec7db1b1e4f6`):
1. Tools → Settings → BIOS
2. Set GBA BIOS file path
3. Check "Use BIOS file if found"
4. Restart mGBA

---

## Crash 8 — Script writing during world map transition

**Symptom:**  
Game freezes or crashes specifically when transitioning from battle to world map.

**Cause:**  
The frame callback was still writing EXP values while the game was in the middle of unloading chapter data. The unit slots still had non-zero level values during transition, so `inChapter()` returned true incorrectly.

**Fix:**  
Added `inChapter()` guard that checks Slot 1's level — if it's 0 or invalid, the script resets all `prev_lvl` values and returns early without writing anything.

---

## Summary table

| # | Error | Cause | Fix |
|---|---|---|---|
| 1 | `nil value (global 'memory')` | Wrong Lua API | Use `emu:read8/write8` |
| 2 | Black screen, chars disappear | Wrong base `0x0202BD44` | Correct base `0x0202BD58` |
| 3 | Sain not affected by EXP lock | Wrong CHAR_SIZE `0x90` | Correct size `0x48` |
| 4 | Black screen on load | `emu:read16` doesn't exist | Write gold byte by byte |
| 5 | `Jumped to invalid address` | Item slot writes | Removed item writes |
| 6 | `Str 20 -2` display bug | No stat cap | Added cap 20/30 |
| 7 | BIOS crash on world map | Missing GBA BIOS | Install official BIOS |
| 8 | Freeze on chapter transition | Writing during unload | Added `inChapter()` guard |

