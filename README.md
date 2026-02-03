# 🚀 Browser Navigation Challenge Solver

**One-click solver that completes all 30 steps in ~30 seconds.**

## Quick Start (One Command)

### macOS / Linux
```bash
./solve.sh
```

### Windows PowerShell
```powershell
.\solve.ps1
```

**That's it!** The script automatically:
1. ✅ Installs Node.js (if missing)
2. ✅ Installs npm dependencies
3. ✅ Installs Playwright Chromium browser
4. ✅ Runs the challenge solver
5. ✅ Opens the victory screenshot

## What It Does

- Solves the [Browser Navigation Challenge](https://serene-frangipane-7fd25b.netlify.app/)
- Completes all **30 steps** in **~30 seconds**
- Handles all dark patterns, popups, and modals automatically
- Extracts session codes via XOR decryption
- Bypasses step 30 validation bug using React Router manipulation

## Requirements

**None!** Everything is installed automatically:

| Component | Size | Installed Automatically |
|-----------|------|------------------------|
| Node.js v20 | ~40MB | ✅ |
| Playwright | ~14MB | ✅ |
| Chromium | ~170MB | ✅ |

## Offline Mode

For air-gapped machines, place these files in an `offline/` directory:
- `offline/node-v20.11.1-darwin-arm64.tar.gz` (or appropriate platform)
- `offline/ms-playwright/` (Chromium binaries)

The installer will use bundled files instead of downloading.

## Output

After running, check:
- `output/router_hack_final.png` - Victory screenshot
- Console output shows step-by-step progress

## Alternative: npm scripts

If Node.js is already installed:
```bash
npm install
npm start
```

## Technical Details

The solver:
1. Extracts encrypted codes from `sessionStorage` (XOR key: `WO_2024_CHALLENGE`)
2. For steps 1-29: Dismisses modals, enters codes, submits forms
3. For step 30: Uses `history.pushState()` to bypass validation bug
4. Completes in ~28-35 seconds total

## Files

| File | Purpose |
|------|---------|
| `solve.sh` | One-click launcher (macOS/Linux) |
| `solve.ps1` | One-click launcher (Windows) |
| `run_router_hack.js` | Main solver (30/30 steps) |
| `package.json` | npm configuration |

## License

MIT
