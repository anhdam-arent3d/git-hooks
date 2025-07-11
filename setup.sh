#!/bin/bash

# Git Pre-Push Hook Setup Script
# Usage: curl -sSL https://raw.githubusercontent.com/anhdam-arent3d/git-hooks/main/setup.sh | bash

set -e

GREEN='\033[0;32m'
BLUE='\033[0;34m'
YELLOW='\033[1;33m'
RED='\033[0;31m'
NC='\033[0m'

echo -e "${BLUE}🚀 Installing Git Pre-Push Hook by anhdam-arent3d...${NC}"

# Check if we're in a git repository
if [ ! -d ".git" ]; then
    echo -e "${RED}❌ Error: Not in a git repository. Please run this command from your project root.${NC}"
    exit 1
fi

# Create hooks directory if it doesn't exist
mkdir -p .git/hooks

# Backup existing hook if it exists
if [ -f ".git/hooks/pre-push" ]; then
    echo -e "${YELLOW}📋 Backing up existing pre-push hook...${NC}"
    mv .git/hooks/pre-push .git/hooks/pre-push.bak.$(date +%Y%m%d_%H%M%S)
fi

# Download the pre-push hook
HOOK_URL="https://raw.githubusercontent.com/anhdam-arent3d/git-hooks/main/pre-push.sh"

echo -e "${BLUE}📥 Downloading pre-push hook from GitHub...${NC}"

# Try curl first, then wget
if command -v curl >/dev/null 2>&1; then
    if curl -sSL "$HOOK_URL" -o .git/hooks/pre-push; then
        echo -e "${GREEN}✅ Downloaded successfully using curl${NC}"
    else
        echo -e "${RED}❌ Failed to download with curl${NC}"
        exit 1
    fi
elif command -v wget >/dev/null 2>&1; then
    if wget -q "$HOOK_URL" -O .git/hooks/pre-push; then
        echo -e "${GREEN}✅ Downloaded successfully using wget${NC}"
    else
        echo -e "${RED}❌ Failed to download with wget${NC}"
        exit 1
    fi
else
    echo -e "${RED}❌ Error: Neither curl nor wget found. Please install one of them.${NC}"
    exit 1
fi

# Make the hook executable
chmod +x .git/hooks/pre-push

# Verify the hook was installed correctly
if [ -x ".git/hooks/pre-push" ]; then
    echo -e "${GREEN}✅ Git pre-push hook installed successfully!${NC}"
else
    echo -e "${RED}❌ Error: Hook installation failed${NC}"
    exit 1
fi

echo -e "\n${BLUE}📋 The hook will now automatically:${NC}"
echo -e "   • 🔍 Check for new commits in main branch before push"
echo -e "   • ⚠️  Detect potential merge conflicts"
echo -e "   • 🔄 Offer to merge/rebase main into your branch"
echo -e "   • 🚫 Prevent pushes with uncommitted changes"
echo -e "   • 🎨 Show colorful, easy-to-read output"

echo -e "\n${YELLOW}💡 Test the hook by pushing to a feature branch:${NC}"
echo -e "   ${BLUE}git checkout -b test-feature${NC}"
echo -e "   ${BLUE}git push origin test-feature${NC}"

echo -e "\n${YELLOW}🔧 To uninstall the hook:${NC}"
echo -e "   ${BLUE}rm .git/hooks/pre-push${NC}"

echo -e "\n${GREEN}🎉 Setup complete! Happy coding! 🚀${NC}"
echo -e "${BLUE}📖 Source: https://github.com/anhdam-arent3d/git-hooks${NC}"
