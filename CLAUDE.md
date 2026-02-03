# MacMind - Claude Development Guide

## Project Overview
MacMind is a conversational AI application designed for Apple System 6, bringing modern AI capabilities to classic Macintosh computing while maintaining the authentic 1988 aesthetic.

## Build Commands
```bash
# Build the project
./build.sh

# Initial setup
./initial_setup.sh

# Build using CMake (from src directory)
cd src
cmake .
make
```

## Code Style Guidelines
- Follow K&R C style for consistency with classic Mac development
- Use descriptive variable names while keeping them reasonably short
- Maintain compatibility with System 6 constraints
- Comment complex logic, especially GUI and serial communication code
- Use consistent indentation (tabs preferred for historical accuracy)

## Testing Instructions
- Test on Mini vMac emulator with System 6.0.8
- Verify GUI rendering with Nuklear framework
- Test serial communication functionality
- Ensure memory usage stays within System 6 limits
- Test on both emulated and real hardware when possible

## Development Environment
- Requires CMake for building
- Uses Nuklear GUI framework
- Mini vMac emulator for testing
- System 6.0.8 disk images provided in `/emulation/`
- Cross-compilation tools for 68k Macintosh

## Repository Structure
- `/src/` - C source code and build files
- `/emulation/` - Mac system files and Mini vMac emulator
- `/docs/` - Documentation and setup guides
- `build.sh` - Main build script
- `initial_setup.sh` - Development environment setup

## File Conventions
- `.c` files for C source code
- `.h` files for headers
- `.r` files for Mac resource definitions
- Keep file names short and descriptive (System 6 filename limitations)

## Key Components
- `mac_main.c` - Main application logic
- `nuklear_app.c` - GUI implementation
- `SerialHelper.c` - Serial communication
- `nuklear_quickdraw.h` - QuickDraw integration

## Development Notes
- This is a retro-computing project targeting genuine System 6 compatibility
- Maintain the classic Mac look and feel
- Consider memory and processing constraints of 1988-era hardware
- Use period-appropriate development practices where possible
- Serial communication is used for external connectivity

## Deployment
- Build creates executable for System 6
- Deploy via disk image or serial transfer
- Test thoroughly on Mini vMac before real hardware