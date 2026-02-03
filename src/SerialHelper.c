#include "SerialHelper.h"
#include "stdio.h"

/*
Read more: http://stason.org/TULARC/os-macintosh/programming/7-1-How-do-I-get-at-the-serial-ports-Communications-and-N.html#ixzz4cIxU3Tob

Serial implementation:

https://opensource.apple.com/source/gdb/gdb-186.1/src/gdb/ser-mac.c?txt
http://mirror.informatimago.com/next/developer.apple.com/documentation/mac/Devices/Devices-320.html
*/

/*
 * Serial debugging is disabled for Retro68 compatibility.
 * PBControl and PBWrite are not available in the Retro68 toolchain.
 * This stub returns noErr to allow the app to run without serial output.
 */
OSErr writeSerialPortDebug(short refNum, const char* str)
{
    #pragma unused(refNum, str)
    return noErr;
}
