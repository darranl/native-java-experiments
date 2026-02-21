# WiringPi API Quick Reference

**Library:** WiringPi community fork — https://github.com/WiringPi/WiringPi (v3.18, Feb 2026)
**Header:** `wiringPi.h`
**Pi 5:** Fully supported except GCLK functionality.

---

## Setup & Pin-Numbering Modes

| Function | Mode | Description |
|---|---|---|
| `wiringPiSetup()` | WPI | WiringPi virtual pin numbers (0-based, board-specific) |
| `wiringPiSetupGpio()` | BCM | Broadcom GPIO numbers |
| `wiringPiSetupPhys()` | Physical | Physical header pin numbers (1–40) |
| `wiringPiSetupSys()` | /sys | Uses `/sys/class/gpio`; no root needed, limited features |
| `wiringPiSetupPinType(int pinType)` | Device | Selects pin numbering mode by constant |

`pinType` constants: `WPI_PIN_WPI`, `WPI_PIN_BCM`, `WPI_PIN_PHYS`, `WPI_PIN_GPIO`

All setup functions return `0` on success, `-1` on error.

---

## Core GPIO

```c
void pinMode        (int pin, int mode);
void digitalWrite   (int pin, int value);
int  digitalRead    (int pin);
void pullUpDnControl(int pin, int pud);
```

### `pinMode` modes
| Constant | Value | Meaning |
|---|---|---|
| `INPUT` | 0 | Digital input |
| `OUTPUT` | 1 | Digital output |
| `PWM_OUTPUT` | 2 | Hardware PWM output (Pi hardware pin only) |
| `GPIO_CLOCK` | 3 | General-purpose clock (not supported on Pi 5) |
| `SOFT_PWM_OUTPUT` | 4 | Software PWM (any pin) |
| `SOFT_TONE_OUTPUT` | 5 | Software tone/frequency (any pin) |
| `PWM_TONE_OUTPUT` | 6 | Hardware PWM tone mode |

### `digitalWrite` / `digitalRead` values
| Constant | Value |
|---|---|
| `LOW` | 0 |
| `HIGH` | 1 |

### `pullUpDnControl` pud
| Constant | Meaning |
|---|---|
| `PUD_OFF` | No pull |
| `PUD_DOWN` | Pull-down |
| `PUD_UP` | Pull-up |

---

## Hardware PWM

```c
void pwmWrite   (int pin, int value);   // 0 .. pwmRange (default 1024)
void pwmSetMode (int mode);             // PWM_MODE_MS or PWM_MODE_BAL
void pwmSetRange(unsigned int range);   // set PWM range (resolution)
void pwmSetClock(int divisor);          // set PWM clock divisor
void pwmToneWrite(int pin, int freq);   // set tone via hardware PWM (Hz; 0 = off)
```

| Constant | Meaning |
|---|---|
| `PWM_MODE_MS` | Mark-space (traditional) |
| `PWM_MODE_BAL` | Balanced (default Broadcom) |

---

## Soft PWM / Soft Tone

Use `pinMode(pin, SOFT_PWM_OUTPUT)` or `pinMode(pin, SOFT_TONE_OUTPUT)`, then:

```c
// Soft PWM (requires wiringPiSetup* called first)
int  softPwmCreate(int pin, int initialValue, int pwmRange);
void softPwmWrite (int pin, int value);
void softPwmStop  (int pin);

// Soft Tone
int  softToneCreate(int pin);
void softToneWrite (int pin, int freq);  // Hz; 0 = off
void softToneStop  (int pin);
```

---

## Byte Operations

```c
unsigned int digitalReadByte  (void);             // read 8 WPi pins 0-7
unsigned int digitalReadByte2 (void);             // read 8 WPi pins 20-27
void         digitalWriteByte (int value);        // write 8 WPi pins 0-7
void         digitalWriteByte2(int value);        // write 8 WPi pins 20-27
```

---

## Timing

```c
void          delay             (unsigned int ms);
void          delayMicroseconds (unsigned int us);
unsigned int  millis            (void);   // ms since wiringPiSetup*
unsigned int  micros            (void);   // µs since wiringPiSetup*
unsigned long long piMicros64   (void);   // µs since epoch (64-bit)
```

---

## Interrupts

```c
int wiringPiISR    (int pin, int edgeType, void (*function)(void));
int wiringPiISR2   (int pin, int edgeType, void (*function)(int, int));
int wiringPiISRStop(int pin);
```

`edgeType` constants:

| Constant | Meaning |
|---|---|
| `INT_EDGE_SETUP` | No change to edge detection |
| `INT_EDGE_FALLING` | Trigger on falling edge |
| `INT_EDGE_RISING` | Trigger on rising edge |
| `INT_EDGE_BOTH` | Trigger on both edges |

`WPIWfiStatus` struct (filled by `wiringPiISR2` callback):

```c
typedef struct WPIWfiStatus {
    int pin;
    int value;
} WPIWfiStatus;
```

The `wiringPiISR2` callback receives `(int pin, int value)`.

---

## Threading

```c
int  piThreadCreate(void *(*fn)(void *));   // create a Pi thread (returns thread id)
void piLock        (int key);               // mutex lock   (key: 0-3)
void piUnlock      (int key);               // mutex unlock (key: 0-3)
int  piHiPri       (int pri);              // set thread priority (1-99)
```

Use `PI_THREAD(name) { ... }` macro to define a thread function.

---

## Board Information

```c
void piBoardId   (int *model, int *rev, int *mem, int *maker, int *overVolted);
int  piBoard40Pin(void);     // returns 1 if 40-pin header board
int  piRP1Model  (void);     // returns RP1 model number (Pi 5)
```

### Model constants (`PI_MODEL_*`)
`PI_MODEL_A`, `PI_MODEL_B`, `PI_MODEL_AP`, `PI_MODEL_BP`, `PI_MODEL_2`,
`PI_MODEL_ALPHA`, `PI_MODEL_CM`, `PI_MODEL_07`, `PI_MODEL_3B`, `PI_MODEL_ZERO`,
`PI_MODEL_CM3`, `PI_MODEL_ZERO_W`, `PI_MODEL_3BP`, `PI_MODEL_3AP`,
`PI_MODEL_CM3P`, `PI_MODEL_4B`, `PI_MODEL_ZERO_2W`, `PI_MODEL_400`,
`PI_MODEL_CM4`, `PI_MODEL_CM4S`, `PI_MODEL_5`

### Maker constants (`PI_MAKER_*`)
`PI_MAKER_SONY`, `PI_MAKER_EGOMAN`, `PI_MAKER_EMBEST`, `PI_MAKER_STADIUM`, `PI_MAKER_UNKNOWN`

---

## Pin Alt Functions

```c
int      getAlt       (int pin);               // get current alt function number
int      getPinModeAlt(int pin);               // get alt function as WPIPinAlt
void     pinModeAlt   (int pin, int mode);     // set alt function directly
```

`WPIPinAlt` enum values: `WPI_ALT0` … `WPI_ALT5`, `WPI_ALT_INPUT`, `WPI_ALT_OUTPUT`, `WPI_ALT_GPIO`

---

## Key Constants Summary

```c
// Logic levels
HIGH   1
LOW    0

// Pin modes
INPUT          0
OUTPUT         1
PWM_OUTPUT     2
GPIO_CLOCK     3   // not on Pi 5
SOFT_PWM_OUTPUT 4
SOFT_TONE_OUTPUT 5
PWM_TONE_OUTPUT  6

// Pull up/down
PUD_OFF   0
PUD_DOWN  1
PUD_UP    2

// Interrupt edges
INT_EDGE_SETUP   0
INT_EDGE_FALLING 1
INT_EDGE_RISING  2
INT_EDGE_BOTH    3

// PWM modes
PWM_MODE_MS  0   // mark-space
PWM_MODE_BAL 1   // balanced
```

---

## Typical Usage Pattern

```c
#include <wiringPi.h>

#define LED_PIN 0   // WiringPi pin 0 = BCM 17 = Physical pin 11

int main(void) {
    wiringPiSetup();              // use WiringPi pin numbering
    pinMode(LED_PIN, OUTPUT);
    digitalWrite(LED_PIN, HIGH);
    delay(1000);
    digitalWrite(LED_PIN, LOW);
    return 0;
}
```

Compile: `gcc -o prog prog.c -lwiringPi`
