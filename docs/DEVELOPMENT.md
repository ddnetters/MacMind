# Development

This document details all steps needed to go from written code to an executable in the emulator.

## Perquisites

- [Development](#development)
  - [Perquisites](#perquisites)
  - [Prerequisites](#prerequisites)
  - [Creating executable binaries](#creating-executable-binaries)
  - [Getting an executable into the emulator](#getting-an-executable-into-the-emulator)


## Prerequisites

- You have followed [the initial setup guide](./SETUP.md) 
- Docker

## Creating executable binaries

There's a general build script which will take all code in `src` and compile it into the `dist` folder.

```bash
./build.sh
```

## Getting an executable into the emulator

Mount ImportFl in your emulator by dragging the file [importfl-1.2.2.dsk](../emulation/importfl-1.2.2.dsk) onto the emulator. [This program](https://www.gryphel.com/c/minivmac/extras/importfl/index.html) allows you to import any file from your computer into the emulator. An ImportFl icon will appear on your desktop. Clicking it twice opens a folder with an 'ImportFl' executable. Double clicking it will start the importing process. You can simply drag files onto your emulator to import them. Once you're doing quit by cmd + q.

![Mini vMac running ImportFL](./images/Mini%20vMac%20ImportFL%20.png)