# MacMind - Claude Development Guide

## Project Overview

MacMind is a conversational AI application for Apple System 6 (1988), bringing modern AI capabilities to classic Macintosh computing while maintaining authentic period aesthetics. The project uses Retro68 cross-compilation, Nuklear immediate-mode GUI, and targets genuine 68000/68020 hardware.

**Target Platform**: System 6.0.8 on Macintosh Plus/SE/II (8MHz 68000, 1-8MB RAM)
**License**: MIT (Copyright 2024 Dominique Netters)

## Build Commands

```bash
# First-time setup (installs Homebrew, Docker, fswatch, hfsutils, cmake)
./initial_setup.sh

# Build the project (uses Docker + Retro68)
./build.sh

# Development mode with auto-rebuild and emulator restart
./dev.sh watch

# Single build cycle
./dev.sh build

# Start/stop emulator manually
./dev.sh start
./dev.sh stop
```

**Important**: Do NOT run `cmake .` directly in `/src/`. The build uses Retro68's Docker container with a specialized toolchain. Always use `./build.sh` from the project root.

## Repository Structure

```
MacMind/
├── src/                    # C source code
│   ├── mac_main.c          # Main app logic, event loop, menus
│   ├── mac_main.h          # Constants, resource IDs, memory config
│   ├── mac_main.r          # Rez resource definitions (menus, windows)
│   ├── nuklear_app.c       # GUI implementation (currently calculator demo)
│   ├── nuklear_quickdraw.h # QuickDraw rendering backend (~46KB)
│   ├── nuklear.h           # Modified Nuklear library (~752KB, integer-only)
│   ├── SerialHelper.c/h    # Serial port debugging (stubbed for Retro68)
│   └── CMakeLists.txt      # Build configuration
├── emulation/              # Mini vMac + System 6 disk images
├── dist/                   # Build outputs (.dsk, .bin files)
├── docs/                   # Setup and development guides
├── tooling/                # Retro68 compiler, tty0tty
├── build.sh                # Main build script
├── dev.sh                  # Development workflow with watch mode
└── initial_setup.sh        # Environment setup
```

## Key Source Files

| File | Lines | Purpose |
|------|-------|---------|
| `mac_main.c` | ~865 | Event loop, menu handling, Toolbox init |
| `mac_main.h` | ~200 | Resource IDs, memory constants |
| `mac_main.r` | ~200 | Menu bar, windows, SIZE resource |
| `nuklear_app.c` | ~127 | GUI widgets (calculator demo) |
| `nuklear_quickdraw.h` | ~1200 | QuickDraw backend, double-buffering |
| `nuklear.h` | ~30000 | Modified Nuklear (integer math, no FPU) |
| `SerialHelper.c` | ~40 | Debug output via serial port |

## Code Style Guidelines

- **K&R C style** for consistency with classic Mac development
- **Tab indentation** (historical accuracy)
- **Short but descriptive names** (System 6 filename limits apply)
- **Comment complex logic**, especially GUI and serial code
- **Use `#pragma segment`** for code organization in large files
- **No floating-point math** - the 68000 has no FPU
- **Keep memory usage minimal** - target 88KB minimum partition

### Example Style

```c
/* K&R function definition style */
void DoMenuCommand(menuResult)
    long menuResult;
{
    short menuID = HiWord(menuResult);
    short menuItem = LoWord(menuResult);

    switch (menuID) {
    case mApple:
        /* Handle Apple menu */
        break;
    }
}
```

## Memory & Performance Constraints

| Resource | Limit | Notes |
|----------|-------|-------|
| Minimum partition | 88KB | Set in SIZE resource |
| Preferred partition | 100KB | For comfortable operation |
| Heap requirement | 21KB | kMinHeap constant |
| Target CPU | 8MHz 68000 | No FPU, limited cache |
| Display | 512x342 B&W | 1-bit monochrome |

### Performance Rules

1. **Integer math only** - Nuklear modified to remove all floating-point
2. **Double-buffer with off-screen bitmap** - prevents flicker
3. **Cache draw commands** - reduce QuickDraw calls
4. **Manual mouse tracking** - System 6 has no mouse-move events
5. **Minimize heap allocations** - use stack when possible

## Toolchain Details

| Tool | Purpose |
|------|---------|
| **Retro68** | GCC-based 68k cross-compiler |
| **Docker** | Isolated build environment |
| **Rez** | Resource compiler for `.r` files |
| **hfsutils** | Mount/modify HFS disk images |
| **Mini vMac** | Accurate System 6 emulation |
| **fswatch** | File change monitoring for dev.sh |

## Testing Workflow

1. Run `./dev.sh watch` for auto-rebuild on file changes
2. Changes are automatically injected into disk image
3. Emulator restarts with updated application
4. Test GUI rendering and responsiveness
5. Verify memory usage in About box (MultiFinder)

### Manual Testing

```bash
# Build and copy to disk
./build.sh

# Open emulator with development disk
open "emulation/Mini vMac.app" --args "emulation/024M.dsk"
```

## Debugging

### Serial Port Output (Currently Stubbed)

SerialHelper.c provides `writeSerialPortDebug()` but Retro68 lacks `PBControl`/`PBWrite`. Debug output is currently disabled.

**Workaround**: Use printf-style debugging to on-screen text or Nuklear widgets.

### Common Issues

| Issue | Cause | Solution |
|-------|-------|----------|
| Build fails in Docker | Retro68 not fetched | Run `./build.sh` (auto-fetches) |
| Emulator won't start | Missing vMac.ROM | Acquire legally from owned Mac |
| App crashes on launch | Memory too low | Increase partition in SIZE resource |
| GUI doesn't render | QuickDraw init failed | Check InitGraf/InitWindows order |
| Mouse not tracking | Event loop issue | Verify GetNextEvent/WaitNextEvent |

## Architecture Decisions

### Why Nuklear?
- Immediate-mode GUI reduces state complexity
- Single-header library (easy to modify)
- Can run on extremely constrained systems with modifications

### Why Integer Math?
- 68000 has no floating-point unit
- Software FPU emulation is too slow for interactive GUI
- Modified Nuklear uses fixed-point where needed

### Why K&R Style?
- Matches authentic 1988 Mac development conventions
- Some Retro68 headers expect classic C
- Maintains historical accuracy for the project

## Adding New Features

1. **New menu items**: Edit `mac_main.r` resources, handle in `DoMenuCommand()` in mac_main.c
2. **New windows**: Add to resources, create handler pattern from existing code
3. **New GUI widgets**: Implement in `nuklear_app.c` using Nuklear API
4. **Serial features**: Extend SerialHelper.c (need Retro68 compatibility work)

## Resource IDs

```c
/* From mac_main.h */
#define rMenuBar    128     /* Main menu bar */
#define rWindow     128     /* Main window */
#define mApple      128     /* Apple menu */
#define mFile       129     /* File menu */
#define mEdit       130     /* Edit menu */
#define mLight      131     /* Light menu (app-specific) */
#define mHelp       132     /* Help menu */
```

## Deployment

1. Build creates `dist/nuklear_quickdraw.dsk` (bootable disk image)
2. For real hardware: Transfer via serial, network, or physical floppy
3. Use ImportFL utility to copy files to HFS disks
4. Test on Mini vMac before real hardware deployment

---

## Lessons Learned

> **Claude: Update this section after discovering important information, encountering bugs, or finding solutions to problems. Each entry should include the date and a brief description.**

### 2025-02-03: Retro68 Serial Port Compatibility
- **Issue**: `PBControl` and `PBWrite` are not available in Retro68's Toolbox implementation
- **Solution**: Stubbed out serial debugging functions; use alternative debug methods
- **Files affected**: `SerialHelper.c`

### 2025-02-03: Build System Clarification
- **Issue**: Running `cmake .` directly in `/src/` doesn't work
- **Solution**: Always use `./build.sh` which runs the proper Docker+Retro68 toolchain
- **Tip**: The CMakeLists.txt is designed for Retro68's `add_application()` macro

### 2025-02-03: Integer Math Requirement
- **Issue**: 68000 has no FPU, floating-point operations are extremely slow
- **Solution**: The modified `nuklear.h` uses integer math throughout
- **Warning**: Avoid introducing any `float` or `double` operations in GUI code

---

## Quick Reference

```bash
# Build
./build.sh

# Develop with auto-reload
./dev.sh watch

# Key files to edit for UI changes
src/nuklear_app.c      # Widget layout and logic
src/mac_main.r         # Menus, windows, resources

# Key files for app behavior
src/mac_main.c         # Event handling, initialization

# Output location
dist/nuklear_quickdraw.dsk
```
