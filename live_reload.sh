#!/bin/bash

# ♨️ Zaza Dance Smart Hot Reload
# פתרון חכם לפיתוח Flutter עם hot reload אוטומטי

set -e

# Colors for better output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
NC='\033[0m' # No Color

echo -e "${PURPLE}🔥 זזה דאנס - Hot Reload חכם${NC}"
echo -e "${BLUE}================================${NC}"

# Check if fswatch is installed
if ! command -v fswatch &> /dev/null; then
    echo -e "${YELLOW}📦 Installing fswatch for file watching...${NC}"
    brew install fswatch
fi

# Clean and prepare
echo -e "${YELLOW}🧹 Cleaning Flutter project...${NC}"
flutter clean > /dev/null 2>&1
flutter pub get > /dev/null 2>&1

# Function to start Flutter with optimized settings
start_flutter() {
    echo -e "${GREEN}🚀 Starting Flutter with optimized hot reload...${NC}"
    
    # Get available devices
    DEVICES=$(flutter devices --machine | jq -r '.[].id' 2>/dev/null || flutter devices | grep -o '[A-Z0-9-]*' | head -1)
    
    if [ -z "$DEVICES" ]; then
        echo -e "${RED}❌ No devices found. Connect a device or start simulator${NC}"
        exit 1
    fi
    
    # Start Flutter with mobile-optimized settings
    flutter run \
        --hot \
        --debug \
        --dart-define=flutter.inspector.structuredErrors=false \
        --enable-software-rendering \
        --verbose &
    
    FLUTTER_PID=$!
    echo -e "${GREEN}✅ Flutter started (PID: $FLUTTER_PID)${NC}"
    
    return $FLUTTER_PID
}

# Function to send hot reload signal to mobile app
trigger_reload() {
    echo -e "${YELLOW}♨️  Triggering hot reload...${NC}"
    
    # Check if Flutter process is still running
    if kill -0 $FLUTTER_PID 2>/dev/null; then
        # Send USR1 signal to trigger hot reload
        kill -USR1 $FLUTTER_PID 2>/dev/null || echo -e "${YELLOW}⚠️  Hot reload signal failed, trying hot restart...${NC}"
        echo -e "${GREEN}✅ Hot reload triggered at $(date '+%H:%M:%S')${NC}"
    else
        echo -e "${RED}❌ Flutter process died, restarting...${NC}"
        start_flutter
    fi
}

# Start Flutter app
start_flutter

# Setup cleanup on exit
cleanup() {
    echo -e "${YELLOW}🛑 Stopping Flutter...${NC}"
    if kill -0 $FLUTTER_PID 2>/dev/null; then
        kill $FLUTTER_PID
    fi
    exit 0
}
trap cleanup SIGINT SIGTERM

echo -e "${BLUE}👀 Watching for file changes...${NC}"
echo -e "${PURPLE}Press Ctrl+C to stop${NC}"
echo ""

# Watch for changes and trigger reload
fswatch -r \
    --event=Updated \
    --event=Created \
    --event=Removed \
    --exclude='.*\.(git|DS_Store|log).*' \
    lib/ | while read file; do
    
    echo -e "${BLUE}📝 Changed: $(basename "$file")${NC}"
    trigger_reload
    echo ""
done