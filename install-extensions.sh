#!/bin/bash

# VS Code/Cursor Extension Batch Installer
# Author: X-Zero-L
# Description: Install multiple VS Code/Cursor extensions from a file or predefined list

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration for parallel jobs
MAX_JOBS=4
PARALLEL=false

# Files
EXTENSIONS_FILE=""
LOG_FILE="extension-install.log"
FAILED_FILE="failed-extensions.txt"

# Detect the command (code, code-insiders, cursor, etc.)
detect_vscode_command() {
    if command -v cursor &> /dev/null; then
        echo "cursor"
    elif command -v code &> /dev/null; then
        echo "code"
    elif command -v code-insiders &> /dev/null; then
        echo "code-insiders"
    elif command -v codium &> /dev/null; then
        echo "codium"
    else
        echo ""
    fi
}

# Default extensions list (if no file provided)
DEFAULT_EXTENSIONS=(
    # Popular Extensions
    "ms-python.python"
    "ms-vscode.cpptools"
    "golang.go"
    "rust-lang.rust-analyzer"
    "dbaeumer.vscode-eslint"
    "esbenp.prettier-vscode"
    "PKief.material-icon-theme"
    "GitHub.copilot"
    "eamodio.gitlens"
    "ms-vscode-remote.remote-ssh"
    "ms-azuretools.vscode-docker"
    "hashicorp.terraform"
    "redhat.vscode-yaml"
    "ms-kubernetes-tools.vscode-kubernetes-tools"
    "Vue.volar"
    "bradlc.vscode-tailwindcss"
)

# Print banner
print_banner() {
    echo -e "${BLUE}"
    echo "╔══════════════════════════════════════════╗"
    echo "║   VS Code Extension Batch Installer      ║"
    echo "╚══════════════════════════════════════════╝"
    echo -e "${NC}"
}

# Print usage
usage() {
    echo -e "${YELLOW}Usage:${NC}"
    echo "  $0 [options] [extensions-file]"
    echo ""
    echo -e "${YELLOW}Options:${NC}"
    echo "  -p, --parallel         Enable parallel installation (default: 4 jobs)"
    echo "  --jobs=N               Set number of parallel jobs (default: 4)"
    echo "  -h, --help             Show this help"
    echo "  --create-sample        Create a sample extensions file"
    echo ""
    echo -e "${YELLOW}Arguments:${NC}"
    echo "  extensions-file        Text file with one extension ID per line (default: extensions.txt)"
    echo ""
    echo -e "${YELLOW}Examples:${NC}"
    echo "  $0                              # Sequential installation from extensions.txt"
    echo "  $0 --parallel                   # Parallel installation with 4 jobs"
    echo "  $0 --parallel --jobs=8          # Parallel installation with 8 jobs"
    echo "  $0 -p my-extensions.txt         # Parallel installation from custom file"
    echo ""
    echo -e "${YELLOW}Extension File Format:${NC}"
    echo "  ms-python.python"
    echo "  ms-vscode.cpptools"
    echo "  # Comments are supported"
    echo "  golang.go"
}

# Create sample extensions file function
create_sample_file() {
    cat > extensions-sample.txt << 'EOF'
# VS Code Extensions List
# One extension ID per line
# Lines starting with # are comments

# Python Development
ms-python.python
ms-python.vscode-pylance
ms-toolsai.jupyter

# Web Development
dbaeumer.vscode-eslint
esbenp.prettier-vscode
bradlc.vscode-tailwindcss
Vue.volar

# Git
eamodio.gitlens
GitHub.copilot

# Themes and Icons
PKief.material-icon-theme
zhuangtongfa.material-theme

# Remote Development
ms-vscode-remote.remote-ssh
ms-azuretools.vscode-docker

# Language Support
golang.go
rust-lang.rust-analyzer
ms-vscode.cpptools

# Utilities
aaron-bond.better-comments
wayou.vscode-todo-highlight
gruntfuggly.todo-tree
EOF
    echo -e "${GREEN}Sample file created:${NC} extensions-sample.txt"
}

# Main installation function
install_extension() {
    local ext="$1"
    local cmd="$2"
    
    echo -n -e "Installing ${BLUE}$ext${NC}... "
    
    if $cmd --install-extension "$ext" &>> "$LOG_FILE"; then
        echo -e "${GREEN}✓ Success${NC}"
        return 0
    else
        echo -e "${RED}✗ Failed${NC}"
        echo "$ext" >> "$FAILED_FILE"
        return 1
    fi
}

# Parallel installation function
install_extension_parallel() {
    local ext="$1"
    local cmd="$2"
    local temp_file="/tmp/vscode-ext-$$-${ext//[^a-zA-Z0-9]/_}.tmp"
    
    {
        if $cmd --install-extension "$ext" &> "$temp_file"; then
            echo -e "${GREEN}✓${NC} $ext"
            echo "SUCCESS: $ext" >> "$LOG_FILE"
            rm -f "$temp_file"
            exit 0
        else
            echo -e "${RED}✗${NC} $ext"
            echo "FAILED: $ext" >> "$LOG_FILE"
            cat "$temp_file" >> "$LOG_FILE"
            echo "$ext" >> "$FAILED_FILE"
            rm -f "$temp_file"
            exit 1
        fi
    } &
}

# Wait for a job slot
wait_for_slot() {
    while [[ $(jobs -r | wc -l) -ge $MAX_JOBS ]]; do
        sleep 0.1
    done
}

# Parse command line arguments
ARGS=()
while [[ $# -gt 0 ]]; do
    case $1 in
        -h|--help)
            usage
            exit 0
            ;;
        --create-sample)
            create_sample_file
            exit 0
            ;;
        -p|--parallel)
            PARALLEL=true
            shift
            ;;
        --jobs=*)
            MAX_JOBS="${1#*=}"
            shift
            ;;
        -*)
            echo -e "${RED}Unknown option: $1${NC}"
            usage
            exit 1
            ;;
        *)
            ARGS+=("$1")
            shift
            ;;
    esac
done

# Set extensions file
if [[ ${#ARGS[@]} -gt 0 ]]; then
    EXTENSIONS_FILE="${ARGS[0]}"
else
    EXTENSIONS_FILE="extensions.txt"
fi

# Main function
main() {
    print_banner
    
    # Detect VS Code command
    VSCODE_CMD=$(detect_vscode_command)
    
    if [[ -z "$VSCODE_CMD" ]]; then
        echo -e "${RED}Error: No VS Code variant found (code, cursor, codium, etc.)${NC}"
        echo "Please install VS Code or Cursor first."
        exit 1
    fi
    
    echo -e "${GREEN}Found command:${NC} $VSCODE_CMD"
    echo ""
    
    # Prepare log files
    > "$LOG_FILE"
    > "$FAILED_FILE"
    
    # Load extensions
    extensions=()
    
    if [[ -f "$EXTENSIONS_FILE" ]]; then
        echo -e "${BLUE}Loading extensions from:${NC} $EXTENSIONS_FILE"
        
        # Read entire file into array
        mapfile -t lines < "$EXTENSIONS_FILE"
        
        # Process each line
        for line in "${lines[@]}"; do
            # Skip empty lines and comments
            [[ -z "$line" || "$line" =~ ^[[:space:]]*# ]] && continue
            
            # Trim whitespace and carriage returns
            ext=$(echo "$line" | tr -d '\r' | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
            
            # Add non-empty extensions
            [[ -n "$ext" ]] && extensions+=("$ext")
        done
    else
        echo -e "${YELLOW}No extensions file found. Using default list.${NC}"
        extensions=("${DEFAULT_EXTENSIONS[@]}")
    fi
    
    # Debug: Show first few extensions if less than total
    if [[ ${#extensions[@]} -gt 0 && ${#extensions[@]} -lt 10 ]]; then
        echo -e "${BLUE}Extensions found:${NC}"
        for ext in "${extensions[@]}"; do
            echo "  - $ext"
        done
    fi
    
    # Check if we have extensions to install
    if [[ ${#extensions[@]} -eq 0 ]]; then
        echo -e "${RED}No extensions to install.${NC}"
        exit 1
    fi
    
    echo -e "${BLUE}Extensions to install:${NC} ${#extensions[@]}"
    if [[ "$PARALLEL" == true ]]; then
        echo -e "${YELLOW}Parallel mode:${NC} $MAX_JOBS jobs"
    fi
    echo ""
    
    # Install extensions
    success_count=0
    fail_count=0
    total=${#extensions[@]}
    current=0
    
    if [[ "$PARALLEL" == true ]]; then
        # Parallel installation
        echo -e "${BLUE}Installing extensions in parallel...${NC}"
        
        for ext in "${extensions[@]}"; do
            wait_for_slot
            install_extension_parallel "$ext" "$VSCODE_CMD"
        done
        
        # Wait for all jobs to complete
        wait
        
        # Count results
        success_count=$(grep -c "^SUCCESS:" "$LOG_FILE" 2>/dev/null || echo 0)
        fail_count=$(grep -c "^FAILED:" "$LOG_FILE" 2>/dev/null || echo 0)
    else
        # Sequential installation
        for ext in "${extensions[@]}"; do
            ((current++))
            echo -n "[$current/$total] "
            
            if install_extension "$ext" "$VSCODE_CMD"; then
                ((success_count++))
            else
                ((fail_count++))
            fi
        done
    fi
    
    # Summary
    echo ""
    echo -e "${BLUE}════════════════════════════════════════${NC}"
    echo -e "${GREEN}✓ Successfully installed:${NC} $success_count"
    echo -e "${RED}✗ Failed:${NC} $fail_count"
    
    if [[ $fail_count -gt 0 ]]; then
        echo ""
        echo -e "${YELLOW}Failed extensions saved to:${NC} $FAILED_FILE"
        echo -e "${YELLOW}Check log for details:${NC} $LOG_FILE"
    fi
}

# Run main function
main