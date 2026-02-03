#!/usr/bin/env bash
#
# 🚀 ONE-CLICK BROWSER CHALLENGE SOLVER
#
# This script automatically:
# 1. Installs Node.js (if missing)
# 2. Installs npm dependencies
# 3. Installs Playwright Chromium browser
# 4. Runs the challenge solver
# 5. Completes all 30 steps in ~30 seconds
#
# Usage: ./solve.sh
#

set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# Get script directory
ROOT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$ROOT_DIR"

echo ""
echo -e "${CYAN}╔════════════════════════════════════════════════════════════╗${NC}"
echo -e "${CYAN}║${NC}  🚀 ${GREEN}ONE-CLICK BROWSER CHALLENGE SOLVER${NC}                      ${CYAN}║${NC}"
echo -e "${CYAN}║${NC}     Completes 30 steps in under 5 minutes                  ${CYAN}║${NC}"
echo -e "${CYAN}╚════════════════════════════════════════════════════════════╝${NC}"
echo ""

# Helper: download a URL to a file
fetch() {
  local url="$1"
  local out="$2"
  if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$url" -o "$out"
    return 0
  fi
  if command -v wget >/dev/null 2>&1; then
    wget -q "$url" -O "$out"
    return 0
  fi
  if command -v python3 >/dev/null 2>&1; then
    python3 -c "import urllib.request; urllib.request.urlretrieve('$url', '$out')"
    return 0
  fi
  echo -e "${RED}❌ Error: No download tool available (curl, wget, or python3)${NC}" >&2
  return 1
}

# Step 1: Check/Install Node.js
echo -e "${BLUE}[1/5]${NC} Checking Node.js..."

NODE_CMD=""
if command -v node >/dev/null 2>&1; then
  NODE_CMD="node"
  NODE_VERSION=$(node --version 2>/dev/null || echo "unknown")
  echo -e "      ${GREEN}✓${NC} Node.js found: ${NODE_VERSION}"
elif [ -x "$HOME/.local/node/bin/node" ]; then
  export PATH="$HOME/.local/node/bin:$PATH"
  NODE_CMD="node"
  NODE_VERSION=$(node --version 2>/dev/null || echo "unknown")
  echo -e "      ${GREEN}✓${NC} Node.js found (local): ${NODE_VERSION}"
else
  echo -e "      ${YELLOW}⚠${NC} Node.js not found. Installing..."

  # Detect OS and architecture
  OS="$(uname -s)"
  ARCH="$(uname -m)"

  case "$OS" in
    Darwin)
      PLATFORM="darwin"
      ;;
    Linux)
      PLATFORM="linux"
      ;;
    *)
      echo -e "${RED}❌ Unsupported OS: $OS${NC}" >&2
      exit 1
      ;;
  esac

  case "$ARCH" in
    arm64|aarch64)
      NODE_ARCH="arm64"
      ;;
    x86_64|amd64)
      NODE_ARCH="x64"
      ;;
    *)
      echo -e "${RED}❌ Unsupported architecture: $ARCH${NC}" >&2
      exit 1
      ;;
  esac

  NODE_VERSION="20.11.1"
  NODE_TAR="node-v${NODE_VERSION}-${PLATFORM}-${NODE_ARCH}.tar.gz"
  NODE_DIR="$HOME/.local/node"
  OFFLINE_TAR="$ROOT_DIR/offline/$NODE_TAR"
  TMP_TAR="$ROOT_DIR/.node_download.tar.gz"

  mkdir -p "$NODE_DIR"

  if [ -f "$OFFLINE_TAR" ]; then
    echo -e "      ${CYAN}📦${NC} Using offline Node.js bundle..."
    cp "$OFFLINE_TAR" "$TMP_TAR"
  else
    echo -e "      ${CYAN}⬇${NC} Downloading Node.js v${NODE_VERSION}..."
    NODE_URL="https://nodejs.org/dist/v${NODE_VERSION}/${NODE_TAR}"
    fetch "$NODE_URL" "$TMP_TAR"
  fi

  echo -e "      ${CYAN}📂${NC} Extracting Node.js..."
  tar -xzf "$TMP_TAR" -C "$NODE_DIR" --strip-components=1
  rm -f "$TMP_TAR"

  export PATH="$NODE_DIR/bin:$PATH"
  NODE_CMD="node"

  if command -v node >/dev/null 2>&1; then
    echo -e "      ${GREEN}✓${NC} Node.js installed: $(node --version)"
  else
    echo -e "${RED}❌ Failed to install Node.js${NC}" >&2
    exit 1
  fi
fi

# Step 2: Install npm dependencies
echo -e "${BLUE}[2/5]${NC} Checking npm dependencies..."

if [ -d "$ROOT_DIR/node_modules/playwright" ]; then
  echo -e "      ${GREEN}✓${NC} Dependencies already installed"
else
  echo -e "      ${CYAN}⬇${NC} Installing npm packages..."
  npm install --silent 2>/dev/null || npm install
  echo -e "      ${GREEN}✓${NC} Dependencies installed"
fi

# Step 3: Install Playwright Chromium
echo -e "${BLUE}[3/5]${NC} Checking Playwright browser..."

# Check if Chromium is already installed
PLAYWRIGHT_BROWSERS="$HOME/Library/Caches/ms-playwright"
if [ "$(uname -s)" = "Linux" ]; then
  PLAYWRIGHT_BROWSERS="$HOME/.cache/ms-playwright"
fi

if [ -d "$PLAYWRIGHT_BROWSERS" ] && ls "$PLAYWRIGHT_BROWSERS"/chromium-* >/dev/null 2>&1; then
  echo -e "      ${GREEN}✓${NC} Chromium browser ready"
else
  # Check for offline cache
  if [ -d "$ROOT_DIR/offline/ms-playwright" ]; then
    echo -e "      ${CYAN}📦${NC} Using offline Chromium bundle..."
    mkdir -p "$PLAYWRIGHT_BROWSERS"
    cp -r "$ROOT_DIR/offline/ms-playwright"/* "$PLAYWRIGHT_BROWSERS/" 2>/dev/null || true
    echo -e "      ${GREEN}✓${NC} Chromium installed from offline cache"
  else
    echo -e "      ${CYAN}⬇${NC} Downloading Chromium browser (~170MB)..."
    npx playwright install chromium 2>/dev/null || npx playwright install chromium
    echo -e "      ${GREEN}✓${NC} Chromium browser installed"
  fi
fi

# Step 4: Create output directory
echo -e "${BLUE}[4/5]${NC} Preparing output directory..."
mkdir -p "$ROOT_DIR/output"
echo -e "      ${GREEN}✓${NC} Output directory ready"

# Step 5: Run the solver
echo ""
echo -e "${BLUE}[5/5]${NC} ${GREEN}🎯 STARTING CHALLENGE SOLVER${NC}"
echo -e "      Target: https://serene-frangipane-7fd25b.netlify.app/"
echo ""
echo -e "${CYAN}────────────────────────────────────────────────────────────${NC}"

# Run the solver
START_TIME=$(date +%s)
node "$ROOT_DIR/solver.js"
EXIT_CODE=$?
END_TIME=$(date +%s)
DURATION=$((END_TIME - START_TIME))

echo -e "${CYAN}────────────────────────────────────────────────────────────${NC}"
echo ""

# Show results
if [ $EXIT_CODE -eq 0 ]; then
  echo -e "${GREEN}╔════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${GREEN}║${NC}  🏆 ${GREEN}CHALLENGE COMPLETE!${NC}                                    ${GREEN}║${NC}"
  echo -e "${GREEN}║${NC}     Total time: ${DURATION} seconds                                  ${GREEN}║${NC}"
  echo -e "${GREEN}╚════════════════════════════════════════════════════════════╝${NC}"

  # Show screenshot location
  if [ -f "$ROOT_DIR/output/final_screenshot.png" ]; then
    echo ""
    echo -e "📸 Screenshot: ${CYAN}output/final_screenshot.png${NC}"
    echo -e "📊 Statistics: ${CYAN}output/run_stats.json${NC}"

    # Try to open the screenshot (macOS)
    if [ "$(uname -s)" = "Darwin" ] && command -v open >/dev/null 2>&1; then
      open "$ROOT_DIR/output/final_screenshot.png" 2>/dev/null || true
    fi
  fi
else
  echo -e "${RED}╔════════════════════════════════════════════════════════════╗${NC}"
  echo -e "${RED}║${NC}  ❌ Solver exited with error code: ${EXIT_CODE}                       ${RED}║${NC}"
  echo -e "${RED}╚════════════════════════════════════════════════════════════╝${NC}"
  exit $EXIT_CODE
fi

echo ""
