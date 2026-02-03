#!/bin/bash
# initial_setup.sh - Comprehensive MacMind development environment setup
# Run this once after cloning the repository

set -e

PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
TOOLING_DIR="$PROJECT_DIR/tooling"
EMULATION_DIR="$PROJECT_DIR/emulation"

# Colors
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
BOLD='\033[1m'
NC='\033[0m'

log_info() { echo -e "${BLUE}ℹ${NC} $1"; }
log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_warn() { echo -e "${YELLOW}⚠${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1"; }
log_step() { echo -e "\n${BOLD}▸ $1${NC}"; }

# Track what needs manual action
MANUAL_STEPS=()

add_manual_step() {
    MANUAL_STEPS+=("$1")
}

# ============================================================================
# Dependency checks and installation
# ============================================================================

check_homebrew() {
    log_step "Checking Homebrew"

    if command -v brew &> /dev/null; then
        log_success "Homebrew is installed"
        return 0
    fi

    log_info "Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

    # Add to path for Apple Silicon
    if [[ -f /opt/homebrew/bin/brew ]]; then
        eval "$(/opt/homebrew/bin/brew shellenv)"
    fi

    log_success "Homebrew installed"
}

check_docker() {
    log_step "Checking Docker"

    if command -v docker &> /dev/null; then
        log_success "Docker is installed"

        if docker info &> /dev/null; then
            log_success "Docker daemon is running"
        else
            log_warn "Docker is installed but not running"
            add_manual_step "Start Docker Desktop before building"
        fi
        return 0
    fi

    log_info "Docker not found"

    if command -v brew &> /dev/null; then
        log_info "Installing Docker via Homebrew..."
        brew install --cask docker
        log_success "Docker installed"
        add_manual_step "Open Docker Desktop to complete setup, then run this script again"
    else
        log_error "Cannot install Docker without Homebrew"
        add_manual_step "Install Docker Desktop from https://docker.com/products/docker-desktop"
    fi
}

check_brew_packages() {
    log_step "Checking development tools"

    local packages=("fswatch" "hfsutils" "cmake")
    local missing=()

    for pkg in "${packages[@]}"; do
        if brew list "$pkg" &> /dev/null; then
            log_success "$pkg is installed"
        else
            missing+=("$pkg")
        fi
    done

    if [ ${#missing[@]} -ne 0 ]; then
        log_info "Installing missing packages: ${missing[*]}"
        brew install "${missing[@]}"
        log_success "Packages installed"
    fi
}

# ============================================================================
# Tooling setup
# ============================================================================

setup_tooling() {
    log_step "Setting up tooling directory"

    mkdir -p "$TOOLING_DIR"
    cd "$TOOLING_DIR"

    # Clone Retro68
    if [ -d "Retro68" ]; then
        log_success "Retro68 already cloned"
    else
        log_info "Cloning Retro68 (this may take a moment)..."
        git clone --depth 1 https://github.com/autc04/Retro68.git
        log_success "Retro68 cloned"
    fi

    # Clone tty0tty (virtual serial ports)
    if [ -d "tty0tty" ]; then
        log_success "tty0tty already cloned"
    else
        log_info "Cloning tty0tty..."
        git clone https://github.com/freemed/tty0tty.git 2>/dev/null || \
        git clone git@github.com:freemed/tty0tty.git
        log_success "tty0tty cloned"
    fi

    cd "$PROJECT_DIR"
}

# ============================================================================
# Docker image setup
# ============================================================================

setup_docker_image() {
    log_step "Preparing Docker build environment"

    if ! docker info &> /dev/null; then
        log_warn "Docker not running, skipping image pull"
        add_manual_step "Run 'docker pull ghcr.io/autc04/retro68' after starting Docker"
        return 0
    fi

    log_info "Pulling Retro68 Docker image (this may take a while on first run)..."
    if docker pull ghcr.io/autc04/retro68; then
        log_success "Retro68 Docker image ready"
    else
        log_warn "Failed to pull Docker image (will be pulled on first build)"
    fi
}

# ============================================================================
# Emulation environment setup
# ============================================================================

check_emulation_files() {
    log_step "Checking emulation environment"

    local required_files=(
        "Mini vMac.app"
        "MacOS_6.0.8_System_Startup.img"
        "MacOS_6.0.8_System_Additions.img"
        "024M.dsk"
        "importfl-1.2.2.dsk"
    )

    local missing=()

    for file in "${required_files[@]}"; do
        if [ -e "$EMULATION_DIR/$file" ]; then
            log_success "Found: $file"
        else
            missing+=("$file")
            log_error "Missing: $file"
        fi
    done

    if [ ${#missing[@]} -ne 0 ]; then
        add_manual_step "Add missing emulation files to $EMULATION_DIR"
    fi
}

check_rom_file() {
    log_step "Checking for Macintosh ROM"

    # Mini vMac looks for ROM in several locations
    local rom_locations=(
        "$EMULATION_DIR/vMac.ROM"
        "$EMULATION_DIR/MacII.ROM"
        "$HOME/Library/Preferences/Gryphel/vMac.ROM"
        "$HOME/vMac.ROM"
    )

    for rom in "${rom_locations[@]}"; do
        if [ -f "$rom" ]; then
            log_success "Found ROM: $rom"
            return 0
        fi
    done

    log_warn "No Macintosh ROM file found"
    echo ""
    echo "  Mini vMac requires a Macintosh ROM file to operate."
    echo "  Place the ROM file in one of these locations:"
    echo "    - $EMULATION_DIR/vMac.ROM"
    echo "    - ~/Library/Preferences/Gryphel/vMac.ROM"
    echo ""
    echo "  ROM acquisition options:"
    echo "    - Extract from physical Mac: https://www.gryphel.com/c/minivmac/extras/copyroms/"
    echo "    - Mac ROM files are copyrighted by Apple"
    echo ""

    add_manual_step "Acquire and install Macintosh ROM file"
}

check_system_installed() {
    log_step "Checking System 6 installation status"

    # Check if the disk image has System folder (indicates OS installed)
    # We can't easily check HFS content without mounting, so check file size
    local disk="$EMULATION_DIR/024M.dsk"

    if [ -f "$disk" ]; then
        local size=$(stat -f%z "$disk" 2>/dev/null || stat --printf="%s" "$disk" 2>/dev/null)

        # A freshly formatted 24MB disk is exactly 25165824 bytes
        # If System 6 is installed, it will be the same size but with content
        # We can check by trying to mount it
        if command -v hmount &> /dev/null; then
            if hmount "$disk" 2>/dev/null; then
                local files=$(hls 2>/dev/null | wc -l)
                humount 2>/dev/null

                if [ "$files" -gt 1 ]; then
                    log_success "Disk image appears to have System 6 installed"
                else
                    log_warn "Disk image appears empty"
                    add_manual_step "Install System 6 on disk image (see docs/SETUP.md)"
                fi
            else
                log_warn "Could not check disk contents"
            fi
        else
            log_info "Install hfsutils to verify disk contents"
        fi
    fi
}

# ============================================================================
# Directory structure setup
# ============================================================================

setup_directories() {
    log_step "Setting up directory structure"

    mkdir -p "$PROJECT_DIR/dist"
    mkdir -p "$PROJECT_DIR/tooling"

    # Create .gitkeep files if needed
    [ ! -f "$PROJECT_DIR/dist/.gitkeep" ] && touch "$PROJECT_DIR/dist/.gitkeep"
    [ ! -f "$PROJECT_DIR/tooling/.gitkeep" ] && touch "$PROJECT_DIR/tooling/.gitkeep"

    log_success "Directory structure ready"
}

# ============================================================================
# Script permissions
# ============================================================================

setup_permissions() {
    log_step "Setting script permissions"

    chmod +x "$PROJECT_DIR/build.sh" 2>/dev/null && log_success "build.sh is executable"
    chmod +x "$PROJECT_DIR/dev.sh" 2>/dev/null && log_success "dev.sh is executable"
    chmod +x "$PROJECT_DIR/initial_setup.sh" 2>/dev/null && log_success "initial_setup.sh is executable"
}

# ============================================================================
# Verification build
# ============================================================================

verify_setup() {
    log_step "Verifying setup"

    local all_good=true

    # Check all critical components
    command -v docker &> /dev/null || { log_error "Docker not available"; all_good=false; }
    command -v brew &> /dev/null || { log_error "Homebrew not available"; all_good=false; }
    command -v fswatch &> /dev/null || { log_error "fswatch not available"; all_good=false; }
    command -v hmount &> /dev/null || { log_error "hfsutils not available"; all_good=false; }
    [ -d "$TOOLING_DIR/Retro68" ] || { log_error "Retro68 not cloned"; all_good=false; }
    [ -d "$EMULATION_DIR/Mini vMac.app" ] || { log_error "Mini vMac not found"; all_good=false; }

    if $all_good; then
        log_success "All automated checks passed"
    fi
}

# ============================================================================
# Summary
# ============================================================================

print_summary() {
    echo ""
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║                    Setup Summary                              ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"
    echo ""

    if [ ${#MANUAL_STEPS[@]} -eq 0 ]; then
        echo -e "${GREEN}${BOLD}Setup complete! No manual steps required.${NC}"
        echo ""
        echo "You can now run:"
        echo "  ./dev.sh        # Start development with auto-reload"
        echo "  ./build.sh      # Single build"
    else
        echo -e "${YELLOW}${BOLD}Setup partially complete. Manual steps required:${NC}"
        echo ""
        local i=1
        for step in "${MANUAL_STEPS[@]}"; do
            echo "  $i. $step"
            ((i++))
        done
        echo ""
        echo "After completing manual steps, run this script again to verify."
    fi

    echo ""
    echo "Documentation:"
    echo "  - Setup guide:       docs/SETUP.md"
    echo "  - Development guide: docs/DEVELOPMENT.md"
    echo ""
}

# ============================================================================
# Main
# ============================================================================

main() {
    echo "╔═══════════════════════════════════════════════════════════════╗"
    echo "║           MacMind Development Environment Setup               ║"
    echo "╚═══════════════════════════════════════════════════════════════╝"

    cd "$PROJECT_DIR"

    # Run all setup steps
    check_homebrew
    check_brew_packages
    check_docker
    setup_directories
    setup_tooling
    setup_docker_image
    check_emulation_files
    check_rom_file
    check_system_installed
    setup_permissions
    verify_setup

    print_summary
}

main "$@"
