# Setup

This document will help you setup a System 6 emulator for local development. It's written for MacOS silicon systems.

- [Setup](#setup)
  - [Required files](#required-files)
  - [Creating a new OS floppy](#creating-a-new-os-floppy)


## Required files

Most required files can be found in the [emulation](emulation) folder. It should contain:

- An emulator: `Mini vMac.app`
- A copy of the System 6 installer: `MacOS_6.0.8_System_Startup.img` and `MacOS_6.0.8_System_Additions.img`
- An empty disk: `024M.dsk`

In addition you should acquire a valid System Software 6 ROM. If you own a physical copy your can copy it to a ROM using [this guide](https://www.gryphel.com/c/minivmac/extras/copyroms/index.html). ROMs can also be found online but only illegally since Apple holds copyright over those files. Once you have acquired the ROM, place it in the [emulation](../emulation/) folder.

## Creating a new OS floppy

The existing system floppy is preinstalled with System Software 6.0.8 with a size of 24M. You might want to create a new floppy if you need a version of System Software or if you need more storage space.

Navigate to the Mini vMac app and open it. You'll be presented by the following screen. Your Macintosh computer is booted and waiting for a disk image to be inserted

![Mini vMac waiting for a disk image](./images/Mini%20vMac%20boot.png)

With the emulator open, drag the file [MacOS_6.0.8_System_Startup.img](../emulation/MacOS_6.0.8_System_Startup.img) onto the emulator. The system will boot to a desktop environment.

![Mini vMac booted into a desktop environment](./images/Mini%20vMac%20startup.png)

Drag [024M.dsk](../emulation/024M.dsk) onto the emulator next. This is an empty disk onto which we're going to install the OS. A new floppy icon will show up underneath 'System Startup'. If you want to create a lager floppy, [gryphel](https://www.gryphel.com/c/minivmac/extras/blanks/index.html) offers collection of empty disks with a range of sizes.

Open the 'System Startup' floppy by double clicking it. In the newly opened floppy, click 'Installer' twice. You will be presented with the Apple Installer.

![Mini vMac Apple Installer](./images/Mini%20vMac%20Apple%20installer.png)

Continue by clicking 'OK' and 'Install' afterwards. Over halfway through the installer will ask you to insert the 'System Additions' disk. Drop the file [MacOS_6.0.8_System_Additions.img](../emulation/MacOS_6.0.8_System_Additions.img) onto the emulator. Shortly after you will be prompted to insert the 'System Startup' once again. Do so by dragging it onto the emulator once more.

You can now boot into your new floppy by restarting the emulator and dragging your new file onto it. Consider saving your disk in to emulator folder with a file name ending with `_installed.dsk`.
