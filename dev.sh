#!/bin/bash
# dev.sh - Automated development workflow for MacMind
# Watch for changes, rebuild, inject into disk image, restart emulator

set -e

# Configuration
PROJECT_DIR="$(cd "$(dirname "$0")" && pwd)"
DISK="$PROJECT_DIR/emulation/024M.dsk"
VMAC="$PROJECT_DIR/emulation/Mini vMac.app"
SRC_DIR="$PROJECT_DIR/src"
DIST_DIR="$PROJECT_DIR/dist"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

log_info() { echo -e "${BLUE}ℹ${NC} $1"; }
log_success() { echo -e "${GREEN}✓${NC} $1"; }
log_warn() { echo -e "${YELLOW}⚠${NC} $1"; }
log_error() { echo -e "${RED}✗${NC} $1"; }

# Check dependencies
check_deps() {
    local missing=()

    if ! command -v fswatch &> /dev/null; then
        missing+=("fswatch")
    fi

    if ! command -v hmount &> /dev/null; then
        missing+=("hfsutils")
    fi

    if [ ${#missing[@]} -ne 0 ]; then
        log_error "Missing dependencies: ${missing[*]}"
        echo "Install with: brew install ${missing[*]}"
        exit 1
    fi

    if [ ! -d "$VMAC" ]; then
        log_error "Mini vMac not found at: $VMAC"
        exit 1
    fi

    if [ ! -f "$DISK" ]; then
        log_error "Disk image not found at: $DISK"
        exit 1
    fi
}

# Stop the emulator
stop_emulator() {
    if pgrep -x "Mini vMac" > /dev/null; then
        log_info "Stopping Mini vMac..."
        osascript -e 'quit app "Mini vMac"' 2>/dev/null || true
        sleep 1
    fi
}

# Start the emulator
start_emulator() {
    log_info "Starting Mini vMac..."
    open "$VMAC" --args "$DISK" \
        "$PROJECT_DIR/emulation/MacOS_6.0.8_System_Startup.img" \
        "$PROJECT_DIR/emulation/importfl-1.2.2.dsk"
}

# Build the project
build() {
    log_info "Building MacMind..."

    cd "$PROJECT_DIR"
    if ./build.sh; then
        log_success "Build completed"
        return 0
    else
        log_error "Build failed"
        return 1
    fi
}

# Inject built app into disk image
inject() {
    log_info "Injecting into disk image..."

    # Find the built application (adjust pattern as needed)
    local app_file
    app_file=$(find "$DIST_DIR" -type f ! -name ".gitkeep" | head -1)

    if [ -z "$app_file" ]; then
        log_warn "No build output found in $DIST_DIR"
        return 1
    fi

    # Ensure emulator is stopped before mounting disk
    stop_emulator
    sleep 1

    # Mount, copy, unmount
    if hmount "$DISK" 2>/dev/null; then
        if hcopy "$app_file" ":"; then
            log_success "Copied $(basename "$app_file") to disk"
        else
            log_error "Failed to copy to disk"
            humount 2>/dev/null || true
            return 1
        fi
        humount
    else
        log_error "Failed to mount disk image"
        return 1
    fi

    return 0
}

# Full rebuild cycle
rebuild_cycle() {
    echo ""
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"
    log_info "Change detected - starting rebuild cycle"
    echo "━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━━"

    if build; then
        if inject; then
            start_emulator
            log_success "Reload complete!"
        fi
    fi
}

# Watch mode
watch_mode() {
    log_info "Watching $SRC_DIR for changes..."
    log_info "Press Ctrl+C to stop"
    echo ""

    # Initial build and start
    rebuild_cycle

    # Watch for changes
    fswatch -o "$SRC_DIR"/*.c "$SRC_DIR"/*.h "$SRC_DIR"/*.r 2>/dev/null | while read -r; do
        rebuild_cycle
    done
}

# Single build mode
single_build() {
    check_deps
    build && inject && start_emulator
}

# Main
main() {
    echo "╔═══════════════════════════════════════╗"
    echo "║     MacMind Development Server        ║"
    echo "╚═══════════════════════════════════════╝"
    echo ""

    check_deps

    case "${1:-watch}" in
        watch)
            watch_mode
            ;;
        build)
            single_build
            ;;
        start)
            start_emulator
            ;;
        stop)
            stop_emulator
            ;;
        *)
            echo "Usage: $0 [watch|build|start|stop]"
            echo ""
            echo "  watch  - Watch for changes and auto-reload (default)"
            echo "  build  - Single build, inject, and start"
            echo "  start  - Start emulator only"
            echo "  stop   - Stop emulator only"
            exit 1
            ;;
    esac
}

main "$@"
