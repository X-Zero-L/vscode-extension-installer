# VS Code Extension Installer

🚀 A powerful bash script to batch install VS Code/Cursor/VSCodium extensions with ease.

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![PRs Welcome](https://img.shields.io/badge/PRs-welcome-brightgreen.svg)](https://github.com/X-Zero-L/vscode-extension-installer/pulls)

## ✨ Features

- 🔍 **Auto-detection** of VS Code variants (Code, Cursor, Codium, Insiders)
- 📦 **Batch installation** from file or predefined list
- ⚡ **Parallel installation** support for faster setup
- 🎨 **Colorful output** with progress indicators
- 📝 **Logging support** with failed extension tracking
- 💾 **Export/Import** existing extensions across machines
- 🔧 **Zero dependencies** - pure bash solution
- 📊 **Progress tracking** with success/failure statistics

## 📋 Requirements

- Bash 4.0+
- VS Code, Cursor, VSCodium, or VS Code Insiders installed
- Internet connection for downloading extensions

## 🚀 Quick Start

### Installation

```bash
# Clone the repository
git clone https://github.com/X-Zero-L/vscode-extension-installer.git
cd vscode-extension-installer

# Make the script executable
chmod +x install-extensions.sh
```

### Basic Usage

```bash
# Install using default extension list
./install-extensions.sh

# Install from custom file
./install-extensions.sh my-extensions.txt

# Create a sample extensions file
./install-extensions.sh --create-sample
```

## 🎯 Command Line Options

| Option | Description |
|--------|-------------|
| `[file]` | Path to extensions file (default: `extensions.txt`) |
| `-p`, `--parallel` | Enable parallel installation (default: 4 concurrent jobs) |
| `--jobs=N` | Set number of parallel jobs (default: 4) |
| `-h`, `--help` | Show help message |
| `--create-sample` | Create a sample extensions file |

## 📖 Usage Examples

### 1. Sequential Installation (Default)

```bash
# Install extensions one by one
./install-extensions.sh extensions.txt
```

Output:
```
[1/81] Installing ms-python.python... ✓ Success
[2/81] Installing golang.go... ✓ Success
[3/81] Installing rust-lang.rust-analyzer... ✓ Success
```

### 2. Parallel Installation (Faster)

```bash
# Install with 4 parallel jobs (default)
./install-extensions.sh --parallel

# Install with 8 parallel jobs
./install-extensions.sh --parallel --jobs=8

# Short form
./install-extensions.sh -p extensions.txt
```

Output:
```
Installing extensions in parallel...
✓ ms-python.python
✓ golang.go
✓ rust-lang.rust-analyzer
✓ dbaeumer.vscode-eslint
```

### 3. Export Current Extensions

```bash
# For VS Code
code --list-extensions > my-extensions.txt

# For Cursor
cursor --list-extensions > my-extensions.txt

# For VSCodium
codium --list-extensions > my-extensions.txt
```

### 4. Install on New Machine

```bash
# Copy your extensions file to the new machine, then:
./install-extensions.sh my-extensions.txt
```

## 📄 Extension File Format

The extension file supports:
- One extension ID per line
- Comments (lines starting with `#`)
- Empty lines (ignored)
- Whitespace trimming
- Windows/Unix line endings

Example `extensions.txt`:
```txt
# Development Tools
ms-python.python
ms-python.vscode-pylance
golang.go

# Web Development
dbaeumer.vscode-eslint
esbenp.prettier-vscode
bradlc.vscode-tailwindcss

# Git Integration
eamodio.gitlens
GitHub.copilot

# Themes and Icons
PKief.material-icon-theme
```

## 🔍 Supported Editors

- ✅ Visual Studio Code (`code`)
- ✅ VS Code Insiders (`code-insiders`)
- ✅ Cursor (`cursor`)
- ✅ VSCodium (`codium`)

## 📊 Output

The script provides:
- Real-time installation progress
- Color-coded success/failure indicators
- Summary statistics
- Failed extensions list (`failed-extensions.txt`)
- Detailed log file (`extension-install.log`)

Example output:
```
╔══════════════════════════════════════════╗
║   VS Code Extension Batch Installer      ║
╚══════════════════════════════════════════╝
Found command: cursor

Loading extensions from: extensions.txt
Extensions to install: 81

[1/81] Installing ms-python.python... ✓ Success
[2/81] Installing golang.go... ✓ Success
[3/81] Installing invalid.extension... ✗ Failed

════════════════════════════════════════
✓ Successfully installed: 80
✗ Failed: 1

Failed extensions saved to: failed-extensions.txt
```

## ⚡ Performance Tips

1. **Use Parallel Mode** for faster installation:
   ```bash
   ./install-extensions.sh --parallel --jobs=8
   ```

2. **Check your internet connection** - slow downloads will affect installation time

3. **Remove duplicates** from your extensions file:
   ```bash
   sort -u extensions.txt > extensions-unique.txt
   ```

## 🛠️ Troubleshooting

### Common Issues

1. **Script exits after first extension**
   - Check file encoding: `file extensions.txt`
   - Convert to Unix format: `dos2unix extensions.txt`
   - Ensure no special characters in extension IDs

2. **Command not found**
   - Ensure VS Code/Cursor is installed and in PATH
   - Try restarting your terminal
   - Check with: `which code` or `which cursor`

3. **Extension installation fails**
   - Check internet connection
   - Verify extension ID is correct
   - Check the log file: `cat extension-install.log`
   - Some extensions may be deprecated or removed

4. **Permission denied**
   - Run: `chmod +x install-extensions.sh`

### Debug Mode

Check what's being loaded:
```bash
# See parsed extensions
cat -A extensions.txt | head -10

# Check log file
tail -f extension-install.log
```

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the repository
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📝 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🙏 Acknowledgments

- Inspired by the need for easy VS Code setup across multiple machines
- Thanks to all contributors and users

## 🔗 Related Projects

- [code-settings-sync](https://github.com/shanalikhan/code-settings-sync) - Synchronize settings
- [vscode-extension-packs](https://code.visualstudio.com/docs/editor/extension-marketplace#_extension-packs) - Official extension packs

---

Made with ❤️ by developers, for developers