#include <stdio.h>
#include <wiringPi.h>

#define PIN_RED   21
#define PIN_AMBER 22
#define PIN_GREEN 23

typedef enum {
    LIGHTS_NONE      = 0,
    LIGHT_RED        = 1 << 0,
    LIGHT_AMBER      = 1 << 1,
    LIGHT_GREEN      = 1 << 2,
    LIGHTS_RED_AMBER = LIGHT_RED | LIGHT_AMBER,
} LightMask;

typedef struct {
    LightMask    lights;
    unsigned int duration_ms;
} Phase;

static const Phase phases[] = {
    { LIGHT_RED,        2000 },
    { LIGHTS_RED_AMBER, 1000 },
    { LIGHT_GREEN,      2000 },
    { LIGHT_AMBER,       750 },
};

static void apply_lights(LightMask mask) {
    digitalWrite(PIN_RED,   (mask & LIGHT_RED)   ? HIGH : LOW);
    digitalWrite(PIN_AMBER, (mask & LIGHT_AMBER) ? HIGH : LOW);
    digitalWrite(PIN_GREEN, (mask & LIGHT_GREEN) ? HIGH : LOW);
}

int main(void) {
    printf("Beginning Traffic Light Management\n");
    fflush(stdout);

    printf("Calling wiringPiSetup...\n");
    fflush(stdout);

    if (wiringPiSetup() == -1) {
        fprintf(stderr, "wiringPiSetup failed\n");
        return 1;
    }

    printf("wiringPiSetup ok, configuring pins...\n");
    fflush(stdout);

    pinMode(PIN_RED,   OUTPUT);
    pinMode(PIN_AMBER, OUTPUT);
    pinMode(PIN_GREEN, OUTPUT);

    printf("Pins configured, starting loop\n");
    fflush(stdout);

    apply_lights(LIGHTS_NONE);

    while (1) {
        for (int i = 0; i < (int)(sizeof(phases) / sizeof(phases[0])); i++) {
            apply_lights(phases[i].lights);
            delay(phases[i].duration_ms);
        }
    }

    return 0;
}
