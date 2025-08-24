#!/bin/bash
set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
NC='\033[0m' # No Color

echo -e "${GREEN}🚀 Starting Flutter Web Build${NC}"

# Install Flutter if not cached
if [ ! -d "/opt/build/cache/flutter" ]; then
    echo -e "${YELLOW}📦 Installing Flutter SDK...${NC}"
    mkdir -p /opt/build/cache
    cd /opt/build/cache
    git clone https://github.com/flutter/flutter.git -b stable --depth 1
    echo -e "${GREEN}✅ Flutter SDK installed${NC}"
else
    echo -e "${GREEN}✅ Flutter SDK found in cache${NC}"
fi

# Set Flutter PATH
export PATH="$PATH:/opt/build/cache/flutter/bin"

# Verify Flutter installation
echo -e "${YELLOW}🔍 Verifying Flutter installation...${NC}"
flutter --version

# Configure Flutter for web
echo -e "${YELLOW}⚙️ Configuring Flutter for web...${NC}"
flutter config --enable-web
flutter precache --web

# Navigate to project directory
cd /opt/build/repo

# Get dependencies
echo -e "${YELLOW}📋 Getting Flutter dependencies...${NC}"
flutter pub get

# Build web app
echo -e "${YELLOW}🔨 Building Flutter web app...${NC}"
flutter build web --base-href / --release

echo -e "${GREEN}🎉 Build completed successfully!${NC}"