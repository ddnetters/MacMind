#include <Serial.h>
#include <Devices.h>
#include <stdio.h>
#include <string.h>

/* Serial port reference numbers - may not be defined in all toolchains */
#ifndef aoutRefNum
#define aoutRefNum (-7)
#endif
#ifndef boutRefNum
#define boutRefNum (-9)
#endif

OSErr writeSerialPortDebug(short refNum, const char* str);