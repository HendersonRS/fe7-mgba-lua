# FE7 mGBA Lua Cheat Script — rkev

Lua cheat script for **Fire Emblem: The Blazing Sword (USA/Australia)** running on **mGBA 0.10.5**.

> Developed and verified live by rkev. All RAM addresses were found directly from the running game — not copied from outdated guides.

---

## Features

| Feature | Description |
|---|---|
| **EXP Lock** | Forces EXP to 99 every frame — units level up after every combat |
| **+1 All Stats** | On every level up, all stats gain +1 on top of what the game normally gives |
| **Auto Promotion Detection** | Detects when a unit promotes and raises stat cap from 20 to 30 automatically |
| **Cap Awareness** | Stops forcing EXP when all stats are maxed — prevents negative stat display bug |
| **Safe Guard** | Script pauses during world map transitions to prevent crashes |
| **12 Slot Coverage** | Works for all 12 unit slots simultaneously |

---

## Stats affected by +1 on level up

- HP Max
- Strength (Str)
- Skill (Skl)
- Speed (Spd)
- Defense (Def)
- Resistance (Res)
- Luck (Lck)
- Constitution (Con)

---

## Requirements

- mGBA **0.10.5** (tested — other versions may vary)
- Fire Emblem: The Blazing Sword ROM **(USA/Australia)**
  - MD5: `f1a1b9742fcd467a531dd4314c4e7d19`
  - SHA1: `c735fdbb9e8abe19e0c6a44708df19acc962e204`
- Official GBA BIOS (`gba_bios.bin`)
  - MD5: `a860e8c0b6d573d191e4ec7db1b1e4f6`
  - **Required** — without it, the game crashes on world map transitions

---

## How to use

1. Open mGBA and load your FE7 ROM
2. Go to **Tools → Scripting**
3. Click **File → Load Script**
4. Select `fe7_rkev.lua`
5. Keep the Scripting window **open** while playing — closing it unloads the script
6. Play normally — the script runs in the background every frame

You should see this in the console:
```
============================================
 FE7 Script v3.0 — rkev
 BASE=0x202BD58 | CHAR=0x48 | SLOTS=12
 EXP->99 | LvUp+1 | AutoPromo | SafeGuard
============================================
```

---

## Important notes

### Prologue
EXP lock does **not** work during Lyn's Prologue — the game hardcodes EXP during the tutorial. The +1 stats on level up still works if a level up occurs.

### Stat caps
- **Unpromoted units**: cap at 20 per stat
- **Promoted units**: cap at 30 per stat
- Constitution is included but has a lower natural cap per class — the script respects the 20/30 limit

### World map
The script automatically detects when you are on the world map or in a transition and stops writing to memory. This prevents crashes during chapter transitions.

### Save files
If your save file was previously modified by faulty cheat codes (CodeBreaker or older versions of this script), it may be corrupted. Starting a new save is recommended.

---

## Known issues and crash history

See [CRASHES.md](CRASHES.md) for full documentation of crashes encountered during development and their causes.

---

## RAM addresses (verified live)

See [ADDRESSES.md](ADDRESSES.md) for the full verified RAM map.

---

## What does NOT exist elsewhere

Most FE7 Lua scripts online are:
- Built for **VBA or BizHawk** — not compatible with modern mGBA
- Focused on **RNG display for speedrunning** — not cheats
- Based on **CodeBreaker codes from 2004** — many don't work in mGBA 0.10.5

This script is the only verified Lua cheat script for FE7 on mGBA 0.10.5.

---

## License

MIT — free to use, modify and share. Credit appreciated.
