# CLI Updater

A tool for updating CLI applications, built with Rust and featuring automated cross-platform releases.

## Features

- Cross-platform support (Linux, macOS, Windows)
- Multiple architectures (x86_64, ARM64)
- Automated GitHub Actions workflows for building and releasing
- Static binary support for maximum compatibility

## Installation

### Quick Install (Linux/macOS)

```bash
# Download the latest release for your platform
curl -L https://github.com/yourusername/cli-updater/releases/latest/download/cli-updater-v0.1.0-x86_64-unknown-linux-gnu.tar.gz | tar -xz
sudo mv cli-updater /usr/local/bin/
```

### Download Pre-built Binaries

Download the appropriate binary for your platform from the [releases page](https://github.com/yourusername/cli-updater/releases).

Available platforms:
- **Linux**: x86_64 and ARM64 (both glibc and musl variants)
- **macOS**: Intel (x86_64) and Apple Silicon (ARM64)
- **Windows**: x86_64 and ARM64

### Build from Source

```bash
git clone https://github.com/yourusername/cli-updater.git
cd cli-updater
cargo build --release
```

## Usage

```bash
# Show help
cli-updater --help

# Show version information
cli-updater --version
```

## Development

### Prerequisites

- Rust 1.70+ (with 2021 edition support)
- Git

### Building

```bash
# Debug build
cargo build

# Release build
cargo build --release

# Build for specific target
cargo build --release --target x86_64-unknown-linux-musl
```

### Testing

```bash
cargo test
```

### Cross-compilation

Install `cross` for easy cross-compilation:

```bash
cargo install cross --git https://github.com/cross-rs/cross
cross build --release --target aarch64-unknown-linux-gnu
```

## Releases

This project uses automated GitHub Actions workflows for building and releasing. See [RELEASE.md](RELEASE.md) for detailed information about the release process.

### Quick Release

```bash
# Create and push a new release
./scripts/release.sh 1.0.0
```

### Supported Platforms

The release workflows automatically build binaries for:

| Platform | Target | Notes |
|----------|---------|-------|
| Linux x64 | `x86_64-unknown-linux-gnu` | Standard Linux with glibc |
| Linux x64 Static | `x86_64-unknown-linux-musl` | Static binary, works everywhere |
| Linux ARM64 | `aarch64-unknown-linux-gnu` | ARM64 Linux with glibc |
| Linux ARM64 Static | `aarch64-unknown-linux-musl` | Static ARM64 binary |
| macOS Intel | `x86_64-apple-darwin` | Intel-based Macs |
| macOS Apple Silicon | `aarch64-apple-darwin` | M1/M2 Macs |
| Windows x64 | `x86_64-pc-windows-msvc` | 64-bit Windows |
| Windows ARM64 | `aarch64-pc-windows-msvc` | ARM64 Windows |

## Contributing

1. Fork the repository
2. Create a feature branch (`git checkout -b feature/amazing-feature`)
3. Commit your changes (`git commit -m 'Add amazing feature'`)
4. Push to the branch (`git push origin feature/amazing-feature`)
5. Open a Pull Request

## License

This project is licensed under either of

- Apache License, Version 2.0, ([LICENSE-APACHE](LICENSE-APACHE) or http://www.apache.org/licenses/LICENSE-2.0)
- MIT license ([LICENSE-MIT](LICENSE-MIT) or http://opensource.org/licenses/MIT)

at your option.

## Acknowledgments

- Built with [Rust](https://www.rust-lang.org/)
- Automated builds powered by [GitHub Actions](https://github.com/features/actions)
- Cross-compilation support via [`cross`](https://github.com/cross-rs/cross)