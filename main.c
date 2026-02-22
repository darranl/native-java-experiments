#include <stdio.h>
#include <unistd.h>
#include <gpiod.h>

#define CHIP       "gpiochip0"
#define PIN_RED     5
#define PIN_AMBER   6
#define PIN_GREEN  13
#define CONSUMER   "traffic-lights"

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

typedef struct {
    struct gpiod_line *red;
    struct gpiod_line *amber;
    struct gpiod_line *green;
} Lights;

static const Phase phases[] = {
    { LIGHT_RED,        2000 },
    { LIGHTS_RED_AMBER, 1000 },
    { LIGHT_GREEN,      2000 },
    { LIGHT_AMBER,       750 },
};

static void apply_lights(const Lights *lights, LightMask mask) {
    gpiod_line_set_value(lights->red,   (mask & LIGHT_RED)   ? 1 : 0);
    gpiod_line_set_value(lights->amber, (mask & LIGHT_AMBER) ? 1 : 0);
    gpiod_line_set_value(lights->green, (mask & LIGHT_GREEN) ? 1 : 0);
}

int main(void) {
    printf("Beginning Traffic Light Management\n");
    fflush(stdout);

    printf("Opening gpiochip...\n");
    fflush(stdout);

    struct gpiod_chip *chip = gpiod_chip_open_by_name(CHIP);
    if (!chip) {
        fprintf(stderr, "gpiod_chip_open_by_name failed\n");
        return 1;
    }

    printf("libgpiod chip open, configuring lines...\n");
    fflush(stdout);

    Lights lights = {
        .red   = gpiod_chip_get_line(chip, PIN_RED),
        .amber = gpiod_chip_get_line(chip, PIN_AMBER),
        .green = gpiod_chip_get_line(chip, PIN_GREEN),
    };

    if (!lights.red || !lights.amber || !lights.green) {
        fprintf(stderr, "gpiod_chip_get_line failed\n");
        gpiod_chip_close(chip);
        return 1;
    }

    if (gpiod_line_request_output(lights.red,   CONSUMER, 0) < 0 ||
        gpiod_line_request_output(lights.amber, CONSUMER, 0) < 0 ||
        gpiod_line_request_output(lights.green, CONSUMER, 0) < 0) {
        fprintf(stderr, "gpiod_line_request_output failed\n");
        gpiod_chip_close(chip);
        return 1;
    }

    printf("Lines configured, starting loop\n");
    fflush(stdout);

    apply_lights(&lights, LIGHTS_NONE);

    while (1) {
        for (int i = 0; i < (int)(sizeof(phases) / sizeof(phases[0])); i++) {
            apply_lights(&lights, phases[i].lights);
            usleep((useconds_t)phases[i].duration_ms * 1000U);
        }
    }

    gpiod_line_release(lights.red);
    gpiod_line_release(lights.amber);
    gpiod_line_release(lights.green);
    gpiod_chip_close(chip);

    return 0;
}
