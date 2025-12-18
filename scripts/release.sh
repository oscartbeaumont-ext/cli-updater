#!/bin/bash
set -euo pipefail

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Help function
show_help() {
    echo "Usage: $0 [OPTIONS] <version>"
    echo ""
    echo "Create and push a release tag for cli-updater"
    echo ""
    echo "Arguments:"
    echo "  version     Version to release (e.g., 1.0.0, 1.0.0-beta.1)"
    echo ""
    echo "Options:"
    echo "  -h, --help          Show this help message"
    echo "  -p, --prerelease    Mark as pre-release (auto-detected for alpha/beta/rc)"
    echo "  -n, --dry-run       Show what would be done without actually doing it"
    echo "  --no-push           Create tag locally but don't push (for testing)"
    echo ""
    echo "Examples:"
    echo "  $0 1.0.0                  # Create stable release v1.0.0"
    echo "  $0 1.0.0-beta.1           # Create pre-release v1.0.0-beta.1"
    echo "  $0 --dry-run 1.0.0        # Preview what would happen"
    echo "  $0 --no-push 1.0.0        # Create tag locally only"
}

# Parse arguments
DRY_RUN=false
NO_PUSH=false
FORCE_PRERELEASE=false

while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            show_help
            exit 0
            ;;
        -p|--prerelease)
            FORCE_PRERELEASE=true
            shift
            ;;
        -n|--dry-run)
            DRY_RUN=true
            shift
            ;;
        --no-push)
            NO_PUSH=true
            shift
            ;;
        -*)
            echo -e "${RED}Error: Unknown option $1${NC}"
            show_help
            exit 1
            ;;
        *)
            VERSION="$1"
            shift
            ;;
    esac
done

# Check if version is provided
if [ -z "${VERSION:-}" ]; then
    echo -e "${RED}Error: Version is required${NC}"
    show_help
    exit 1
fi

# Validate version format
if ! [[ $VERSION =~ ^[0-9]+\.[0-9]+\.[0-9]+(-[a-zA-Z0-9.-]+)?$ ]]; then
    echo -e "${RED}Error: Invalid version format. Use semantic versioning (e.g., 1.0.0, 1.0.0-beta.1)${NC}"
    exit 1
fi

# Add 'v' prefix if not present
if [[ ! $VERSION =~ ^v ]]; then
    TAG="v$VERSION"
else
    TAG="$VERSION"
    VERSION="${VERSION#v}"
fi

# Check if we're in a git repository
if ! git rev-parse --git-dir > /dev/null 2>&1; then
    echo -e "${RED}Error: Not in a git repository${NC}"
    exit 1
fi

# Check if working directory is clean
if ! git diff-index --quiet HEAD --; then
    echo -e "${RED}Error: Working directory is not clean. Please commit or stash your changes.${NC}"
    exit 1
fi

# Check if tag already exists
if git tag -l | grep -q "^$TAG$"; then
    echo -e "${RED}Error: Tag $TAG already exists${NC}"
    exit 1
fi

# Determine if this is a pre-release
IS_PRERELEASE=false
if [[ $VERSION == *"alpha"* ]] || [[ $VERSION == *"beta"* ]] || [[ $VERSION == *"rc"* ]] || [[ $FORCE_PRERELEASE == true ]]; then
    IS_PRERELEASE=true
fi

# Get current branch
CURRENT_BRANCH=$(git branch --show-current)

# Show what we're going to do
echo -e "${BLUE}=== Release Configuration ===${NC}"
echo -e "Version: ${GREEN}$VERSION${NC}"
echo -e "Tag: ${GREEN}$TAG${NC}"
echo -e "Branch: ${GREEN}$CURRENT_BRANCH${NC}"
echo -e "Pre-release: ${GREEN}$IS_PRERELEASE${NC}"
echo -e "Dry run: ${GREEN}$DRY_RUN${NC}"
echo ""

# Get the latest commits for preview
echo -e "${BLUE}=== Recent Commits ===${NC}"
git log --oneline -10
echo ""

# Get last tag for comparison
LAST_TAG=$(git tag --sort=-version:refname | head -n 1 2>/dev/null || echo "none")
if [[ "$LAST_TAG" != "none" ]]; then
    echo -e "${BLUE}=== Changes since $LAST_TAG ===${NC}"
    git log --oneline "$LAST_TAG..HEAD"
    echo ""
fi

if [[ $DRY_RUN == true ]]; then
    echo -e "${YELLOW}=== DRY RUN MODE - No changes will be made ===${NC}"
    echo "Would execute:"
    echo "1. git tag -a $TAG -m 'Release $TAG'"
    if [[ $NO_PUSH == false ]]; then
        echo "2. git push origin $TAG"
        echo "3. GitHub Actions will automatically build and create the release"
    fi
    exit 0
fi

# Confirm before proceeding
if [[ $IS_PRERELEASE == true ]]; then
    echo -e "${YELLOW}⚠️  This will create a PRE-RELEASE${NC}"
else
    echo -e "${GREEN}✅ This will create a STABLE RELEASE${NC}"
fi

read -p "Do you want to continue? (y/N): " -n 1 -r
echo
if [[ ! $REPLY =~ ^[Yy]$ ]]; then
    echo -e "${YELLOW}Cancelled${NC}"
    exit 0
fi

echo -e "${BLUE}=== Creating Release ===${NC}"

# Update Cargo.toml version
echo -e "${BLUE}Updating Cargo.toml version to $VERSION${NC}"
if command -v sed >/dev/null 2>&1; then
    if [[ "$OSTYPE" == "darwin"* ]]; then
        sed -i '' "s/^version = \".*\"/version = \"$VERSION\"/" Cargo.toml
    else
        sed -i "s/^version = \".*\"/version = \"$VERSION\"/" Cargo.toml
    fi
else
    echo -e "${RED}Error: sed command not found${NC}"
    exit 1
fi

# Check if Cargo.toml was updated
if git diff --quiet Cargo.toml; then
    echo -e "${YELLOW}No changes needed in Cargo.toml${NC}"
else
    echo -e "${GREEN}Updated version in Cargo.toml${NC}"
    git add Cargo.toml
    git commit -m "chore: bump version to $VERSION"
fi

# Create the tag
echo -e "${BLUE}Creating tag $TAG${NC}"
git tag -a "$TAG" -m "Release $TAG"

if [[ $NO_PUSH == true ]]; then
    echo -e "${GREEN}✅ Tag $TAG created locally${NC}"
    echo -e "${YELLOW}Use 'git push origin $TAG' to trigger the release build${NC}"
else
    # Push the tag
    echo -e "${BLUE}Pushing tag to origin${NC}"
    git push origin "$TAG"

    echo -e "${GREEN}✅ Release $TAG has been created and pushed!${NC}"
    echo ""
    echo -e "${BLUE}=== Next Steps ===${NC}"
    echo "1. GitHub Actions will automatically build binaries for all platforms"
    echo "2. A release will be created with auto-generated release notes"
    echo "3. Monitor the progress at: https://github.com/$(git remote get-url origin | sed 's/.*github\.com[:/]\([^.]*\)\.git/\1/')/actions"
    echo ""
    echo -e "${BLUE}Release URL will be:${NC}"
    echo "https://github.com/$(git remote get-url origin | sed 's/.*github\.com[:/]\([^.]*\)\.git/\1/')/releases/tag/$TAG"
fi
