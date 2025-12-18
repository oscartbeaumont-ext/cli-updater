# Release Guide

This document explains how to create releases for `cli-updater` using the automated GitHub Actions workflows.

## Overview

The project includes two GitHub Actions workflows for creating releases:

1. **Tag Release** (`tag-release.yml`) - Automatically triggered when you push a version tag
2. **Manual Release** (`release.yml`) - Manually triggered via GitHub's workflow dispatch

Both workflows build binaries for multiple platforms and create GitHub releases with auto-generated release notes.

## Supported Platforms

The workflows build binaries for the following platforms:

### Linux
- `x86_64-unknown-linux-gnu` (glibc-based systems)
- `x86_64-unknown-linux-musl` (static binary, works on any Linux)
- `aarch64-unknown-linux-gnu` (ARM64 with glibc)
- `aarch64-unknown-linux-musl` (ARM64 static binary)

### macOS
- `x86_64-apple-darwin` (Intel Macs)
- `aarch64-apple-darwin` (Apple Silicon M1/M2)

### Windows
- `x86_64-pc-windows-msvc` (64-bit Windows)
- `aarch64-pc-windows-msvc` (ARM64 Windows)

## Method 1: Automatic Tag-Based Release (Recommended)

This is the easiest way to create releases. Simply create and push a version tag.

### Using the Release Script

The project includes a helper script that makes releasing easy:

```bash
# Create a stable release
./scripts/release.sh 1.0.0

# Create a pre-release
./scripts/release.sh 1.0.0-beta.1

# Preview what would happen (dry run)
./scripts/release.sh --dry-run 1.0.0

# Create tag locally but don't push yet
./scripts/release.sh --no-push 1.0.0
```

### Manual Tag Creation

If you prefer to create tags manually:

```bash
# Update version in Cargo.toml
sed -i 's/version = ".*"/version = "1.0.0"/' Cargo.toml

# Commit the version bump
git add Cargo.toml
git commit -m "chore: bump version to 1.0.0"

# Create and push the tag
git tag -a v1.0.0 -m "Release v1.0.0"
git push origin v1.0.0
```

### Version Format

Use semantic versioning (semver) for your tags:
- `v1.0.0` - Stable release
- `v1.0.0-beta.1` - Beta pre-release
- `v1.0.0-alpha.1` - Alpha pre-release  
- `v1.0.0-rc.1` - Release candidate

The workflow automatically detects pre-releases based on the presence of `alpha`, `beta`, or `rc` in the tag name.

## Method 2: Manual Workflow Dispatch

You can also trigger releases manually from the GitHub web interface:

1. Go to your repository on GitHub
2. Click on "Actions" tab
3. Select "Build and Release" workflow
4. Click "Run workflow"
5. Fill in the form:
   - **Tag**: The version tag (e.g., `v1.0.0`)
   - **Pre-release**: Check if this is a pre-release

## What Happens During a Release

1. **Build Phase**: 
   - Builds the Rust binary for all supported platforms
   - Uses cross-compilation tools for non-native targets
   - Packages binaries into compressed archives (`.tar.gz` for Unix, `.zip` for Windows)

2. **Release Creation**:
   - Downloads all built artifacts
   - Generates release notes from commit history since the last tag
   - Creates a GitHub release with all binary assets
   - Categorizes commits into Features, Bug Fixes, and Other Changes

3. **Version Update** (tag-based releases only):
   - Updates `Cargo.toml` with the new version number
   - Commits the version change back to the repository

## Release Notes

Release notes are automatically generated and include:

- **Changelog**: All commits since the last release, categorized by type
- **Platform Support**: List of all available binary downloads
- **Installation Instructions**: How to download and install the binary
- **Quick Install Commands**: One-liner installation commands for Unix systems

## Binary Naming Convention

Binaries follow this naming pattern:
```
cli-updater-{version}-{target}.{extension}
```

Examples:
- `cli-updater-v1.0.0-x86_64-unknown-linux-gnu.tar.gz`
- `cli-updater-v1.0.0-x86_64-apple-darwin.tar.gz` 
- `cli-updater-v1.0.0-x86_64-pc-windows-msvc.zip`

## Troubleshooting

### Build Failures

If a build fails for a specific platform:
1. Check the GitHub Actions logs for that platform
2. Common issues include missing system dependencies for cross-compilation
3. The workflow uses `cross` for cross-compilation, which runs builds in Docker containers

### Tag Already Exists

If you need to recreate a release:
```bash
# Delete the tag locally and remotely
git tag -d v1.0.0
git push origin --delete v1.0.0

# Delete the GitHub release through the web interface
# Then create the tag again
```

### Permission Issues

Make sure your repository has the following permissions enabled:
- **Actions**: Read and write permissions
- **Contents**: Write permissions (for creating releases)

## Best Practices

1. **Test Before Release**: Use `--dry-run` to preview what will happen
2. **Semantic Versioning**: Follow semver for version numbers
3. **Meaningful Commits**: Use conventional commit messages for better release notes
4. **Clean Working Directory**: Ensure no uncommitted changes before releasing
5. **Test Builds**: Consider testing critical platform builds locally with `cross`

## Commit Message Conventions

For better automated release notes, consider using conventional commits:

- `feat: add new feature` → Goes under "Features"
- `fix: resolve bug in parser` → Goes under "Bug Fixes"  
- `docs: update README` → Goes under "Other Changes"
- `chore: update dependencies` → Goes under "Other Changes"

## Security Considerations

- Release binaries are built in GitHub's secure runners
- No secrets or API keys are embedded in binaries
- All build steps are reproducible and auditable
- Cross-compilation uses official Rust toolchains and Docker images