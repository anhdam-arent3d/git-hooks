#!/bin/bash

# Git pre-push hook to check for conflicts and missing main commits
# Place this file in: .git/hooks/pre-push (and make it executable)

remote="$1"
url="$2"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}🔍 Checking branch status before push...${NC}"

# Get current branch
current_branch=$(git rev-parse --abbrev-ref HEAD)
echo -e "Current branch: ${GREEN}$current_branch${NC}"

# Skip check if pushing to main
if [ "$current_branch" = "main" ] || [ "$current_branch" = "master" ]; then
    echo -e "${GREEN}✅ Pushing to main branch, skipping checks${NC}"
    exit 0
fi

# Fetch latest changes from remote
echo -e "${BLUE}📡 Fetching latest changes...${NC}"
git fetch origin main --quiet

# Check if main has new commits that current branch doesn't have
main_commits=$(git rev-list origin/main ^$current_branch --count)

if [ "$main_commits" -gt 0 ]; then
    echo -e "${YELLOW}⚠️  Warning: Main branch has $main_commits new commit(s) that your branch doesn't have${NC}"
    
    # Check for potential conflicts
    echo -e "${BLUE}🔍 Checking for potential conflicts...${NC}"
    
    # Try a test merge to see if there would be conflicts
    git merge-tree $(git merge-base origin/main $current_branch) origin/main $current_branch > /tmp/merge-test 2>/dev/null
    
    if [ -s /tmp/merge-test ]; then
        echo -e "${RED}⚠️  Potential merge conflicts detected!${NC}"
        echo -e "${YELLOW}Files that may have conflicts:${NC}"
        grep "<<<<<<< " /tmp/merge-test | sed 's/<<<<<<< .*//' | sort -u | head -5
    fi
    
    echo -e "\n${YELLOW}What would you like to do?${NC}"
    echo -e "1) ${GREEN}Merge${NC} main into current branch"
    echo -e "2) ${GREEN}Rebase${NC} current branch onto main"
    echo -e "3) ${YELLOW}Continue push anyway${NC}"
    echo -e "4) ${RED}Cancel push${NC}"
    
    # Fix for input reading in git hooks
    exec < /dev/tty
    read -p "Choose an option (1-4): " choice
    exec <&-
    
    case $choice in
        1)
            echo -e "${BLUE}🔄 Merging main into $current_branch...${NC}"
            git merge origin/main
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✅ Merge completed successfully!${NC}"
                echo -e "${BLUE}📤 Continuing with push...${NC}"
            else
                echo -e "${RED}❌ Merge failed due to conflicts. Please resolve them manually.${NC}"
                echo -e "${YELLOW}After resolving conflicts, run: git add . && git commit${NC}"
                exit 1
            fi
            ;;
        2)
            echo -e "${BLUE}🔄 Rebasing $current_branch onto main...${NC}"
            git rebase origin/main
            if [ $? -eq 0 ]; then
                echo -e "${GREEN}✅ Rebase completed successfully!${NC}"
                echo -e "${BLUE}📤 Continuing with push...${NC}"
            else
                echo -e "${RED}❌ Rebase failed due to conflicts. Please resolve them manually.${NC}"
                echo -e "${YELLOW}After resolving conflicts, run: git rebase --continue${NC}"
                exit 1
            fi
            ;;
        3)
            echo -e "${YELLOW}⚠️  Continuing push without updating from main...${NC}"
            ;;
        4)
            echo -e "${RED}❌ Push cancelled by user${NC}"
            exit 1
            ;;
        "")
            echo -e "${RED}❌ No input received. Push cancelled.${NC}"
            exit 1
            ;;
        *)
            echo -e "${RED}❌ Invalid choice '$choice'. Push cancelled.${NC}"
            exit 1
            ;;
    esac
else
    echo -e "${GREEN}✅ Your branch is up to date with main${NC}"
fi

# Additional check: ensure no uncommitted changes
if ! git diff-index --quiet HEAD --; then
    echo -e "${RED}❌ You have uncommitted changes. Please commit or stash them first.${NC}"
    exit 1
fi

echo -e "${GREEN}✅ All checks passed. Proceeding with push...${NC}"
exit 0
