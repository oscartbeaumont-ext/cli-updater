# Release System Usage Examples

This document provides practical examples of how to use the automated release system for `cli-updater`.

## Quick Start

The easiest way to create a release is using the provided script:

```bash
# Make sure the script is executable
chmod +x scripts/release.sh

# Create your first release
./scripts/release.sh 0.1.0
```

## Example Release Scenarios

### 1. Creating Your First Stable Release

```bash
# Preview what will happen
./scripts/release.sh --dry-run 1.0.0

# If everything looks good, create the release
./scripts/release.sh 1.0.0
```

**What happens:**
- Updates `Cargo.toml` version to `1.0.0`
- Creates git tag `v1.0.0`
- Pushes to GitHub
- Triggers automated build for all platforms
- Creates GitHub release with generated release notes

### 2. Creating a Beta Release

```bash
./scripts/release.sh 1.1.0-beta.1
```

**Result:**
- Creates a pre-release on GitHub
- Binaries are built but marked as beta
- Won't be marked as "latest" release

### 3. Creating an Alpha Release

```bash
./scripts/release.sh 2.0.0-alpha.1
```

### 4. Manual Tag Creation (Alternative Method)

If you prefer to work with git directly:

```bash
# Update version manually
sed -i 's/version = ".*"/version = "1.2.0"/' Cargo.toml

# Commit the version bump
git add Cargo.toml
git commit -m "chore: bump version to 1.2.0"

# Create and push tag
git tag -a v1.2.0 -m "Release v1.2.0"
git push origin v1.2.0
```

### 5. Using GitHub Web Interface

1. Go to `https://github.com/yourusername/cli-updater/actions`
2. Click on "Build and Release" workflow
3. Click "Run workflow" button
4. Fill in:
   - **Tag**: `v1.3.0`
   - **Pre-release**: ☐ (unchecked for stable release)
5. Click "Run workflow"

## Real-World Workflow Examples

### Example 1: Feature Release

You've added a new feature and want to release it:

```bash
# Make sure your changes are committed
git status

# Preview the release
./scripts/release.sh --dry-run 1.1.0

# Check what commits will be included
git log v1.0.0..HEAD --oneline

# Create the release
./scripts/release.sh 1.1.0
```

### Example 2: Hotfix Release

You've fixed a critical bug and need to release quickly:

```bash
# Create patch release
./scripts/release.sh 1.0.1

# Monitor the build progress
# https://github.com/yourusername/cli-updater/actions
```

### Example 3: Testing a Release Candidate

Before a major release, create an RC for testing:

```bash
# Create release candidate
./scripts/release.sh 2.0.0-rc.1

# After testing, create final release
./scripts/release.sh 2.0.0
```

### Example 4: Local Testing Only

Test tag creation without pushing:

```bash
# Create tag locally but don't trigger build
./scripts/release.sh --no-push 1.2.0

# Later, push to trigger build
git push origin v1.2.0
```

## Monitoring Releases

### Check Build Status

After creating a release, monitor the build progress:

```bash
# Open the Actions page in your browser
open https://github.com/yourusername/cli-updater/actions
```

### Download and Test Binaries

Once the release is complete:

```bash
# Download and test Linux binary
curl -L https://github.com/yourusername/cli-updater/releases/download/v1.0.0/cli-updater-v1.0.0-x86_64-unknown-linux-gnu.tar.gz | tar -xz
./cli-updater --version

# Download and test macOS binary
curl -L https://github.com/yourusername/cli-updater/releases/download/v1.0.0/cli-updater-v1.0.0-x86_64-apple-darwin.tar.gz | tar -xz
./cli-updater --version
```

## Generated Assets

Each release automatically generates:

### Binary Archives
- `cli-updater-v1.0.0-x86_64-unknown-linux-gnu.tar.gz`
- `cli-updater-v1.0.0-x86_64-unknown-linux-musl.tar.gz`
- `cli-updater-v1.0.0-aarch64-unknown-linux-gnu.tar.gz`
- `cli-updater-v1.0.0-aarch64-unknown-linux-musl.tar.gz`
- `cli-updater-v1.0.0-x86_64-apple-darwin.tar.gz`
- `cli-updater-v1.0.0-aarch64-apple-darwin.tar.gz`
- `cli-updater-v1.0.0-x86_64-pc-windows-msvc.zip`
- `cli-updater-v1.0.0-aarch64-pc-windows-msvc.zip`

### Release Notes
Auto-generated with:
- Commit changelog since last release
- Platform-specific download links  
- Installation instructions
- Version information

## Troubleshooting Common Issues

### Issue: "Tag already exists"

```bash
# Delete tag locally and remotely
git tag -d v1.0.0
git push origin --delete v1.0.0

# Delete the release on GitHub web interface
# Then create the tag again
```

### Issue: Build failure for specific platform

1. Check the Actions logs for that specific platform
2. Common issues:
   - Missing cross-compilation dependencies
   - Target platform not supported
   - Network issues downloading dependencies

### Issue: "Working directory not clean"

```bash
# Check what files are modified
git status

# Either commit the changes
git add .
git commit -m "fix: prepare for release"

# Or stash them temporarily  
git stash
```

### Issue: Version format error

```bash
# ❌ Invalid formats
./scripts/release.sh 1.0          # Missing patch version
./scripts/release.sh v1.0.0       # Script adds 'v' automatically
./scripts/release.sh 1.0.0.1      # Too many version components

# ✅ Valid formats
./scripts/release.sh 1.0.0
./scripts/release.sh 1.0.0-beta.1
./scripts/release.sh 1.0.0-alpha.1
./scripts/release.sh 1.0.0-rc.1
```

## Best Practices

1. **Test before releasing**: Always use `--dry-run` first
2. **Follow semantic versioning**: Major.Minor.Patch
3. **Write good commit messages**: They become your changelog
4. **Test critical platforms**: Download and test key binaries
5. **Keep a clean history**: Squash feature branches before release
6. **Document breaking changes**: Note them in commit messages

## Integration with CI/CD

You can also trigger releases from other CI systems:

```bash
# From another CI system, trigger a release
curl -X POST \
  -H "Authorization: token $GITHUB_TOKEN" \
  -H "Accept: application/vnd.github.v3+json" \
  https://api.github.com/repos/yourusername/cli-updater/actions/workflows/release.yml/dispatches \
  -d '{"ref":"main","inputs":{"tag":"v1.0.0","prerelease":false}}'
```

## Version Strategy Examples

### Conservative Approach
- `v0.1.0`, `v0.2.0`, `v0.3.0` - Minor releases during development
- `v1.0.0` - First stable release
- `v1.0.1`, `v1.0.2` - Patch releases
- `v1.1.0` - Feature releases

### Aggressive Development
- `v0.1.0-alpha.1`, `v0.1.0-alpha.2` - Early development
- `v0.1.0-beta.1` - Beta testing
- `v0.1.0-rc.1` - Release candidate
- `v0.1.0` - Stable release

Choose the approach that best fits your project's needs!